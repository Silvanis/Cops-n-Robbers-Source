//
//  CLevel.h
//  CopsnRobbersTest
//
//  Created by John Markle on 8/27/12.
//  Copyright 2012 Silver Moonfire LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"
#import "CScore.h"
#import "CInspector.h"
#import "CRookie.h"
#import "CRobber.h"
#import "CFatCop.h"
#import "CCorruptCop.h"
#import "CRival.h"
#import "CSexBot.h"
#import "AStarNode.h"
#import "GameKit/GameKit.h"
#import "LevelEndViewController.h"

@interface CLevel : CCNode 
{
    CInspector *inspector;
    CRookie *rookie;
    CRobber *robber;
    CFatCop *fatCop;
    CCorruptCop *corruptCop;
    CRival *rival;
    CSexBot *sexbot;
    int tileSize;
    CCSprite *levelSprite;
    NSString *levelType;
    NSMutableArray *mapGrid;
    NSMutableArray *AStarGrid;
    CScore *score;
    int copsToSpawn;
    int copsSpawned;
    NSMutableArray *copsArray;
    int coinsToPickup; //determines victory on a level
    CGPoint bonusPosition;
    int itemsHeld[4];
    CGPoint itemBoxPositions[4];
    BOOL smokeBombActive;
    CGPoint smokeBombPosition;
    BOOL sexBotActive;
    CGPoint sexBotPosition;
    CGPoint sexBotMapPosition;
    BOOL doughnutActive;
    CGPoint doughtnutPosition;
    CGPoint doughnutMapPosition;
    BOOL lawyerActive;
    CGPoint lawyerPosition;
    CGPoint lawyerMapPosition;
    BOOL deadCops;
    int copSickenedCount;
    int copBlindedCount;
    int copScaredCount;
    int copBombedCount;
    int timerInSeconds;
    int timeBonusThreshhold;
    NSString *moneyIconFileName;
    NSString *bonusIconFileName;
    NSMutableString *backgroundMusicFileName;
    CCLabelTTF *robberGemCountLabel;
    CCLabelTTF *rivalGemCountLabel;
    CCLabelTTF *countdownTimerText;
    int rivalCountdownTimer;
    int robberGemCount;
    int rivalGemCount;
    int minimapXOffset;
    int minimapYOffset;
    int minimapScale;
    CCSprite *minimapSprite;
    int copsSubdued;
    int stepsTaken;
    CCSprite *eyesSprite;
    int eyeSpriteXPosition;
    int startingLevel;
    int levelsBeat;
    int levelsBeatWithoutDying;
    int levelsBeatWithoutUsingItem;
    BOOL robberDied;
    enum LEVEL_STATE levelState;
    UIViewController *levelEndDisplay;
    BOOL loadScoreFromSave;
}
@property (nonatomic, readonly) CGPoint robberStart;
@property (nonatomic) CGPoint robberCurrent;
@property (nonatomic, readonly) CGPoint copStart;
@property (nonatomic) CGPoint copCurrent;
@property (nonatomic, readonly) CGPoint rivalStart;
@property (nonatomic, readonly) CGPoint sexbotStart;
@property (nonatomic, readonly) int mapXOffset;
@property (nonatomic, readonly) int mapYOffset;
@property (nonatomic, readonly) int mapHeight;
@property (nonatomic, readonly) CCLayer *mapLayer;
@property (nonatomic, readonly) int level;
@property(nonatomic, retain) NSMutableDictionary *achievementsDictionary;

+(id) levelWithParentNode:(CCNode*)parentNode;
+(id) levelWithSaveStateParentNode:(CCNode *)parentNode;
-(id) initWithParentNode:(CCNode*)parentNode;
-(id) initWithSaveStateParentNode:(CCNode *)parentNode;
-(void) commonInit;

-(BOOL) verifyMove:(int) gridX :(int) gridY;
-(void) enteringSquare: (int) gridX y:(int) gridY sender: (id) sender;
-(BOOL) checkForCopCollision: (CGPoint) robberPosition;
-(void) rivalCheckForCopCollision:(CGPoint) rivalPosition;
-(void) spawnCops;
-(void) respawnCops;
-(CGPoint) getRobberPosition;
-(CGPoint) getRobberMapPosition;
-(void) killRobber;
-(void) spawnBonus;
-(void) showBonus;
-(void) useItem: (int) item;
-(void) stopSmokeBomb;
-(void) stopLawyer;
-(void) sexbotByeBye;
-(void) explodeSexBot;
-(void) stopSexBot;
-(void) stopDoughnut;
-(void) loadLevel: (int) levelToLoad;
-(void) endLevel;
-(void) cleanupLevel;
-(void) removeRobber;
-(void) startNextLevel: (NSNotification *)notification;
-(void) quitLevel: (NSNotification *)notification;
-(void) moveMap: (CGFloat) distance;
-(void) resetMapPosition;
-(void) updateRivalCoutdown;
-(void) startRivalLevelRunning;
-(void) saveState;
-(enum ROBBER_STATE)getRobberState;
-(void) resetLevel: (NSNotification *)notification;
-(void) resetLives: (NSNotification *)notification;

//used to update score for cops interacting with items
-(void) copSickened;
-(void) copBlinded;
-(void) copScared;
-(void) copBombed;
-(void) timerUpdate;

//pathfinding functions
-(enum DIRECTION) findPathToRobber: (CGPoint)position;
-(enum DIRECTION) findPathToDoughnut: (CGPoint)position;
-(enum DIRECTION) findPathToSexbot: (CGPoint)position;
-(enum DIRECTION) findPathFromLawyer: (CGPoint)position;
-(enum DIRECTION) findPathToBonus: (CGPoint)position;
-(enum DIRECTION) findPathToHome: (CGPoint)position;
-(enum DIRECTION) findPathFromNode: (AStarNode *)fromNode toNode: (AStarNode *) toNode;
-(enum DIRECTION) findNearestGem: (CGPoint)rivalPosition;
-(BOOL) searchUp: (int) searchRadius searchX: (int *) searchPositionX searchY: (int *) searchPositionY;
-(BOOL) searchDown: (int) searchRadius searchX: (int *) searchPositionX searchY: (int *) searchPositionY;
-(BOOL) searchLeft: (int) searchRadius searchX: (int *) searchPositionX searchY: (int *) searchPositionY;
-(BOOL) searchRight: (int) searchRadius searchX: (int *) searchPositionX searchY: (int *) searchPositionY;

//eyes functions
-(void) moveEyesUp;
-(void) moveEyesDown;
-(void) moveEyesLeft;
-(void) moveEyesRight;
-(void) moveEyesMoney;
-(void) moveEyesReturn;

//achievement functions
- (GKAchievement*) getAchievementForIdentifier: (NSString*) identifier;
- (void) reportAchievementIdentifier: (NSString*) identifier percentComplete: (float) percent;
- (void) resetAchievements;
@end
