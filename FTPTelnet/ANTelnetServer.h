//
//  ANTelnetServer.h
//  FTPTransfer
//
//  Created by Alex Nichol on 12/15/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "ANClient.h"
#import "FPDataReceiver.h"

@interface ANTelnetServer : ANClient <FPDataReceiverDelegate>

@property (nonatomic, retain) FPDataReceiver * receiver;

@end
