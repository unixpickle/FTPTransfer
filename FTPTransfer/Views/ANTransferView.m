//
//  ANTransferView.m
//  FTPTransfer
//
//  Created by Alex Nichol on 12/14/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "ANTransferView.h"

@implementation ANTransferView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)setTransfer:(ANTransfer *)aTransfer {
    transfer = aTransfer;
    transfer.delegate = self;
}

- (IBAction)cancelPressed:(id)sender {
    [transfer initiateCancel];
    [progress setIndeterminate:YES];
    [progress startAnimation:nil];
}

#pragma mark - Transfer Delegate -

- (void)transfer:(id)sender statusUpdated:(NSString *)status {
    statusLabel.stringValue = status;
}

- (void)transfer:(id)sender bytesUpdated:(UInt64)bytes {
    bytesLabel.stringValue = [NSString stringWithFormat:@"%llu bytes transferred", bytes];
}

- (void)transfer:(id)sender filesUpdated:(UInt64)files {
    filesLabel.stringValue = [NSString stringWithFormat:@"%llu files transferred", files];
}

- (void)transfer:(id)sender failedWithError:(NSError *)error {
    // TODO: make this a popover
    NSRunAlertPanel(@"Error", @"%@", @"OK", nil, nil, [error description]);
    if (self.doneCallback) self.doneCallback();
}

- (void)transferDone:(id)sender {
    if (self.doneCallback) self.doneCallback();
}

@end
