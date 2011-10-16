//
//  Utilities.h
//  DriverStation
//
//  Created by Ben Abraham on 12/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utilities : NSObject
{

}

+(void)setShort:(void *)data value:(uint16_t)val;
+(void)setInt:(void *)data value:(uint32_t)val;
+(void)setLong:(void *)data value:(uint64_t)val;

+(uint16_t)getShort:(void *)data;
+(uint32_t)getInt:(void *)data;
+(uint64_t)getLong:(void *)data;

+(id)getFromArray:(NSArray *)controls withTag:(NSInteger)tag;

@end

@interface NSHost
+(NSHost *)currentHost;
-(id)address;
@end
