//
//  ANTransfer.h
//  FTPTransfer
//
//  Created by Alex Nichol on 12/15/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANFileDescriptor.h"
#import "ANDirDescriptor.h"

@protocol ANTransferDelegate

- (void)transfer:(id)sender statusUpdated:(NSString *)status;
- (void)transfer:(id)sender bytesUpdated:(UInt64)bytes;
- (void)transfer:(id)sender filesUpdated:(UInt64)files;

- (void)transfer:(id)sender failedWithError:(NSError *)error;
- (void)transferDone:(id)sender;

@end

@interface ANTransfer : NSObject

@property (nonatomic, weak) id<ANTransferDelegate> delegate;
@property (nonatomic, retain) NSString * host;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * localPath;
@property (readwrite) UInt64 totalSize;

- (void)start;
- (void)initiateCancel;

@end
