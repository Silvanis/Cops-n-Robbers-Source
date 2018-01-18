//
//  CCopBase.h
//  Cops 'n Robbers
//
//  Created by John Markle on 1/19/13.
//  Copyright 2013 Silver Moonfire LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCharacter.h"

@interface CCopBase : CCharacter
{
    int thresholdAI;    //% chance of moving towards robber
    int sightThreshold; //how far away the cop can see the robber
    int chaseStepsThreshold; //number of tiles cop will persue robber
    int currentChaseSteps; //number of tiles cop has persued robber
    enum COP_STATE currentState;
    CCSprite *alertEmote;
    CCAction *alertAction;
    CCSprite *scaredEmote;
    CCParticleSystemQuad *scaredSystem;
    CCSprite *attractEmote;
    CCSprite *confusedEmote;
    CCParticleSystemQuad *attractSystem;
    CGPoint attractedItemPosition; //used to hold position of item cop is attracted to
    BOOL alertCycle; //make sure to only play alert sound once
}

@property enum COP_STATE currentState;

-(id) initWithParentNode:(CCNode*)parentNode;
-(id) initWithSaveState:(NSMutableDictionary *)saveData parentNode:(CCNode *)parentNode;
-(BOOL) checkIfSeesRobber: (CGPoint)robberPosition;
-(void) determineNextMove;
-(void) enterAttractedDoughnutState: (CGPoint)itemPosition;
-(void) leaveAttractedDoughnutState;
-(void) enterAttractedSexbotState: (CGPoint)itemPosition;
-(void) leaveAttractedSexbotState;
-(void) enterChasingState;
-(void) leaveChasingState;
-(void) enterConfusedState;
-(void) leaveConfusedState;
-(void) enteringScaredState: (CGPoint)itemPosition;
-(void) leaveScaredState;
-(void) enterSickState;
-(void) leaveSickState;
-(void) enterDyingState;
-(void) enterAliveState;
-(void) enterAttackingState;
-(void) leaveAttackingState;
-(void) enterBlindedState;
-(void) leaveBlindedState;
-(void) stopMoving: (BOOL)rival;
-(void) resumeMoving;
-(void) removeCop;
-(void) showCop;
-(void) saveState: (NSMutableDictionary *)saveData;
@end
