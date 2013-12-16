//
//  main.m
//  FTPTelnet
//
//  Created by Alex Nichol on 12/15/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANTelnetClient.h"
#import "ANTelnetServer.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {        
        if (argc != 6) {
            fprintf(stderr, "Usage: %s <server|client> <FTP host> <username> <password> <path>\n", argv[0]);
            return 1;
        }
        FPSession * session = nil;
        ANClient * client = nil;
        if (strcmp(argv[1], "server") == 0) {
            session = [[FPDataReceiver alloc] init];
            client = [[ANTelnetServer alloc] init];
            [(id)session setDeleteSource:YES];
            [(id)client setReceiver:(id)session];
        } else if (strcmp(argv[1], "client") == 0) {
            session = [[FPDataSender alloc] init];
            client = [[ANTelnetClient alloc] init];
            [(id)client setSender:(id)session];
        } else {
            fprintf(stderr, "Invalid role: %s\n", argv[1]);
            return 1;
        }
        session.username = [[NSString alloc] initWithUTF8String:argv[3]];
        session.password = [[NSString alloc] initWithUTF8String:argv[4]];
        session.remoteDirectory = [[NSString alloc] initWithUTF8String:argv[5]];
        session.remoteHost = [[NSString alloc] initWithUTF8String:argv[2]];
        [client start];
        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}
