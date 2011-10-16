//
//  NetworkMain.m
//  DriverStation
//
//  Created by Ben Abraham on 12/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NetworkMain.h"


@implementation NetworkMain

@synthesize cs,status,joy,sliders,dIn,dOut,teamNumber,ipField,myIP,IP,robotIP,accel,controlSwitches,buttons,mode,enableDisable,goodIP,statusSmall,accelMode,camScreen;

int toRobotPort = 1110;
int fromRobotPort = 1150;
BOOL robotConnected = FALSE;

int missed = 10;
int state;
int inputSocket,outputSocket;
struct sockaddr_in robotMain;
struct sockaddr_in myself;

struct FRCCommonControlData toRobotData;
struct RobotDataPacket fromRobotData;

CMMotionManager *motion;

#define BUFSIZE 1024

-(id)init
{
	[super init];
	
	motion = [[CMMotionManager alloc] init];
	
	veri = [[CRCVerifier alloc] init];
	[veri buildTable];
	
	NSLog(@"%i",sizeof(toRobotData));
	memset(&toRobotData,0,1024);
	memset(&fromRobotData,0,1024);
	
	toRobotData.control = 0x40;
	toRobotData.dsID_Alliance = 0x52;
	toRobotData.dsID_Position = 0x31;
	toRobotData.packetIndex = 0x0;
	[Utilities setLong:&toRobotData.versionData value:0x3130303230383030];
	[self getAddress];
	myIP = [self getAddress];
	NSLog(@"Network Main Finished Init");
	return self;
}

-(void)CloseSockets
{
	NSLog(@"Closing Sockets");
	close(inputSocket);
	close(outputSocket);
}

-(void)ToggleState
{
	NSLog(@"Toggling State");
	if(!sender)
		[self StartTimer];
	else
		[self EndTimer];
}

-(void)StartTimer
{
	[self setButtonsSelected:NO];
	[motion startAccelerometerUpdates];
	NSLog(@"Closing Sockets for safety");
	[self CloseSockets];
	short teamNum = [teamNumber.text intValue];
	NSLog(@"Starting With Team Number:%i",teamNum);
	[Utilities setShort:&toRobotData.teamID value:teamNum];
	IP = [NSString stringWithFormat:@"10.%i.%i.6",(int)(teamNum/100),teamNum%100];
	robotIP = [NSString stringWithFormat:@"10.%i.%i.2",(int)(teamNum/100),teamNum%100];
	[self startListner];
	[self startClient];
	sender = [NSTimer timerWithTimeInterval:.019 target:self selector:@selector(updateAndSend)
											userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:sender forMode:NSDefaultRunLoopMode];
}

-(void)EndTimer
{
	if(sender)
	{
		[self setButtonsSelected:NO];
		[motion stopAccelerometerUpdates];
		[sender invalidate];
		sender = nil;
		state = RobotNotConnected;
		[self CloseSockets];
	}
}

-(BOOL)startListner
{
	
	if((inputSocket=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP))==-1)
	{
		NSLog(@"Error");
		return FALSE;
	}
	memset((char *) &myself,0,sizeof(myself));
	myself.sin_family = AF_INET;
	myself.sin_port = htons(fromRobotPort);
	myself.sin_addr.s_addr = htonl(INADDR_ANY);
	
	fcntl(inputSocket, F_SETFL, O_NONBLOCK);
	
	if(bind(inputSocket,(struct sockaddr*)&myself,sizeof(myself))==-1)
	{
		NSLog(@"Bind Error");
		return FALSE;
	}
	NSLog(@"Succesfully Created UDP Server");
	
	return TRUE;
}
-(NSString*)getAddress
{
	NSString *ip = @"Check Wifi";
	struct ifaddrs *interfaces = NULL;
	struct ifaddrs *temp_addr = NULL;
	int success = 0;
	
	success = getifaddrs(&interfaces);
	if(success==0)
	{
		temp_addr = interfaces;
		while(temp_addr!=NULL)
		{
			if(temp_addr->ifa_addr->sa_family==AF_INET)
			{
				if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
				{
					ip = [[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)] retain];
					break;
				}
			}
			temp_addr = temp_addr->ifa_next;
		}
	}
	
	freeifaddrs(interfaces);
	return ip;
}
-(BOOL)startClient
{

	if ((outputSocket=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP))==-1)
	{
		NSLog(@"Error creating Socket");
		return FALSE;
	}
    
	memset((char *) &robotMain, 0, sizeof(robotMain));
	robotMain.sin_family = AF_INET;
	robotMain.sin_port = htons(toRobotPort);
	if (inet_aton([robotIP cStringUsingEncoding:NSStringEncodingConversionAllowLossy], &robotMain.sin_addr)==0)
	{
		NSLog(@"Error with iNet_aton function");
		return FALSE;
	}
	
	NSLog(@"Successfully created UDP Client");
	return TRUE;
}

-(BOOL)updateAndSend
{
	int amount = recvfrom(inputSocket, &fromRobotData, 1024, 0, nil, 0);
	[self updateUI:amount];
	[self updatePacket];
	
	int sent = sendto(outputSocket, &toRobotData, 1024, 0, (struct sockaddr *)&robotMain, sizeof(robotMain));
	if(sent == -1)
		NSLog(@"Send Error:%i",errno);
//	else
//		NSLog(@"Sent %i",sent);
	return TRUE;
}

-(void)updateUI:(int)amountRecieved
{
	if(amountRecieved==-1)
	{
		//NSLog(@"Error: %i",errno);
		
		if(missed >= 30) //600 ms
		{
			//NSLog(@"Robot Lost connection");
			status.text = @"No Robot Detected";
			[self setButtonsSelected:NO];
			state = RobotNotConnected;
			statusSmall.text = @"N/C";
			toRobotData.control &= 0xDF;
		}
		missed++;
	}
	else
	{
		//NSLog(@"Recieved: %i",amountRecieved);
		missed = 0;
		if((toRobotData.control & 0x20)==0x20)
		{
			if((fromRobotData.control & 0x20)==0x20)
			{
				if((toRobotData.control & 0x10)==0x10)
				{
					status.text = @"Robot Autonomous";
					state = RobotAutonomous;
				}
				else
				{
					status.text = @"Robot Enabled";
					state = RobotEnabled;
				}
			}
			else
			{
				status.text = @"Watchdog Not Fed";
				state = RobotWatchdogNotFed;
			}
		}
		else
		{
			status.text = @"Robot Disabled";
			state = RobotDisabled;
		}
		
		status.text=[NSString stringWithFormat:@"%@\nBattery:%X.%XV",status.text,fromRobotData.batteryVolts,fromRobotData.batteryMV];
		statusSmall.text = [NSString stringWithFormat:@"%X.%XV",fromRobotData.batteryVolts,fromRobotData.batteryMV];
		
		for(int i=0;i<8;i++)
		{
			BOOL dO = (fromRobotData.digitalOutput.dio & (1<<i))== (1<<i);
			((UISwitch *)[Utilities getFromArray:dOut withTag:i]).on = dO;
		}
	}
}

-(void)updatePacket
{
	[Utilities setShort:&toRobotData.packetIndex value:[Utilities getShort:&toRobotData.packetIndex]+1];
	
	uint16_t buttons_Out = 0;
	buttons_Out = 1 << buttons.selectedSegmentIndex;
	buttons_Out = buttons_Out | (((UISwitch *)[Utilities getFromArray:controlSwitches withTag:7]).on ? (1<<7) : 0);
	buttons_Out = buttons_Out | (((UISwitch *)[Utilities getFromArray:controlSwitches withTag:8]).on ? (1<<8) : 0);
	buttons_Out = buttons_Out | (((UISwitch *)[Utilities getFromArray:controlSwitches withTag:9]).on ? (1<<9) : 0);
	
	memset(&toRobotData.stick0.stick0Axes,0,32);
	if(joy.selectedSegmentIndex!=4)
	{
		if([camScreen isShown])
		{
			switch(joy.selectedSegmentIndex)
			{
				case 0: [camScreen getAxis:&toRobotData.stick0.stick0Axes[0]]; break;
				case 1: [camScreen getAxis:&toRobotData.stick1.stick1Axes[0]]; break;
				case 2: [camScreen getAxis:&toRobotData.stick2.stick2Axes[0]]; break;
				case 3: [camScreen getAxis:&toRobotData.stick3.stick3Axes[0]]; break;
			}
		}
		else
		{
			switch(joy.selectedSegmentIndex)
			{
				case 0: [cs getAxis:&toRobotData.stick0.stick0Axes[0]];
					[Utilities setShort:&toRobotData.stick0Buttons value:buttons_Out]; break;
				case 1: [cs getAxis:&toRobotData.stick1.stick1Axes[0]];
					[Utilities setShort:&toRobotData.stick1Buttons value:buttons_Out]; break;
				case 2: [cs getAxis:&toRobotData.stick2.stick2Axes[0]];
					[Utilities setShort:&toRobotData.stick2Buttons value:buttons_Out]; break;
				case 3: [cs getAxis:&toRobotData.stick3.stick3Axes[0]];
					[Utilities setShort:&toRobotData.stick3Buttons value:buttons_Out]; break;
			}
		}
	}
	if(accel.selectedSegmentIndex!=4)
	{
		double x = [motion accelerometerData].acceleration.x;
		double y = [motion accelerometerData].acceleration.y;
		double z = [motion accelerometerData].acceleration.z;
		if([accelMode selectedSegmentIndex]==1)
		{
			x /= 3;
			y /= 3;
			z /= 3;
		}
		x = (x<-1)?-1:((x>1)?1:x);
		y = (y<-1)?-1:((y>1)?1:y);
		z = (z<-1)?-1:((z>1)?1:z);
		if(x < 0) x *= 128; else x *= 127;
		if(y < 0) y *= 128; else y *= 127;
		if(z < 0) z *= 128; else z *= 127;
		int8_t xn = (int8_t)x;
		int8_t yn = (int8_t)y;
		int8_t zn = (int8_t)z;
		uint8_t data [6]={xn,yn,zn,0,0,0}; 
		
		switch(accel.selectedSegmentIndex)
		{
			case 0: memcpy(&toRobotData.stick0.stick0Axes, data, 6); break;
			case 1: memcpy(&toRobotData.stick1.stick1Axes, data, 6); break;
			case 2: memcpy(&toRobotData.stick2.stick2Axes, data, 6); break;
			case 3: memcpy(&toRobotData.stick3.stick3Axes, data, 6); break;
		}
	}
	
	
	[Utilities setShort:&toRobotData.analog1 value:(uint16_t)((UISlider *)[Utilities getFromArray:sliders withTag:0]).value];
	[Utilities setShort:&toRobotData.analog2 value:(uint16_t)((UISlider *)[Utilities getFromArray:sliders withTag:1]).value];
	[Utilities setShort:&toRobotData.analog3 value:(uint16_t)((UISlider *)[Utilities getFromArray:sliders withTag:2]).value];
	[Utilities setShort:&toRobotData.analog4 value:(uint16_t)((UISlider *)[Utilities getFromArray:sliders withTag:3]).value];
	
	uint8_t dI = 0;
	for(int i=0;i<8;i++)
	{
		BOOL temp = ((UISwitch *)[Utilities getFromArray:dIn withTag:i]).on;
		if(temp)
		{
			dI = dI | (1 << i);
		}
	}
	toRobotData.dsDigitalIn = dI;
	
	toRobotData.control |= (mode.selectedSegmentIndex) << 4;
	
	toRobotData.CRC = 0;
	uint32_t crc = [veri verify:&toRobotData length:1024];
	//NSLog(@"CRC: %x",crc);
	[Utilities setInt:&toRobotData.CRC value:crc];
}

-(void)setButtonsSelected:(BOOL)selected
{
	for(int i=0;i<[enableDisable count];i++)
	{
		((UIButton *)[enableDisable objectAtIndex:i]).selected = selected;
	}
}

-(struct RobotDataPacket*)getInputPacket
{
	return &fromRobotData;
}

-(struct FRCCommonControlData*)getOutputPacket
{
	return &toRobotData;
}

-(int)getState
{
	return state;
}

@end
