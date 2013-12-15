//
//  FPDataPacket.m
//  FTPTransfer
//
//  Created by Alex Nichol on 12/14/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "FPDataPacket.h"

@implementation FPDataPacket

@synthesize type, body;

+ (FPDataPacket *)packetByDecoding:(NSData *)data {
    if (!data.length) return nil;
    UInt8 typeVal = ((const UInt8 *)[data bytes])[0];
    if (typeVal != FPDataPacketTypeEOF && typeVal != FPDataPacketTypePayload) {
        return nil;
    }
    NSData * theBody = [data subdataWithRange:NSMakeRange(1, data.length - 1)];
    return [[FPDataPacket alloc] initWithType:typeVal body:theBody];
}

- (id)initWithType:(FPDataPacketType)aType body:(NSData *)aBody {
    if ((self = [super init])) {
        type = aType;
        body = aBody;
    }
    return self;
}

- (NSData *)encodePacket {
    NSMutableData * theData = [NSMutableData data];
    UInt8 theType = type;
    [theData appendBytes:&theType length:1];
    [theData appendData:body];
    return [theData copy];
}

- (FPDataPacket *)packetByAppendingBody:(NSData *)someData {
    NSMutableData * newBody = [NSMutableData dataWithData:body];
    [newBody appendData:someData];
    return [[FPDataPacket alloc] initWithType:type body:newBody];
}

@end
