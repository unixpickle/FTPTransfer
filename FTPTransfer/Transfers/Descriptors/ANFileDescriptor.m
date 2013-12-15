//
//  ANFileDescriptor.m
//  FTPTransfer
//
//  Created by Alex Nichol on 12/15/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "ANFileDescriptor.h"

@implementation ANFileDescriptor

- (UInt64)totalSize {
    return self.size;
}

- (NSData *)encodeBody {
    UInt64 bigEndian = CFSwapInt64HostToBig(self.size);
    return [NSData dataWithBytes:&bigEndian length:8];
}

- (id)init {
    if ((self = [super init])) {
        self.descriptorType = ANItemDescriptorTypeFile;
    }
    return self;
}

- (id)initWithEncoded:(NSData *)encoded {
    if ((self = [super initWithEncoded:encoded])) {
        if (_initialBody.length != 8) return nil;
        self.size = CFSwapInt64BigToHost(*((const UInt64 *)_initialBody.bytes));
    }
    return self;
}

- (id)initWithPath:(NSString *)path relative:(NSString *)relative {
    if ((self = [super init])) {
        self.relativePath = relative;
        NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:path];
        if (!handle) return nil;
        [handle seekToEndOfFile];
        self.size = [handle offsetInFile];
        [handle closeFile];
    }
    return self;
}

@end
