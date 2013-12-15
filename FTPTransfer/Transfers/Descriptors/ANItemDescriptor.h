//
//  ANItemDescriptor.h
//  FTPTransfer
//
//  Created by Alex Nichol on 12/15/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ANItemDescriptorTypeFile,
    ANItemDescriptorTypeDirectory
} ANItemDescriptorType;

@interface ANItemDescriptor : NSObject {
    NSData * _initialBody;
}

@property (nonatomic, retain) NSString * relativePath;
@property (readwrite) ANItemDescriptorType descriptorType;

- (UInt64)totalSize;

+ (id)decodeDescriptor:(NSData *)data;
+ (id)loadDescriptorWithPath:(NSString *)path relative:(NSString *)relative;

- (id)initWithPath:(NSString *)path relative:(NSString *)relative;
- (NSArray *)flatten;

- (NSData *)encodeDescriptor;
- (NSData *)encodeBody;

- (id)initWithEncoded:(NSData *)encoded;

@end
