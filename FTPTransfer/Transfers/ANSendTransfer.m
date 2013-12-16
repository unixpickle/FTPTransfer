//
//  ANSendTransfer.m
//  FTPTransfer
//
//  Created by Alex Nichol on 12/15/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "ANSendTransfer.h"

@interface ANSendTransfer (Private)

- (void)sendMoreData;
- (void)startNextFile;

@end

@implementation ANSendTransfer

- (void)start {
    // first, we'll gather file system information about the base path
    descriptor = [ANItemDescriptor loadDescriptorWithPath:self.localPath
                                                 relative:@"/"];
    if (!descriptor) {
        NSError * error = [NSError errorWithDomain:@"ANSendTransfer"
                                              code:1
                                          userInfo:@{NSLocalizedDescriptionKey: @"Failed to process input file."}];
        [self.delegate transfer:self failedWithError:error];
        return;
    }
    
    self.totalSize = [descriptor totalSize];
    
    // create the communications channel
    stream = [[FPDataSender alloc] initWithBufferSize:kANSendTransferBufferSize];
    stream.username = self.username;
    stream.password = self.password;
    stream.remoteDirectory = [self.path hasPrefix:@"/"] ? self.path : [@"/" stringByAppendingString:self.path];
    stream.remoteHost = self.host;
    stream.delegate = self;
    [stream initiateStream];
    
    // send our file list over the channel
    NSData * information = [descriptor encodeDescriptor];
    UInt32 lenBuff = CFSwapInt32HostToBig((UInt32)information.length);
    [stream writeData:[NSData dataWithBytes:&lenBuff length:4]];
    [stream writeData:information];
    
    // generate a list of files to send
    fileList = [[NSMutableArray alloc] initWithArray:descriptor.flatten];
    for (int i = 0; i < fileList.count; i++) {
        if (![fileList[i] isKindOfClass:[ANFileDescriptor class]]) {
            [fileList removeObjectAtIndex:i];
            i--;
        }
    }
}

- (void)initiateCancel {
    [super initiateCancel];
    [stream endStream];
    [currentHandle closeFile];
    currentHandle = nil;
}

#pragma mark - Stream Delegate -

- (void)fpDataSender:(id)sender failedWithError:(NSError *)error {
    [self.delegate transfer:self failedWithError:error];
    stream = nil;
}

- (void)fpDataSenderEnded:(id)sender {
    [self.delegate transferDone:self];
}

- (void)fpDataSenderBufferEmpty:(id)sender {
    [self sendMoreData];
}

#pragma mark - Private -

- (void)sendMoreData {
    if (!currentHandle) {
        return [self startNextFile];
    }
    NSData * more = [currentHandle readDataOfLength:kANSendTransferBufferSize];
    if (more.length == 0) {
        sentFiles++;
        [self.delegate transfer:self filesUpdated:sentFiles];
        [currentHandle closeFile];
        currentHandle = nil;
        return [self startNextFile];
    }
    [stream writeData:more];
    written += more.length;
    [self.delegate transfer:self bytesUpdated:written];
}

- (void)startNextFile {
    if (fileList.count == 0) {
        [stream endStream];
        return;
    }
    
    ANFileDescriptor * file = fileList[0];
    [fileList removeObjectAtIndex:0];
    
    [self.delegate transfer:self statusUpdated:[NSString stringWithFormat:@"Sending %@", file.relativePath]];
    
    // encode the file descriptor and begin to send it
    NSData * encoded = [file encodeDescriptor];
    NSMutableData * nextPacket = [NSMutableData data];
    [nextPacket appendData:encoded];
    
    NSString * absolutePath = [self.localPath stringByAppendingPathComponent:file.relativePath];
    currentHandle = [NSFileHandle fileHandleForReadingAtPath:absolutePath];
    if (encoded.length < kANSendTransferBufferSize) {
        NSInteger sendSize = kANSendTransferBufferSize - encoded.length;
        NSData * buff = [currentHandle readDataOfLength:sendSize];
        [nextPacket appendData:buff];
        written += buff.length;
        [self.delegate transfer:self bytesUpdated:written];
    }
    
    [stream writeData:nextPacket];
}

@end
