//
//  ANConnectView.m
//  FTPTransfer
//
//  Created by Alex Nichol on 12/14/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "ANConnectView.h"

@interface ANConnectView (Private)

- (void)populateTransfer:(ANTransfer *)xfer;

@end

@implementation ANConnectView

- (IBAction)transferPressed:(id)sender {
    if (!self.callback) return;
    
    ANTransfer * xfer = nil;
    if ([popUp.selectedItem.title isEqualToString:@"Sender"]) {
        xfer = [[ANSendTransfer alloc] init];
    } else {
        xfer = [[ANReceiveTransfer alloc] init];
    }
    [self populateTransfer:xfer];
    self.callback(xfer);
}

#pragma mark - Private -

- (void)populateTransfer:(ANTransfer *)xfer {
    xfer.host = host.stringValue;
    xfer.username = username.stringValue;
    xfer.password = password.stringValue;
    xfer.path = path.stringValue;
    xfer.localPath = localPath.stringValue;
}

@end
