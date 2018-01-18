//
//  CFatCop.h
//  CopsnRobbersTest
//
//  Created by John Markle on 10/27/12.
//  Copyright 2012 Silver Moonfire LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCopBase.h"

@interface CFatCop : CCopBase
{
    
}
+(id) fatCopWithParentNode:(CCNode *)parentNode;
+(id) fatCopWithSaveState:(NSMutableDictionary *)saveData parentNode:(CCNode *)parentNode;
-(void) turnSprite: (enum DIRECTION) direction;


@end
