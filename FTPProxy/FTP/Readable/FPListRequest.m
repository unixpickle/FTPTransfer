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
    NSMutableArray * allFiles = [NSMutableArray array];
    
    while (YES) {
        CFDictionaryRef dict = NULL;
        CFIndex consumed = CFFTPCreateParsedResourceListing(NULL, rawData.bytes,
                                                            rawData.length, &dict);
        if (!consumed || !dict) break;
        [allFiles addObject:(__bridge_transfer NSDictionary *)dict];
        [rawData replaceBytesInRange:NSMakeRange(0, consumed) withBytes:NULL length:0];
    }
    
    self.callback(nil, allFiles);
}

@end
