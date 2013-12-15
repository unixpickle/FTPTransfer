//
//  ANSendTransfer.h
//  FTPTransfer
//
//  Created by Alex Nichol on 12/15/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "ANTransfer.h"
#import <FTPProxy/FTPProxy.h>

#define kANSendTransferBufferSize 4194303

@interface ANSendTransfer : ANTransfer <FPDataSenderDelegate> {
    FPDataSender * stream;
    NSFileHandle * currentHandle;
    BOOL isCancelling;
    
    ANItemDescriptor * descriptor;
    NSMutableArray * fileList;
    
    UInt64 written;
    UInt64 sentFiles;
}

@end
