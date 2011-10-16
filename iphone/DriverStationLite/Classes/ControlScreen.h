//
//  ControlScreen.h
//  DriverStation
//
//  Created by Ben Abraham on 12/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ControlScreen : UIView
{
}

-(void)getAxis:(int8_t *)outputLocation;
-(IBAction)toggleInfo:(UIButton *)sender;
-(IBAction)buttonDown:(id)sender;

@end
