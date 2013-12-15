//
//  FPDeleteRequest.m
//  FTPTransfer
//
//  Created by Alex Nichol on 12/14/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "FPDeleteRequest.h"

@interface FPDeleteRequest (Private)

- (void)backgroundMethod;

@end

@implementation FPDeleteRequest

- (NSURL *)authenticatedURL {
    if (self.url.user && self.url.password) return self.url;
    NSString * encUser = [self.username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * encPass = [self.password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * finalStr = [NSString stringWithFormat:@"%@:%@@@%@", encUser, encPass, self.url.host];
    return [[NSURL alloc] initWithScheme:@"ftp" host:finalStr path:self.url.path];
}

- (void)start {
    bgThread = [[NSThread alloc] initWithTarget:self
                                       selector:@selector(backgroundMethod)
                                         object:nil];
    [bgThread start];
}

- (void)cancel {
    [bgThread cancel];
    bgThread = nil;
}

#pragma mark - Private -

- (void)backgroundMethod {
    @autoreleasepool {
        SInt32 error;
        Boolean result = CFURLDestroyResource((__bridge CFURLRef)[self authenticatedURL], &error); // I know, it's deprecated :/
        if ([NSThread currentThread].isCancelled) return;
        dispatch_sync(dispatch_get_main_queue(), ^{
            bgThread = nil;
            if (result) {
                self.callback(nil);
            } else {
                self.callback([NSError errorWithDomain:@"CFURLDestroyResource" code:error userInfo:nil]);
            }
        });
    }
}

@end
