//
//  FPDataSender.h
//  FTPTransfer
//
//  Created by Alex Nichol on 12/14/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "FPSession.h"
#import "FPDataPacket.h"
#import "FPWriteData.h"

@protocol FPDataSenderDelegate <NSObject>

/**
 * Called when the sender fails with an error.
 * After this call, do not call any more methods on sender.
 */
- (void)fpDataSender:(id)sender failedWithError:(NSError *)error;

/**
 * Called when the sender has finished sending the EOF packet.
 */
- (void)fpDataSenderEnded:(id)sender;

/**
 * Called when the FPDataSender has written everything in
 * its internal buffer. This is where new data should be piped
 * in from a file handle or a similar type of stream.
 */
- (void)fpDataSenderBufferEmpty:(id)sender;

@end

/**
 * A FIFO, one-way stream through an FTP server.
 */
@interface FPDataSender : FPSession {
    FPWriteData * currentOpener; // for initialization only
    BOOL hasBegun; // YES if remote directory is created
    
    NSInteger bufferSize; // size of each payload
    NSInteger sequence; // current sequence number
    NSMutableArray * packets; // array of packets to send
    BOOL isEnded; // set to YES if endStream has been called
    
    FPWriteData * currentWriter;
}

@property (nonatomic, weak) id<FPDataSenderDelegate> delegate;

- (id)initWithBufferSize:(NSInteger)size;

/**
 * Call this method once to initiate the stream.
 * This creates a directory on the remote server for use.
 */
- (void)initiateStream;

/**
 * Append a piece of data to the internal buffer to be written.
 * This may be called as long as the stream has not ended,
 * although the data may not be written until after the stream
 * is finished initializing.
 */
- (void)writeData:(NSData *)data;

/**
 * Adds an EOF to the queue. This may only be called once.
 */
- (void)endStream;

/**
 * Terminates the FTP connection immediately without sending an
 * EOF of any sort. This may leave the remote end hanging.
 */
- (void)forceClose;

@end
