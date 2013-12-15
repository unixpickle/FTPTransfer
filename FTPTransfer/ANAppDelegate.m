//
//  ANAppDelegate.m
//  FTPTransfer
//
//  Created by Alex Nichol on 12/13/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "ANAppDelegate.h"

@implementation ANAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self createNewWindow:nil];
}

- (IBAction)createNewWindow:(id)sender {
    ANConnectView * connect = [self createClass:[ANConnectView class]
                                        fromNib:@"ANConnectView"];
    NSRect frame = NSMakeRect(0, 0, connect.frame.size.width, connect.frame.size.height);
    ANMainWindow * window = [[ANMainWindow alloc] initWithContentRect:frame
                                                    styleMask:(NSTitledWindowMask | NSClosableWindowMask)
                                                      backing:NSBackingStoreBuffered defer:NO];
    
    window.connectView = connect;
    [window.contentView addSubview:connect];
    
    [window center];
    [window makeKeyAndOrderFront:nil];
    
    __weak ANMainWindow * theWindow = window;
    connect.callback = ^(ANTransfer * t) {
        ANTransferView * view = [self createClass:[ANTransferView class] fromNib:@"ANTransferView"];
        view.doneCallback = ^() {
            [theWindow presentConnectView];
        };
        [theWindow presentView:view callback:^ {
            [view setTransfer:t];
            [t start];
        }];
    };
}

- (id)createClass:(Class)c fromNib:(NSString *)name {
    NSArray * topLevel = nil;
    [[NSBundle mainBundle] loadNibNamed:name
                                  owner:nil
                        topLevelObjects:&topLevel];
    for (NSObject * obj in topLevel) {
        if ([obj isKindOfClass:c]) return obj;
    }
    return nil;
}

@end
