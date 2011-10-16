//
//  DriverStationAppDelegate.m
//  DriverStation
//
//  Created by Ben Abraham on 11/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DriverStationAppDelegate.h"


@implementation DriverStationAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize netController;
@synthesize scroller,sliders,sliderOutput,hide,startStop,cam;
@synthesize helpPage;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	NSLog(@"Yup");
	
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
	
	[self loadSettings];
	
	[scroller setContentSize:CGSizeMake(scroller.frame.size.width, scroller.frame.size.height)];
	
	short teamNum = [netController.teamNumber.text intValue];
	netController.IP = [NSString stringWithFormat:@"10.%i.%i.6",(int)(teamNum/100),teamNum%100];
	netController.robotIP = [NSString stringWithFormat:@"10.%i.%i.2",(int)(teamNum/100),teamNum%100];
	netController.ipField.text = netController.myIP;
	netController.goodIP.selected = [netController.IP isEqualToString:netController.myIP];
	netController.camScreen.robotIP = netController.robotIP;
	[netController.camScreen doInit];
	
	[helpPage loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://comets.firstobjective.org/DSHelp.html"]]];
	
	[helpPage setBounds:CGRectMake(0,0,[UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
	
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	[self saveSettings];
    [netController EndTimer];
	startStop.selected = NO;
	netController.status.text = @"Not Started";
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
	netController.myIP = [netController getAddress];
	[self hideKeyboard];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
}


- (void)applicationWillTerminate:(UIApplication *)application
{
}

#pragma mark -
#pragma mark Control Methods


-(IBAction)buttonPress:(id)sender
{
	if([netController getState]!=RobotNotConnected)
	{
		UIButton* button = (UIButton *)sender;
		[netController setButtonsSelected:!button.selected];
		if(button.selected)
		{
			struct FRCCommonControlData* data = [netController getOutputPacket];
			data->control |= 0x20;
		}
		else
		{
			struct FRCCommonControlData* data = [netController getOutputPacket];
			data->control &= 0xDF;
		}
	}
}

-(IBAction)startSending:(id)sender
{
	UIButton* button = (UIButton *)sender;
	[button setSelected:!button.selected];
	[netController ToggleState];
}

-(IBAction)sliderUpdate:(UISlider *)sender
{
	UILabel *l = (UILabel *)([Utilities getFromArray:sliderOutput withTag:sender.tag]);
	l.text = [NSString stringWithFormat:@"%4.0f",sender.value];
}

-(IBAction)showHelp
{
	UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"IP Help"
					message:@"This is the IP of your iPhone/iPod Touch\nIt should be set to 10.xx.yy.6 in the settings application\nWhere xx and yy is your team number\neg.10.33.57.6 for team 3357" 
					delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[myAlertView show];
	[myAlertView release];
}

-(IBAction)hideKeyboard
{
	int team = [netController.teamNumber.text intValue];
	if(team<=0 || team > 9999)
	{
		UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Invalid Team" message:@"The team number specified is invalid" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[myAlertView show];
		[myAlertView release];
	}
	else
	{
		hide.hidden = TRUE;
		
		netController.IP = [NSString stringWithFormat:@"10.%i.%i.6",(int)(team/100),team%100];
		netController.robotIP = [NSString stringWithFormat:@"10.%i.%i.2",(int)(team/100),team%100];
		[netController.teamNumber resignFirstResponder];
		netController.goodIP.selected = [netController.IP isEqualToString:netController.myIP];
		netController.camScreen.robotIP = netController.robotIP;
		[netController.camScreen doInit];
	}
}

-(IBAction)startEdit
{
	hide.hidden = FALSE;
}

#pragma mark -
#pragma mark Memory management

-(void)saveSettings
{
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
	NSLog(@"Saving Settings");
	int dI = 0;
	for(int i=0;i<8;i++)
	{
		BOOL temp = ((UISwitch *)[Utilities getFromArray:netController.dIn withTag:i]).on;
		if(temp)
		{
		dI = dI | (1 << i);
		}
	}
	[def setInteger:dI forKey:@"DigitalInput"];
	int analog0 = ((UISlider *)[Utilities getFromArray:sliders withTag:0]).value;
	int analog1 = ((UISlider *)[Utilities getFromArray:sliders withTag:1]).value;
	int analog2 = ((UISlider *)[Utilities getFromArray:sliders withTag:2]).value;
	int analog3 = ((UISlider *)[Utilities getFromArray:sliders withTag:3]).value;
	[def setInteger:analog0 forKey:@"Analog0"];
	[def setInteger:analog1 forKey:@"Analog1"];
	[def setInteger:analog2 forKey:@"Analog2"];
	[def setInteger:analog3 forKey:@"Analog3"];

	[def setBool:((UISwitch *)[Utilities getFromArray:netController.controlSwitches withTag:7]).on forKey:@"Control7"];
	[def setBool:((UISwitch *)[Utilities getFromArray:netController.controlSwitches withTag:8]).on forKey:@"Control8"];
	[def setBool:((UISwitch *)[Utilities getFromArray:netController.controlSwitches withTag:9]).on	forKey:@"Control9"];

	[def setInteger:netController.mode.selectedSegmentIndex forKey:@"Mode"];
	[def setInteger:netController.joy.selectedSegmentIndex forKey:@"JoystickPort"];
	[def setInteger:netController.accel.selectedSegmentIndex forKey:@"AccelerometerPort"];
	[def setValue:netController.teamNumber.text forKey:@"TeamNumber"];
	[def synchronize];
}

-(void)loadSettings
{
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
	
	if([def valueForKey:@"TeamNumber"]!=nil)
	{
		int dI = [def integerForKey:@"DigitalInput"];
		for(int i=0;i<8;i++)
		{
			BOOL temp = (dI & (1<<i))== (1<<i);
			((UISwitch *)[Utilities getFromArray:netController.dIn withTag:i]).on = temp;
		}
		((UISlider *)[Utilities getFromArray:sliders withTag:0]).value = [def integerForKey:@"Analog0"];
		((UISlider *)[Utilities getFromArray:sliders withTag:1]).value = [def integerForKey:@"Analog1"];
		((UISlider *)[Utilities getFromArray:sliders withTag:2]).value = [def integerForKey:@"Analog2"];
		((UISlider *)[Utilities getFromArray:sliders withTag:3]).value = [def integerForKey:@"Analog3"];
		[self sliderUpdate:[Utilities getFromArray:sliders withTag:0]];
		[self sliderUpdate:[Utilities getFromArray:sliders withTag:1]];
		[self sliderUpdate:[Utilities getFromArray:sliders withTag:2]];
		[self sliderUpdate:[Utilities getFromArray:sliders withTag:3]];
		
		
		netController.mode.selectedSegmentIndex = [def integerForKey:@"Mode"];
		
		((UISwitch *)[Utilities getFromArray:netController.controlSwitches withTag:7]).on = [def boolForKey:@"Control7"];
		((UISwitch *)[Utilities getFromArray:netController.controlSwitches withTag:8]).on = [def boolForKey:@"Control8"];
		((UISwitch *)[Utilities getFromArray:netController.controlSwitches withTag:9]).on = [def boolForKey:@"Control9"];
		
		netController.mode.selectedSegmentIndex = [def integerForKey:@"Mode"];
		netController.joy.selectedSegmentIndex = [def integerForKey:@"JoystickPort"];
		netController.accel.selectedSegmentIndex = [def integerForKey:@"AccelerometerPort"];
		netController.teamNumber.text = [def valueForKey:@"TeamNumber"];
		[self hideKeyboard];
		NSLog(@"Loaded Settings");
	}
	else {
		NSLog(@"No Settings Present");
	}

}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
}


- (void)dealloc
{
    [tabBarController release];
    [window release];
    [super dealloc];
}

-(BOOL)tabBarController:(UITabBarController *)tbc shouldSelectViewController:(UIViewController *)viewController
{
	BOOL temp = [[[viewController.view.subviews objectAtIndex:0] class] isSubclassOfClass:[UIImageView class]];
	if(!temp)
	{
		NSLog(@"Switched From");
		[cam endTimer];
		[cam endCamera];
	}
	else
	{
		NSLog(@"Switched To");
		[cam startTimer];
	}
	return YES;

}

@end

