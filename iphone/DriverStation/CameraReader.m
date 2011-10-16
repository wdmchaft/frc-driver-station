//
//  CameraReader.m
//  DriverStation
//
//  Created by Ben Abraham on 12/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CameraReader.h"


@implementation CameraReader

@synthesize robotIP, act;

int status = CameraNotStarted;
int cameraSocket;
struct sockaddr_in robotCamera;
int cameraPort = 1180;

int mode;
int imageLength;
int headerPosition;

NSMutableData *buffer;
NSTimer *timer;
UIImageView *imgView;
UIImage *image;

-(void)awakeFromNib
{
	[super awakeFromNib];
	
	timer = nil;
	image = nil;
	buffer = [[NSMutableData alloc] initWithLength:2048];
	imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.height,self.frame.size.width)];
	imgView.image = image;
	[self.superview insertSubview:imgView belowSubview:self];
	self.opaque = NO;
	NSLog(@"Camera Reader Init");
}

-(void)doInit
{
	if([self initCamera])
	{
		NSLog(@"Initialized Camera");
		status = CameraNotConnected;
	}
	else
	{
		NSLog(@"Error initializing camera");
		status = CameraNotStarted;
	}
}

-(void)endTimer
{
	if(timer!=nil)
		[timer invalidate];
	timer = nil;
}

-(void)startTimer
{
	[self endTimer];
	timer = [NSTimer timerWithTimeInterval:.3 target:self selector:@selector(readCamera)
										   userInfo:nil repeats:YES];
	
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	[timer fire];
}

-(BOOL)isShown
{
	return timer != nil;
}

-(BOOL)initCamera
{
	if((cameraSocket=socket(AF_INET, SOCK_STREAM, IPPROTO_TCP))==-1)
	{
		NSLog(@"Camera socket creation Error: %i",errno);
		return FALSE;
	}
	memset((char *) &robotCamera,0,sizeof(robotCamera));
	robotCamera.sin_family = AF_INET;
	robotCamera.sin_port = htons(cameraPort);
	
	if(inet_aton([robotIP cStringUsingEncoding:NSASCIIStringEncoding],&robotCamera.sin_addr)!=1)
	{
		NSLog(@"Inavalid IP");
		return NO;
	}
	
	fcntl(cameraSocket, F_SETFL, O_NONBLOCK);
	
	image = nil;
	imageLength = 0;
	mode = 0;
	headerPosition = 0;
	
	return YES;
}

-(BOOL)connectCamera
{
	if(connect(cameraSocket,(struct sockaddr*)&robotCamera,sizeof(robotCamera))==-1)
	{
		if(errno == EISCONN)
			return YES;
		
		//[self performSelector:@selector(connectCamera) withObject:nil afterDelay:.3];
		NSLog(@"Camera Connect Error:%i",errno);
		return NO;
	}
	return YES;
}

-(void)readCamera
{
	if(status == CameraNotStarted)
	{
		if([self initCamera])
			status = CameraNotConnected;
		else
			return;
	}
	
	
	BOOL startedNC = status == CameraNotConnected;
	
	if(status == CameraNotConnected)
	{
		BOOL connected = [self connectCamera];
		if(connected)
		{
			NSLog(@"Camera Connected");
			status = CameraConnected;
			[act stopAnimating];
		}
		else
		{
			if(errno == EINPROGRESS)
			{
				[self connectCamera];
				return;
			}
			NSLog(@"Failed Connect");
			status = CameraNotConnected;
			if(!startedNC)
			{
				NSLog(@"Timer Slowdown");
				[act startAnimating];
				[self endTimer];
				timer = [NSTimer timerWithTimeInterval:.3 target:self selector:@selector(readCamera)userInfo:nil repeats:YES];
				[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
				[timer fire];
			}
		}

	}
	
	if(status == CameraConnected)
	{
		BOOL read = [self doRead];
		if(read && startedNC)
		{
			[self endTimer];
			timer = [NSTimer timerWithTimeInterval:.03 target:self selector:@selector(readCamera)userInfo:nil repeats:YES];
			[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
			[timer fire];
		}
	}
	
	if(status == CameraNotStarted)
	{
		if(![self initCamera])
		{
			NSLog(@"Camera Init Failure");
		}
	}
	
	
}

-(BOOL)doRead
{
	switch (mode)
	{
		case 0:
		{
			imageLength = 0;
			Byte b[4];
			if(recv(cameraSocket,&b,4,0)==-1)
			{
				NSLog(@"Header Recieve Error:%i",errno);
				if(errno == ECONNRESET)
				{
					//Connection Reset
					[self endCamera];
					[self initCamera];
					[act startAnimating];
				}
				return NO;
			}
			
			if(b[0]==1 && b[1]==b[2]==b[3]==0)
			{
				mode++;
			}
			else
			{
				NSLog(@"Header Issue");
			}

			
			break;
		}
		case 1:
		{
			char size[] = {0,0,0,0};
			if(recv(cameraSocket,&size,4,MSG_WAITALL)==-1)
			{
				NSLog(@"Get Size Error:%i",errno);
				if(errno == ECONNRESET)
				{
					//Connection Reset
					[self endCamera];
					[self initCamera];
					[act startAnimating];
				}
				return NO;
			}
			imageLength = [Utilities getInt:&size];
			mode++;
			[buffer setLength:imageLength];
			break;
		}
		case 2:
		{
			if(recv(cameraSocket,[buffer mutableBytes],imageLength,0)==-1)
			{
				NSLog(@"Recieve Error:%i",errno);
				if(errno == ECONNRESET)
				{
					//Connection Reset
					[self endCamera];
					[self initCamera];
					[act startAnimating];
				}
				return NO;
			}
			//[imgView.image release];
			image = [[UIImage imageWithData:buffer] retain];
			//imgView.image = image;
			[imgView setImage:image];
			[image release];
			mode = 0;
			headerPosition = 0;
			[self setNeedsDisplay];
			break;
		}
	}
	
	return YES;
}

-(void)endCamera
{
	close(cameraSocket);
	status = CameraNotStarted;
}

-(void)dealloc
{
	[self endCamera];
	[super dealloc];
}

-(int)getStatus
{
	return status;
}

@end
