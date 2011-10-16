//
//  NetworkMain.h
//  DriverStation
//
//  Created by Ben Abraham on 12/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CFNetwork/CFNetwork.h>
#import <CoreMotion/CoreMotion.h>
#import "CRCVerifier.h"
#import "PacketDef.h"
#import "ControlScreen.h"
#import "Utilities.h"
#import "DriverStation_Prefix.pch"

#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <fcntl.h>
#include <ifaddrs.h>


@interface NetworkMain : NSObject
{
	CRCVerifier *veri;
	ControlScreen *cs;
	
	NSTimer *sender;
	
	UILabel *status;
	
	NSArray* enableDisable;
	
	UISegmentedControl *joy;
	UISegmentedControl *buttons;
	UISegmentedControl *mode;
	
	UITextField* teamNumber;
	UILabel* ipField;
	
	NSString* IP;
	NSString* myIP;
	NSString* robotIP;
	
	NSArray *dIn;
}

-(int)getState;
-(BOOL)startClient;
-(BOOL)startListner;
-(BOOL)updateAndSend;
-(void)updateUI:(int)amountRecieved;
-(void)setButtonsSelected:(BOOL)selected;
-(void)updatePacket;
-(void)ToggleState;
-(void)StartTimer;
-(void)EndTimer;
-(NSString *)getAddress;
-(struct RobotDataPacket *) getInputPacket;
-(struct FRCCommonControlData *) getOutputPacket;

@property (nonatomic, retain) IBOutlet NSString* IP;
@property (nonatomic, retain) IBOutlet NSString* myIP;
@property (nonatomic, retain) IBOutlet NSString* robotIP;

@property (nonatomic, retain) IBOutlet ControlScreen* cs;

@property (nonatomic, retain) IBOutlet UILabel* status;
@property (nonatomic, retain) IBOutlet UILabel* statusSmall;

@property (nonatomic, retain) IBOutletCollection (UIButton) NSArray* enableDisable;
@property (nonatomic, retain) IBOutlet UIButton* goodIP;

@property (nonatomic, retain) IBOutlet UISegmentedControl* joy;
@property (nonatomic, retain) IBOutlet UISegmentedControl* buttons;
@property (nonatomic, retain) IBOutlet UISegmentedControl* mode;

@property (nonatomic, retain) IBOutlet UITextField* teamNumber;
@property (nonatomic, retain) IBOutlet UILabel* ipField;

@property (nonatomic, retain) IBOutletCollection (UISlider) NSArray *sliders;
@property (nonatomic, retain) IBOutletCollection (UISwitch) NSArray *dIn;
@property (nonatomic, retain) IBOutletCollection (UISwitch) NSArray *dOut;
@property (nonatomic, retain) IBOutletCollection (UISwitch) NSArray *controlSwitches;

@end
