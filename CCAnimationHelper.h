//
//  CCAnimationHelper.h
//  CopsnRobbersTest
//
//  Created by John Markle on 11/3/12.
//  Copyright 2012 Silver Moonfire LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCAnimation (Helper)
+(CCAnimation *) animationWithFile:(NSString *)name;
+(CCAnimation *) animationWithFile4Frames:(NSString *)name;

@end
