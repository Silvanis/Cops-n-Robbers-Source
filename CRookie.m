//
//  CRookie.m
//  CopsnRobbersTest
//
//  Created by John Markle on 9/12/12.
//  Copyright 2012 Silver Moonfire LLC. All rights reserved.
//

#import "CRookie.h"
#import <stdlib.h>
#import "CLevel.h"
#import "CCAnimationHelper.h"
#import "SimpleAudioEngine.h"

@implementation CRookie

-(id)initWithParentNode:(CCNode *)parentNode
{
    if (self = [super init])
    {
        [super initWithParentNode:parentNode];
        [parentNode addChild:self];
        charSprite = [CCSprite spriteWithFile:@"Graphics/Rookie/rookiefront.png"];
        CCAnimation *frontAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Rookie/rookiefront"];
        CCAnimation *rearAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Rookie/rookierear"];
        CCAnimation *rightAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Rookie/rookieright"];
        CCAnimation *leftAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Rookie/rookieleft"];
        CCAnimation *sickAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Rookie/rookiesick"];
        CCAnimation *deadAnim = [CCAnimation animationWithFile:@"Graphics/Rookie/rookiedead"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:frontAnim name:@"RookieFront"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rearAnim name:@"RookieRear"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rightAnim name:@"RookieRight"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:leftAnim name:@"RookieLeft"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:sickAnim name:@"RookieSick"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:deadAnim name:@"RookieDead"];
        charSprite.anchorPoint = ccp(0.25,0);
        charSprite.position = ccp(((gridPosition.x * tileSize)), (gridPosition.y * tileSize));
        currentDirection = DIR_DOWN;
        nextDirection = DIR_LEFT;
        thresholdAI = 30;
        sightThreshold = 4;
        chaseStepsThreshold = 4;
        [[levelPtr mapLayer] addChild:charSprite z:Z_CHARACTERS tag:CHARACTER_ROOKIE];
        CCAnimate *anim = [CCAnimate actionWithAnimation:frontAnim];
        CCRepeatForever *repeat = [CCRepeatForever actionWithAction:anim];
        [charSprite runAction:repeat];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            velocity = 24;
            chaseVelocity = 28;
        }
        else
        {
            velocity = 48;
            chaseVelocity = 56;
        }
        //velocity = (tileSize * 2) - (tileSize / 4); // 28 on iPhone, 56 on iPad
        //chaseVelocity = (tileSize * 2) - (tileSize / 8); //30 on iPhone, 60 on iPad
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sound/Sound Effects/rookie victory.caf"];
    }
    
    return self;
}

-(id)initWithSaveState:(NSMutableDictionary *)saveData parentNode:(CCNode *)parentNode
{
    if (self = [super init])
    {
        [super initWithParentNode:parentNode];
        NSMutableDictionary *rookieData = [saveData objectForKey:@"RookieData"];
        [parentNode addChild:self];
        charSprite = [CCSprite spriteWithFile:@"Graphics/Rookie/rookiefront.png"];
        CCAnimation *frontAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Rookie/rookiefront"];
        CCAnimation *rearAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Rookie/rookierear"];
        CCAnimation *rightAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Rookie/rookieright"];
        CCAnimation *leftAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Rookie/rookieleft"];
        CCAnimation *sickAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Rookie/rookiesick"];
        CCAnimation *deadAnim = [CCAnimation animationWithFile:@"Graphics/Rookie/rookiedead"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:frontAnim name:@"RookieFront"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rearAnim name:@"RookieRear"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rightAnim name:@"RookieRight"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:leftAnim name:@"RookieLeft"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:sickAnim name:@"RookieSick"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:deadAnim name:@"RookieDead"];
        charSprite.anchorPoint = ccp(0.25,0);
        charSprite.position = CGPointFromString([rookieData objectForKey:@"SpritePosition"]);
        mapPosition = CGPointFromString([rookieData objectForKey:@"MapPosition"]);
        gridPosition = CGPointFromString([rookieData objectForKey:@"MapPosition"]);
        currentDirection = [[rookieData objectForKey:@"CurrentDirection"]intValue];
        nextDirection = [[rookieData objectForKey:@"NextDirection"]intValue];
        thresholdAI = 30;
        sightThreshold = 3;
        chaseStepsThreshold = 4;
        currentChaseSteps = [[rookieData objectForKey:@"CurrentChaseSteps"]intValue];
        [[levelPtr mapLayer] addChild:charSprite z:Z_CHARACTERS tag:CHARACTER_ROOKIE];
        [self turnSprite:currentDirection];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            velocity = 24;
            chaseVelocity = 28;
        }
        else
        {
            velocity = 48;
            chaseVelocity = 56;
        }
        //velocity = (tileSize * 2) - (tileSize / 4); // 28 on iPhone, 56 on iPad
        //chaseVelocity = (tileSize * 2) - (tileSize / 8); //30 on iPhone, 60 on iPad
        currentVelocity = velocity;
        currentState = [[rookieData objectForKey:@"CurrentState"]intValue];
        attractedItemPosition = CGPointFromString([rookieData objectForKey:@"AttractedItemPosition"]);
        
        switch (currentState)
        {
            case COP_ALIVE:
                [self enterAliveState];
                break;
            case COP_ATTACKING:
                [self resumeMoving];
                break;
            case COP_ATTRACTED_DOUGHNUT:
                [self enterAttractedDoughnutState:attractedItemPosition];
                break;
            case COP_ATTRACTED_SEXBOT:
                [self enterAttractedSexbotState:attractedItemPosition];
                break;
            case COP_BLINDED:
                [self enterBlindedState];
                break;
            case COP_CHASING:
                [self enterChasingState];
                break;
            case COP_CONFUSED:
                [self enterConfusedState];
                break;
            case COP_DEAD:
                break;
            case COP_DYING:
                [self enterDyingState];
                break;
            case COP_SCARED:
                [self enteringScaredState:attractedItemPosition];
                break;
            case COP_SICK:
                [self enterSickState];
                break;
            default:
                break;
        }

    }
        return self;
}

+(id) rookieWithParentNode:(CCNode *)parentNode
{
    return [[[self alloc] initWithParentNode:parentNode] autorelease];
}

+(id) rookieWithSaveState:(NSMutableDictionary *)saveData parentNode:(CCNode *)parentNode
{
    return [[[self alloc] initWithSaveState:saveData parentNode:parentNode] autorelease];
}


-(void) turnSprite:(enum DIRECTION)direction
{
    [charSprite stopAllActions];
    CCAnimation *anim;
    
    if (currentState == COP_SICK)
    {
        CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Rookie/rookiesick.png"];
        [charSprite setTexture:sprite];
        anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"RookieSick"];
    }
    else if (currentState == COP_DYING)
    {
        CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Rookie/rookiedead.png"];
        [charSprite setTexture:sprite];
        anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"RookieDead"];
    }
    else
    {
        if (direction == DIR_LEFT)
        {
            CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Rookie/rookieleft.png"];
            [charSprite setTexture:sprite];
            anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"RookieLeft"];
        }
        else if (direction == DIR_RIGHT)
        {
            CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Rookie/rookieright.png"];
            [charSprite setTexture:sprite];
            anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"RookieRight"];
        }
        else if (direction == DIR_UP)
        {
            CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Rookie/rookierear.png"];
            [charSprite setTexture:sprite];
            anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"RookieRear"];
        }
        else // (direction == DIR_DOWN)
        {
            CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Rookie/rookiefront.png"];
            [charSprite setTexture:sprite];
            anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"RookieFront"];
        }
    }
    
    
    CCAnimate *animAction = [CCAnimate actionWithAnimation:anim];
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:animAction];
    [charSprite runAction:repeat];
}

-(void) enterBlindedState
{
    [super enterBlindedState];
    [charSprite stopAllActions];
    CCAnimation *deadAnim = [[CCAnimationCache sharedAnimationCache] animationByName:@"RookieDead"];
    CCAnimate *animAction = [CCAnimate actionWithAnimation:deadAnim];
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:animAction];
    [charSprite runAction:repeat];
}

-(void) leaveBlindedState
{
    [super leaveBlindedState];
    [self turnSprite:currentDirection];
}

-(void) enterChasingState
{
    if (alertCycle == NO)
    {
        alertCycle = YES;
        [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/rookie alert.caf"];
    }
    [super enterChasingState];
}

-(void) update:(ccTime)time
{
    if (currentState == COP_LOADING)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/rookie spawn.caf"];
    }
    else if (currentState == COP_BLINDED)
    {
        return;
    }
    [super update:time];
}

-(void)saveState:(NSMutableDictionary *)saveData
{
    NSMutableDictionary *rookieData = [[NSMutableDictionary alloc]init];
    [rookieData setValue:[NSNumber numberWithInt:currentState] forKey:@"CurrentState"];
    [rookieData setValue:NSStringFromCGPoint(mapPosition) forKey:@"MapPosition"];
    [rookieData setValue:NSStringFromCGPoint(charSprite.position) forKey:@"SpritePosition"];
    [rookieData setValue:[NSNumber numberWithInt:currentDirection] forKey:@"CurrentDirection"];
    [rookieData setValue:[NSNumber numberWithInt:nextDirection] forKey:@"NextDirection"];
    [rookieData setValue:[NSNumber numberWithFloat:distanceToNextTile] forKey:@"DistanceToNextTile"];
    [rookieData setValue:[NSNumber numberWithBool:turnedAround] forKey:@"TurnedAround"];
    [rookieData setValue:[NSNumber numberWithInt:currentChaseSteps] forKey:@"CurrentChaseSteps"];
    [rookieData setValue:NSStringFromCGPoint(attractedItemPosition) forKey:@"AttractedItemPosition"];

    [saveData setValue:rookieData forKey:@"RookieData"];
    [rookieData release];
}

-(void) resumeMoving
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/rookie victory.caf"];
    [super resumeMoving];
    
}

-(void)showCop
{
    [super showCop];
    [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/rookie spawn.caf"];
}
@end
