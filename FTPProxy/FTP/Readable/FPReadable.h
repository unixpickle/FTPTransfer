//
//  FPReadable.h
//  FTPTransfer
//
//  Created by Alex Nichol on 12/13/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FPReadable : NSObject {
    CFReadStreamRef stream;
}

@property (strong, nonatomic) NSURL * url;
@property (strong, nonatomic) NSString * username;
@property (strong, nonatomic) NSString * password;

- (BOOL)start;
- (void)cancel;

- (void)handleFTPData:(NSData *)data;
- (void)handleFTPError:(NSError *)error;
- (void)handleFTPDone;

/**
 * This should not be over-ridden.
 */
- (void)handleFTPEvent:(CFStreamEventType)event;

@end
