//
//  ControlScreen.m
//  DriverStation
//
//  Created by Ben Abraham on 12/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ControlScreen.h"

#define Max .9921875

@implementation ControlScreen

CGRect dPadLeft;
CGRect dPadRight;

CGPoint leftTouch,rightTouch;

BOOL showInfo = false;


-(void) awakeFromNib
{
	[super awakeFromNib];
	leftTouch = CGPointZero;
	rightTouch = CGPointZero;
	
	CGSize size = CGSizeMake(self.frame.size.width*.5,self.frame.size.width*.5);
	
	dPadLeft = CGRectMake(self.frame.size.height*.05,self.frame.size.width*.3,0,0);
	dPadRight = CGRectMake(self.frame.size.height*.65, self.frame.size.width*.3,0,0);
	dPadLeft.size = size;
	dPadRight.size = size;
}

-(void) drawRect:(CGRect)rect
{
	
	CGContextRef g = UIGraphicsGetCurrentContext();
	
	//[[UIColor blueColor] setFill];
    //UIRectFill( rect );
	
	float color[] = {0.0, 0.0, 0.0, 1.0};
	
	color[3] = .6;
	CGContextSetStrokeColor(g, color);
	CGContextSetFillColor(g, color);
	
	if(!CGPointEqualToPoint(leftTouch, CGPointZero))
	{
		CGContextFillEllipseInRect(g, dPadLeft);
		
	}
	else
	{
		color[3] = .4;
		CGContextSetFillColor(g, color);
		CGContextFillEllipseInRect(g, CGRectInset(dPadLeft,25,25));
		color[3] = .6;
		CGContextSetFillColor(g, color);
	}
	
	if(!CGPointEqualToPoint(rightTouch, CGPointZero))
	{
		CGContextFillEllipseInRect(g, dPadRight);
	}
	else
	{
		color[3] = .4;
		CGContextSetFillColor(g, color);
		CGContextFillEllipseInRect(g, CGRectInset(dPadRight,25,25));
		color[3] = .6;
		CGContextSetFillColor(g, color);
	}
	
	color[3] = color[0] = 1.0;
	CGContextSetStrokeColor(g, color);
	CGContextSetFillColor(g, color);
	
	if(!CGPointEqualToPoint(leftTouch, CGPointZero))
	{
		CGContextFillEllipseInRect(g, CGRectMake(leftTouch.x-25, leftTouch.y-25, 50, 50));
	}
	if(!CGPointEqualToPoint(rightTouch, CGPointZero))
	{
		CGContextFillEllipseInRect(g, CGRectMake(rightTouch.x-25, rightTouch.y-25, 50, 50));
	}
	if(showInfo)
	{
		
	}
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//rightTouch = leftTouch = CGPointZero;
	for(int i=0;i<[touches count];i++)
	{
		UITouch* t = [[touches allObjects] objectAtIndex:i];
		CGPoint pt = [t locationInView:self];
		if(CGRectIntersectsRect(dPadLeft, CGRectMake(pt.x-5, pt.y-5, 10, 10)))
			leftTouch = pt;
		if(CGRectIntersectsRect(dPadRight, CGRectMake(pt.x-5, pt.y-5, 10, 10)))
			rightTouch = pt;
	}
	[self setNeedsDisplay];
}
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	//rightTouch = leftTouch = CGPointZero;
	for(int i=0;i<[touches count];i++)
	{
		UITouch* t = [[touches allObjects] objectAtIndex:i];
		CGPoint pt = [t locationInView:self];
		if(CGRectIntersectsRect(dPadLeft, CGRectMake(pt.x-5, pt.y-5, 10, 10)))
			leftTouch = pt;
		if(CGRectIntersectsRect(dPadRight, CGRectMake(pt.x-5, pt.y-5, 10, 10)))
			rightTouch = pt;
	}
	[self setNeedsDisplay];
}
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	rightTouch = leftTouch = CGPointZero;
	[self setNeedsDisplay];
}

-(void) getAxis:(int8_t *)outputLocation
{
	double leftX = 0,leftY=0,rightX=0,rightY=0;
	if(!CGPointEqualToPoint(leftTouch, CGPointZero))
	{
		leftX = (leftTouch.x - (dPadLeft.size.width / 2) - dPadLeft.origin.x) / dPadLeft.size.width;
		leftY = (leftTouch.y - (dPadLeft.size.height / 2) - dPadLeft.origin.y) / dPadLeft.size.height;
		leftX*=2;
		leftY*=-2;
		if(leftX > Max) leftX = Max;
		if(leftX < -1) leftX = -1;
		if(leftY > Max) leftY = Max;
		if(leftY < -1) leftY = -1;
		leftX*=128;
		leftY*=128;
	}
	if(!CGPointEqualToPoint(rightTouch, CGPointZero))
	{
		rightX = (rightTouch.x - (dPadRight.size.width / 2) - dPadRight.origin.x) / dPadRight.size.width;
		rightY = (rightTouch.y - (dPadRight.size.height / 2) - dPadRight.origin.y) / dPadRight.size.height;
		rightX*=2;
		rightY*=-2;
		if(rightX > Max) rightX = Max;
		if(rightX < -1) rightX = -1;
		if(rightY > Max) rightY = Max;
		if(rightY < -1) rightY = -1;
		rightX*=128;
		rightY*=128;
	}
	outputLocation[0] = (int8_t)round(leftX);
	outputLocation[1] = (int8_t)round(leftY);
	outputLocation[2] = (int8_t)round(rightX);
	outputLocation[3] = (int8_t)round(rightY);
}

-(IBAction)toggleInfo:(UIButton *)sender
{
	showInfo = !showInfo;
	[self setNeedsLayout];
}

-(IBAction)buttonDown:(id)sender
{
	NSLog(@"%i",((UISegmentedControl *)sender).selectedSegmentIndex);
}


@end
