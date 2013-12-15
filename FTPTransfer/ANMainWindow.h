//
//  ANMainWindow.h
//  FTPTransfer
//
//  Created by Alex Nichol on 12/15/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANTransferView.h"
#import "ANConnectView.h"

#define kResizeDelay 0.2

@interface ANMainWindow : NSWindow

@property (nonatomic, retain) ANConnectView * connectView;

- (void)presentView:(NSView *)aView callback:(void (^)())callback;
- (void)presentConnectView;

@end
