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

static NSString * escapeURLStr(NSString * str);

@implementation FPDeleteRequest

- (NSURL *)authenticatedURL:(NSURL *)aURL {
    if (aURL.user && aURL.password) return aURL;
    NSString * encUser = escapeURLStr(self.username);
    NSString * encPass = escapeURLStr(self.password);
    NSString * finalStr = [NSString stringWithFormat:@"%@:%@%@%@", encUser, encPass, @"@", aURL.host];
    NSString * theStr = [NSString stringWithFormat:@"ftp://%@/%@", finalStr, aURL.path];
    if (![aURL.path hasSuffix:@"/"] && [[aURL description] hasSuffix:@"/"]) {
        return [[NSURL alloc] initWithString:[theStr stringByAppendingString:@"/"]];
    } else {
        return [[NSURL alloc] initWithString:theStr];
    }
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
        for (NSURL * url in self.urls) {
            SInt32 error;
            Boolean result = CFURLDestroyResource((__bridge CFURLRef)[self authenticatedURL:url], &error); // I know, it's deprecated :/
            if ([NSThread currentThread].isCancelled) return;
            if (!result) {
                return dispatch_sync(dispatch_get_main_queue(), ^{
                    bgThread = nil;
                    self.callback([NSError errorWithDomain:@"CFURLDestroyResource" code:error userInfo:nil]);
                });
            }
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            bgThread = nil;
            self.callback(nil);
        });
    }
}

@end

static NSString * escapeURLStr(NSString * str) {
    // stolen from http://stackoverflow.com/questions/8088473/url-encode-an-nsstring
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[str UTF8String];
    int sourceLen = (int)strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}
