//
//  CRival.h
//  Cops 'n Robbers
//
//  Created by John Markle on 1/21/13.
//  Copyright 2013 Silver Moonfire LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCharacter.h"
#import "Constants.h"

@interface CRival : CCharacter
{
    CCSprite *rivalCloud;
    BOOL cloudActive;
}

@property enum RIVAL_STATE currentState;
- (id) initWithParentNode:(CCNode *)parentNode;
-(id) initWithSaveState: (NSMutableDictionary *)saveData parentNode:(CCNode *)parentNode;
+(id) rivalWithParentNode:(CCNode *)parentNode;
+(id) rivalwithSaveState:(NSMutableDictionary *)saveData parentNode:(CCNode *)parentNode;
-(void) turnSprite:(enum DIRECTION)direction;
-(void) enterPausedState;
-(void) leavePausedState;
-(void) enterAliveState;
-(void) leaveAliveState;
-(void) enterRetreatState;
-(void) leaveRetreatState;
-(void) saveState: (NSMutableDictionary *)saveData;
-(void) removeCloud;
@end
