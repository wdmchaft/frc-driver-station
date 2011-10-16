//
//  DriverStationAppDelegate.h
//  DriverStation
//
//  Created by Ben Abraham on 11/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkMain.h"

@interface DriverStationAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	NetworkMain *netController;
	UIScrollView *scroller;
	UIButton *hide;
	NSArray *sliders;
	NSArray *sliderOutput;
	UIWebView *helpPage;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet NetworkMain *netController;
@property (nonatomic, retain) IBOutlet UIScrollView *scroller;
@property (nonatomic, retain) IBOutlet UIButton *hide;
@property (nonatomic, retain) IBOutlet UIButton *startStop;
@property (nonatomic, retain) IBOutlet UIWebView *helpPage;

@property (nonatomic, retain) IBOutletCollection (UISlider) NSArray *sliders;
@property (nonatomic, retain) IBOutletCollection (UILabel) NSArray *sliderOutput;


-(IBAction)buttonPress:(id)sender;
-(IBAction)startSending:(id)sender;
-(IBAction)sliderUpdate:(UISlider *)sender;
-(IBAction)showHelp;
-(IBAction)hideKeyboard;
-(IBAction)startEdit;
-(void)saveSettings;
-(void)loadSettings;

@end
