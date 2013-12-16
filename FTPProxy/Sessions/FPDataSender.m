//
//  FPDataSender.m
//  FTPTransfer
//
//  Created by Alex Nichol on 12/14/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "FPDataSender.h"

@interface FPDataSender (Private)

- (void)handleRemoteCreated;
- (void)sendNextPacket;
- (void)handlePacketSent;
- (void)handleError:(NSError *)error;

@end

@implementation FPDataSender

- (id)init {
    return ((self = [self initWithBufferSize:1048575])); // 1MB chunks
}

- (id)initWithBufferSize:(NSInteger)size {
    if ((self = [super init])) {
        bufferSize = size;
        packets = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)initiateStream {
    if (isEnded) @throw [NSException exceptionWithName:@"FPChannelClosed"
                                                reason:@"Cannot initiate a closed stream"
                                              userInfo:nil];
    currentOpener = [[FPWriteData alloc] initWithData:[NSData data]];
    currentOpener.username = self.username;
    currentOpener.password = self.password;
    currentOpener.url = [self urlForRoot];
    __weak FPDataSender * weakSelf = self;
    currentOpener.callback = ^(NSError * error) {
        if (error) {
            [weakSelf handleError:error];
        } else {
            [weakSelf handleRemoteCreated];
        }
    };
    if (![currentOpener start]) {
        [self handleError:[NSError errorWithDomain:@"FPWriteData" code:0 userInfo:nil]];
    }
}

- (void)writeData:(NSData *)data {
    if (isEnded) @throw [NSException exceptionWithName:@"FPChannelClosed"
                                                reason:@"Cannot write to a closed stream"
                                              userInfo:nil];
    if (data.length == 0) return;
    
    NSData * leftOver = data; // data to append to remaining packets
    
    if (packets.count > 0) {
        FPDataPacket * lastPacket = [packets lastObject];
        if (lastPacket.body.length < bufferSize) {
            NSInteger sendOver = MIN(bufferSize - lastPacket.body.length, data.length);
            leftOver = [data subdataWithRange:NSMakeRange(sendOver, data.length - sendOver)];
            NSData * appendEnd = [data subdataWithRange:NSMakeRange(0, sendOver)];
            FPDataPacket * newLastPacket = [lastPacket packetByAppendingBody:appendEnd];
            packets[packets.count - 1] = newLastPacket;
        }
    }
    
    for (NSInteger i = 0; i < leftOver.length; i += bufferSize) {
        NSInteger len = MIN(bufferSize, leftOver.length - i);
        NSData * packetBody = [leftOver subdataWithRange:NSMakeRange(i, len)];
        [packets addObject:[[FPDataPacket alloc] initWithType:FPDataPacketTypePayload body:packetBody]];
    }
    
    if (!currentWriter && hasBegun) [self sendNextPacket];
}

- (void)endStream {
    if (isEnded) @throw [NSException exceptionWithName:@"FPChannelClosed"
                                                reason:@"Cannot end a closed stream"
                                              userInfo:nil];
    FPDataPacket * close = [[FPDataPacket alloc] initWithType:FPDataPacketTypeEOF body:[NSData data]];
    [packets addObject:close];
    isEnded = YES;
    
    if (!currentWriter && hasBegun) [self sendNextPacket];
}

- (void)forceClose {
    [currentWriter cancel];
    currentWriter = nil;
    [currentOpener cancel];
    currentOpener = nil;
    [packets removeAllObjects];
    packets = nil;
    isEnded = YES;
}

- (void)dealloc {
    [self forceClose];
}

#pragma mark - Private -

- (void)handleRemoteCreated {
    hasBegun = YES;
    currentOpener = nil;
    if (packets.count != 0) {
        [self sendNextPacket];
    }
}

- (void)sendNextPacket {
    currentWriter = nil;
    if (packets.count == 0) {
        if (isEnded) [self.delegate fpDataSenderEnded:self];
        else {
            [self.delegate fpDataSenderBufferEmpty:self];
        }
        return;
    }
    
    sequence++;
    
    FPDataPacket * packet = packets[0];
    [packets removeObjectAtIndex:0];
    
    currentWriter = [[FPWriteData alloc] initWithData:[packet encodePacket]];
    currentWriter.username = self.username;
    currentWriter.password = self.password;
    currentWriter.url = [self urlForSegment:sequence];
    
    __weak FPDataSender * weakSelf = self;
    currentWriter.callback = ^(NSError * error) {
        if (error) {
            [weakSelf handleError:error];
        } else {
            [weakSelf handlePacketSent];
        }
    };
    
    if (![currentWriter start]) {
        [self handleError:[NSError errorWithDomain:@"FPWriteData" code:0 userInfo:nil]];
    }
}

- (void)handlePacketSent {
    currentWriter = [[FPWriteData alloc] initWithData:[NSData dataWithBytes:"GOOD" length:4]];
    currentWriter.username = self.username;
    currentWriter.password = self.password;
    currentWriter.url = [self urlForSegmentEnd:sequence];
    
    __weak FPDataSender * weakSelf = self;
    currentWriter.callback = ^(NSError * error) {
        if (error) {
            [weakSelf handleError:error];
        } else {
            [weakSelf sendNextPacket];
        }
    };
    if (![currentWriter start]) {
        [self handleError:[NSError errorWithDomain:@"FPWriteData" code:0 userInfo:nil]];
    }
}

- (void)handleError:(NSError *)error {
    currentOpener = nil;
    currentWriter = nil;
    isEnded = YES;
    [self.delegate fpDataSender:self failedWithError:error];
}

@end
