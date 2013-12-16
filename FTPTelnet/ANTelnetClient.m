//
//  ANTelnetClient.m
//  FTPTransfer
//
//  Created by Alex Nichol on 12/15/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "ANTelnetClient.h"

@implementation ANTelnetClient

- (void)start {
    self.sender.delegate = self;
    [self.sender initiateStream];
    
    [[[NSThread alloc] initWithTarget:self selector:@selector(consoleThread) object:nil] start];
}

- (void)fpDataSender:(id)sender failedWithError:(NSError *)error {
    fprintf(stderr, "Error: %s\n", error.description.UTF8String);
    exit(1);
}

- (void)fpDataSenderEnded:(id)sender {
    fprintf(stderr, "Connection closed.\n");
    exit(0);
}

- (void)fpDataSenderBufferEmpty:(id)sender {
    // nothing to do here
}

- (void)consoleThread {
    @autoreleasepool {
        char buff[512];
        while (YES) {
            if (!fgets(buff, 512, stdin)) {
                [self.sender performSelectorOnMainThread:@selector(endStream)
                                              withObject:nil waitUntilDone:NO];
                return;
            }
            NSData * data = [NSData dataWithBytes:buff length:strlen(buff)];
            [self.sender performSelectorOnMainThread:@selector(writeData:)
                                          withObject:data waitUntilDone:NO];
        }
    }
}

@end
