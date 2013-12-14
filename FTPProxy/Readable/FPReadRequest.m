//
//  FPReadRequest.m
//  FTPTransfer
//
//  Created by Alex Nichol on 12/13/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "FPReadRequest.h"

@implementation FPReadRequest

- (void)handleFTPError:(NSError *)error {
    self.callback(error, nil);
}

- (void)handleFTPData:(NSData *)data {
    self.callback(nil, data, NO);
}

- (void)handleFTPDone {
    self.callback(nil, nil, YES);
}

@end
