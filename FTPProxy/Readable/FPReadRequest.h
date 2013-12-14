//
//  FPReadRequest.h
//  FTPTransfer
//
//  Created by Alex Nichol on 12/13/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "FPReadable.h"

typedef void (^FPReadCallback)(NSError * error, NSData * data, BOOL done);

@interface FPReadRequest : FPReadable

@property (nonatomic, copy) FPReadCallback callback;

@end
