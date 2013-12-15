//
//  ANSenderView.h
//  FTPTransfer
//
//  Created by Alex Nichol on 12/14/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ANSenderView : NSView {
    IBOutlet NSTextField * statusLabel;
    IBOutlet NSProgressIndicator * progress;
    IBOutlet NSTextField * bytesLabel;
    IBOutlet NSTextField * filesLabel;
}

- (IBAction)cancelPressed:(id)sender;

@end
