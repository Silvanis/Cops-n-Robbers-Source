//
//  CScore.h
//  CopsnRobbersTest
//
//  Created by John Markle on 10/4/12.
//  Copyright 2012 Silver Moonfire LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CScore : CCNode
{
    CCLabelTTF *pointsLabel;
    CCLabelTTF *livesLabel;
    CCLabelTTF *levelLabel;
    int highScore;
}
@property (nonatomic) int points;
@property (nonatomic) int lives;
@property (nonatomic) int level;
@property (nonatomic) int currentLevelScore;

+(id) scoreWithParentNode:(CCNode*)parentNode;
+(id) scoreWithSaveState: (NSMutableDictionary *)saveData parentNode: (CCNode *)parentNode;
-(id) initWithParentNode:(CCNode*)parentNode;
-(id) initWithSaveState: (NSMutableDictionary *)saveData parentNode: (CCNode *)parentNode;
-(void) updateScore: (int) addToScore;
-(void) newLevel: (int) newLevel;
-(void) updateLives: (int) newLives;
-(void) saveState: (NSMutableDictionary *)saveData;
-(void) resetScore;
-(void) resetLives;
@end
