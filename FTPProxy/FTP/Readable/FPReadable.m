//
//  FPReadable.m
//  FTPTransfer
//
//  Created by Alex Nichol on 12/13/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "FPReadable.h"

static void _FPReadableCallback(CFReadStreamRef stream, CFStreamEventType type, void * clientCallBackInfo);
static NSMutableArray * readables = nil;

@interface FPReadable (Private)

- (NSError *)streamError;
- (void)handleError;
- (void)handleDone;

@end

@implementation FPReadable

- (BOOL)start {
    // create FTP handle
    stream = CFReadStreamCreateWithFTPURL(kCFAllocatorDefault, (__bridge CFURLRef)self.url);
    if (!stream) {
        return NO;
    }
    
    CFReadStreamSetProperty(stream, kCFStreamPropertyFTPUserName, (__bridge CFStringRef)self.username);
    CFReadStreamSetProperty(stream, kCFStreamPropertyFTPPassword, (__bridge CFStringRef)self.password);
    CFReadStreamSetProperty(stream, kCFStreamPropertyFTPAttemptPersistentConnection, kCFBooleanTrue);
    
    CFStreamClientContext context;
    context.info = (__bridge void *)self;
    context.retain = NULL;
    context.release = NULL;
    context.copyDescription = NULL;
    context.version = 0;
    
    CFReadStreamSetClient(stream, kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered | kCFStreamEventHasBytesAvailable, _FPReadableCallback, &context);
    CFReadStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    if (!CFReadStreamOpen(stream)) {
        CFRelease(stream);
        stream = NULL;
        return NO;
    }
    
    if (!readables) {
        readables = [[NSMutableArray alloc] init];
    }
    if (![readables containsObject:self]) [readables addObject:self];
    
    return YES;
}

- (void)cancel {
    if (stream) {
        CFReadStreamClose(stream);
        CFRelease(stream);
        stream = NULL;
    }
    if ([readables containsObject:self]) [readables removeObject:self];
}

- (void)handleFTPEvent:(CFStreamEventType)event {
    // do something in sub-class
    if (event == kCFStreamEventHasBytesAvailable) {
        NSMutableData * data = [NSMutableData data];
        UInt8 * buffer = (UInt8 *)malloc(65536);
        while (CFReadStreamHasBytesAvailable(stream)) {
            CFIndex value = CFReadStreamRead(stream, buffer, 65536);
            if (value < 0) {
                free(buffer);
                return [self performSelectorOnMainThread:@selector(handleError)
                                              withObject:nil
                                           waitUntilDone:NO];
            }
            [data appendBytes:buffer length:value];
        }
        free(buffer);
        [self performSelectorOnMainThread:@selector(handleFTPData:)
                               withObject:data
                            waitUntilDone:NO];
    } else if (event == kCFStreamEventErrorOccurred) {
        [self performSelectorOnMainThread:@selector(handleError)
                               withObject:nil
                            waitUntilDone:NO];
    } else if (event == kCFStreamEventEndEncountered) {
        [self performSelectorOnMainThread:@selector(handleDone)
                               withObject:nil
                            waitUntilDone:NO];
    }
}

- (void)dealloc {
    [self cancel];
}

#pragma mark - Subclass -

- (void)handleFTPData:(NSData *)data {
}

- (void)handleFTPError:(NSError *)error {
}

- (void)handleFTPDone {
}

#pragma mark - Private -

- (NSError *)streamError {
    if (!stream) return nil;
    
    CFErrorRef error = CFReadStreamCopyError(stream);
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

@end

static void _FPReadableCallback(CFReadStreamRef stream, CFStreamEventType type, void * clientCallBackInfo) {
    FPReadable * transfer = (__bridge FPReadable *)clientCallBackInfo;
    [transfer handleFTPEvent:type];
}
