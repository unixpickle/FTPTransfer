//
//  FPDeleteQueue.h
//  FTPTransfer
//
//  Created by Alex Nichol on 12/15/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPDeleteRequest.h"

@protocol FPDeleteQueueDelegate

- (void)fpDeleteQueue:(id)sender failedWithError:(NSError *)error;
- (void)fpDeleteQueueDonePending:(id)sender;

@end

@interface FPDeleteQueue : NSObject {
    NSMutableArray * requests;
    FPDeleteRequest * current;
}

/**
 * Called whenever the queue is exhausted.
 */
@property (nonatomic, weak) id<FPDeleteQueueDelegate> delegate;

- (void)pushRequest:(FPDeleteRequest *)request;
- (void)cancel;
- (BOOL)isDone;

@end
