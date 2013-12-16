//
//  FPDeleteRequest.h
//  FTPTransfer
//
//  Created by Alex Nichol on 12/14/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FPDeleteCallback)(NSError * error);

@interface FPDeleteRequest : NSObject {
    NSThread * bgThread;
}

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSArray * urls;
@property (nonatomic, copy) FPDeleteCallback callback;

- (NSURL *)authenticatedURL:(NSURL *)aURL;
- (void)start;
- (void)cancel;

@end
