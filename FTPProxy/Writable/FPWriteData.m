//
//  FPWriteData.m
//  FTPTransfer
//
//  Created by Alex Nichol on 12/14/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "FPWriteData.h"

@implementation FPWriteData

- (id)initWithData:(NSData *)someData {
    if ((self = [super init])) {
        [self pushData:someData];
    }
    return self;
}

- (void)handleFTPError:(NSError *)error {
    self.callback(error);
}

- (void)handleFTPDone {
    self.callback(nil);
}

@end
