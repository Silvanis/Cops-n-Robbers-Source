//
//  CScore.m
//  CopsnRobbersTest
//
//  Created by John Markle on 10/4/12.
//  Copyright 2012 Silver Moonfire LLC. All rights reserved.
//

#import "CScore.h"
#import "CLevel.h"
#import "GameOverViewController.h"

@implementation CScore
@synthesize points, lives, level, currentLevelScore;

- (id) initWithParentNode:(CCNode *)parentNode
{
    if (self = [super init])
    {
        [parentNode addChild:self];
        points = 0;
        lives = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Lives"]intValue];

        if (lives < 3)
        {
            lives = 3;
            [[NSUserDefaults standardUserDefaults] setInteger:lives forKey:@"Lives"];
        }
        level = [(CLevel*)parentNode level];
        
        CGFloat fontSize;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            fontSize = 18.0;
        }
        else // (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            fontSize = 36.0;
        }
        NSString *levelText = [NSString stringWithFormat:@"%02d", level];
        NSString *livesText = [NSString stringWithFormat:@"%02d", lives];
        levelLabel = [CCLabelTTF labelWithString:levelText fontName:@"Brush StrokeFast" fontSize:fontSize];
        pointsLabel = [CCLabelTTF labelWithString:@"000000" fontName:@"Brush StrokeFast" fontSize:fontSize];
        livesLabel = [CCLabelTTF labelWithString:livesText fontName:@"Brush StrokeFast" fontSize:fontSize];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            levelLabel.position = ccp(70, 310);
            pointsLabel.position = ccp(50, 160);
            livesLabel.position = ccp(50,125);
        }
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            levelLabel.position = ccp(140, 745);
            pointsLabel.position = ccp(90, 438);
            livesLabel.position = ccp(90, 328);
        }
        
        
        [[parentNode parent] addChild:levelLabel z:Z_TEXT];

        [[parentNode parent] addChild:pointsLabel z:Z_TEXT];
        [[parentNode parent]addChild:livesLabel z:Z_TEXT];
        [self setTag:1500];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"HighScore"] == nil)
        {
            [[NSUserDefaults standardUserDefaults] setInteger:10000 forKey:@"HighScore"];
            highScore = 10000;
        }
        else
        {
            highScore = [[[NSUserDefaults standardUserDefaults] objectForKey:@"HighScore"]intValue];
        }
    }
    return self;
}

-(id) initWithSaveState: (NSMutableDictionary *) saveData parentNode: (CCNode *)parentNode
{
    if (self = [super init])
    {
        NSMutableDictionary *scoreData = [saveData objectForKey:@"ScoreDict"];
        [parentNode addChild:self];
        points = [[scoreData objectForKey:@"Points"]intValue];
        lives = [[scoreData objectForKey:@"Lives"]intValue];
        level = [(CLevel*)parentNode level];
        
        CGFloat fontSize;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            fontSize = 18.0;
        }
        else // (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            fontSize = 36.0;
        }
        NSString *levelText = [NSString stringWithFormat:@"%02d", level];
        NSString *livesText = [NSString stringWithFormat:@"%02d", lives];
        NSString *score = [NSString stringWithFormat:@"%06d", points];
        levelLabel = [CCLabelTTF labelWithString:levelText fontName:@"Brush StrokeFast" fontSize:fontSize];
        pointsLabel = [CCLabelTTF labelWithString:score fontName:@"Brush StrokeFast" fontSize:fontSize];
        livesLabel = [CCLabelTTF labelWithString:livesText fontName:@"Brush StrokeFast" fontSize:fontSize];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            levelLabel.position = ccp(70, 310);
            pointsLabel.position = ccp(50, 160);
            livesLabel.position = ccp(50,125);
        }
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            levelLabel.position = ccp(140, 745);
            pointsLabel.position = ccp(90, 438);
            livesLabel.position = ccp(90, 328);
        }
        
        
        [[parentNode parent] addChild:levelLabel z:Z_TEXT];
        [[parentNode parent] addChild:pointsLabel z:Z_TEXT];
        [[parentNode parent]addChild:livesLabel z:Z_TEXT];
        [self setTag:1500];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"HighScore"] == nil)
        {
            [[NSUserDefaults standardUserDefaults] setInteger:10000 forKey:@"HighScore"];
            highScore = 10000;
        }
        else
        {
            highScore = [[[NSUserDefaults standardUserDefaults] objectForKey:@"HighScore"]intValue];
        }
    }
    return self;
}

+(id) scoreWithParentNode:(CCNode *)parentNode
{
    return [[[self alloc] initWithParentNode:parentNode] autorelease];
}

+(id) scoreWithSaveState:(NSMutableDictionary *)saveData parentNode:(CCNode *)parentNode
{
    return [[[self alloc] initWithSaveState:saveData parentNode:parentNode] autorelease];
}

-(void)updateScore:(int)addToScore
{
    points = points + addToScore;
    if (points > highScore)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:points forKey:@"HighScore"];
        highScore = points;
        pointsLabel.color = ccc3(0, 255, 0);
    }
    NSString *score = [NSString stringWithFormat:@"%06d", points];
    [pointsLabel setString:score];
    currentLevelScore = currentLevelScore + addToScore;
}

-(void)newLevel:(int)newLevel
{
    currentLevelScore = 0;
    level = newLevel;
    NSString *levelText = [NSString stringWithFormat:@"%02d", level];
    [levelLabel setString:levelText];
}

-(void)updateLives:(int)newLives
{
    lives = lives + newLives;
    NSString *livesText = [NSString stringWithFormat:@"%02d", lives];
    [livesLabel setString:livesText];
    [[NSUserDefaults standardUserDefaults] setInteger:lives forKey:@"Lives"];
    if (lives < 1)
    {
        //game over
        [[CCDirector sharedDirector] pause];
        
        livesText = @"00";
        [livesLabel setString:livesText];
        
        GameOverViewController *levelEndDisplay = [[GameOverViewController alloc] initWithScoreData:points];
        if ([[UIScreen mainScreen] bounds].size.height == 568)
        {
            levelEndDisplay.view.frame = CGRectMake(42.0, 0, 480, 320);
        }
        UIView *glView = [CCDirector sharedDirector].openGLView;
        [glView addSubview:levelEndDisplay.view];
        //[levelEndDisplay release];
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"Lives"]intValue] > 1)
        {
            //resume game
            [self resetLives];
            [[CCDirector sharedDirector] resume];
            
        }
    }
}

-(void) saveState: (NSMutableDictionary *)saveData
{
    NSMutableDictionary *scoreDict = [[NSMutableDictionary alloc]init];
    [scoreDict setValue:[NSNumber numberWithInt:points] forKey:@"Points"];
    [scoreDict setValue:[NSNumber numberWithInt:lives] forKey:@"Lives"];
    [saveData setValue:scoreDict forKey:@"ScoreDict"];
    [scoreDict release];
}

-(void) resetScore
{
    points = 0;
    lives = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Lives"]intValue];
    if (lives < 3)
    {
        lives = 3;
        [[NSUserDefaults standardUserDefaults] setInteger:lives forKey:@"Lives"];
    }
    pointsLabel.color = ccc3(255, 255, 255);
    [pointsLabel setString:[NSString stringWithFormat:@"%06d", points]];
    NSString *livesText = [NSString stringWithFormat:@"%02d", lives];
    [livesLabel setString:livesText];
}

-(void) resetLives
{
    lives = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Lives"]intValue];
    NSString *livesText = [NSString stringWithFormat:@"%02d", lives];
    [livesLabel setString:livesText];
}
@end
