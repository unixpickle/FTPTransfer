//
//  FPDataPacket.h
//  FTPTransfer
//
//  Created by Alex Nichol on 12/14/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    FPDataPacketTypePayload,
    FPDataPacketTypeEOF
} FPDataPacketType;

@interface FPDataPacket : NSObject {
    FPDataPacketType type;
    NSData * body;
}

@property (readonly) FPDataPacketType type;
@property (readonly) NSData * body;

+ (FPDataPacket *)packetByDecoding:(NSData *)data;

- (id)initWithType:(FPDataPacketType)aType body:(NSData *)aBody;
- (NSData *)encodePacket;

- (FPDataPacket *)packetByAppendingBody:(NSData *)someData;

@end
