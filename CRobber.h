//
//  CRobber.h
//  CopsnRobbersTest
//
//  Created by John Markle on 6/21/12.
//  Copyright 2012 Silver Moonfire LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"
#import "CCharacter.h"

@interface CRobber : CCharacter
{
    CCTimer *invulnTimer;
}

@property  enum ROBBER_STATE currentState;
+(id) robberWithParentNode:(CCNode*)parentNode;
+(id) robberWithSaveState: (NSMutableDictionary*)saveData parentNode:(CCNode *)parentNode;
-(id) initWithParentNode:(CCNode*)parentNode;
-(id) initWithSaveState: (NSMutableDictionary*)saveData parentNode:(CCNode *)parentNode;
-(void) turnSprite:(enum DIRECTION) direction;
-(void) turnCharacter:(enum DIRECTION) direction;
-(void) resetRobber;
-(void) endInvuln: (ccTime) dt;
-(void) enterPausedState;
-(void) leavePausedState;
-(void) enterDyingState;
-(void) leaveDyingState;
-(void) enterDeadState;
-(void) leaveDeadState;
-(void) enterAliveState;
-(void) leaveAliveState;
-(void) enterInvulnState;
-(void) leaveInvulnState;
-(enum DIRECTION)getDirection;
-(void) saveState: (NSMutableDictionary *)saveData;
@end
