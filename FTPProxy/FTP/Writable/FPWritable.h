//
//  FPWritable.h
//  FTPTransfer
//
//  Created by Alex Nichol on 12/13/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FPWritable : NSObject {
    CFWriteStreamRef stream;
    NSMutableData * buffer;
}

@property (strong, nonatomic) NSURL * url;
@property (strong, nonatomic) NSString * username;
@property (strong, nonatomic) NSString * password;

- (BOOL)start;
- (void)cancel;

/**
 * Called when an error occurs.
 */
- (void)handleFTPError:(NSError *)error;

/**
 * Called when all data has been received by the server.
 */
- (void)handleFTPDone;

/**
 * This should not be over-ridden.
 */
- (void)handleFTPEvent:(CFStreamEventType)event;

/**
 * Return YES if all the data has been pushed that you wanted to push.
 * You MUST override this if you plan to continually push new data.
 */
- (BOOL)isComplete;

/**
 * Pushes data to the stream.
 */
- (void)pushData:(NSData *)someData;

@end
