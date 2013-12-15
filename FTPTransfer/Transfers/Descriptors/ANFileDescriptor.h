//
//  ANFileDescriptor.h
//  FTPTransfer
//
//  Created by Alex Nichol on 12/15/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "ANItemDescriptor.h"

@interface ANFileDescriptor : ANItemDescriptor

@property (readwrite) UInt64 size;

+ (ANFileDescriptor *)fileDescriptorForFile:(NSString *)file;

@end
