//
//  CSexBot.m
//  Cops 'n Robbers
//
//  Created by John Markle on 5/27/13.
//  Copyright 2013 Silver Moonfire LLC. All rights reserved.
//

#import "CSexBot.h"
#import "CCAnimationHelper.h"
#import "CLevel.h"

@implementation CSexBot
@synthesize currentState;

- (id) initWithParentNode:(CCNode *)parentNode
{
    if (self = [super init])
    {
        [super initWithParentNode:parentNode];
        [parentNode addChild:self];
        charSprite = [CCSprite spriteWithFile:@"Graphics/Sexbot/sexbombfront.png"];
        CCAnimation *sexbotFrontAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Sexbot/sexbombfront"];
        CCAnimation *sexbotRearAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Sexbot/sexbombrear"];
        CCAnimation *sexbotRightAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Sexbot/sexbombright"];
        CCAnimation *sexbotLeftAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Sexbot/sexbombleft"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:sexbotFrontAnim name:@"SexbotFront"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:sexbotRearAnim name:@"SexbotRear"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:sexbotRightAnim name:@"SexbotRight"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:sexbotLeftAnim name:@"SexbotLeft"];
        gridPosition = [levelPtr sexbotStart];
        mapPosition = [levelPtr sexbotStart];
        velocity = tileSize * 2;
        currentVelocity = velocity;
        distanceToNextTile = 0.0;
        charSprite.anchorPoint = ccp(0.25,0);
        charSprite.position = ccp(((gridPosition.x * tileSize)), (gridPosition.y * tileSize));
        currentDirection = DIR_DOWN;
        nextDirection = DIR_DOWN;
        [[levelPtr mapLayer] addChild:charSprite z:Z_CHARACTERS tag:CHARACTER_SEXBOT];
        [self setTag:CHARACTER_SEXBOT];
        CCAnimate *anim = [CCAnimate actionWithAnimation:sexbotFrontAnim];
        CCRepeatForever *repeat = [CCRepeatForever actionWithAction:anim];
        [charSprite runAction:repeat];
        repeat.tag = 2012;
        turnedAround = NO;
        currentState = SEXBOT_LOADING;
    }
    
    return self;
}

+(id) sexbotWithParentNode:(CCNode *)parentNode
{
    return [[[self alloc] initWithParentNode:parentNode] autorelease];
}

-(void) update:(ccTime)time
{
    if (currentState == SEXBOT_LOADING)
    {
        currentState = SEXBOT_ALIVE;
        return;
    }
    [super update:time];
}

-(void) turnSprite:(enum DIRECTION)direction
{
    //stop current animation
    [charSprite stopAllActions];
    CCAnimation *anim;
    if (direction == DIR_LEFT)
    {
        anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"SexbotLeft"];
        
    }
    else if (direction == DIR_RIGHT)
    {
        anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"SexbotRight"];
    }
    else if (direction == DIR_UP)
    {
        anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"SexbotRear"];
    }
    else // (direction == DIR_DOWN)
    {
        anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"SexbotFront"];
    }
    CCAnimate *animAction = [CCAnimate actionWithAnimation:anim];
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:animAction];
    [charSprite runAction:repeat];
}

- (void)determineNextMove
{
    if ([self checkIfCanTurn])
    {
        BOOL canMove = NO;
        enum DIRECTION tempDirection;
        
        while (!canMove)
        {
            int randomDirection = arc4random_uniform(4);
            tempDirection = randomDirection;
            
            if ((tempDirection == DIR_LEFT) && (currentDirection != DIR_RIGHT))
            {
                if ([levelPtr verifyMove:mapPosition.x -1 :mapPosition.y])
                {
                    canMove = YES;
                }
            }
            else if ((tempDirection == DIR_RIGHT) && (currentDirection != DIR_LEFT))
            {
                if ([levelPtr verifyMove:mapPosition.x + 1 :mapPosition.y])
                {
                    canMove = YES;
                }
            }
            else if ((tempDirection == DIR_UP) && (currentDirection != DIR_DOWN))
            {
                if ([levelPtr verifyMove:mapPosition.x :mapPosition.y + 1])
                {
                    canMove = YES;
                }
            }
            else if ((tempDirection == DIR_DOWN) && (currentDirection != DIR_UP))
            {
                if ([levelPtr verifyMove:mapPosition.x :mapPosition.y - 1])
                {
                    canMove = YES;
                }
            }
            
        }
        
        nextDirection = tempDirection;
    }
    else
    {
        nextDirection = currentDirection;
    }
    
    
    if (currentDirection != nextDirection)
    {
        [self turnSprite:nextDirection];
    }
    currentDirection = nextDirection;
    return;
}
@end
