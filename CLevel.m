//
//  CLevel.m
//  CopsnRobbersTest
//
//  Created by John Markle on 8/27/12.
//  Copyright 2012 Silver Moonfire LLC. All rights reserved.
//

#import "CLevel.h"
#import <stdlib.h>
#import "SimpleAudioEngine.h"
#import "cnrLibraryFunctions.h"
#import "LevelEndViewController.h"
#import "AStarNode.h"
#import "AStarPathNode.h"
#import "CCAnimationHelper.h"
#import "Flurry/Flurry.h"
#import "TitleScreenController.h"
#import "HelloWorldLayer.h"
#import "VictoryViewController.h"

@implementation CLevel
@synthesize copStart, robberStart, copCurrent, robberCurrent, rivalStart, sexbotStart;
@synthesize mapXOffset, mapYOffset, mapHeight, mapLayer, level, achievementsDictionary;

- (id) initWithParentNode:(CCNode *)parentNode
{
    if (self = [super init]) 
    {
        [self commonInit];
        mapLayer = [CLevel node];
        [parentNode addChild:mapLayer];
        [parentNode addChild:self];
        mapLayer.position = ccp(mapXOffset, mapYOffset);
        for (int x = 0; x < 4; x++)
        {
            itemsHeld[x] = 0;
        }
        

        level = [[NSUserDefaults standardUserDefaults] integerForKey:@"LevelToLoad"];
        startingLevel = level;
        levelsBeat = 0;
        levelsBeatWithoutDying = 0;
        levelsBeatWithoutUsingItem = 0;
        if (level == 0)
        {
            level = 1;
        }
        [self loadLevel:level];
        
        if (loadScoreFromSave)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectoryPath = [paths objectAtIndex:0];
            NSString *bundlePath = [NSString stringWithFormat:@"%@/savestate.plist", documentsDirectoryPath];
            NSMutableDictionary *saveData = [[[NSMutableDictionary alloc] initWithContentsOfFile:bundlePath]autorelease];
            score = [CScore scoreWithSaveState:saveData parentNode:self];
        }
        else
        {
            score = [CScore scoreWithParentNode:self];
        }
        
        
        robberDied = NO;
        copsArray = [[NSMutableArray alloc]initWithCapacity:4];
        doughnutActive = NO;
        sexBotActive = NO;
        smokeBombActive = NO;
        lawyerActive = NO;
        timerInSeconds = 0;
        
        deadCops = NO;
        
        copsSpawned = 0;
        stepsTaken = [[[NSUserDefaults standardUserDefaults] objectForKey:@"StepsTaken"]intValue];
        [self scheduleUpdate];
        [self setTag:1501];
        //if pressed New Game after qutting, need to resume updates for CCDirector
        [[CCDirector sharedDirector] resume];
        levelState = LEVEL_STATE_RUNNING;
    }
    
    return self;
}

-(id) initWithSaveStateParentNode:(CCNode *)parentNode
{
    if (self = [super init])
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectoryPath = [paths objectAtIndex:0];
        NSString *bundlePath = [NSString stringWithFormat:@"%@/savestate.plist", documentsDirectoryPath];
        NSMutableDictionary *saveData = [[[NSMutableDictionary alloc] initWithContentsOfFile:bundlePath]autorelease];
        
        enum LEVEL_STATE currentState = [[saveData objectForKey:@"LevelState"]intValue];
        if (currentState == LEVEL_STATE_ENDING)
        {
            int levelSaved = [[saveData objectForKey:@"Level"]intValue];
            levelSaved++;
            [[NSUserDefaults standardUserDefaults] setInteger:levelSaved forKey:@"LevelToLoad"];
            level = levelSaved;
            loadScoreFromSave = YES;
            [self initWithParentNode:parentNode];

            
            return self;
        }
        [self commonInit];
        mapLayer = [CLevel node];
        [parentNode addChild:mapLayer];
        [parentNode addChild:self];
        mapLayer.position = ccp(mapXOffset, mapYOffset);
        //setup class
        
        
        
        NSArray *itemsHeldArray = [saveData objectForKey:@"ItemsHeld"];
        for (int x = 0; x < 4; x++)
        {
            itemsHeld[x] = [[itemsHeldArray objectAtIndex:x]intValue];
            if (itemsHeld[x] == TILE_DONUT)
            {
                CCSprite *icon = [CCSprite spriteWithFile:@"Graphics/Doughnut/doughnuticon.png"];
                icon.position = itemBoxPositions[x];
                icon.anchorPoint = ccp(0.0, 0.0);
                [[self parent] addChild:icon z:Z_TEXT tag:ITEM_TAG_DOUGHNUT_ICON];

            }
            else if (itemsHeld[x] == TILE_LAWYER)
            {
                CCSprite *icon = [CCSprite spriteWithFile:@"Graphics/Lawyer/lawyericon.png"];
                icon.position = itemBoxPositions[x];
                icon.anchorPoint = ccp(0.0, 0.0);
                [[self parent] addChild:icon z:Z_TEXT tag:ITEM_TAG_LAWYER_ICON];
            }
            else if (itemsHeld[x] == TILE_SEXBOT)
            {
                CCSprite *icon = [CCSprite spriteWithFile:@"Graphics/Sexbot/sexbombicon.png"];
                icon.position = itemBoxPositions[x];
                icon.anchorPoint = ccp(0.0, 0.0);
                [[self parent] addChild:icon z:Z_TEXT tag:ITEM_TAG_SEXBOT_ICON];
            }
            else if (itemsHeld[x] == TILE_SMOKE_BOMB)
            {
                CCSprite *icon = [CCSprite spriteWithFile:@"Graphics/Smokebomb/smokebombicon.png"];
                icon.position = itemBoxPositions[x];
                icon.anchorPoint = ccp(0.0, 0.0);
                [[self parent] addChild:icon z:Z_TEXT tag:ITEM_TAG_SMOKEBOMB_ICON];
            }
        }
        
        mapLayer.position = ccp(mapXOffset, mapYOffset);
        backgroundMusicFileName = [[NSMutableString alloc] init];
        level = [[saveData objectForKey:@"Level"]intValue];
        startingLevel = [[saveData objectForKey:@"StartingLevel"]intValue];
        levelsBeat = [[saveData objectForKey:@"LevelsBeat"]intValue];
        levelsBeatWithoutDying = [[saveData objectForKey:@"LevelsBeatWithoutDying"]intValue];
        levelsBeatWithoutUsingItem = [[saveData objectForKey:@"LevelsBeatWithoutUsingItem"]intValue];
        if (level == 0)
        {
            level = 1;
        }
        
        
        //setup level
        
        //pull data from level .plist
        
        NSString *levelSpritefile = [NSString stringWithFormat:@"level%d", level];
        NSString *spritePath = [[NSBundle mainBundle] pathForResource:levelSpritefile ofType:@"png" inDirectory:@"Levels/Standard"];
        NSString *levelFileName = [NSString stringWithFormat:@"Level %d", level];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:levelFileName ofType:@"plist" inDirectory:@"Levels/Standard"];
        NSDictionary *levelData = [[[NSDictionary alloc] initWithContentsOfFile:filePath]autorelease];
        levelType = [[levelData objectForKey:@"Level Type"]retain];

        moneyIconFileName = [[levelData objectForKey:@"Money Icon"]retain];
        bonusIconFileName = [[levelData objectForKey:@"Bonus Icon"]retain];
        
        coinsToPickup = [[saveData objectForKey:@"CoinsToPickup"]intValue];
        timeBonusThreshhold = [[levelData objectForKey:@"Time Bonus"]intValue];
        mapHeight = [[levelData objectForKey:@"Number of Rows"]intValue];
        
        //map sprite
        
        levelSprite = [CCSprite spriteWithFile:spritePath];
        levelSprite.anchorPoint = ccp(0,0);
        levelSprite.position = ccp(0,0);
        [mapLayer addChild:levelSprite z:Z_MAP];
        
        //minimap
        
        NSString *minimapSpritefile = [NSString stringWithFormat:@"level %d mini", level];
        NSString *minimapPath = [[NSBundle mainBundle] pathForResource:minimapSpritefile ofType:@"png" inDirectory:@"Levels/Standard"];
        minimapSprite = [CCSprite spriteWithFile:minimapPath];
        minimapSprite.anchorPoint = ccp(0,0);
        minimapSprite.position = ccp(minimapXOffset, minimapYOffset);
        [[self parent] addChild:minimapSprite z:Z_UI];
        
        //eyes
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            eyesSprite = [CCSprite spriteWithFile:@"eyesdown.png"];
        }
        else
        {
            eyesSprite = [CCSprite spriteWithFile:@"eyesdown-ipad.png"];
        }
        eyesSprite.anchorPoint = ccp(0,0);
        eyesSprite.position = ccp(eyeSpriteXPosition,0);
        [[self parent] addChild:eyesSprite z:Z_TEXT tag:99999];
        
        //fill in map grid data
        
        mapGrid = [[saveData objectForKey:@"MapGrid"]retain];
        int x,y;

        for (y = 0; y < mapHeight; y++)
        {
            for (x = 0; x < 24; x++)
            {
                if ([[[mapGrid objectAtIndex:y] objectAtIndex:x]intValue] == TILE_MONEY)
                {
                    CCSprite *moneySmall = [CCSprite spriteWithFile:moneyIconFileName];
                    moneySmall.position = ccp((tileSize * x),(tileSize * y));
                    moneySmall.anchorPoint = ccp(0,0);
                    [mapLayer addChild:moneySmall z:Z_MONEY tag:(x+(y*24))];
                    CCSprite *roadMapTile = [CCSprite spriteWithFile:@"MoneyMap.png"];
                    roadMapTile.anchorPoint = ccp(0.0,0.0);
                    roadMapTile.position = ccp(((minimapScale*x) + minimapXOffset), ((minimapScale*y) + minimapYOffset));
                    [[self parent] addChild:roadMapTile z:Z_TEXT tag:(x +(y * 24) + 2000)];

                }
                else if ([[[mapGrid objectAtIndex:y] objectAtIndex:x]intValue] == TILE_BONUS)
                {
                    bonusPosition = ccp(x, y);
                    if ([[saveData objectForKey:@"BonusVisible"]boolValue])
                    {
                        [self spawnBonus];
                    }
                    else
                    {
                        int timer = arc4random_uniform(15) + 5; //set spawn for 5-20 seconds
                        [self schedule:@selector(spawnBonus) interval:timer];
                    }

                }
                else if([[[mapGrid objectAtIndex:y] objectAtIndex:x]intValue] == TILE_ROBBER_START)
                {
                    robberStart = ccp(x,y);
                    CCSprite *robberMapTile = [CCSprite spriteWithFile:@"RobberMap.png"];
                    robberMapTile.anchorPoint = ccp(0.0,0.0);
                    robberMapTile.position = ccp(((minimapScale*x) + minimapXOffset), ((minimapScale*y) + minimapYOffset));
                    [[self parent] addChild:robberMapTile z:Z_TEXT tag:MINIMAP_TAG_ROBBER];

                }
                else if([[[mapGrid objectAtIndex:y] objectAtIndex:x]intValue] == TILE_COP_START)
                {
                    copStart = ccp(x,y);
                    
                    
                }
                else if([[[mapGrid objectAtIndex:y] objectAtIndex:x] intValue] == TILE_RIVAL_START)
                {
                    rivalStart = ccp(x,y);
                }
                else if ([[[mapGrid objectAtIndex:y] objectAtIndex:x]intValue] == TILE_SMOKE_BOMB)
                {
                    CCSprite *bombSprite = [CCSprite spriteWithFile:@"Graphics/Smokebomb/smokebomb.png"];
                    bombSprite.position = ccp((tileSize * x), (tileSize * y));
                    bombSprite.anchorPoint = ccp(0,0);
                    [mapLayer addChild:bombSprite z:Z_MONEY tag:ITEM_TAG_SMOKEBOMB];
                    CCSprite *itemMapSprite = [CCSprite spriteWithFile:@"ItemMap.png"];
                    itemMapSprite.anchorPoint = ccp(0,0);
                    itemMapSprite.position = ccp(((minimapScale * x) + minimapXOffset), (minimapScale * y) + minimapYOffset);
                    [[self parent] addChild:itemMapSprite z:Z_TEXT tag:MINIMAP_TAG_SMOKEBOMB];
                }
                else if ([[[mapGrid objectAtIndex:y] objectAtIndex:x]intValue] == TILE_DONUT)
                {
                    CCSprite *doughnutSprite = [CCSprite spriteWithFile:@"Graphics/Doughnut/doughnut.png"];
                    doughnutSprite.position = ccp((tileSize * x), (tileSize * y));
                    doughnutSprite.anchorPoint = ccp(0,0);
                    [mapLayer addChild:doughnutSprite z:Z_MONEY tag:ITEM_TAG_DOUGHNUT];
                    CCSprite *itemMapSprite = [CCSprite spriteWithFile:@"ItemMap.png"];
                    itemMapSprite.anchorPoint = ccp(0,0);
                    itemMapSprite.position = ccp(((minimapScale * x) + minimapXOffset), (minimapScale * y) + minimapYOffset);
                    [[self parent] addChild:itemMapSprite z:Z_TEXT tag:MINIMAP_TAG_DOUGHNUT];
                }
                else if ([[[mapGrid objectAtIndex:y] objectAtIndex:x]intValue] == TILE_LAWYER)
                {
                    CCSprite *lawyerSprite = [CCSprite spriteWithFile:@"Graphics/Lawyer/lawyermapicon.png"];
                    lawyerSprite.position = ccp((tileSize * x), (tileSize * y));
                    lawyerSprite.anchorPoint = ccp(0,0);
                    [mapLayer addChild:lawyerSprite z:Z_MONEY tag:ITEM_TAG_LAWYER];
                    CCSprite *itemMapSprite = [CCSprite spriteWithFile:@"ItemMap.png"];
                    itemMapSprite.anchorPoint = ccp(0,0);
                    itemMapSprite.position = ccp(((minimapScale * x) + minimapXOffset), (minimapScale * y) + minimapYOffset);
                    [[self parent] addChild:itemMapSprite z:Z_TEXT tag:MINIMAP_TAG_LAWYER];
                }
                else if ([[[mapGrid objectAtIndex:y] objectAtIndex:x]intValue] == TILE_SEXBOT)
                {
                    CCSprite *sexbotSprite = [CCSprite spriteWithFile:@"Graphics/Sexbot/sexbombmapicon.png"];
                    sexbotSprite.position = ccp((tileSize * x), (tileSize * y));
                    sexbotSprite.anchorPoint = ccp(0,0);
                    [mapLayer addChild:sexbotSprite z:Z_MONEY tag:ITEM_TAG_SEXBOT];
                    CCSprite *itemMapSprite = [CCSprite spriteWithFile:@"ItemMap.png"];
                    itemMapSprite.anchorPoint = ccp(0,0);
                    itemMapSprite.position = ccp(((minimapScale * x) + minimapXOffset), (minimapScale * y) + minimapYOffset);
                    [[self parent] addChild:itemMapSprite z:Z_TEXT tag:MINIMAP_TAG_SEXBOT];
                }
            }
        }
        
        //sound
                
        [self scheduleUpdate];
        [self setTag:1501];

        if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying] || ![[levelData objectForKey:@"Background Music"] isEqualToString:backgroundMusicFileName])
        {
            NSString *musicFileName = [levelData objectForKey:@"Background Music"];
            backgroundMusicFileName = [[NSMutableString stringWithString:musicFileName]retain];
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:backgroundMusicFileName loop:YES];
        }
        
        //setup pathfinding grid
        
        AStarGrid = [[NSMutableArray alloc] initWithCapacity:24];
        for (int x = 0; x < 24; x++)
        {
            [AStarGrid addObject:[[NSMutableArray alloc] initWithCapacity:mapHeight]];
        }
        //fill grid with nodes
        for (int x = 0; x < 24; x++)
        {
            for (int y = 0; y < mapHeight; y++)
            {
                AStarNode *node = [[AStarNode alloc] init];
                node.position = ccp(x,y);
                [[AStarGrid objectAtIndex:x] addObject:node];
            }
        }
        
        //add neightbor nodes and set active status
        for (int x = 0; x < 24; x++)
        {
            for (int y = 0; y < mapHeight; y++)
            {
                AStarNode *node = [[AStarGrid objectAtIndex:x] objectAtIndex:y];
                
                if ([[[mapGrid objectAtIndex:y] objectAtIndex:x]intValue] == TILE_NO_ACCESS || [[[mapGrid objectAtIndex:y] objectAtIndex:x]intValue] == TILE_ROBBER_START)
                {
                    
                    [node setActive:NO];
                }
                
                if (x - 1 > 0)
                {
                    AStarNode *neighbor = [[AStarGrid objectAtIndex:x - 1] objectAtIndex:y];
                    [node.neighbors addObject:neighbor];
                }
                if (x + 1 < 24)
                {
                    AStarNode *neighbor = [[AStarGrid objectAtIndex:x + 1] objectAtIndex:y];
                    [node.neighbors addObject:neighbor];
                }
                if (y - 1 > 0)
                {
                    AStarNode *neighbor = [[AStarGrid objectAtIndex:x] objectAtIndex:y - 1];
                    [node.neighbors addObject:neighbor];
                }
                if (y + 1 < mapHeight)
                {
                    AStarNode *neighbor = [[AStarGrid objectAtIndex:x] objectAtIndex:y + 1];
                    [node.neighbors addObject:neighbor];
                }
                
                
            }
        }
        
        //setup robber
        
        robber = [CRobber robberWithSaveState:saveData parentNode:self];
        
        
        //setup cops
        
        copsToSpawn = [[saveData objectForKey:@"CopsToSpawn"]intValue];
        copsSpawned = [[saveData objectForKey:@"CopsSpawned"]intValue];
        copsArray = [[NSMutableArray alloc]initWithCapacity:4];
        copBlindedCount = [[saveData objectForKey:@"CopBlindedCount"]intValue];
        copBombedCount = [[saveData objectForKey:@"CopBombedCount"]intValue];
        copScaredCount = [[saveData objectForKey:@"CopScaredCount"]intValue];
        copSickenedCount = [[saveData objectForKey:@"CopSickenedCount"]intValue];
        deadCops = [[saveData objectForKey:@"DeadCops"]boolValue];
        
        //1st condition: cops haven't spawned yet
        if (copsToSpawn > 0 && copsToSpawn != copsSpawned)
        {
            [self schedule:@selector(spawnCops) interval:5.0];
        }
        
        //2nd conidition: cops are active
        if (copsSpawned >= 1)
        {
            rookie = [CRookie rookieWithSaveState:saveData parentNode:self];
            [copsArray addObject:rookie];

            
            CCSprite *rookieMapTile = [CCSprite spriteWithFile:@"CopMap.png"];
            rookieMapTile.anchorPoint = ccp(0.0,0.0);
            rookieMapTile.position = ccp(((minimapScale * copStart.x) + minimapXOffset), ((minimapScale * copStart.y) + minimapYOffset));
            [[self parent] addChild:rookieMapTile z:Z_TEXT tag:MINIMAP_TAG_ROOKIE];
        }
        if(copsSpawned >= 2)
        {
            fatCop = [CFatCop fatCopWithSaveState:saveData parentNode:self];
            [copsArray addObject:fatCop];
            
            CCSprite *fatCopMapTile = [CCSprite spriteWithFile:@"CopMap.png"];
            fatCopMapTile.anchorPoint = ccp(0.0,0.0);
            fatCopMapTile.position = ccp(((minimapScale * copStart.x) + minimapXOffset), ((minimapScale * copStart.y) + minimapYOffset));
            [[self parent] addChild:fatCopMapTile z:Z_TEXT tag:MINIMAP_TAG_FATCOP];
            
        }
        if(copsSpawned >= 3)
        {
            corruptCop = [CCorruptCop corruptCopWithSaveState:saveData parentNode:self];
            [copsArray addObject:corruptCop];
            
            CCSprite *corruptCopMapTile = [CCSprite spriteWithFile:@"CopMap.png"];
            corruptCopMapTile.anchorPoint = ccp(0.0,0.0);
            corruptCopMapTile.position = ccp(((minimapScale * copStart.x) + minimapXOffset), ((minimapScale * copStart.y) + minimapYOffset));
            [[self parent] addChild:corruptCopMapTile z:Z_TEXT tag:MINIMAP_TAG_CORRUPTCOP];

        }
        if(copsSpawned >= 4)
        {
            inspector = [CInspector inspectorWithSaveState:saveData parentNode:self];
            [copsArray addObject:inspector];
            
            CCSprite *inspectorMapTile = [CCSprite spriteWithFile:@"CopMap.png"];
            inspectorMapTile.anchorPoint = ccp(0.0,0.0);
            inspectorMapTile.position = ccp(((minimapScale * copStart.x) + minimapXOffset), ((minimapScale * copStart.y) + minimapYOffset));
            [[self parent] addChild:inspectorMapTile z:Z_TEXT tag:MINIMAP_TAG_INSPECTOR];
 
        }
        
        //3rd conditiion: cops are waiting for respawn
        if (deadCops)
        {
            [self schedule:@selector(respawnCops) interval:5.0];
        }
        
        //setup rival level
        
        if ([levelType isEqual:@"RIVAL"])
        {
            robberGemCount = [[saveData objectForKey:@"RobberGemCount"]intValue];
            rivalGemCount = [[saveData objectForKey:@"RivalGemCount"]intValue];
            rivalCountdownTimer = 5;
            rival = [CRival rivalwithSaveState:saveData parentNode:self];
            CCSprite *gemCounter = [CCSprite spriteWithFile:@"Graphics/gem counter.png"];
            int fontSize;

            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                fontSize = 14;
                robberGemCountLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",robberGemCount] fontName:@"Marker Felt" fontSize:fontSize];
                rivalGemCountLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",rivalGemCount] fontName:@"Marker Felt" fontSize:fontSize];
                gemCounter.position = ccp(mapXOffset + 384/2,304);
                robberGemCountLabel.position = ccp(mapXOffset + 171, 296);
                rivalGemCountLabel.position = ccp(mapXOffset + 214, 296);
                
            }
            else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                fontSize = 28;
                robberGemCountLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",robberGemCount] fontName:@"Marker Felt" fontSize:fontSize];
                rivalGemCountLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",rivalGemCount] fontName:@"Marker Felt" fontSize:fontSize];
                gemCounter.position = ccp(mapXOffset + 384,768 - 48);
                robberGemCountLabel.position = ccp(mapXOffset + 171 * 2, 768 - 60);
                rivalGemCountLabel.position = ccp(mapXOffset + 214 * 2, 768 - 60);
                
            }
            [self addChild:gemCounter z:Z_UI tag:5010];
            [self addChild:robberGemCountLabel z:Z_TEXT];
            [self addChild:rivalGemCountLabel z:Z_TEXT];
        
        }
        
        [self schedule:@selector(timerUpdate) interval:1.0];
        NSDictionary *flurryDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:level], @"Level", nil];
        [Flurry logEvent:@"Level Resumed" withParameters:flurryDict timed:YES];
        
        
        score = [CScore scoreWithSaveState:saveData parentNode:self];
        robberDied = [[saveData objectForKey:@"RobberDied"]boolValue];
        //setup items
        
        doughnutActive = [[saveData objectForKey:@"DoughnutActive"]boolValue];
        if (doughnutActive)
        {
            //use box of doughnuts
            doughtnutPosition = CGPointFromString([saveData objectForKey:@"DoughnutPosition"]);
            doughnutMapPosition = CGPointFromString([saveData objectForKey:@"DoughnutMapPosition"]);
            CCSprite *doughnutSprite = [CCSprite spriteWithFile:@"Graphics/Doughnut/doughnut.png"];
            doughnutSprite.position = doughtnutPosition;
            doughnutSprite.anchorPoint = ccp(0,0);
            [mapLayer addChild:doughnutSprite z:Z_MONEY tag:ITEM_TAG_DOUGHNUT];
            [self schedule:@selector(stopDoughnut) interval:5.0];
        }
        sexBotActive = [[saveData objectForKey:@"SexBotActive"]boolValue];
        if (sexBotActive)
        {
            sexbotStart = CGPointFromString([saveData objectForKey:@"SexBotMapPosition"]);
            sexbot = [CSexBot sexbotWithParentNode:self];
            [self scheduleOnce:@selector(explodeSexBot) delay:5.0];
        }
        smokeBombActive = [[saveData objectForKey:@"SmokeBombActive"]boolValue];
        if (smokeBombActive)
        {
            //use smoke bomb
            smokeBombPosition = CGPointFromString([saveData objectForKey:@"SmokeBombPosition"]);
            CCSprite *smokeBombCloud = [CCSprite spriteWithFile:@"Graphics/Smokebomb/smokecloud.png"];
            smokeBombCloud.position = smokeBombPosition;
            //smokeBombCloud.anchorPoint = ccp(0,0);
            smokeBombCloud.opacity = 256*.7;
            [mapLayer addChild:smokeBombCloud z:Z_UI tag:ITEM_TAG_SMOKEBOMB_CLOUD];
            [self schedule:@selector(stopSmokeBomb) interval:5.0];
        }
        lawyerActive = [[saveData objectForKey:@"LawyerActive"]boolValue];
        if (lawyerActive)
        {
            //use inflatable lawyer
            lawyerPosition = CGPointFromString([saveData objectForKey:@"LawyerPosition"]);
            lawyerMapPosition = CGPointFromString([saveData objectForKey:@"LawyerMapPosition"]);
            CCSprite *lawyerSprite = [CCSprite spriteWithFile:@"Graphics/Lawyer/lawyer.png"];
            lawyerSprite.position = lawyerPosition;
            lawyerSprite.anchorPoint = ccp(0.25,0);
            [mapLayer addChild:lawyerSprite z:Z_CHARACTERS tag:ITEM_TAG_LAWYER];
            CCAnimation *lawyerAnim = [CCAnimation animationWithFile:@"Graphics/Lawyer/lawyer"];
            CCAnimate *animation = [CCAnimate actionWithAnimation:lawyerAnim];
            CCRepeatForever *repeat = [CCRepeatForever actionWithAction:animation];
            [lawyerSprite runAction:repeat];
            [self schedule:@selector(stopLawyer) interval:5.0];
        }
        timerInSeconds = [[saveData objectForKey:@"TimerInSeconds"]intValue];
        
        
        stepsTaken = [[saveData objectForKey:@"StepsTaken"]intValue];
        [[CCDirector sharedDirector] resume];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:bundlePath error:nil];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"SaveExists"];
        
        levelState = LEVEL_STATE_RUNNING;
    }
    
    return self;
}

-(void) commonInit
{
    levelState = LEVEL_STATE_LOADING;
    tileSize = getTileSize();
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        mapXOffset = 96;
        mapYOffset = 64;
        if ([[UIScreen mainScreen] bounds].size.height == 568)
        {
            itemBoxPositions[0] = ccp(274,12);
            itemBoxPositions[1] = ccp(322,12);
            itemBoxPositions[2] = ccp(368,12);
            itemBoxPositions[3] = ccp(416,12);
        }
        else
        {
            itemBoxPositions[0] = ccp(224,12);
            itemBoxPositions[1] = ccp(272,12);
            itemBoxPositions[2] = ccp(318,12);
            itemBoxPositions[3] = ccp(366,12);
        }
        
        minimapXOffset = 14;
        minimapYOffset = 199;
        minimapScale = 3;
        
        eyeSpriteXPosition = 129;
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        mapXOffset = 238;
        mapYOffset = 242;
        
        itemBoxPositions[0] = ccp(827,122);
        itemBoxPositions[1] = ccp(927,122);
        itemBoxPositions[2] = ccp(827,20);
        itemBoxPositions[3] = ccp(927,20);
        
        minimapXOffset = 24;
        minimapYOffset = 522;
        minimapScale = 6;
        
        eyeSpriteXPosition = 332;
    }

    backgroundMusicFileName = [[NSMutableString alloc] init];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sound/Sound Effects/coinpickup2.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sound/Sound Effects/powerup.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sound/Sound Effects/money.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sound/Sound Effects/doughnut.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sound/Sound Effects/lawyer.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sound/Sound Effects/smokebomb.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sound/Sound Effects/magic-explosion.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sound/Sound Effects/bonus.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sound/Sound Effects/trap pickup.caf"];
    float backgroundVolume = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Master Volume"] floatValue] * [[[NSUserDefaults standardUserDefaults] objectForKey:@"Music Volume"] floatValue];
    float soundVolume = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Master Volume"] floatValue] * [[[NSUserDefaults standardUserDefaults] objectForKey:@"Sound Volume"] floatValue];
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:backgroundVolume];
    [[SimpleAudioEngine sharedEngine] setEffectsVolume:soundVolume];
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"Master Volume Mute"] boolValue])
    {
        [[SimpleAudioEngine sharedEngine] setMute:YES];
    }
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"Music Volume Mute"] boolValue])
    {
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
    }
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"Sound Volume Mute"] boolValue])
    {
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.0];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startNextLevel:) name:@"LevelCompleteButton" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitLevel:) name:@"QuitButton" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetLevel:) name:@"RestartLevelPressed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetLives:) name:@"ResetLives" object:nil];
    if ([GKLocalPlayer localPlayer].isAuthenticated)
    {
        achievementsDictionary = [[NSMutableDictionary alloc] init];
        [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error)
         {
             if (error == nil)
             {
                 for (GKAchievement* achievement in achievements)
                     [achievementsDictionary setObject: achievement forKey: achievement.identifier];
             }
         }];
    }
    //[self resetAchievements];
    //[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"StepsTaken"];
}

+(id) levelWithParentNode:(CCNode *)parentNode
{
    return [[[self alloc] initWithParentNode:parentNode] autorelease];
}

+(id) levelWithSaveStateParentNode:(CCNode *)parentNode
{
    return [[[self alloc] initWithSaveStateParentNode:parentNode] autorelease];
}

-(BOOL) verifyMove:(int) gridX : (int) gridY
{
    if ((gridX < 24) && (gridX > -1) && (gridY < mapHeight) && (gridY > -1) && ([[[mapGrid objectAtIndex:gridY] objectAtIndex:gridX]intValue] != TILE_NO_ACCESS) && ([[[mapGrid objectAtIndex:gridY] objectAtIndex:gridX]intValue] != TILE_COP_START) && ([[[mapGrid objectAtIndex:gridY] objectAtIndex:gridX]intValue] != TILE_ROBBER_START) && ([[[mapGrid objectAtIndex:gridY] objectAtIndex:gridX]intValue] != TILE_RIVAL_START))
    {
        return YES;
    }
    else 
    {
        return NO;
    }
}

-(void) enteringSquare: (int) gridX y: (int) gridY sender: (id)sender
{
    if ([sender isKindOfClass:[CRookie class]])
    {
        CCNode *rookieMapTile = [[self parent] getChildByTag:MINIMAP_TAG_ROOKIE];
        rookieMapTile.position = ccp(((minimapScale * gridX) + minimapXOffset), ((minimapScale * gridY) + minimapYOffset));
        return;
    }
    else if ([sender isKindOfClass:[CFatCop class]])
    {
        CCNode *fatCopMapTile = [[self parent] getChildByTag:MINIMAP_TAG_FATCOP];
        fatCopMapTile.position = ccp(((minimapScale * gridX) + minimapXOffset), ((minimapScale * gridY) + minimapYOffset));
        return;

    }
    else if ([sender isKindOfClass:[CCorruptCop class]])
    {
        CCNode *corruptCopMapTile = [[self parent] getChildByTag:MINIMAP_TAG_CORRUPTCOP];
        corruptCopMapTile.position = ccp(((minimapScale * gridX) + minimapXOffset), ((minimapScale * gridY) + minimapYOffset));
        int mapValue = [[[mapGrid objectAtIndex:gridY] objectAtIndex:gridX]intValue];
        if (mapValue == TILE_BONUS)
        {
            //bonus item
            CCNode *bonusSprite = [mapLayer getChildByTag:ITEM_TAG_BONUS];
            bonusSprite.visible = NO;
            CCNode *bonusMinimap = [[self parent] getChildByTag:MINIMAP_TAG_BONUS];
            bonusMinimap.visible = NO;
            [[mapGrid objectAtIndex:gridY] setObject:[NSNumber numberWithInt:TILE_ROAD] atIndex:gridX];
            int respawnTimer = arc4random_uniform(25) + 5;
            [self schedule:@selector(showBonus) interval:respawnTimer];
            [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/corrupt cop bonus.caf"];
        }
        return;
        
    }
    else if ([sender isKindOfClass:[CInspector class]])
    {
        CCNode *inspectorMapTile = [[self parent] getChildByTag:MINIMAP_TAG_INSPECTOR];
        inspectorMapTile.position = ccp(((minimapScale * gridX) + minimapXOffset), ((minimapScale * gridY) + minimapYOffset));
        return;
        
    }
    else if ([sender isKindOfClass:[CRival class]])
    {
        int mapValue = [[[mapGrid objectAtIndex:gridY] objectAtIndex:gridX]intValue];
        if (mapValue == TILE_NO_ACCESS)
        {
            //shouldn't happen
            return;
        }
        else if (mapValue == TILE_MONEY)
        {
            //money pickup
            [mapLayer removeChildByTag:(gridX + (gridY * 24)) cleanup:YES];
            [[self parent]removeChildByTag:(gridX +(gridY * 24) + 2000) cleanup:YES];
            [[mapGrid objectAtIndex:gridY] setObject:[NSNumber numberWithInt:TILE_ROAD] atIndex:gridX];
            coinsToPickup--;
            rivalGemCount++;
            [rivalGemCountLabel setString:[NSString stringWithFormat:@"%d", rivalGemCount]];
            if (coinsToPickup == 0)
            {
                //level beat; go to vicotry screen
                [self endLevel];
            }
        }
        else if (mapValue == TILE_BONUS)
        {
            //bonus item
            CCNode *bonusSprite = [mapLayer getChildByTag:ITEM_TAG_BONUS];
            bonusSprite.visible = NO;
            CCNode *bonusMinimap = [[self parent] getChildByTag:MINIMAP_TAG_BONUS];
            bonusMinimap.visible = NO;
            [[mapGrid objectAtIndex:gridY] setObject:[NSNumber numberWithInt:TILE_ROAD] atIndex:gridX];
            int respawnTimer = arc4random_uniform(25) + 5;
            [self schedule:@selector(showBonus) interval:respawnTimer];
            rivalGemCount = rivalGemCount + 5;
            [rivalGemCountLabel setString:[NSString stringWithFormat:@"%d", rivalGemCount]];
            [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/rival bonus.caf"];
        }

    }
    else if ([sender isKindOfClass:[CRobber class]])
    {
        int mapValue = [[[mapGrid objectAtIndex:gridY] objectAtIndex:gridX]intValue];
        if (mapValue == TILE_NO_ACCESS)
        {
            //shouldn't happen
            return;
        }
        else if (mapValue == TILE_ROAD)
        {
            
        }
        else if (mapValue == TILE_MONEY)
        {
            //money pickup
            [mapLayer removeChildByTag:(gridX + (gridY * 24)) cleanup:YES];
            [[self parent]removeChildByTag:(gridX +(gridY * 24) + 2000) cleanup:YES];
            [[mapGrid objectAtIndex:gridY] setObject:[NSNumber numberWithInt:TILE_ROAD] atIndex:gridX];
            [score updateScore:10 * level];
            [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/coinpickup2.caf"];
            [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/money.caf"];
            coinsToPickup--;
            if ([levelType isEqualToString:@"RIVAL"])
            {
                robberGemCount++;
                [robberGemCountLabel setString:[NSString stringWithFormat:@"%d", robberGemCount]];
            }
            if (coinsToPickup == 0)
            {
                //level beat; go to vicotry screen
                [self endLevel];
            }
        }
        else if (mapValue == TILE_BONUS)
        {
            //bonus item
            CCNode *bonusSprite = [mapLayer getChildByTag:ITEM_TAG_BONUS];
            bonusSprite.visible = NO;
            CCNode *bonusMinimap = [[self parent] getChildByTag:MINIMAP_TAG_BONUS];
            bonusMinimap.visible = NO;
            [[mapGrid objectAtIndex:gridY] setObject:[NSNumber numberWithInt:TILE_ROAD] atIndex:gridX];
            int respawnTimer = arc4random_uniform(25) + 5;
            [self schedule:@selector(showBonus) interval:respawnTimer];
            [score updateScore:50 * level];
            if ([levelType isEqualToString:@"RIVAL"])
            {
                robberGemCount = robberGemCount + 5;
                [robberGemCountLabel setString:[NSString stringWithFormat:@"%d", robberGemCount]];
            }
            [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/coinpickup2.caf" pitch:1.2 pan:0.0 gain:1.0];
            [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/bonus.caf"];
            [self moveEyesMoney];
            [self scheduleOnce:@selector(moveEyesReturn) delay:1.0];
            if (corruptCop && [corruptCop currentState] == COP_ATTRACTED_BONUS)
            {
                [corruptCop leaveAttractedBonusState];
                [corruptCop enterAliveState];
            }
        }
        else if (mapValue == TILE_SMOKE_BOMB)
        {
            int x = 0;
            while (itemsHeld[x] != 0)
            {
                //find first open slot
                x++;
            }
            itemsHeld[x] = TILE_SMOKE_BOMB;
            CCSprite *smokeBombIcon = [CCSprite spriteWithFile:@"Graphics/Smokebomb/smokebombicon.png"];
            smokeBombIcon.position = itemBoxPositions[x];
            smokeBombIcon.anchorPoint = ccp(0.0, 0.0);
            [[self parent] addChild:smokeBombIcon z:Z_TEXT tag:ITEM_TAG_SMOKEBOMB_ICON];
            [[mapGrid objectAtIndex:gridY] setObject:[NSNumber numberWithInt:TILE_ROAD] atIndex:gridX];
            [mapLayer removeChildByTag:ITEM_TAG_SMOKEBOMB cleanup:NO];
            [score updateScore:20 * level];
            [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/powerup.caf"];
            [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/trap pickup.caf"];
            [[self parent]removeChildByTag:MINIMAP_TAG_SMOKEBOMB cleanup:YES];
        }
        else if (mapValue == TILE_DONUT)
        {
            int x = 0;
            while (itemsHeld[x] != 0)
            {
                //find first open slot
                x++;
            }
            itemsHeld[x] = TILE_DONUT;
            CCSprite *doughnutIcon = [CCSprite spriteWithFile:@"Graphics/Doughnut/doughnuticon.png"];
            doughnutIcon.position = itemBoxPositions[x];
            doughnutIcon.anchorPoint = ccp(0.0, 0.0);
            [[self parent] addChild:doughnutIcon z:Z_TEXT tag:ITEM_TAG_DOUGHNUT_ICON];
            [[mapGrid objectAtIndex:gridY] setObject:[NSNumber numberWithInt:TILE_ROAD] atIndex:gridX];
            [mapLayer removeChildByTag:ITEM_TAG_DOUGHNUT cleanup:NO];
            [score updateScore:20 * level];
            [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/powerup.caf"];
            [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/trap pickup.caf"];
            [[self parent]removeChildByTag:MINIMAP_TAG_DOUGHNUT cleanup:YES];
        }
        else if (mapValue == TILE_LAWYER)
        {
            int x = 0;
            while (itemsHeld[x] != 0)
            {
                //find first open slot
                x++;
            }
            itemsHeld[x] = TILE_LAWYER;
            CCSprite *lawyerIcon = [CCSprite spriteWithFile:@"Graphics/Lawyer/lawyericon.png"];
            lawyerIcon.position = itemBoxPositions[x];
            lawyerIcon.anchorPoint = ccp(0.0, 0.0);
            [[self parent] addChild:lawyerIcon z:Z_TEXT tag:ITEM_TAG_LAWYER_ICON];
            [[mapGrid objectAtIndex:gridY] setObject:[NSNumber numberWithInt:TILE_ROAD] atIndex:gridX];
            [mapLayer removeChildByTag:ITEM_TAG_LAWYER cleanup:NO];
            [score updateScore:20 * level];
            [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/powerup.caf"];
            [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/trap pickup.caf"];
            [[self parent]removeChildByTag:MINIMAP_TAG_LAWYER cleanup:YES];
        }
        else if (mapValue == TILE_SEXBOT)
        {
            int x = 0;
            while (itemsHeld[x] != 0)
            {
                //find first open slot
                x++;
            }
            itemsHeld[x] = TILE_SEXBOT;
            CCSprite *sexbotIcon = [CCSprite spriteWithFile:@"Graphics/Sexbot/sexbombicon.png"];
            sexbotIcon.position = itemBoxPositions[x];
            sexbotIcon.anchorPoint = ccp(0.0, 0.0);
            [[self parent] addChild:sexbotIcon z:Z_TEXT tag:ITEM_TAG_SEXBOT_ICON];
            [[mapGrid objectAtIndex:gridY] setObject:[NSNumber numberWithInt:TILE_ROAD] atIndex:gridX];
            [mapLayer removeChildByTag:ITEM_TAG_SEXBOT cleanup:NO];
            [score updateScore:20 * level];
            [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/powerup.caf"];
            [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/trap pickup.caf"];
            [[self parent]removeChildByTag:MINIMAP_TAG_SEXBOT cleanup:YES];
        }
        
        CCNode *robberMapTile = [[self parent] getChildByTag:MINIMAP_TAG_ROBBER];
        robberMapTile.position = ccp(((minimapScale * gridX) + minimapXOffset), ((minimapScale * gridY) + minimapYOffset));
        stepsTaken++;
        if ([GKLocalPlayer localPlayer].isAuthenticated)
        {
            if (stepsTaken == 500 && [self getAchievementForIdentifier:@"grp.CnR500Steps"] == nil)
            {
                [self reportAchievementIdentifier:@"grp.CnR500Steps" percentComplete:100.0];
            }
            else if (stepsTaken == 1000 && [self getAchievementForIdentifier:@"grp.CnR1000Steps"] == nil)
            {
                [self reportAchievementIdentifier:@"grp.CnR1000Steps" percentComplete:100.0];
            }
            else if (stepsTaken == 5000 && [self getAchievementForIdentifier:@"grp.CnR50-0Steps"] == nil)
            {
                [self reportAchievementIdentifier:@"grp.CnR5000Steps" percentComplete:100.0];
            }
        }

    }
}

-(BOOL) checkForCopCollision: (CGPoint) robberPosition
{
    BOOL collision = NO;
    CGFloat threshold = tileSize / 4.0;
    for (CCopBase *cop in copsArray)
    {
        enum COP_STATE copState = [cop currentState];
        if (copState == COP_ALIVE || copState == COP_CHASING || copState == COP_CONFUSED)
        {
            CGPoint copPosition = [cop getPosition];
            CGFloat distanceToCop = ccpDistance(robberPosition, copPosition);
            
            if (distanceToCop < threshold)
            {
                collision = YES;
                [cop stopMoving: NO];
                
                break;
            }
        }
        
    }
    
    return collision;
}

-(void) rivalCheckForCopCollision:(CGPoint)rivalPosition
{
    BOOL collision = NO;
    CGFloat threshold = tileSize / 2.0;
    for (CCopBase *cop in copsArray)
    {
        enum COP_STATE copState = [cop currentState];
        if (copState == COP_ALIVE || copState == COP_CHASING || copState == COP_CONFUSED)
        {
            CGPoint copPosition = [cop getPosition];
            CGFloat distanceToCop = ccpDistance(rivalPosition, copPosition);
            
            if (distanceToCop < threshold)
            {
                collision = YES;
                if ([cop isKindOfClass:[CRookie class]] || [cop isKindOfClass:[CFatCop class]])
                {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/rival rookie.caf"];
                    [cop enterDyingState];
                }
                else
                {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/rival inspector.caf"];
                    [rival enterRetreatState];
                    [cop stopMoving: YES];
                }
                
                
                break;
            }
        }
        
    }

}
-(void) spawnCops
{
    if (copsToSpawn >= 1 && copsSpawned == 0)
    {
        rookie = [CRookie rookieWithParentNode:self];
        [copsArray addObject:rookie];
        copsSpawned++;
        
        CCSprite *rookieMapTile = [CCSprite spriteWithFile:@"CopMap.png"];
        rookieMapTile.anchorPoint = ccp(0.0,0.0);
        rookieMapTile.position = ccp(((minimapScale * copStart.x) + minimapXOffset), ((minimapScale * copStart.y) + minimapYOffset));
        [[self parent] addChild:rookieMapTile z:Z_TEXT tag:MINIMAP_TAG_ROOKIE];
    }
    else if(copsToSpawn >= 2 && copsSpawned == 1)
    {
        fatCop = [CFatCop fatCopWithParentNode:self];
        [copsArray addObject:fatCop];
        
        CCSprite *fatCopMapTile = [CCSprite spriteWithFile:@"CopMap.png"];
        fatCopMapTile.anchorPoint = ccp(0.0,0.0);
        fatCopMapTile.position = ccp(((minimapScale * copStart.x) + minimapXOffset), ((minimapScale * copStart.y) + minimapYOffset));
        [[self parent] addChild:fatCopMapTile z:Z_TEXT tag:MINIMAP_TAG_FATCOP];
        copsSpawned++;
        if (copsSpawned == copsToSpawn)
        {
            [self unschedule:@selector(spawnCops)];
        }
        
    }
    else if(copsToSpawn >= 3 && copsSpawned == 2)
    {
        corruptCop = [CCorruptCop corruptCopWithParentNode:self];
        [copsArray addObject:corruptCop];
        
        CCSprite *corruptCopMapTile = [CCSprite spriteWithFile:@"CopMap.png"];
        corruptCopMapTile.anchorPoint = ccp(0.0,0.0);
        corruptCopMapTile.position = ccp(((minimapScale * copStart.x) + minimapXOffset), ((minimapScale * copStart.y) + minimapYOffset));
        [[self parent] addChild:corruptCopMapTile z:Z_TEXT tag:MINIMAP_TAG_CORRUPTCOP];
        copsSpawned++;
        if (copsSpawned == copsToSpawn)
        {
            [self unschedule:@selector(spawnCops)];
        }
    }
    else if(copsToSpawn >= 4 && copsSpawned == 3)
    {
        inspector = [CInspector inspectorWithParentNode:self];
        [copsArray addObject:inspector];
        
        CCSprite *inspectorMapTile = [CCSprite spriteWithFile:@"CopMap.png"];
        inspectorMapTile.anchorPoint = ccp(0.0,0.0);
        inspectorMapTile.position = ccp(((minimapScale * copStart.x) + minimapXOffset), ((minimapScale * copStart.y) + minimapYOffset));
        [[self parent] addChild:inspectorMapTile z:Z_TEXT tag:MINIMAP_TAG_INSPECTOR];
        copsSpawned++;
        if (copsSpawned == copsToSpawn)
        {
            [self unschedule:@selector(spawnCops)];
        }
    }
    
}

-(CGPoint) getRobberPosition
{
    return [[robber charSprite]position];
}

-(CGPoint) getRobberMapPosition
{
    return [robber mapPosition];
}

-(void) killRobber
{
    [robber resetRobber];
    if ((mapHeight > 16) && (robberStart.y > 7))
    {
        //adjust map to center on robber
        int yPosition;
        if (((mapHeight - 9) < robberStart.y))
        {
            yPosition = (mapHeight - 16) * tileSize;
        }
        else
        {
            yPosition = (robberStart.y - 7) * tileSize;
        }
        
        mapLayer.position = ccp(mapLayer.position.x, (mapLayer.position.y - yPosition));
    }
    robberDied = YES;
}

-(void) spawnBonus
{
    
    CCSprite *moneyBonus = [CCSprite spriteWithFile:bonusIconFileName];
    moneyBonus.position = ccp(((tileSize * bonusPosition.x)),((tileSize * bonusPosition.y)));
    moneyBonus.anchorPoint = ccp(0,0);
    [mapLayer addChild:moneyBonus z:Z_MONEY tag:ITEM_TAG_BONUS];
    int x = bonusPosition.x;
    int y = bonusPosition.y;
    [[mapGrid objectAtIndex:y] setObject:[NSNumber numberWithInt:TILE_BONUS] atIndex:x];
    CCSprite *bonusMapTile = [CCSprite spriteWithFile:@"BonusMap.png"];
    bonusMapTile.anchorPoint = ccp(0.0,0.0);
    bonusMapTile.position = ccp(((minimapScale * bonusPosition.x) + minimapXOffset), ((minimapScale * bonusPosition.y) + minimapYOffset));
    [[self parent] addChild:bonusMapTile z:Z_TEXT tag:MINIMAP_TAG_BONUS];
    [self unschedule:@selector(spawnBonus)];
}

-(void) showBonus
{
    CCNode *bonusMapTile = [mapLayer getChildByTag:ITEM_TAG_BONUS];
    [bonusMapTile setVisible:YES];
    CCNode *bonusSprite = [[self parent] getChildByTag:MINIMAP_TAG_BONUS];
    [bonusSprite setVisible:YES];
    [[mapGrid objectAtIndex:bonusPosition.y] setObject:[NSNumber numberWithInt:TILE_BONUS] atIndex:bonusPosition.x];
    [self unschedule:@selector(showBonus)];
    
}

-(void) useItem:(int)item
{
    if (itemsHeld[item] != 0)
    {
        //item exists
        if (itemsHeld[item] == TILE_SMOKE_BOMB)
        {
            //use smoke bomb
            smokeBombPosition = [self getRobberPosition];
            CCSprite *smokeBombCloud = [CCSprite spriteWithFile:@"Graphics/Smokebomb/smokecloud.png"];
            smokeBombCloud.position = smokeBombPosition;
            //smokeBombCloud.anchorPoint = ccp(0,0);
            smokeBombCloud.opacity = 256*.7;
            [mapLayer addChild:smokeBombCloud z:Z_UI tag:ITEM_TAG_SMOKEBOMB_CLOUD];
            [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/smokebomb.caf"];
            [[self parent] removeChildByTag:ITEM_TAG_SMOKEBOMB_ICON cleanup:YES];
            itemsHeld[item] = 0;
            [self schedule:@selector(stopSmokeBomb) interval:5.0];
            smokeBombActive = YES;
            [Flurry logEvent:@"Smokebomb Used"];
        }
        else if (itemsHeld[item] == TILE_SEXBOT)
        {
            //use sexbot
            sexbotStart = [self getRobberMapPosition];
            sexbot = [CSexBot sexbotWithParentNode:self];
            sexBotActive = YES;
            [[self parent] removeChildByTag:ITEM_TAG_SEXBOT_ICON cleanup:YES];
            itemsHeld[item] = 0;
            [self scheduleOnce:@selector(explodeSexBot) delay:5.0];
            [Flurry logEvent:@"Sexbot Used"];
            [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/sexbomb spawn.caf"];
            [self scheduleOnce:@selector(sexbotByeBye) delay:4.0];
        }
        else if (itemsHeld[item] == TILE_LAWYER)
        {
            //use inflatable lawyer
            lawyerPosition = [self getRobberPosition];
            lawyerMapPosition = [self getRobberMapPosition];
            CCSprite *lawyerSprite = [CCSprite spriteWithFile:@"Graphics/Lawyer/lawyer.png"];
            lawyerSprite.position = lawyerPosition;
            lawyerSprite.anchorPoint = ccp(0.25,0);
            [mapLayer addChild:lawyerSprite z:Z_CHARACTERS tag:ITEM_TAG_LAWYER];
            [[self parent] removeChildByTag:ITEM_TAG_LAWYER_ICON cleanup:YES];
            itemsHeld[item] = 0;
            CCAnimation *lawyerAnim = [CCAnimation animationWithFile:@"Graphics/Lawyer/lawyer"];
            CCAnimate *animation = [CCAnimate actionWithAnimation:lawyerAnim];
            CCRepeatForever *repeat = [CCRepeatForever actionWithAction:animation];
            [lawyerSprite runAction:repeat];
            [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/lawyer.caf"];
            lawyerActive = YES;
            [self schedule:@selector(stopLawyer) interval:5.0];
            [Flurry logEvent:@"Lawyer Used"];
        }
        else if (itemsHeld[item] == TILE_DONUT)
        {
            //use box of doughnuts
            doughtnutPosition = [self getRobberPosition];
            doughnutMapPosition = [self getRobberMapPosition];
            CCSprite *doughnutSprite = [CCSprite spriteWithFile:@"Graphics/Doughnut/doughnut.png"];
            doughnutSprite.position = doughtnutPosition;
            doughnutSprite.anchorPoint = ccp(0,0);
            [mapLayer addChild:doughnutSprite z:Z_MONEY tag:ITEM_TAG_DOUGHNUT];
            [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/doughnut.caf"];
            [[self parent] removeChildByTag:ITEM_TAG_DOUGHNUT_ICON cleanup:YES];
            itemsHeld[item] = 0;
            doughnutActive = YES;
            [self schedule:@selector(stopDoughnut) interval:5.0];
            [Flurry logEvent:@"Doughnut Used"];
        }
    }
    else
    {
        return;
    }
}

-(void) update: (ccTime) time
{
    if (smokeBombActive)
    {
        //check for cops in smoke cloud
        BOOL collision = NO;
        CGFloat threshold = tileSize * 3;
        for (CCopBase *cop in copsArray)
        {
            enum COP_STATE copState = [cop currentState];
            if (copState == COP_ALIVE || copState == COP_CHASING || copState == COP_CONFUSED || copState == COP_BLINDED)
            {
                CGPoint copPosition = [cop getPosition];
                CGFloat distanceToCop = ccpDistance(smokeBombPosition, copPosition);
                
                if (distanceToCop < threshold)
                {
                    collision = YES;
                    if (copState != COP_BLINDED)
                    {
                        [cop enterBlindedState];
                        [self copBlinded];
                    }
                
                }
                else if (copState == COP_BLINDED)
                {
                    [cop leaveBlindedState];
                }
            }
            
        }
    }
    if (sexBotActive)
    {
        //check for cops near sexbot
        CGFloat threshold = tileSize * 6;
        for (CCopBase *cop in copsArray)
        {
            enum COP_STATE copState = [cop currentState];
            if ([cop isKindOfClass:[CInspector class]])
            {
                if (copState == COP_ALIVE || copState == COP_CHASING || copState == COP_CONFUSED || copState == COP_BLINDED)
                {
                    [cop enterAttractedSexbotState:[sexbot mapPosition]];
                }
            }
            else if (copState == COP_ALIVE || copState == COP_CHASING || copState == COP_CONFUSED || copState == COP_BLINDED)
            {
                CGPoint copPosition = [cop getPosition];
                sexBotPosition = [sexbot getPosition];
                CGFloat distanceToCop = ccpDistance(sexBotPosition, copPosition);
                
                if (distanceToCop < threshold)
                {
                    [cop enterAttractedSexbotState:[sexbot mapPosition]];
                    
                }
                
            }
            else if (copState == COP_ATTRACTED_SEXBOT)
            {
                CGPoint copPosition = [cop getPosition];
                sexBotPosition = [sexbot getPosition];
                CGFloat distanceToCop = ccpDistance(sexBotPosition, copPosition);
                
                if (distanceToCop > threshold)
                {
                    [cop leaveAttractedSexbotState];
                    
                }
            }
    
    
        }
    }
    if (lawyerActive)
    {
        //check for cops near lawyer
        CGFloat threshold = tileSize * 6;
        for (CCopBase *cop in copsArray)
        {
            enum COP_STATE copState = [cop currentState];
            if ([cop isKindOfClass:[CCorruptCop class]])
            {
                if (copState == COP_ALIVE || copState == COP_CHASING || copState == COP_CONFUSED || copState == COP_BLINDED)
                {
                    [cop enteringScaredState:lawyerMapPosition];
                }
            }
            else if (copState == COP_ALIVE || copState == COP_CHASING || copState == COP_CONFUSED || copState == COP_BLINDED)
            {
                CGPoint copPosition = [cop getPosition];
                CGFloat distanceToCop = ccpDistance(lawyerPosition, copPosition);
                
                if (distanceToCop < threshold)
                {
                    [cop enteringScaredState:lawyerMapPosition];
                    
                }
            }
            
        }
    }
    if (doughnutActive)
    {
        //check for cops near doughnut
        CGFloat threshold = tileSize * 6;
        for (CCopBase *cop in copsArray)
        {
            enum COP_STATE copState = [cop currentState];
            if ([cop isKindOfClass:[CFatCop class]])
            {
                if (copState == COP_ALIVE || copState == COP_CHASING || copState == COP_CONFUSED || copState == COP_BLINDED)
                {
                    [cop enterAttractedDoughnutState: doughnutMapPosition];
                }
            }
            else if (copState == COP_ALIVE || copState == COP_CHASING || copState == COP_CONFUSED || copState == COP_BLINDED)
            {
                CGPoint copPosition = [cop getPosition];
                CGFloat distanceToCop = ccpDistance(doughtnutPosition, copPosition);
                
                if (distanceToCop < threshold)
                {
                    [cop enterAttractedDoughnutState: doughnutMapPosition];
                    
                }
            }
            
        }
    }
    CCNode *bonusSprite = [mapLayer getChildByTag:ITEM_TAG_BONUS];
    BOOL bonusVisible = bonusSprite.visible;
    if ([corruptCop isKindOfClass:[CCorruptCop class]] && bonusVisible)
    {
        enum COP_STATE copState = [corruptCop currentState];
        if (copState == COP_ALIVE || copState == COP_CHASING || copState == COP_CONFUSED)
        {
            CGFloat threshold = tileSize * 6;
            CGPoint copPosition = [corruptCop getPosition];
            CGFloat distanceToCop = ccpDistance(bonusSprite.position, copPosition);
            
            if (distanceToCop < threshold)
            {
                [corruptCop enterAttractedBonusState: bonusPosition];
            }
        }
    }

}

-(void) stopSmokeBomb
{
    smokeBombActive = NO;
    [mapLayer removeChildByTag:ITEM_TAG_SMOKEBOMB_CLOUD cleanup:YES];
    for (CCopBase *cop in copsArray)
    {
        if ([cop currentState] == COP_BLINDED)
        {
            [cop leaveBlindedState];
        }
    }
    copBlindedCount = 0;
    [self unschedule:@selector(stopSmokeBomb)];
}

-(void) stopDoughnut
{
    doughnutActive = NO;
    [mapLayer removeChildByTag:ITEM_TAG_DOUGHNUT cleanup:YES];
    [self unschedule:@selector(stopDoughnut)];
    for (CCopBase *cop in copsArray)
    {
        if ([cop currentState] == COP_ATTRACTED_DOUGHNUT)
        {
            [cop leaveAttractedDoughnutState];
        }
    }
    copSickenedCount = 0;
}

-(void) loadLevel:(int)levelToLoad
{
    NSMutableArray *levelsEntered = [[[NSUserDefaults standardUserDefaults] objectForKey:@"LevelsEntered"]mutableCopy];
    if (levelsEntered == nil)
    {
        levelsEntered = [[NSMutableArray alloc] initWithCapacity:20];
        for (int i = 0; i < 20; i++)
        {
            [levelsEntered addObject:[NSNumber numberWithBool:NO]];
        }
    }
    [levelsEntered replaceObjectAtIndex:(levelToLoad-1) withObject:[NSNumber numberWithBool:YES]];
    [[NSUserDefaults standardUserDefaults] setObject:levelsEntered forKey:@"LevelsEntered"];
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Level Packs" ofType:@"plist" inDirectory:@"Levels"];
    NSArray *bundleArray = [[[NSArray alloc] initWithContentsOfFile:bundlePath]autorelease];
    NSDictionary *bundleData = [bundleArray objectAtIndex:0];
    int numOfLevels = [[bundleData objectForKey:@"Number of Levels"]intValue];
    if (levelToLoad > numOfLevels)
    {
        levelToLoad = 1;
        [score newLevel:levelToLoad];
        [self resetMapPosition];
        level = 1;
    }
    NSString *levelSpritefile = [NSString stringWithFormat:@"level%d", levelToLoad];
    NSString *spritePath = [[NSBundle mainBundle] pathForResource:levelSpritefile ofType:@"png" inDirectory:@"Levels/Standard"];
    NSString *levelFileName = [NSString stringWithFormat:@"Level %d", levelToLoad];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:levelFileName ofType:@"plist" inDirectory:@"Levels/Standard"];
    NSDictionary *levelData = [[[NSDictionary alloc] initWithContentsOfFile:filePath]autorelease];
    levelType = [[levelData objectForKey:@"Level Type"]retain];
    NSArray *levelDataArray = [levelData objectForKey:@"Level Data"];
    moneyIconFileName = [[levelData objectForKey:@"Money Icon"]retain];
    bonusIconFileName = [[levelData objectForKey:@"Bonus Icon"]retain];
    copsToSpawn = [[levelData objectForKey:@"Cops To Spawn"]intValue];
    copsSpawned = 0;
    coinsToPickup = 0;
    timeBonusThreshhold = [[levelData objectForKey:@"Time Bonus"]intValue];
    mapHeight = [[levelData objectForKey:@"Number of Rows"]intValue];
    levelSprite = [CCSprite spriteWithFile:spritePath];
    levelSprite.anchorPoint = ccp(0,0);
    levelSprite.position = ccp(0,0);
    [mapLayer addChild:levelSprite z:Z_MAP];
    if (level == 20)
    {
        CCSprite *levelLighting = [CCSprite spriteWithFile:@"Levels/Standard/level20 lighting.png"];
        levelLighting.anchorPoint = ccp(0,0);
        levelLighting.position = ccp(0,0);
        [mapLayer addChild:levelLighting z:Z_LIGHTING tag:123456];
    }
    NSString *minimapSpritefile = [NSString stringWithFormat:@"level %d mini", levelToLoad];
    NSString *minimapPath = [[NSBundle mainBundle] pathForResource:minimapSpritefile ofType:@"png" inDirectory:@"Levels/Standard"];
    minimapSprite = [CCSprite spriteWithFile:minimapPath];
    minimapSprite.anchorPoint = ccp(0,0);
    minimapSprite.position = ccp(minimapXOffset, minimapYOffset);
    [[self parent] addChild:minimapSprite z:Z_UI];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        eyesSprite = [CCSprite spriteWithFile:@"eyesdown.png"];
    }
    else
    {
        eyesSprite = [CCSprite spriteWithFile:@"eyesdown-ipad.png"];
    }
    eyesSprite.anchorPoint = ccp(0,0);
    eyesSprite.position = ccp(eyeSpriteXPosition,0);
    [[self parent] addChild:eyesSprite z:Z_TEXT tag:99999];
    mapGrid = [[NSMutableArray alloc] initWithCapacity:mapHeight];
    int x,y;
    for (y = 0; y < mapHeight; y++)
    {
        NSMutableArray *subArray = [[NSMutableArray alloc] initWithCapacity:24];
        for (x = 0; x < 24; x++)
        {
            int value = [[[levelDataArray objectAtIndex:y]objectAtIndex:x]intValue];
            [subArray addObject:[NSNumber numberWithInt:value]];
            
        }
        [mapGrid addObject:subArray];
    }
    for (y = 0; y < mapHeight; y++)
    {
        for (x = 0; x < 24; x++)
        {
            if ([[[mapGrid objectAtIndex:y] objectAtIndex:x]intValue] == TILE_MONEY)
            {
                CCSprite *moneySmall = [CCSprite spriteWithFile:moneyIconFileName];
                moneySmall.position = ccp((tileSize * x),(tileSize * y));
                moneySmall.anchorPoint = ccp(0,0);
                [mapLayer addChild:moneySmall z:Z_MONEY tag:(x+(y*24))];
                CCSprite *roadMapTile = [CCSprite spriteWithFile:@"MoneyMap.png"];
                roadMapTile.anchorPoint = ccp(0.0,0.0);
                roadMapTile.position = ccp(((minimapScale*x) + minimapXOffset), ((minimapScale*y) + minimapYOffset));
                [[self parent] addChild:roadMapTile z:Z_TEXT tag:(x +(y * 24) + 2000)];
                coinsToPickup++;
            }
            else if ([[[mapGrid objectAtIndex:y] objectAtIndex:x]intValue] == TILE_BONUS)
            {
                bonusPosition = ccp(x, y);
                int timer = arc4random_uniform(15) + 5; //set spawn for 5-20 seconds
                [self schedule:@selector(spawnBonus) interval:timer];
                [[mapGrid objectAtIndex:y] setObject:[NSNumber numberWithInt:TILE_ROAD] atIndex:x];
            }
            else if([[[mapGrid objectAtIndex:y] objectAtIndex:x]intValue] == TILE_ROBBER_START)
            {
                robberStart = ccp(x,y);
                
                CCSprite *robberMapTile = [CCSprite spriteWithFile:@"RobberMap.png"];
                robberMapTile.anchorPoint = ccp(0.0,0.0);
                robberMapTile.position = ccp(((minimapScale*x) + minimapXOffset), ((minimapScale*y) + minimapYOffset));
                [[self parent] addChild:robberMapTile z:Z_TEXT tag:MINIMAP_TAG_ROBBER];
                [self resetMapPosition];
            }
            else if([[[mapGrid objectAtIndex:y] objectAtIndex:x]intValue] == TILE_COP_START)
            {
                copStart = ccp(x,y);
                
                
            }
            else if([[[mapGrid objectAtIndex:y] objectAtIndex:x] intValue] == TILE_RIVAL_START)
            {
                rivalStart = ccp(x,y);
            }
            else if ([[[mapGrid objectAtIndex:y] objectAtIndex:x]intValue] == TILE_SMOKE_BOMB)
            {
                CCSprite *bombSprite = [CCSprite spriteWithFile:@"Graphics/Smokebomb/smokebomb.png"];
                bombSprite.position = ccp((tileSize * x), (tileSize * y));
                bombSprite.anchorPoint = ccp(0,0);
                [mapLayer addChild:bombSprite z:Z_MONEY tag:ITEM_TAG_SMOKEBOMB];
                CCSprite *itemMapSprite = [CCSprite spriteWithFile:@"ItemMap.png"];
                itemMapSprite.anchorPoint = ccp(0,0);
                itemMapSprite.position = ccp(((minimapScale * x) + minimapXOffset), (minimapScale * y) + minimapYOffset);
                [[self parent] addChild:itemMapSprite z:Z_TEXT tag:MINIMAP_TAG_SMOKEBOMB];
            }
            else if ([[[mapGrid objectAtIndex:y] objectAtIndex:x]intValue] == TILE_DONUT)
            {
                CCSprite *doughnutSprite = [CCSprite spriteWithFile:@"Graphics/Doughnut/doughnut.png"];
                doughnutSprite.position = ccp((tileSize * x), (tileSize * y));
                doughnutSprite.anchorPoint = ccp(0,0);
                [mapLayer addChild:doughnutSprite z:Z_MONEY tag:ITEM_TAG_DOUGHNUT];
                CCSprite *itemMapSprite = [CCSprite spriteWithFile:@"ItemMap.png"];
                itemMapSprite.anchorPoint = ccp(0,0);
                itemMapSprite.position = ccp(((minimapScale * x) + minimapXOffset), (minimapScale * y) + minimapYOffset);
                [[self parent] addChild:itemMapSprite z:Z_TEXT tag:MINIMAP_TAG_DOUGHNUT];
            }
            else if ([[[mapGrid objectAtIndex:y] objectAtIndex:x]intValue] == TILE_LAWYER)
            {
                CCSprite *lawyerSprite = [CCSprite spriteWithFile:@"Graphics/Lawyer/lawyermapicon.png"];
                lawyerSprite.position = ccp((tileSize * x), (tileSize * y));
                lawyerSprite.anchorPoint = ccp(0,0);
                [mapLayer addChild:lawyerSprite z:Z_MONEY tag:ITEM_TAG_LAWYER];
                CCSprite *itemMapSprite = [CCSprite spriteWithFile:@"ItemMap.png"];
                itemMapSprite.anchorPoint = ccp(0,0);
                itemMapSprite.position = ccp(((minimapScale * x) + minimapXOffset), (minimapScale * y) + minimapYOffset);
                [[self parent] addChild:itemMapSprite z:Z_TEXT tag:MINIMAP_TAG_LAWYER];
            }
            else if ([[[mapGrid objectAtIndex:y] objectAtIndex:x]intValue] == TILE_SEXBOT)
            {
                CCSprite *sexbotSprite = [CCSprite spriteWithFile:@"Graphics/Sexbot/sexbombmapicon.png"];
                sexbotSprite.position = ccp((tileSize * x), (tileSize * y));
                sexbotSprite.anchorPoint = ccp(0,0);
                [mapLayer addChild:sexbotSprite z:Z_MONEY tag:ITEM_TAG_SEXBOT];
                CCSprite *itemMapSprite = [CCSprite spriteWithFile:@"ItemMap.png"];
                itemMapSprite.anchorPoint = ccp(0,0);
                itemMapSprite.position = ccp(((minimapScale * x) + minimapXOffset), (minimapScale * y) + minimapYOffset);
                [[self parent] addChild:itemMapSprite z:Z_TEXT tag:MINIMAP_TAG_SEXBOT];
            }
        }
    }
    AStarGrid = [[NSMutableArray alloc] initWithCapacity:24];
    for (int x = 0; x < 24; x++)
    {
        [AStarGrid addObject:[[NSMutableArray alloc] initWithCapacity:mapHeight]];
    }
    //fill grid with nodes
    for (int x = 0; x < 24; x++)
    {
        for (int y = 0; y < mapHeight; y++)
        {
            AStarNode *node = [[AStarNode alloc] init];
            node.position = ccp(x,y);
            [[AStarGrid objectAtIndex:x] addObject:node];
        }
    }
    
    //add neightbor nodes and set active status
    for (int x = 0; x < 24; x++)
    {
        for (int y = 0; y < mapHeight; y++)
        {
            AStarNode *node = [[AStarGrid objectAtIndex:x] objectAtIndex:y];
            
            if ([[[mapGrid objectAtIndex:y] objectAtIndex:x]intValue] == TILE_NO_ACCESS || [[[mapGrid objectAtIndex:y] objectAtIndex:x]intValue] == TILE_ROBBER_START)
            {
                
                [node setActive:NO];
            }
            
            if (x - 1 > 0)
            {
                AStarNode *neighbor = [[AStarGrid objectAtIndex:x - 1] objectAtIndex:y];
                [node.neighbors addObject:neighbor];
            }
            if (x + 1 < 24)
            {
                AStarNode *neighbor = [[AStarGrid objectAtIndex:x + 1] objectAtIndex:y];
                [node.neighbors addObject:neighbor];
            }
            if (y - 1 > 0)
            {
                AStarNode *neighbor = [[AStarGrid objectAtIndex:x] objectAtIndex:y - 1];
                [node.neighbors addObject:neighbor];
            }
            if (y + 1 < mapHeight)
            {
                AStarNode *neighbor = [[AStarGrid objectAtIndex:x] objectAtIndex:y + 1];
                [node.neighbors addObject:neighbor];
            }
            
            
        }
    }
    
    copCurrent = copStart;
    robberCurrent = robberStart;
    robber = [CRobber robberWithParentNode:self];
    if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying] || ![[levelData objectForKey:@"Background Music"] isEqualToString:backgroundMusicFileName])
    {
        NSString *musicFileName = [levelData objectForKey:@"Background Music"];
        backgroundMusicFileName = [[NSMutableString stringWithString:musicFileName]retain];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:backgroundMusicFileName loop:YES];
    }
    bool masterMute = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Master Volume Mute"] boolValue];
    bool musicMute = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Music Volume Mute"] boolValue];
    if ( !(musicMute && masterMute) )
    {
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
    }
    
    

    copBlindedCount = 0;
    copBombedCount = 0;
    copScaredCount = 0;
    copSickenedCount = 0;
    if (copsToSpawn > 0)
    {
        [self schedule:@selector(spawnCops) interval:5.0];
    }
    if ([levelType isEqual:@"RIVAL"])
    {
        robberGemCount = 0;
        rivalGemCount = 0;
        rivalCountdownTimer = 5;
        rival = [CRival rivalWithParentNode:self];
        CCSprite *gemCounter = [CCSprite spriteWithFile:@"Graphics/gem counter.png"];
        int fontSize, textboxXposition, textboxYposition, textboxWidth;
        CCSprite *textBoxBackground = [CCSprite spriteWithFile:@"Graphics/textbackground.png"];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            fontSize = 14;
            textboxXposition = 280;
            textboxYposition = 250;
            textboxWidth = 300;
            robberGemCountLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",robberGemCount] fontName:@"Marker Felt" fontSize:fontSize];
            rivalGemCountLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",rivalGemCount] fontName:@"Marker Felt" fontSize:fontSize];
            countdownTimerText = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", rivalCountdownTimer] fontName:@"Marker Felt" fontSize:fontSize * 3];
            countdownTimerText.position = ccp(mapXOffset + 200, 170);
            gemCounter.position = ccp(mapXOffset + 384/2,304);
            robberGemCountLabel.position = ccp(mapXOffset + 171, 296);
            rivalGemCountLabel.position = ccp(mapXOffset + 214, 296);
            
        }
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            fontSize = 28;
            textboxXposition = 600;
            textboxYposition = 600;
            textboxWidth = 600;
            robberGemCountLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",robberGemCount] fontName:@"Marker Felt" fontSize:fontSize];
            rivalGemCountLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",rivalGemCount] fontName:@"Marker Felt" fontSize:fontSize];
            countdownTimerText = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", rivalCountdownTimer] fontName:@"Marker Felt" fontSize:fontSize * 3];
            countdownTimerText.position = ccp(mapXOffset + 400, 400);
            gemCounter.position = ccp(mapXOffset + 384,768 - 48);
            robberGemCountLabel.position = ccp(mapXOffset + 171 * 2, 768 - 60);
            rivalGemCountLabel.position = ccp(mapXOffset + 214 * 2, 768 - 60);
            
        }
        [self addChild:gemCounter z:Z_UI tag:5010];
        [self addChild:robberGemCountLabel z:Z_TEXT];
        [self addChild:rivalGemCountLabel z:Z_TEXT];
        [rival enterPausedState];
        [robber enterPausedState];
        
        textBoxBackground.position = ccp(textboxXposition, textboxYposition);
        NSString *rivalText = [levelData objectForKey:@"Rival Text"];
        CGSize textSize;
        textSize.height = (fontSize + 4) * 3;
        textSize.width = textboxWidth;
        CCLabelTTF *textbox = [CCLabelTTF labelWithString:rivalText dimensions:textSize alignment:UITextAlignmentCenter vertAlignment:UITextAlignmentCenter lineBreakMode:UILineBreakModeWordWrap fontName:@"Marker Felt" fontSize:fontSize];
        
        textbox.position = ccp(textboxXposition, textboxYposition);
        [self addChild:textBoxBackground z:Z_TEXT tag:10102];
        [self addChild:textbox z:Z_TEXT tag:10101];
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sound/Sound Effects/rival bonus.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sound/Sound Effects/rival robber lose.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sound/Sound Effects/rival robber win.caf"];
        //CCAction *fadeOutAction = [CCFadeOut actionWithDuration:1.0];
        CCAction *scaleAction = [CCScaleTo actionWithDuration:1.0 scale:3.0];
        [self addChild:countdownTimerText z:Z_TEXT];
        //[countdownTimerText runAction:fadeOutAction];
        [countdownTimerText runAction:scaleAction];
        [self schedule:@selector(updateRivalCoutdown) interval:1.0];
        
    }
    
    [self schedule:@selector(timerUpdate) interval:1.0];
    NSDictionary *flurryDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:level], @"Level", nil];
    [Flurry logEvent:@"Level Started" withParameters:flurryDict timed:YES];
    levelState = LEVEL_STATE_RUNNING;
}

-(void) updateRivalCoutdown
{
    rivalCountdownTimer--;
    if (rivalCountdownTimer == 0)
    {
        [self unschedule:@selector(updateRivalCoutdown)];
        [self startRivalLevelRunning];
        [self removeChild:countdownTimerText cleanup:YES];
        return;
    }
    else
    {
        [countdownTimerText setString:[NSString stringWithFormat:@"%d", rivalCountdownTimer]];
        countdownTimerText.scale = 1.0;
        //countdownTimerText.opacity = 1.0;
        //CCAction *fadeOutAction = [CCFadeOut actionWithDuration:1.0];
        CCAction *scaleAction = [CCScaleTo actionWithDuration:1.0 scale:3.0];
        //[countdownTimerText runAction:fadeOutAction];
        [countdownTimerText runAction:scaleAction];
    }
}
-(void) respawnCops
{
    for (int i = 0; i < [copsArray count]; i++)
    {
        CCopBase *cop = (CCopBase *)[copsArray objectAtIndex:i];
        if ([cop currentState] == COP_DEAD)
        {
            NSLog(@"Respawning %@", [cop class]);
            [cop showCop];
            deadCops = YES;
            return;
        }
    }
    if (deadCops == NO)
    {
        [self unschedule:@selector(respawnCops)];
    }
}

-(void) endLevel
{
    [self cleanupLevel];
    levelState = LEVEL_STATE_ENDING;
    //move Robber off screen
    [self unschedule:@selector(timerUpdate)];
    CCMoveBy *leaveScreen = [CCMoveBy actionWithDuration:1.5 position:ccp(800,0)];
    [robber turnSprite:DIR_RIGHT];
    [robber enterPausedState];
    [[robber charSprite] runAction:leaveScreen];
    [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/level end.caf"];
    [self scheduleOnce:@selector(removeRobber) delay:2.2];
    [[NSUserDefaults standardUserDefaults] setInteger:stepsTaken forKey:@"StepsTaken"];
    
    //setup scores and data to send to level end view
    
    int timeBonusScore = 0;
    if (timerInSeconds < timeBonusThreshhold)
    {
        //give bonus for quick completion
        timeBonusScore = (timeBonusThreshhold - timerInSeconds) * 10;
    }
    
    [score updateScore:timeBonusScore];
    NSNumber *scoreBonus = [NSNumber numberWithInt:[score lives] * 100];
    [score updateScore:[scoreBonus intValue]];
    NSMutableArray *itemsKept = [NSMutableArray arrayWithCapacity:4];
    int numOfItemsKept = 0;
    for (int index = 0; index < 4; index++)
    {
        if (itemsHeld[index] != 0)
        {
            if (itemsHeld[index] == TILE_SMOKE_BOMB)
            {
                [itemsKept addObject:@"Graphics/Smokebomb/smokebombicon"];
                [[self parent] removeChildByTag:ITEM_TAG_SMOKEBOMB_ICON cleanup:YES];
                //[[self parent] removeChildByTag:MINIMAP_TAG_SMOKEBOMB cleanup:YES];
            }
            else if (itemsHeld[index] == TILE_DONUT)
            {
                [itemsKept addObject:@"Graphics/Doughnut/doughnuticon"];
                [[self parent] removeChildByTag:ITEM_TAG_DOUGHNUT_ICON cleanup:YES];
                //[[self parent] removeChildByTag:MINIMAP_TAG_DOUGHNUT cleanup:YES];
            }
            else if (itemsHeld[index] == TILE_SEXBOT)
            {
                [itemsKept addObject:@"Graphics/Sexbot/sexboticon"];
                [[self parent] removeChildByTag:ITEM_TAG_SEXBOT_ICON cleanup:YES];
                //[[self parent] removeChildByTag:MINIMAP_TAG_SEXBOT cleanup:YES];
            }
            else if (itemsHeld[index] == TILE_LAWYER)
            {
                [itemsKept addObject:@"Graphics/Lawyer/lawyericon"];
                [[self parent] removeChildByTag:ITEM_TAG_LAWYER_ICON cleanup:YES];
                //[[self parent] removeChildByTag:MINIMAP_TAG_LAWYER cleanup:YES];
            }
            numOfItemsKept++;
            itemsHeld[index] = 0;
        }
    }
    
    CCNode *itemsMinimapIcons = [[[self parent] getChildByTag:MINIMAP_TAG_SMOKEBOMB]autorelease];
    if (itemsMinimapIcons != nil)
    {
        [[self parent] removeChildByTag:MINIMAP_TAG_SMOKEBOMB cleanup:NO];
    }
    itemsMinimapIcons = [[[self parent] getChildByTag:MINIMAP_TAG_SEXBOT]autorelease];
    if (itemsMinimapIcons != nil)
    {
        [[self parent] removeChildByTag:MINIMAP_TAG_SEXBOT cleanup:NO];
    }
    itemsMinimapIcons = [[[self parent] getChildByTag:MINIMAP_TAG_DOUGHNUT]autorelease];
    if (itemsMinimapIcons != nil)
    {
        [[self parent] removeChildByTag:MINIMAP_TAG_DOUGHNUT cleanup:NO];
    }
    itemsMinimapIcons = [[[self parent] getChildByTag:MINIMAP_TAG_LAWYER]autorelease];
    if (itemsMinimapIcons != nil)
    {
        [[self parent] removeChildByTag:MINIMAP_TAG_LAWYER cleanup:NO];
    }
    
    
    NSNumber *itemScore = [NSNumber numberWithInt:(numOfItemsKept * 100)];
    [score updateScore:[itemScore intValue]];
    NSNumber *levelScore = [NSNumber numberWithInt:[score currentLevelScore]];
   
    NSMutableDictionary *levelEndItems = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:timeBonusScore], @"TimeBonus",
                                   itemsKept, @"ItemsKept",
                                   itemScore, @"ItemScore",
                                   scoreBonus, @"Lives",
                                   levelType, @"LevelType",
                                   levelScore, @"LevelScore", nil];
    if ([levelType isEqualToString:@"RIVAL"])
    {
        if (robberGemCount > rivalGemCount)
        {
            NSNumber *rivalScore = [NSNumber numberWithInt:5000 * (level/5)];
            [score updateScore:[rivalScore intValue]];
            [levelEndItems setObject:rivalScore forKey:@"RivalScore"];
            if (level != 20)
            {
                [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/rival robber win.caf"];
            }
            
            if ([GKLocalPlayer localPlayer].isAuthenticated)
            {
                NSString *achievementString = [NSString stringWithFormat:@"grp.CnRBeatRival%i", level];
                if ([self getAchievementForIdentifier:achievementString] == nil)
                {
                    [self reportAchievementIdentifier:achievementString percentComplete:100.0];
                }
                
                if ([self getAchievementForIdentifier:@"grp.CnRBeatRivalAll"] == nil)
                {
                    if ([self getAchievementForIdentifier:@"grp.CnRBeatRival5"] && [self getAchievementForIdentifier:@"grp.CnRBeatRival10"] && [self getAchievementForIdentifier:@"grp.CnRBeatRival15"] && [self getAchievementForIdentifier:@"grp.CnRBeatRival20"])
                    {
                        //award Rival meta
                        [self reportAchievementIdentifier:@"grp.CnRBeatRivalAll" percentComplete:100.0];
                    }
                }
            }
        }
        else
        {
            [levelEndItems setObject:[NSNumber numberWithInt:0] forKey:@"RivalScore"];
            if (level != 20)
            {
                [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/rival robber lose.caf"];
            }
        
        }
    }
    
    //check if level beat without using items
    if (level < 5)
    {
        if (numOfItemsKept == 2)
        {
            levelsBeatWithoutUsingItem++;
        }
        else
        {
            levelsBeatWithoutUsingItem = 0;
        }
    }
    else if (level == 5 || level == 10 || level == 15 || level == 20)
    {
        levelsBeatWithoutUsingItem++;
    }
    else if (level > 5 && level < 10)
    {
        if (numOfItemsKept == 3)
        {
            levelsBeatWithoutUsingItem++;
        }
        else
        {
            levelsBeatWithoutUsingItem = 0;
        }

    }
    else if (level > 10 && level < 15)
    {
        if (numOfItemsKept == 4)
        {
            levelsBeatWithoutUsingItem++;
        }
        else
        {
            levelsBeatWithoutUsingItem = 0;
        }
    }
    else if (level > 15 && level < 20)
    {
        if (numOfItemsKept == 4)
        {
            levelsBeatWithoutUsingItem++;
        }
        else
        {
            levelsBeatWithoutUsingItem = 0;
        }
    }
    
    //check if level beat without losing a life
    if (!robberDied)
    {
        levelsBeatWithoutDying++;
    }
    else
    {
        levelsBeatWithoutDying = 0;
    }
    
    //check for achievements
    if ([GKLocalPlayer localPlayer].isAuthenticated)
    {
        NSMutableArray *achievements = [[NSMutableArray alloc] init];
        if (levelsBeat > 4)
        {
            //minimum of 5 levels beaten needed for achievments
            if (startingLevel == 1)
            {
                //most achievements start at level 1
                if (((startingLevel + levelsBeat) > 5)) //beat 1 - 5
                {
                    if ([self getAchievementForIdentifier:@"grp.CnRBeatFarm"] == nil)
                    {
                        GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:@"grp.CnRBeatFarm"];
                        achievement.percentComplete = 100.0;
                        [achievements addObject:achievement];
                    }
                }
                if ((startingLevel + levelsBeatWithoutDying) > 5)
                {
                    if ([self getAchievementForIdentifier:@"grp.CnRBeatFarmNoDying"] == nil)
                    {
                        GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:@"grp.CnRBeatFarmNoDying"];
                        achievement.percentComplete = 100.0;
                        [achievements addObject:achievement];
                    }
                }
                if ((startingLevel + levelsBeatWithoutUsingItem) > 5)
                {
                    if ([self getAchievementForIdentifier:@"grp.CnRBeatFarmNoItems"] == nil)
                    {
                        GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:@"grp.CnRBeatFarmNoItems"];
                        achievement.percentComplete = 100.0;
                        [achievements addObject:achievement];
                    }
                }
                if ((startingLevel + levelsBeatWithoutDying) > 10)
                {
                    if ([self getAchievementForIdentifier:@"grp.CnRUndying"] == nil)
                    {
                        GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:@"grp.CnRUndying"];
                        achievement.percentComplete = 100.0;
                        [achievements addObject:achievement];
                    }
                }
                if ((startingLevel + levelsBeatWithoutDying) > 15)
                {
                    if ([self getAchievementForIdentifier:@"grp.CnRInvincible"] == nil)
                    {
                        GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:@"grp.CnRInvincible"];
                        achievement.percentComplete = 100.0;
                        [achievements addObject:achievement];
                    }
                }
                if ((startingLevel + levelsBeatWithoutDying) > 20)
                {
                    if ([self getAchievementForIdentifier:@"grp.CnRImmortal"] == nil)
                    {
                        GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:@"grp.CnRImmortal"];
                        achievement.percentComplete = 100.0;
                        [achievements addObject:achievement];
                    }
                }
            }
            else if (startingLevel < 6)
            {
                if (((startingLevel + levelsBeat) > 10)) //beat 6 - 10
                {
                    if ([self getAchievementForIdentifier:@"grp.CnRBeatRural"] == nil)
                    {
                        GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:@"grp.CnRBeatRural"];
                        achievement.percentComplete = 100.0;
                        [achievements addObject:achievement];
                    }
                }
                if ((startingLevel + levelsBeatWithoutDying) > 10)
                {
                    if ([self getAchievementForIdentifier:@"grp.CnRBeatRuralNoDying"] == nil)
                    {
                        GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:@"grp.CnRBeatRuralNoDying"];
                        achievement.percentComplete = 100.0;
                        [achievements addObject:achievement];
                    }
                }
                if ((startingLevel + levelsBeatWithoutUsingItem) > 10)
                {
                    if ([self getAchievementForIdentifier:@"grp.CnRBeatRuralNoItems"] == nil)
                    {
                        GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:@"grp.CnRBeatRuralNoItems"];
                        achievement.percentComplete = 100.0;
                        [achievements addObject:achievement];
                    }
                }
            }
            else if (startingLevel < 11)
            {
                if (((startingLevel + levelsBeat) > 15)) //beat 11 - 15
                {
                    if ([self getAchievementForIdentifier:@"grp.CnRBeatSuburb"] == nil)
                    {
                        GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:@"grp.CnRBeatSuburb"];
                        achievement.percentComplete = 100.0;
                        [achievements addObject:achievement];
                    }
                }
                if ((startingLevel + levelsBeatWithoutDying) > 15)
                {
                    if ([self getAchievementForIdentifier:@"grp.CnRBeatSuburbNoDying"] == nil)
                    {
                        GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:@"grp.CnRBeatSuburbNoDying"];
                        achievement.percentComplete = 100.0;
                        [achievements addObject:achievement];
                    }
                }
                if ((startingLevel + levelsBeatWithoutUsingItem) > 15)
                {
                    if ([self getAchievementForIdentifier:@"grp.CnRBeatSuburblNoItems"] == nil)
                    {
                        GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:@"grp.CnRBeatSuburbNoItems"];
                        achievement.percentComplete = 100.0;
                        [achievements addObject:achievement];
                    }
                }
            }
            else if (startingLevel < 16)
            {
                if (((startingLevel + levelsBeat) > 20)) //beat 16 - 20
                {
                    if ([self getAchievementForIdentifier:@"grp.CnRBeatCity"] == nil)
                    {
                        GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:@"grp.CnRBeatCity"];
                        achievement.percentComplete = 100.0;
                        [achievements addObject:achievement];
                    }
                }
                if ((startingLevel + levelsBeatWithoutDying) > 20)
                {
                    if ([self getAchievementForIdentifier:@"grp.CnRBeatCityNoDying"] == nil)
                    {
                        GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:@"grp.CnRBeatCityNoDying"];
                        achievement.percentComplete = 100.0;
                        [achievements addObject:achievement];
                    }
                }
                if ((startingLevel + levelsBeatWithoutUsingItem) > 20)
                {
                    if ([self getAchievementForIdentifier:@"grp.CnRBeatCityNoItems"] == nil)
                    {
                        GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:@"grp.CnRBeatCityNoItems"];
                        achievement.percentComplete = 100.0;
                        [achievements addObject:achievement];
                    }
                }
            }
        }
        //did we get any achievements?
        if ([achievements count] > 0)
        {
            [GKAchievement reportAchievements: achievements withCompletionHandler:^(NSError *error)
             {
                 if (error != nil)
                 {
                     NSLog(@"Error in reporting achievements: %@", error);
                 }
             }];
            for (GKAchievement *achive in achievements)
            {
                [achievementsDictionary setObject:achive forKey:achive.identifier];
            }
        }
    }
    levelsBeat++;
    NSString * booleanString = (robberDied) ? @"YES" : @"NO";
    //NSString *copsSubduedString = [[NSString stringWithFormat:@"%d", copsSubdued]autorelease];
    //NSString *timerString = [[NSString stringWithFormat:@"%d", timerInSeconds]autorelease];
    //NSString *levelString = [[NSString stringWithFormat:@"%d",level]autorelease];
    //NSString *levelScoreString = [[NSString stringWithFormat:@"%@",levelScore]autorelease];
    NSDictionary *flurryDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:copsSubdued], @"Cops Subdued", [NSNumber numberWithInt:timerInSeconds], @"Level Time", [NSNumber numberWithInt:level], @"Level Number", booleanString, @"Died in level", levelScore, @"Level Score", nil];
    robberDied = NO;
    copsSubdued = 0;
    timerInSeconds = 0;
    //[mapGrid removeAllObjects];
    [Flurry endTimedEvent:@"Level Start" withParameters:nil];
    
    [Flurry logEvent:@"End of Level Stats" withParameters:flurryDict timed:NO];
    NSNumber *totalScore = [NSNumber numberWithInt:[score points]];
    [levelEndItems setObject:totalScore forKey:@"TotalScore"];
    if (level == 20)
    {
        levelEndDisplay = [[VictoryViewController alloc] initwithScoreData:levelEndItems];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        NSString *category;
        
        category = @"grp.CNRGLobalLeaderboad";
        
        if ([GKLocalPlayer localPlayer].isAuthenticated) {
            GKScore *scoreReporter = [[GKScore alloc] initWithCategory:category];
            scoreReporter.value = [score points];
            scoreReporter.context = 0;
            scoreReporter.shouldSetDefaultLeaderboard = YES;
            
            [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
                // Do something interesting here.
            }];
        }
    }
    else
    {
        levelEndDisplay = [[LevelEndViewController alloc] initwithScoreData:levelEndItems];
        if ([[UIScreen mainScreen] bounds].size.height == 568)
        {
            levelEndDisplay.view.frame = CGRectMake(42.0, 0, 480, 320);
        }

    }
    UIView *glView = [CCDirector sharedDirector].openGLView;
    [glView addSubview:levelEndDisplay.view];
}

-(void) cleanupLevel
{
    if ([levelType isEqual:@"RIVAL"])
    {
        [mapLayer removeChild:[rival charSprite] cleanup:YES];
        [rival unscheduleAllSelectors];
        [self removeChildByTag:5010 cleanup:YES];
        [self removeChild:robberGemCountLabel cleanup:YES];
        [self removeChild:rivalGemCountLabel cleanup:YES];
    }
    if ([copsArray count] > 0)
    {
        for (CCopBase *cop in copsArray)
        {
            [cop setCurrentState:COP_DEAD];
        }
        
        [mapLayer removeChildByTag:CHARACTER_ROOKIE cleanup:YES];
        [rookie unscheduleAllSelectors];
        [[self parent] removeChildByTag:MINIMAP_TAG_ROOKIE cleanup:YES];
        if (copsToSpawn > 1)
        {
            [mapLayer removeChildByTag:CHARACTER_FAT_COP cleanup:YES];
            [[self parent] removeChildByTag:MINIMAP_TAG_FATCOP cleanup:YES];
            //[fatCop removeFromParentAndCleanup:NO];
            [fatCop unscheduleAllSelectors];
        }
        if (copsToSpawn > 2)
        {
            [mapLayer removeChildByTag:CHARACTER_CORRUPT_COP cleanup:YES];
            [[self parent] removeChildByTag:MINIMAP_TAG_CORRUPTCOP cleanup:YES];
            //[corruptCop removeFromParentAndCleanup:NO];
            [corruptCop unscheduleAllSelectors];
        }
        if (copsToSpawn > 3)
        {
            [mapLayer removeChildByTag:CHARACTER_INSPECTOR cleanup:YES];
            [[self parent] removeChildByTag:MINIMAP_TAG_INSPECTOR cleanup:YES];
            //[inspector removeFromParentAndCleanup:NO];
            [inspector unscheduleAllSelectors];
        }
        
        
        [copsArray removeAllObjects];
        //[rookie release];
        rookie = nil;
        //[corruptCop release];
        corruptCop = nil;
        //[fatCop release];
        fatCop = nil;
        //[inspector release];
        inspector = nil;

        
    }
    //[rival release];
    rival = nil;
    
    for (int x = 2000; x < 2500; x++)
    {
        CCNode *moneyMinimap = [[self parent] getChildByTag:x];
        if (moneyMinimap != nil)
        {
            [[self parent] removeChild:moneyMinimap cleanup:YES];
        }
    }
    [[self parent]removeChildByTag:MINIMAP_TAG_ROBBER cleanup:YES];
    [[self parent]removeChildByTag:MINIMAP_TAG_BONUS cleanup:YES];
    
    
    
    
}
-(void) removeRobber
{
    [[self parent]removeChild:eyesSprite cleanup:YES];
    [mapLayer removeChild:[robber charSprite] cleanup:YES];
    //[self removeChildByTag:CHARACTER_ROBBER cleanup:NO];
    [robber unscheduleAllSelectors];
    [robber setTag:9999999];
    //[robber release];
    robber = nil;
}

-(void) startNextLevel: (NSNotification *) notification
{
    [levelEndDisplay release];
    levelEndDisplay = nil;
    level++;
    [score newLevel:level];
    [mapLayer removeAllChildrenWithCleanup:YES];
    [self loadLevel:level];
}

-(void) quitLevel:(NSNotification *)notification
{
    if (levelEndDisplay)
    {
        [levelEndDisplay release];
        levelEndDisplay = nil;
    }
    if ([score lives] > 0)
    {
        [self saveState];
    }
    [self cleanupLevel];
    [self removeRobber];
    [mapLayer removeAllChildrenWithCleanup:YES];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"quitToMainMenu" object:self];
    [[CCDirector sharedDirector] popScene];
    
}
-(void) copSickened
{
    copSickenedCount++;
    [score updateScore:100 * level * copSickenedCount];
    copsSubdued++;
}

-(void) copBlinded
{
    copBlindedCount++;
    [score updateScore:50 * level * copBlindedCount];
    copsSubdued++;
}

-(void) copScared
{
    copScaredCount++;
    [score updateScore:50 * level * copScaredCount];
    copsSubdued++;
}

-(void) copBombed
{
    copBombedCount++;
    [score updateScore:100 * level * copBombedCount];
    copsSubdued++;
}

-(void) stopLawyer
{
    lawyerActive = NO;
    [mapLayer removeChildByTag:ITEM_TAG_LAWYER cleanup:YES];
    [self unschedule:@selector(stopLawyer)];
    for (CCopBase *cop in copsArray)
    {
        if ([cop currentState] == COP_SCARED)
        {
            [cop leaveScaredState];
        }
    }
    copScaredCount = 0;
}

-(void) sexbotByeBye
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/sexbomb explode.caf"];
}
-(void) explodeSexBot
{
    sexBotActive = NO;
    sexBotPosition = [sexbot getPosition];
    [sexbot stopAllActions];
    [mapLayer removeChildByTag:CHARACTER_SEXBOT cleanup:YES];
    [sexbot removeFromParentAndCleanup:YES];
    [self scheduleOnce:@selector(stopSexBot) delay:2.0];
    for (CCopBase *cop in copsArray)
    {
        CGPoint copPosition = [cop getPosition];
        CGFloat distanceToCop = ccpDistance(sexBotPosition, copPosition);
        [cop leaveAttractedSexbotState];
        if (distanceToCop < tileSize * 3)
        {
            [cop enterDyingState];
            [self copBombed];
        }

    }
    CCSprite *explosion = [[CCSprite alloc] initWithFile:@"Graphics/Sexbot/heartexplosion.png"];
    explosion.position = sexBotPosition;
    explosion.anchorPoint = ccp(0.5,0.5);
    explosion.scale = 0.5;
    CCAction *fadeOutAction = [CCFadeOut actionWithDuration:2.0 opacity:0.1];
    CCAction *scaleAction = [CCScaleTo actionWithDuration:2.0 scale:4.0];
    [explosion runAction:fadeOutAction];
    [explosion runAction:scaleAction];
    [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/magic-explosion.caf"];
    [mapLayer addChild:explosion z:Z_CHARACTERS tag:10102];
    
}

-(void) stopSexBot
{
    //[sexbot release];
    [mapLayer removeChildByTag:10102 cleanup:YES];
}

-(void) timerUpdate
{
    timerInSeconds++;
}

//pathfinding functions
-(enum DIRECTION) findPathToRobber: (CGPoint)position
{
    
    //NSLog(@"Cops current position: %d, %d", (int)position.x, (int)position.y);
    //match cop's position to A* grid
    AStarNode *fromNode = [[AStarGrid objectAtIndex:(int)position.x] objectAtIndex:(int)position.y];
    
    //match robber's position to A* grid
    CGPoint robberPosition = [robber mapPosition];
    if (ccpDistance(position, robberPosition) < 1)
    {
        //follow robber's lead
        enum DIRECTION robberDirection = [robber getDirection];
        return robberDirection;
    }
    AStarNode *toNode = [[AStarGrid objectAtIndex:(int)robberPosition.x] objectAtIndex:(int)robberPosition.y];
    
    //call findPathFromNode with start and end nodes
    enum DIRECTION nextDirection;
    nextDirection = [self findPathFromNode:fromNode toNode:toNode];
    return nextDirection;
}

-(enum DIRECTION) findPathToDoughnut: (CGPoint)position
{
    //match cop's position to A* grid
    AStarNode *fromNode = [[AStarGrid objectAtIndex:(int)position.x] objectAtIndex:(int)position.y];
    
    //match doughnut's position to A* grid
    //convert doughnut position to map coordinates
    
    AStarNode *toNode = [[AStarGrid objectAtIndex:(int)doughnutMapPosition.x] objectAtIndex:(int)doughnutMapPosition.y];
    
    //call findPathFromNode with start and end nodes
    enum DIRECTION nextDirection;
    nextDirection = [self findPathFromNode:fromNode toNode:toNode];
    return nextDirection;
}

-(enum DIRECTION) findPathToSexbot: (CGPoint)position
{
    //match cop's position to A* grid
    AStarNode *fromNode = [[AStarGrid objectAtIndex:(int)position.x] objectAtIndex:(int)position.y];
    
    //match sexbot's position to A* grid
    //convert sexbot position to map coordinates
    sexBotPosition = [sexbot mapPosition];
    AStarNode *toNode = [[AStarGrid objectAtIndex:(int)sexBotPosition.x] objectAtIndex:(int)sexBotPosition.y];
    
    //call findPathFromNode with start and end nodes
    enum DIRECTION nextDirection;
    nextDirection = [self findPathFromNode:fromNode toNode:toNode];
    return nextDirection;
}

-(enum DIRECTION) findPathToBonus: (CGPoint)position
{
    //match cop's position to A* grid
    AStarNode *fromNode = [[AStarGrid objectAtIndex:(int)position.x] objectAtIndex:(int)position.y];
    
    //match doughnut's position to A* grid
    //convert doughnut position to map coordinates
    
    AStarNode *toNode = [[AStarGrid objectAtIndex:(int)bonusPosition.x] objectAtIndex:(int)bonusPosition.y];
    
    //call findPathFromNode with start and end nodes
    enum DIRECTION nextDirection;
    nextDirection = [self findPathFromNode:fromNode toNode:toNode];
    return nextDirection;
}

-(enum DIRECTION) findPathFromLawyer:(CGPoint)position
{
    //match cop's position to A* grid
    AStarNode *fromNode = [[AStarGrid objectAtIndex:(int)position.x] objectAtIndex:(int)position.y];
    
    //find a valid road tile on opposite side from lawyer
    //NOTE: this only works if there is another valid location to run to in the same row as the lawyer
    int tileXPosition = 0;
    if (lawyerMapPosition.x < 12)
    {
        BOOL validTile = NO;
        int xPosition = 23;
        while (!validTile)
        {
            
            enum TILE_TYPE tile = [[[mapGrid objectAtIndex:lawyerMapPosition.y]objectAtIndex:xPosition]intValue];
            if ( tile == TILE_ROAD || tile == TILE_BONUS || tile == TILE_MONEY)
            {
                //found tile
                tileXPosition = xPosition;
                validTile = YES;
            }
            xPosition--;
        }
    }
    else
    {
        BOOL validTile = NO;
        int xPosition = 0;
        while (!validTile)
        {
            
            enum TILE_TYPE tile = [[[mapGrid objectAtIndex:lawyerMapPosition.y]objectAtIndex:xPosition]intValue];
            if ( tile == TILE_ROAD || tile == TILE_BONUS || tile == TILE_MONEY)
            {
                //found tile
                tileXPosition = xPosition;
                validTile = YES;
            }
            xPosition++;
        }
    }

    //match lawyer's position to A* grid
    //convert lawyer position to map coordinates
    
    AStarNode *toNode = [[AStarGrid objectAtIndex:tileXPosition] objectAtIndex:(int)lawyerMapPosition.y];
    
    //call findPathFromNode with start and end nodes
    enum DIRECTION nextDirection;
    nextDirection = [self findPathFromNode:fromNode toNode:toNode];
    
    return nextDirection;
}

-(enum DIRECTION) findPathToHome:(CGPoint)position
{
    AStarNode *fromNode = [[AStarGrid objectAtIndex:(int)position.x] objectAtIndex:(int)position.y];
    AStarNode *toNode = [[AStarGrid objectAtIndex:(int)copStart.x] objectAtIndex:(int)copStart.y];
    enum DIRECTION nextDirection;
    nextDirection = [self findPathFromNode:fromNode toNode:toNode];
    return nextDirection;
}

-(enum DIRECTION) findPathFromNode: (AStarNode *)fromNode toNode: (AStarNode *) toNode
{
    NSMutableArray *foundPath = [[NSMutableArray alloc] init];
    if (foundPath)
    {
        [foundPath removeAllObjects];
        //[foundPath release];
    }
    //foundPath = nil;
    foundPath = [AStarPathNode findPathFrom:fromNode to:toNode];
    if (!foundPath)
    {
        NSLog(@"Could not find a path!");
        //NSLog(@"Start Node: %d, %d End Node %d, %d", (int)fromNode.position.x, (int)fromNode.position.y, (int)toNode.position.x, (int)toNode.position.y);
        BOOL canMove = NO;
        enum DIRECTION tempDirection;
        CGPoint mapPosition = [fromNode position];
        while (!canMove)
        {
            int randomDirection = arc4random_uniform(4);
            tempDirection = randomDirection;
            
            if (tempDirection == DIR_LEFT)
            {
                if ([self verifyMove:mapPosition.x -1 :mapPosition.y])
                {
                    canMove = YES;
                }
            }
            else if (tempDirection == DIR_RIGHT)
            {
                if ([self verifyMove:mapPosition.x + 1 :mapPosition.y])
                {
                    canMove = YES;
                }
            }
            else if (tempDirection == DIR_UP)
            {
                if ([self verifyMove:mapPosition.x :mapPosition.y + 1])
                {
                    canMove = YES;
                }
            }
            else if (tempDirection == DIR_DOWN)
            {
                if ([self verifyMove:mapPosition.x :mapPosition.y - 1])
                {
                    canMove = YES;
                }
            }
            
        }
        return tempDirection;

    }
    else
    {
        CGPoint firstPoint = [[foundPath objectAtIndex:[foundPath count] - 1] CGPointValue];
        CGPoint secondPoint = [[foundPath objectAtIndex:[foundPath count] - 2] CGPointValue];
        //NSLog(@"values from foundPath: firstpoint %d, %d; second point %d, %d", (int)firstPoint.x, (int)firstPoint.y, (int)secondPoint.x, (int)secondPoint.y);
        if (firstPoint.x < secondPoint.x)
        {
            return DIR_RIGHT;
        }
        else if (firstPoint.x > secondPoint.x)
        {
            return DIR_LEFT;
        }
        else if (firstPoint.y < secondPoint.y)
        {
            return DIR_UP;
        }
        else if (firstPoint.y > secondPoint.y)
        {
            return DIR_DOWN;
        }
        else
        {
            NSLog(@"Compare of first two nodes in foundPath isn't working.");
            return DIR_LEFT;
        }
        
    }
}

-(enum DIRECTION)findNearestGem:(CGPoint)rivalPosition
{
    int searchPositionX = rivalPosition.x;
    int searchPositionY = rivalPosition.y;
    int searchRadius = 1;
    BOOL foundGem = NO;
    
    while (!foundGem)
    {
        NSMutableArray *randomArray = [[NSMutableArray alloc] initWithObjects:@"searchUp:searchX:searchY:", @"searchDown:searchX:searchY:", @"searchLeft:searchX:searchY:", @"searchRight:searchX:searchY:", nil];
        for (int i = 0; i < [randomArray count]; i++)
        {
            int rand = arc4random_uniform([randomArray count]);
            [randomArray exchangeObjectAtIndex:i withObjectAtIndex:rand];
            
        }
        for (int i = 0; i < [randomArray count]; i++)
        {
            NSString *selectorName = [randomArray objectAtIndex:i];
            if ([selectorName isEqualToString:@"searchUp:searchX:searchY:"])
            {
                foundGem = [self searchUp:searchRadius searchX:&searchPositionX searchY:&searchPositionY];
            }
            else if ([selectorName isEqualToString:@"searchDown:searchX:searchY:"])
            {
                foundGem = [self searchDown:searchRadius searchX:&searchPositionX searchY:&searchPositionY];
            }
            else if ([selectorName isEqualToString:@"searchLeft:searchX:searchY:"])
            {
                foundGem = [self searchLeft:searchRadius searchX:&searchPositionX searchY:&searchPositionY];
            }
            else if ([selectorName isEqualToString:@"searchRight:searchX:searchY:"])
            {
                foundGem = [self searchRight:searchRadius searchX:&searchPositionX searchY:&searchPositionY];
            }
            if (foundGem)
            {
                break;
            }
        }
        if (foundGem)
        {
            break;
        }
        //didn't find anything; increase radius of search
        searchRadius++;
        [randomArray removeAllObjects];
        [randomArray release];
    }

    
    AStarNode *fromNode = [[AStarGrid objectAtIndex:rivalPosition.x] objectAtIndex:rivalPosition.y];
    AStarNode *toNode = [[AStarGrid objectAtIndex:searchPositionX] objectAtIndex:searchPositionY];
    NSLog(@"Start Node: %d, %d End Node %d, %d", (int)fromNode.position.x, (int)fromNode.position.y, (int)toNode.position.x, (int)toNode.position.y);
    enum DIRECTION direction = [self findPathFromNode:fromNode toNode:toNode];
    return direction;
}

-(BOOL) searchUp:(int)searchRadius searchX:(int *)searchPositionX searchY:(int *)searchPositionY
{
    int searchX = *searchPositionX;
    int searchY = *searchPositionY;
    int x,y;
    BOOL foundGem = NO;
    y = searchY + searchRadius;
    if (y < [mapGrid count])
    {
        for (x = searchX - searchRadius; x <= searchX + searchRadius; x++)
        {
            if (x >= 0 && x < 24)
            {
                int value = [[[mapGrid objectAtIndex:y] objectAtIndex:x] intValue];
                if (value == TILE_BONUS || value == TILE_MONEY)
                {
                    foundGem = YES;
                    *searchPositionX = x;
                    *searchPositionY = y;
                    break;
                }
                
            }
        }
    }
    return foundGem;
}

-(BOOL) searchDown:(int)searchRadius searchX:(int *)searchPositionX searchY:(int *)searchPositionY
{
    BOOL foundGem = NO;
    int searchX = *searchPositionX;
    int searchY = *searchPositionY;
    int y = searchY - searchRadius;
    if (y >= 0)
    {
        for (int x = searchX - searchRadius; x <= searchX + searchRadius; x++)
        {
            if (x >= 0 && x < 24)
            {
                int value = [[[mapGrid objectAtIndex:y] objectAtIndex:x] intValue];
                if (value == TILE_BONUS || value == TILE_MONEY)
                {
                    foundGem = YES;
                    *searchPositionX = x;
                    *searchPositionY = y;
                    break;
                }
                
            }
        }
    }
    return foundGem;
}

-(BOOL) searchLeft:(int)searchRadius searchX:(int *)searchPositionX searchY:(int *)searchPositionY
{
    BOOL foundGem = NO;
    int searchX = *searchPositionX;
    int searchY = *searchPositionY;
    int x,y;
    x = searchX - searchRadius;
    if (x >= 0)
    {
        for (y = searchY - searchRadius; y <= searchY + searchRadius; y++)
        {
            if (y >= 0 && y < [mapGrid count])
            {
                int value = [[[mapGrid objectAtIndex:y] objectAtIndex:x] intValue];
                if (value == TILE_BONUS || value == TILE_MONEY)
                {
                    foundGem = YES;
                    *searchPositionX = x;
                    *searchPositionY = y;
                    break;
                }
            }
        }
    }
    return foundGem;
}

-(BOOL) searchRight:(int)searchRadius searchX:(int *)searchPositionX searchY:(int *)searchPositionY
{
    int x,y;
    int searchX = *searchPositionX;
    int searchY = *searchPositionY;
    BOOL foundGem = NO;
    x = searchX + searchRadius;
    if (x < 24) //maps are 24 wide
    {
        for (y = searchY - searchRadius; y <= searchY + searchRadius; y++)
        {
            if (y >= 0 && y < [mapGrid count])
            {
                int value = [[[mapGrid objectAtIndex:y] objectAtIndex:x] intValue];
                if (value == TILE_BONUS || value == TILE_MONEY)
                {
                    foundGem = YES;
                    *searchPositionX = x;
                    *searchPositionY = y;
                    break;
                }
            }
        }
    }
    return foundGem;
}

-(void) moveMap:(CGFloat)distance
{
    mapLayer.position = ccp(mapXOffset,(mapLayer.position.y - distance));
    if (mapLayer.position.y > mapYOffset)
    {
        mapLayer.position = ccp(mapLayer.position.x, mapYOffset);
    }
    else if (mapLayer.position.y < mapYOffset - ((mapHeight - 16) * tileSize))
    {
        mapLayer.position = ccp(mapLayer.position.x, mapYOffset - ((mapHeight - 16) * tileSize));
    }
    NSLog(@"Map Y position: %f", mapLayer.position.y);
}

-(void) resetMapPosition
{
    if ((mapHeight > 16))
    {
        //adjust map to center on robber
        int yPosition;
        if (((mapHeight - 9) < robberStart.y))
        {
            yPosition = (mapHeight - 16) * tileSize;
        }
        else
        {
            yPosition = (robberStart.y - 7) * tileSize;
        }
        
        mapLayer.position = ccp(mapLayer.position.x, (mapYOffset - yPosition));
        if (mapLayer.position.y > mapYOffset)
        {
            mapLayer.position = ccp(mapLayer.position.x, mapYOffset);
        }
        else if (mapLayer.position.y < -((mapHeight - 16) * tileSize))
        {
            mapLayer.position = ccp(mapLayer.position.x, mapYOffset - ((mapHeight - 16) * tileSize));
        }
    }
    else
    {
        mapLayer.position = ccp(mapXOffset, mapYOffset);
    }

}

-(void) startRivalLevelRunning
{
    [self removeChildByTag:10102 cleanup:YES];
    [self removeChildByTag:10101 cleanup:YES];
    [robber leavePausedState];
    [rival leavePausedState];
}

-(void) saveState
{
    [[NSUserDefaults standardUserDefaults] setInteger:stepsTaken forKey:@"StepsTaken"];
    if ([score lives] > 0)
    {
        NSString *category;
        
        category = @"grp.CNRGLobalLeaderboad";
        
        if ([GKLocalPlayer localPlayer].isAuthenticated) {
            GKScore *scoreReporter = [[GKScore alloc] initWithCategory:category];
            scoreReporter.value = [score points];
            scoreReporter.context = 0;
            scoreReporter.shouldSetDefaultLeaderboard = YES;
            
            [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
                // Do something interesting here.
            }];
        }

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectoryPath = [paths objectAtIndex:0];
        NSMutableDictionary *saveData = [[NSMutableDictionary alloc] init];
        
        [saveData setValue:[NSNumber numberWithInt:levelState] forKey:@"LevelState"];
        [saveData setValue:[NSNumber numberWithInt:level] forKey:@"Level"];
        [saveData setValue:[NSNumber numberWithInt:startingLevel] forKey:@"StartingLevel"];
        [saveData setValue:[NSNumber numberWithInt:levelsBeat] forKey:@"LevelsBeat"];
        [saveData setValue:[NSNumber numberWithInt:levelsBeatWithoutUsingItem] forKey:@"LevelsBeatWithoutUsingItem"];
        [saveData setValue:[NSNumber numberWithInt:levelsBeatWithoutDying] forKey:@"LevelsBeatWithoutDying"];
        [saveData setValue:mapGrid forKey:@"MapGrid"];
        [saveData setValue:[NSNumber numberWithBool:smokeBombActive] forKey:@"SmokeBombActive"];
        [saveData setValue:NSStringFromCGPoint(smokeBombPosition) forKey:@"SmokeBombPosition"];
        [saveData setValue:[NSNumber numberWithBool:doughnutActive] forKey:@"DoughnutActive"];
        [saveData setValue:NSStringFromCGPoint(doughnutMapPosition) forKey:@"DoughnutMapPosition"];
        [saveData setValue:NSStringFromCGPoint(doughtnutPosition) forKey:@"DoughnutPosition"];
        [saveData setValue:[NSNumber numberWithBool:sexBotActive] forKey:@"SexBotActive"];
        if (sexBotActive)
        {
            [saveData setValue:NSStringFromCGPoint([sexbot mapPosition]) forKey:@"SexBotMapPosition"];
            [saveData setValue:NSStringFromCGPoint([sexbot getPosition]) forKey:@"SexBotPosition"];
        }
        [saveData setValue:[NSNumber numberWithBool:lawyerActive] forKey:@"LawyerActive"];
        [saveData setValue:NSStringFromCGPoint(lawyerMapPosition) forKey:@"LawyerMapPosition"];
        [saveData setValue:NSStringFromCGPoint(lawyerPosition) forKey:@"LawyerPosition"];
        [saveData setValue:[NSNumber numberWithInt:coinsToPickup] forKey:@"CoinsToPickup"];
        [saveData setValue:NSStringFromCGPoint(mapLayer.position) forKey:@"MapLayerPosition"];
        NSMutableArray *itemsHeldArray = [[NSMutableArray alloc] initWithCapacity:4];
        for (int x = 0; x < 4; x++)
        {
            [itemsHeldArray addObject:[NSNumber numberWithInt:itemsHeld[x]]];
        }
        [saveData setValue:itemsHeldArray forKey:@"ItemsHeld"];
        
        CCNode *bonusSprite = [[self parent] getChildByTag:ITEM_TAG_BONUS];
        if (bonusSprite.visible)
        {
            [saveData setValue:YES forKey:@"BonusVisible"];
        }
        else
        {
            [saveData setValue:NO forKey:@"BonusVisible"];
        }
        if ([copsArray count] > 0)
        {
            for (CCopBase *cop in copsArray)
            {
                [cop saveState: saveData];
            }
        }
        
        
        [saveData setValue:[NSNumber numberWithInt:copBlindedCount] forKey:@"CopBlindedCount"];
        [saveData setValue:[NSNumber numberWithInt:copSickenedCount] forKey:@"CopSickenedCount"];
        [saveData setValue:[NSNumber numberWithInt:copScaredCount] forKey:@"CopScaredCount"];
        [saveData setValue:[NSNumber numberWithInt:copBombedCount] forKey:@"CopBombedCount"];
        [saveData setValue:[NSNumber numberWithBool:deadCops] forKey:@"DeadCops"];
        [saveData setValue:[NSNumber numberWithInt:timerInSeconds] forKey:@"TimerInSeconds"];
        [saveData setValue:[NSNumber numberWithInt:stepsTaken] forKey:@"StepsTaken"];
        [saveData setValue:[NSNumber numberWithInt:copsSpawned] forKey:@"CopsSpawned"];
        [saveData setValue:[NSNumber numberWithInt:copsToSpawn] forKey:@"CopsToSpawn"];
        
        if ([levelType isEqualToString:@"RIVAL"])
        {
            [saveData setValue:[NSNumber numberWithInt:rivalGemCount] forKey:@"RivalGemCount"];
            [saveData setValue:[NSNumber numberWithInt:robberGemCount] forKey:@"RobberGemCount"];
            if (rival)
            {
                [rival saveState: saveData];
            }
        
        }
        
        [robber saveState: saveData];
        [saveData setValue:[NSNumber numberWithBool:robberDied] forKey:@"RobberDied"];
        [score saveState: saveData];

        [saveData writeToFile:[documentsDirectoryPath stringByAppendingPathComponent:@"/savestate.plist"] atomically:YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SaveExists"];
    }
        
}

-(enum ROBBER_STATE)getRobberState
{
    return [robber currentState];
}

-(void) dealloc
{
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LevelCompleteButton" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"QuitButton" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RestartLevelPressed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ResetLives" object:nil];
}

-(void) resetLevel: (NSNotification *)notification
{
    [self cleanupLevel];
    [self removeRobber];
    [score resetScore];
    [mapLayer removeAllChildrenWithCleanup:YES];
    
    [[CCDirector sharedDirector] resume];
    [self loadLevel:level];
}

-(void) moveEyesUp
{
    CCTexture2D *newTexture;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        newTexture = [[CCTextureCache sharedTextureCache] addImage:@"eyesup.png"];
    }
    else
    {
        newTexture = [[CCTextureCache sharedTextureCache] addImage:@"eyesup-ipad.png"];
    }
    [eyesSprite setTexture:newTexture];
}

-(void) moveEyesDown
{
    CCTexture2D *newTexture;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        newTexture = [[CCTextureCache sharedTextureCache] addImage:@"eyesdown.png"];
    }
    else
    {
        newTexture = [[CCTextureCache sharedTextureCache] addImage:@"eyesdown-ipad.png"];
    }
    [eyesSprite setTexture:newTexture];
}

-(void) moveEyesLeft
{
    CCTexture2D *newTexture;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        newTexture = [[CCTextureCache sharedTextureCache] addImage:@"eyesleft.png"];
    }
    else
    {
        newTexture = [[CCTextureCache sharedTextureCache] addImage:@"eyesleft-ipad.png"];
    }
    [eyesSprite setTexture:newTexture];
}

-(void) moveEyesRight
{
    CCTexture2D *newTexture;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        newTexture = [[CCTextureCache sharedTextureCache] addImage:@"eyesright.png"];
    }
    else
    {
        newTexture = [[CCTextureCache sharedTextureCache] addImage:@"eyesright-ipad.png"];
    }
    [eyesSprite setTexture:newTexture];
}

-(void) moveEyesMoney
{
    CCTexture2D *newTexture;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        newTexture = [[CCTextureCache sharedTextureCache] addImage:@"eyesmoney.png"];
    }
    else
    {
        newTexture = [[CCTextureCache sharedTextureCache] addImage:@"eyesmoney-ipad.png"];
    }
    [eyesSprite setTexture:newTexture];
}

-(void) moveEyesReturn
{
    enum DIRECTION currentDirection = [robber getDirection];
    switch (currentDirection)
    {
        case DIR_DOWN:
            [self moveEyesDown];
            break;
        case DIR_LEFT:
            [self moveEyesLeft];
            break;
        case DIR_RIGHT:
            [self moveEyesRight];
            break;
        case DIR_UP:
            [self moveEyesUp];
            break;
        default:
            [self moveEyesDown];
            break;
    }
}

-(void) resetLives:(NSNotification *)notification
{
    [score resetLives];
    [[CCDirector sharedDirector] resume];
    [robber resetRobber];
    [score updateLives:1]; //reset robber removes a life
}

- (GKAchievement*) getAchievementForIdentifier: (NSString*) identifier
{
    GKAchievement *achievement = [achievementsDictionary objectForKey:identifier];
    if (achievement == nil)
    {
        return nil;
    }
    return achievement;
}

- (void) reportAchievementIdentifier: (NSString*) identifier percentComplete: (float) percent
{
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier: identifier];
    if (achievement)
    {
        achievement.percentComplete = percent;
        achievement.showsCompletionBanner = YES;
        [achievement reportAchievementWithCompletionHandler:^(NSError *error)
         {
             if (error != nil)
             {
                 NSLog(@"Error in reporting achievements: %@", error);
             }
         }];
    }
    if ([achievementsDictionary objectForKey:identifier] == nil)
    {
        [achievementsDictionary setObject:achievement forKey:identifier];
    }
}

- (void) resetAchievements
{
    // Clear all locally saved achievement objects.
    achievementsDictionary = [[NSMutableDictionary alloc] init];
    // Clear all progress saved on Game Center
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
     {
         if (error != nil)
             // handle errors
             NSLog(@"Error in reporting achievements: %@", error);
             }];
}
@end
