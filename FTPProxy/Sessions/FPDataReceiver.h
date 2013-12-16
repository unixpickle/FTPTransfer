//
//  FPDataReceiver.h
//  FTPTransfer
//
//  Created by Alex Nichol on 12/14/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "FPSession.h"
#import "FPListRequest.h"
#import "FPReadRequest.h"
#import "FPDeleteQueue.h"
#import "FPDataPacket.h"

@protocol FPDataReceiverDelegate

/**
 * Called to indicate new data on the line.
 */
- (void)fpDataReceiver:(id)sender gotData:(NSData *)data;

/**
 * The stream has reached EOF. If `deleteSource` is YES, this method
 * will be called AFTER the root directory has been removed.
 */
- (void)fpDataReceiverEOF:(id)sender;

/**
 * Called upon ANY error. After an error, consider the FPDataReceiver invalidated.
 */
- (void)fpDataReceiver:(id)sender failedWithError:(NSError *)error;

@end

/**
 * This is a one-directional receiver for an FTP "socket"
 */
@interface FPDataReceiver : FPSession <FPDeleteQueueDelegate> {
    NSInteger sequence; // the current sequence number
    FPReadable * currentReader; // the current sequence reader or dir lister
    FPDeleteQueue * deleteQueue; // the delete queue (if used)
    
    BOOL completionPending; // set to YES if EOF has been reached and
                            // we are deleting the root directory
}

@property (nonatomic, weak) id<FPDataReceiverDelegate> delegate;

/**
 * If set to YES, packets will be deleted from the server as they are received.
 * In addition, the root directory will be unlinked immediately after the
 * stream hits EOF (if this is YES).
 */
@property (readwrite) BOOL deleteSource;

/**
 * Starts receiving data.
 */
- (void)startReading;

/**
 * Terminates the read session. No further delegate
 * methods will be called.
 */
- (void)cancelReading;

@end
