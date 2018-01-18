//
//  CCharacter.h
//  CopsnRobbersTest
//
//  Created by John Markle on 9/12/12.
//  Copyright 2012 Silver Moonfire LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"

@class CLevel;
@interface CCharacter : CCNode 
{
    CGPoint gridPosition;
    CGPoint mapPosition;
    int velocity;
    int chaseVelocity;
    int currentVelocity;
    enum DIRECTION currentDirection;
    enum DIRECTION nextDirection;
    int tileSize;
    float distanceToNextTile;
    float distanceIncrement;
    BOOL turnedAround;
    CCSprite *charSprite;
    CLevel *levelPtr;
}
@property (readonly) CGPoint mapPosition;
@property (readonly) CCSprite *charSprite;
-(id) initWithParentNode:(CCNode*)parentNode;

-(void) determineNextMove;
-(void) moveCharacter: (CGPoint *)position;
-(void) turnSprite:(enum DIRECTION) direction;
-(void) update:(ccTime) time;

-(CGPoint) getPosition;
-(BOOL) checkIfCanTurn;

@end
