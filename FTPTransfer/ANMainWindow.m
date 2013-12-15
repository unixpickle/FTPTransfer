//
//  ANMainWindow.m
//  FTPTransfer
//
//  Created by Alex Nichol on 12/15/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "ANMainWindow.h"

@interface ANMainWindow (Private)

- (void)runBlockAndAdd:(NSArray *)args;

@end

static NSMutableArray * windows = nil;

@implementation ANMainWindow

- (void)makeKeyAndOrderFront:(id)sender {
    [super makeKeyAndOrderFront:sender];
    if (!windows) {
        windows = [NSMutableArray array];
    }
    [windows addObject:self];
}

- (void)close {
    [super close];
    [windows removeObject:self];
}

- (void)presentView:(NSView *)aView callback:(void (^)())callback {
    while ([self.contentView subviews].count) {
        [[self.contentView subviews][0] removeFromSuperview];
    }
    
    CGFloat heightDiff = self.frame.size.height - [self.contentView frame].size.height;
    
    NSRect frame = self.frame;
    frame.origin.y -= aView.frame.size.height - [self.contentView frame].size.height;
    frame.size.height = aView.frame.size.height + heightDiff;
    [self setFrame:frame display:YES animate:YES];
    
    [self performSelector:@selector(runBlockAndAdd:)
               withObject:@[callback, aView]
               afterDelay:kResizeDelay];
}

- (void)presentConnectView {
    [self presentView:self.connectView callback:^{}];
}

- (void)runBlockAndAdd:(NSArray *)args {
    void (^callback)() = args[0];
    [self.contentView addSubview:args[1]];
    callback();
}

@end
