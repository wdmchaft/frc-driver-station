//
//  CRCVerifier.h
//  DriverStation
//
//  Created by Ben Abraham on 12/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CRCVerifier : NSObject
{

}

-(void)buildTable;
-(uint32_t)verify:(void *)data length:(int)length;

@end
