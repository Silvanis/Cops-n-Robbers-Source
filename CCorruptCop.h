//
//  CCorruptCop.h
//  CopsnRobbersTest
//
//  Created by John Markle on 10/28/12.
//  Copyright 2012 Silver Moonfire LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCopBase.h"

@interface CCorruptCop : CCopBase
{
    
}

+(id) corruptCopWithParentNode:(CCNode *)parentNode;
+(id) corruptCopWithSaveState:(NSMutableDictionary *)saveData parentNode:(CCNode *)parentNode;
-(void) turnSprite: (enum DIRECTION) direction;

-(void) enterAttractedBonusState: (CGPoint)itemPosition;
-(void) leaveAttractedBonusState;

@end
