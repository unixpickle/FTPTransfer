//
//  FPDataReceiver.m
//  FTPTransfer
//
//  Created by Alex Nichol on 12/14/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "FPDataReceiver.h"

@interface FPDataReceiver (Private)

/**
 * Called continuously. Checks for the next segment.
 */
- (void)pollForNextSegment;

/**
 * Called every time after pollForNextSegment.
 */
- (void)handleDirListing:(NSArray *)listing;

/**
 * Called when the next segment appears on the server.
 */
- (void)downloadNextPacket;

/**
 * Called when a packet is downloaded from the server.
 */
- (void)handleReadPacket:(NSData *)packet;

/**
 * Called immediately after handleReadPacket: with a parsed packet.
 */
- (void)reactToPacket:(FPDataPacket *)packet;

/**
 * Called whenever a terminal error occurs.
 */
- (void)handleError:(NSError *)error;

/**
 * Called when a connection cannot be established and so
 * there is no error object to look at.
 */
- (void)handleStartError;

@end

@implementation FPDataReceiver

- (void)startReading {
    sequence = 1;
    deleteQueue = [[FPDeleteQueue alloc] init];
    deleteQueue.delegate = self;
    [self pollForNextSegment];
}

- (void)cancelReading {
    [deleteQueue cancel];
    [currentReader cancel];
    currentReader = nil;
}

- (void)dealloc {
    [self cancelReading];
}

#pragma mark - Delete Queue -

- (void)fpDeleteQueueDonePending:(id)sender {
    if (completionPending) {
        [self handleEOF];
    }
}

- (void)fpDeleteQueue:(id)sender failedWithError:(NSError *)error {
    [self cancelReading];
    [self handleError:error];
}

#pragma mark - Private -

- (void)pollForNextSegment {
    FPListRequest * req = [[FPListRequest alloc] init];
    req.username = self.username;
    req.password = self.password;
    req.url = [self urlForRoot];
    __weak id weakSelf = self;
    req.callback = ^(NSError * err, NSArray * listing) {
        if (err) {
            [weakSelf handleError:err];
        } else [weakSelf handleDirListing:listing];
    };
    if (![req start]) {
        return [self handleStartError];
    }
    currentReader = req;
}

- (void)handleDirListing:(NSArray *)listing {
    currentReader = nil;
    NSString * fileName = [NSString stringWithFormat:@"%llu_end", (unsigned long long)sequence];
    for (NSDictionary * dict in listing) {
        if ([dict[(__bridge NSString *)kCFFTPResourceName] isEqualToString:fileName]) {
            return [self downloadNextPacket];
        }
    }
    [self pollForNextSegment];
}

- (void)downloadNextPacket {
    FPReadRequest * read = [[FPReadRequest alloc] init];
    read.username = self.username;
    read.password = self.password;
    read.url = [self urlForSegment:sequence];
    NSMutableData * fullData = [NSMutableData data];
    __weak id weakSelf = self;
    read.callback = ^(NSError * error, NSData * data, BOOL done) {
        if (error) {
            return [weakSelf handleError:error];
        } else if (data) {
            [fullData appendData:data];
        }
        if (done) [weakSelf handleReadPacket:fullData];
    };
    if (![read start]) {
        return [self handleStartError];
    }
    currentReader = read;
}

- (void)handleReadPacket:(NSData *)data {
    currentReader = nil;
    FPDataPacket * packet = [FPDataPacket packetByDecoding:data];
    if (!packet) {
        return [self handleError:[NSError errorWithDomain:@"FPDataPacket" code:1
                                                 userInfo:@{NSLocalizedDescriptionKey: @"Failed to parse packet."}]];
    }
    if (self.deleteSource) {
        FPDeleteRequest * currentDelete = [[FPDeleteRequest alloc] init];
        currentDelete.username = self.username;
        currentDelete.password = self.password;
        currentDelete.urls = @[[self urlForSegment:sequence], [self urlForSegmentEnd:sequence]];
        [deleteQueue pushRequest:currentDelete];
    }
    [self reactToPacket:packet];
}

- (void)reactToPacket:(FPDataPacket *)packet {
    if (packet.type == FPDataPacketTypeEOF) {
        if (self.deleteSource) {
            FPDeleteRequest * currentDelete = [[FPDeleteRequest alloc] init];
            currentDelete.username = self.username;
            currentDelete.password = self.password;
            currentDelete.urls = @[[self urlForRoot]];
            [deleteQueue pushRequest:currentDelete];
            completionPending = YES;
        } else [self handleEOF];
    } else {
        [self.delegate fpDataReceiver:self gotData:packet.body];
        
        // read more data
        sequence++;
        [self pollForNextSegment];
    }
}

- (void)handleEOF {
    currentReader = nil;
    [self.delegate fpDataReceiverEOF:self];
}

- (void)handleError:(NSError *)error {
    currentReader = nil;
    [deleteQueue cancel];
    [self.delegate fpDataReceiver:self failedWithError:error];
}

- (void)handleStartError {
    currentReader = nil;
    [deleteQueue cancel];
    [self handleError:[NSError errorWithDomain:@"FTPProxy" code:1
                                      userInfo:@{NSLocalizedDescriptionKey: @"Failed to send request."}]];
}

@end
