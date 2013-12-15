//
//  ANDirDescriptor.m
//  FTPTransfer
//
//  Created by Alex Nichol on 12/15/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "ANDirDescriptor.h"

@implementation ANDirDescriptor

- (UInt64)totalSize {
    UInt64 sum = 0;
    for (ANItemDescriptor * item in self.items) {
        sum += item.totalSize;
    }
    return sum;
}

- (NSData *)encodeBody {
    NSMutableData * result = [NSMutableData data];
    
    for (ANItemDescriptor * desc in self.items) {
        NSData * data = [desc encodeDescriptor];
        UInt32 lenBuff = CFSwapInt32HostToBig((UInt32)data.length);
        [result appendBytes:&lenBuff length:4];
        [result appendData:data];
    }
    
    return [result copy];
}

- (id)init {
    if ((self = [super init])) {
        self.descriptorType = ANItemDescriptorTypeDirectory;
    }
    return self;
}

- (NSArray *)flatten {
    NSMutableArray * flat = [NSMutableArray array];
    for (ANItemDescriptor * desc in self.items) {
        [flat addObjectsFromArray:[desc flatten]];
    }
    return [flat copy];
}

- (id)initWithEncoded:(NSData *)encoded {
    if ((self = [super initWithEncoded:encoded])) {
        NSMutableArray * theItems = [NSMutableArray array];
        const UInt8 * buffer = (const UInt8 *)encoded.bytes;
        
        int byteIndex = 0;
        while (byteIndex <= _initialBody.length - 6) {
            UInt32 size = CFSwapInt32BigToHost(*((const UInt32 *)&buffer[byteIndex]));
            if (size < 2) return nil;
            
            byteIndex += 4;
            if (byteIndex + size > _initialBody.length) {
                return nil;
            }
            
            NSData * itemData = [NSData dataWithBytes:&buffer[byteIndex] length:size];
            ANItemDescriptor * desc = [ANItemDescriptor decodeDescriptor:itemData];
            if (!desc) return nil;
            [theItems addObject:desc];
            
            byteIndex += size;
        }
        
        self.items = [theItems copy];
    }
    return self;
}

- (id)initWithPath:(NSString *)path relative:(NSString *)relative {
    if ((self = [super init])) {
        NSArray * listing = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        if (!listing) return nil;
        NSMutableArray * theItems = [NSMutableArray array];
        for (NSString * name in listing) {
            NSString * newPath = [path stringByAppendingPathComponent:name];
            NSString * newRelative = [relative stringByAppendingPathComponent:name];
            ANItemDescriptor * desc = [ANItemDescriptor loadDescriptorWithPath:newPath relative:newRelative];
            if (desc) [theItems addObject:desc];
        }
        self.items = [theItems copy];
        self.relativePath = relative;
    }
    return self;
}

@end
