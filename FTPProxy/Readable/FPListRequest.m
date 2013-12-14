//
//  FPListRequest.m
//  FTPTransfer
//
//  Created by Alex Nichol on 12/13/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "FPListRequest.h"

@implementation FPListRequest

- (void)handleFTPError:(NSError *)error {
    self.callback(error, nil);
}

- (void)handleFTPData:(NSData *)data {
    if (!rawData) rawData = [NSMutableData data];
    [rawData appendData:data];
}

- (void)handleFTPDone {
    CFDictionaryRef dict;
    CFIndex consumed = CFFTPCreateParsedResourceListing(NULL, rawData.bytes,
                                                        rawData.length, &dict);
    
    if (consumed != rawData.length) {
        self.callback([NSError errorWithDomain:@"CFFTP"
                                          code:0
                                      userInfo:@{NSLocalizedDescriptionKey: @"CFFTPCreateParsedResourceListing failed"}], nil);
        return;
    }
    
    self.callback(nil, (__bridge_transfer NSDictionary *)dict);
}

@end
