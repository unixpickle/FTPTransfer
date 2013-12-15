//
//  FPWriteData.h
//  FTPTransfer
//
//  Created by Alex Nichol on 12/14/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "FPWritable.h"

typedef void (^FPWriteCallback)(NSError * error);

@interface FPWriteData : FPWritable

@property (nonatomic, copy) FPWriteCallback callback;

- (id)initWithData:(NSData *)someData;

@end
