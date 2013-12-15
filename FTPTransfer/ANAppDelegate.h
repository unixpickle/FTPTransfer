//
//  ANAppDelegate.h
//  FTPTransfer
//
//  Created by Alex Nichol on 12/13/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANMainWindow.h"

@interface ANAppDelegate : NSObject <NSApplicationDelegate> {
    NSMutableArray * windows;
}

- (IBAction)createNewWindow:(id)sender;
- (id)createClass:(Class)c fromNib:(NSString *)name;

@end
