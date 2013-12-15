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

- (void)fpDataSender:(id)sender failedWithError:(NSError *)error;
- (void)fpDataSenderEnded:(id)sender;

@end

@interface FPDataSender : FPSession {
    NSInteger bufferSize; // size of each payload
    NSInteger sequence; // current sequence number
    NSMutableArray * packets; // array of packets to send
    BOOL isEnded; // set to YES if endStream has been called
    
    FPWriteData * currentWriter;
}

@property (nonatomic, weak) id<FPDataSenderDelegate> delegate;

- (id)initWithBufferSize:(NSInteger)size;

- (void)writeData:(NSData *)data;
- (void)endStream;
- (void)forceClose;

@end
