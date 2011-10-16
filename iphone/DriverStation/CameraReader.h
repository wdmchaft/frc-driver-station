//
//  CameraReader.h
//  DriverStation
//
//  Created by Ben Abraham on 12/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DriverStation_Prefix.pch"
#import "ControlScreen.h"
#import "Utilities.h"

#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <fcntl.h>
#include <ifaddrs.h>

@interface CameraReader : ControlScreen
{
}

-(void)doInit;
-(void)startTimer;
-(void)endTimer;
-(BOOL)initCamera;
-(BOOL)connectCamera;
-(BOOL)doRead;
-(BOOL)isShown;
-(void)endCamera;
-(void)dealloc;
-(void)readCamera;

-(int)getStatus;


@property (nonatomic, retain) IBOutlet NSString* robotIP;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* act;

@end
