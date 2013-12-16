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

- (void)fpDataReceiver:(id)sender gotData:(NSData *)data;
- (void)fpDataReceiverEOF:(id)sender;
- (void)fpDataReceiver:(id)sender failedWithError:(NSError *)error;

@end

@interface FPDataReceiver : FPSession <FPDeleteQueueDelegate> {
    NSInteger sequence;
    FPReadable * currentReader;
    FPDeleteQueue * deleteQueue;
    
    BOOL completionPending;
}

@property (nonatomic, weak) id<FPDataReceiverDelegate> delegate;
@property (readwrite) BOOL deleteSource;

- (void)startReading;
- (void)cancelReading;

@end
