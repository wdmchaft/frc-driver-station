//
//  RotationLock.m
//  DriverStation
//
//  Created by Ben Abraham on 11/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RotationLock.h"


@implementation RotationLock

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft
	   ||toInterfaceOrientation==UIInterfaceOrientationLandscapeRight)
		return YES;
	
	return NO;
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

@end
