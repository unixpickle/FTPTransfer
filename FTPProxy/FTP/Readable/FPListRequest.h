//
//  FPListRequest.h
//  FTPTransfer
//
//  Created by Alex Nichol on 12/13/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "FPReadable.h"

typedef void (^FPListCallback)(NSError * error, NSDictionary * listing);

@interface FPListRequest : FPReadable {
    NSMutableData * rawData;
}

@property (nonatomic, copy) FPListCallback callback;

@end
