//
//  FPDeleteQueue.m
//  FTPTransfer
//
//  Created by Alex Nichol on 12/15/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "FPDeleteQueue.h"

@interface FPDeleteQueue (Private)

- (void)startRequest:(FPDeleteRequest *)req;
- (void)handleRequestDone:(NSError *)err;

@end

@implementation FPDeleteQueue

- (id)init {
    if ((self = [super init])) {
        requests = [NSMutableArray array];
    }
    return self;
}

- (void)pushRequest:(FPDeleteRequest *)request {
    if (!current) {
        return [self startRequest:request];
    }
    [requests addObject:request];
}

- (void)cancel {
    [current cancel];
    current = nil;
    [requests removeAllObjects];
}

- (BOOL)isDone {
    return !current;
}

#pragma mark - Private -

- (void)startRequest:(FPDeleteRequest *)req {
    __weak id weakSelf = self;
    req.callback = ^(NSError * err) {
        [weakSelf handleRequestDone:err];
    };
    current = req;
    [current start];
}

- (void)handleRequestDone:(NSError *)err {
    current = nil;
    if (err) {
        [self.delegate fpDeleteQueue:self failedWithError:err];
    } else {
        if (!requests.count) {
            [self.delegate fpDeleteQueueDonePending:self];
        } else {
            FPDeleteRequest * req = requests[0];
            [requests removeObjectAtIndex:0];
            [self startRequest:req];
        }
    }
}

@end
