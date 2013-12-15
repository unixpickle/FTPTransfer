//
//  ANConnectView.h
//  FTPTransfer
//
//  Created by Alex Nichol on 12/14/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANSendTransfer.h"
#import "ANReceiveTransfer.h"

@interface ANConnectView : NSView {
    IBOutlet NSTextField * host;
    IBOutlet NSTextField * path;
    IBOutlet NSTextField * username;
    IBOutlet NSTextField * password;
    IBOutlet NSTextField * localPath;
    IBOutlet NSPopUpButton * popUp;
}

@property (nonatomic, copy) void (^callback)(ANTransfer * transfer);

- (IBAction)transferPressed:(id)sender;

@end
