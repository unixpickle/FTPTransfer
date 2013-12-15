//
//  FPDataReceiver.m
//  FTPTransfer
//
//  Created by Alex Nichol on 12/14/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "FPDataReceiver.h"

@implementation FPDataReceiver

- (void)startReading {
    // TODO: pull for segment
}

- (void)cancelReading {
    [currentDelete cancel];
    [currentReader cancel];
    currentReader = nil;
    currentDelete = nil;
}

- (void)dealloc {
    [self cancelReading];
}

@end
