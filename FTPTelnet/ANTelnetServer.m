//
//  ANTelnetServer.m
//  FTPTransfer
//
//  Created by Alex Nichol on 12/15/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "ANTelnetServer.h"

@implementation ANTelnetServer

- (void)start {
    self.receiver.delegate = self;
    [self.receiver startReading];
}

- (void)fpDataReceiver:(id)sender gotData:(NSData *)data {
    fwrite(data.bytes, 1, data.length, stdout);
}

- (void)fpDataReceiverEOF:(id)sender {
    fprintf(stderr, "Connection closed.\n");
    exit(0);
}

- (void)fpDataReceiver:(id)sender failedWithError:(NSError *)error {
    fprintf(stderr, "Error: %s\n", error.description.UTF8String);
    exit(1);
}

@end
