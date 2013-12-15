//
//  ANItemDescriptor.m
//  FTPTransfer
//
//  Created by Alex Nichol on 12/15/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "ANItemDescriptor.h"
#import "ANFileDescriptor.h"
#import "ANDirDescriptor.h"

@implementation ANItemDescriptor

- (UInt64)totalSize {
    [self doesNotRecognizeSelector:@selector(totalSize)];
    return 0;
}

+ (id)decodeDescriptor:(NSData *)data {
    if (data.length < 2) return nil;
    UInt8 type = ((UInt8 *)data.bytes)[0];
    if (type == ANItemDescriptorTypeDirectory) {
        return [[ANDirDescriptor alloc] initWithEncoded:data];
    } else if (type == ANItemDescriptorTypeFile) {
        return [[ANFileDescriptor alloc] initWithEncoded:data];
    }
    return nil;
}

+ (id)loadDescriptorWithPath:(NSString *)path relative:(NSString *)relative {
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSDictionary * dict = [fileManager attributesOfItemAtPath:path error:nil];
    if (!dict) return nil;
    NSString * fileType = dict[NSFileType];
    if ([fileType isEqualToString:NSFileTypeDirectory]) {
        return [[ANDirDescriptor alloc] initWithPath:path relative:relative];
    } else if ([fileType isEqualToString:NSFileTypeRegular]) {
        return [[ANFileDescriptor alloc] initWithPath:path relative:relative];
    }
    return nil;
}

- (id)initWithPath:(NSString *)path relative:(NSString *)relative {
    return nil;
}

- (NSArray *)flatten {
    return @[self];
}

- (NSData *)encodeDescriptor {
    NSMutableData * encoded = [NSMutableData data];
    UInt8 type = self.descriptorType;
    
    [encoded appendBytes:&type length:1];
    
    const char * relPath = self.relativePath.UTF8String;
    [encoded appendBytes:relPath length:(strlen(relPath) + 1)];
    
    NSData * body = [self encodeBody];
    if (body) [encoded appendData:body];
    
    return [encoded copy];
}

- (NSData *)encodeBody {
    return _initialBody;
}

- (id)initWithEncoded:(NSData *)encoded {
    if ((self = [super init])) {
        if (encoded.length < 2) return nil;
        const char * buffer = encoded.bytes;
        self.descriptorType = (UInt8)buffer[0];
        
        NSMutableData * nameBuff = [NSMutableData data];
        for (int i = 1; i < encoded.length; i++) {
            if (buffer[i] == 0) {
                _initialBody = [encoded subdataWithRange:NSMakeRange(i + 1, encoded.length - (i + 1))];
                break;
            }
            [nameBuff appendBytes:&buffer[i] length:1];
        }
        self.relativePath = [[NSString alloc] initWithData:nameBuff
                                                  encoding:NSUTF8StringEncoding];
    }
    return self;
}

@end
