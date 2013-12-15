//
//  ANTransferView.h
//  FTPTransfer
//
//  Created by Alex Nichol on 12/14/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANTransfer.h"

@interface ANTransferView : NSView <ANTransferDelegate> {
    IBOutlet NSTextField * statusLabel;
    IBOutlet NSProgressIndicator * progress;
    IBOutlet NSTextField * bytesLabel;
    IBOutlet NSTextField * filesLabel;
    ANTransfer * transfer;
}

@property (nonatomic, copy) void (^doneCallback)();

- (void)setTransfer:(ANTransfer *)aTransfer;
- (IBAction)cancelPressed:(id)sender;

@end
