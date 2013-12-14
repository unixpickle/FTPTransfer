//
//  FPSession.h
//  FTPTransfer
//
//  Created by Alex Nichol on 12/14/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FPSession : NSObject

@property (nonatomic, retain) NSString * remoteDirectory;
@property (nonatomic, retain) NSString * remoteHost;

- (NSURL *)urlForRoot;
- (NSURL *)urlForContainedFile:(NSString *)filename;

@end
