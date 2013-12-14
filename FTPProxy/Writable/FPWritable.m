//
//  FPWritable.m
//  FTPTransfer
//
//  Created by Alex Nichol on 12/13/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "FPWritable.h"

static void _FPWritableCallback(CFWriteStreamRef stream, CFStreamEventType type, void * clientCallBackInfo);
static NSMutableArray * writables = nil;

@interface FPWritable (Private)

- (NSError *)streamError;
- (void)handleError;
- (void)handleDone;
- (void)writeLoop;

@end

@implementation FPWritable

- (id)init {
    if ((self = [super init])) {
        buffer = [[NSMutableData alloc] init];
    }
    return self;
}

- (BOOL)start {
    stream = CFWriteStreamCreateWithFTPURL(NULL, (__bridge CFURLRef)self.url);
    if (!stream) return NO;
    CFWriteStreamSetProperty(stream, kCFStreamPropertyFTPUserName, (__bridge CFStringRef)self.username);
    CFWriteStreamSetProperty(stream, kCFStreamPropertyFTPPassword, (__bridge CFStringRef)self.password);
    CFWriteStreamSetProperty(stream, kCFStreamPropertyFTPAttemptPersistentConnection, kCFBooleanTrue);
    
    CFStreamClientContext context;
    context.info = (__bridge void *)self;
    context.retain = NULL;
    context.release = NULL;
    context.copyDescription = NULL;
    context.version = 0;
    
    CFWriteStreamSetClient(stream, kCFStreamEventErrorOccurred | kCFStreamEventCanAcceptBytes,
                           _FPWritableCallback, &context);
    CFWriteStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    if (!CFWriteStreamOpen(stream)) {
        CFRelease(stream);
        stream = NULL;
        return NO;
    }
    
    if (!writables) {
        writables = [[NSMutableArray alloc] init];
    }
    if (![writables containsObject:self]) [writables addObject:self];
    
    return YES;
}

- (void)cancel {
    if (stream) {
        CFWriteStreamClose(stream);
        CFRelease(stream);
        stream = NULL;
    }
    if ([writables containsObject:self]) [writables removeObject:self];
}

- (void)handleFTPEvent:(CFStreamEventType)event {
    if (event == kCFStreamEventCanAcceptBytes) {
        [self writeLoop];
    } else if (event == kCFStreamEventErrorOccurred) {
        [self handleError];
    }
}

- (void)pushData:(NSData *)someData {
    [buffer appendData:someData];
    [self writeLoop];
}

#pragma mark - Subclass -

- (void)handleFTPError:(NSError *)error {
}

- (void)handleFTPDone {
}

- (BOOL)isComplete {
    return YES;
}

#pragma mark - Private -

- (NSError *)streamError {
    if (!stream) return nil;
    
    CFErrorRef error = CFWriteStreamCopyError(stream);
    return (__bridge_transfer NSError *)error;
}

- (void)handleError {
    NSError * error = [self streamError];
    [self cancel];
    [self handleFTPError:error];
}

- (void)handleDone {
    [self cancel];
    [self handleFTPDone];
}

- (void)writeLoop {
    while (CFWriteStreamCanAcceptBytes(stream)) {
        if (!buffer.length) {
            if (self.isComplete) {
                [self handleDone];
            }
            return;
        }
        CFIndex written = CFWriteStreamWrite(stream, buffer.bytes, buffer.length);
        if (written < 0) {
            return [self performSelectorOnMainThread:@selector(handleError)
                                          withObject:nil
                                       waitUntilDone:NO];
        }
        if (written > 0) {
            [buffer replaceBytesInRange:NSMakeRange(0, written) withBytes:NULL length:0];
        }
    }
}

@end

static void _FPWritableCallback(CFWriteStreamRef stream, CFStreamEventType type, void * clientCallBackInfo) {
    FPWritable * transfer = (__bridge FPWritable *)clientCallBackInfo;
    dispatch_sync(dispatch_get_main_queue(), ^{
        [transfer handleFTPEvent:type];
    });
}
