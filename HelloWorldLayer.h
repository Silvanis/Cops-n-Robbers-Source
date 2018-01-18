//
//  HelloWorldLayer.h
//  CopsnRobbersTest
//
//  Created by John Markle on 5/24/12.
//  Copyright Silver Moonfire LLC 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "CLevel.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
    CLevel *level;
    enum GAME_STATE gameState;
    CGPoint firstTouch;
    CGPoint lastTouch;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

-(BOOL)checkForValidMove: (int) x :(int) y;
-(void)pauseGame;
-(void)showInstructions;
-(void)saveState;
-(void)endPausedState;
@end
