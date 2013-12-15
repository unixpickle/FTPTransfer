//
//  ANTransfer.m
//  FTPTransfer
//
//  Created by Alex Nichol on 12/15/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "ANTransfer.h"

@implementation ANTransfer

- (void)start {
    [self doesNotRecognizeSelector:@selector(start)];
}

- (void)initiateCancel {
    [self.delegate transfer:self statusUpdated:@"Cancelling..."];
}

@end
