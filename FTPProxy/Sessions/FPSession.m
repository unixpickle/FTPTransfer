//
//  FPSession.m
//  FTPTransfer
//
//  Created by Alex Nichol on 12/14/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "FPSession.h"

@implementation FPSession

- (NSURL *)urlForRoot {
    NSString * dirPath = self.remoteDirectory;
    if ([dirPath hasSuffix:@"/"]) dirPath = [dirPath substringToIndex:(dirPath.length - 1)];
    return [[[NSURL alloc] initWithScheme:@"ftp" host:self.remoteHost path:dirPath] URLByAppendingPathComponent:@"/"];
}

- (NSURL *)urlForContainedFile:(NSString *)filename {
    NSString * path = [self.remoteDirectory stringByAppendingPathComponent:filename];
    return [[NSURL alloc] initWithScheme:@"ftp" host:self.remoteHost path:path];
}

- (NSURL *)urlForSegment:(NSInteger)segment {
    NSString * filename = [NSString stringWithFormat:@"%llu_body", (unsigned long long)segment];
    return [self urlForContainedFile:filename];
}

- (NSURL *)urlForSegmentEnd:(NSInteger)segment {
    NSString * filename = [NSString stringWithFormat:@"%llu_end", (unsigned long long)segment];
    return [self urlForContainedFile:filename];
}

@end
