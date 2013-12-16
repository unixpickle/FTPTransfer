//
//  ANTelnetClient.h
//  FTPTransfer
//
//  Created by Alex Nichol on 12/15/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "ANClient.h"
#import "FPDataSender.h"

@interface ANTelnetClient : ANClient <FPDataSenderDelegate>

@property (nonatomic, retain) FPDataSender * sender;

- (void)consoleThread;

@end
