//
//  CRival.m
//  Cops 'n Robbers
//
//  Created by John Markle on 1/21/13.
//  Copyright 2013 Silver Moonfire LLC. All rights reserved.
//

#import "CRival.h"
#import "cnrLibraryFunctions.h"
#import "CLevel.h"
#import "CCAnimationHelper.h"

@implementation CRival
@synthesize currentState;

- (id) initWithParentNode:(CCNode *)parentNode
{
    if (self = [super init])
    {
        [super initWithParentNode:parentNode];
        tileSize = getTileSize();
        [parentNode addChild:self];
        charSprite = [CCSprite spriteWithFile:@"Graphics/Rival/rivalfront.png"];
        CCAnimation *rivalFrontAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Rival/rivalfront"];
        CCAnimation *rivalRearAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Rival/rivalrear"];
        CCAnimation *rivalRightAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Rival/rivalright"];
        CCAnimation *rivalLeftAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Rival/rivalleft"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rivalFrontAnim name:@"RivalFront"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rivalRearAnim name:@"RivalRear"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rivalRightAnim name:@"RivalRight"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rivalLeftAnim name:@"RivalLeft"];
        gridPosition = [levelPtr rivalStart];
        mapPosition = [levelPtr rivalStart];
        velocity = tileSize * 2;
        currentVelocity = velocity;
        distanceToNextTile = 0.0;
        charSprite.anchorPoint = ccp(0.25,0);
        charSprite.position = ccp(((gridPosition.x * tileSize)), (gridPosition.y * tileSize));
        currentDirection = DIR_DOWN;
        nextDirection = DIR_DOWN;
        [[levelPtr mapLayer] addChild:charSprite z:Z_CHARACTERS];
        [self setTag:CHARACTER_RIVAL];
        CCAnimate *anim = [CCAnimate actionWithAnimation:rivalFrontAnim];
        CCRepeatForever *repeat = [CCRepeatForever actionWithAction:anim];
        [charSprite runAction:repeat];
        repeat.tag = 2011;
        turnedAround = NO;
        currentState = RIVAL_LOADING;
        cloudActive = NO;
    }
    
    return self;
}

-(id) initWithSaveState:(NSMutableDictionary *)saveData parentNode:(CCNode *)parentNode
{
    if (self = [super init])
    {
        [super initWithParentNode:parentNode];
        NSMutableDictionary *rivalData = [saveData objectForKey:@"RivalData"];
        tileSize = getTileSize();
        [parentNode addChild:self];
        charSprite = [CCSprite spriteWithFile:@"Graphics/Rival/rivalfront.png"];
        CCAnimation *rivalFrontAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Rival/rivalfront"];
        CCAnimation *rivalRearAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Rival/rivalrear"];
        CCAnimation *rivalRightAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Rival/rivalright"];
        CCAnimation *rivalLeftAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Rival/rivalleft"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rivalFrontAnim name:@"RivalFront"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rivalRearAnim name:@"RivalRear"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rivalRightAnim name:@"RivalRight"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rivalLeftAnim name:@"RivalLeft"];
        gridPosition = CGPointFromString([rivalData objectForKey:@"MapPosition"]);
        mapPosition = CGPointFromString([rivalData objectForKey:@"MapPosition"]);
        velocity = tileSize * 2;
        currentVelocity = velocity;
        distanceToNextTile = [[rivalData objectForKey:@"DistanceToNextTile"]floatValue];
        charSprite.anchorPoint = ccp(0.25,0);
        charSprite.position = CGPointFromString([rivalData objectForKey:@"SpritePosition"]);
        currentDirection = [[rivalData objectForKey:@"CurrentDirection"]intValue];
        nextDirection = [[rivalData objectForKey:@"NextDirection"]intValue];
        [[levelPtr mapLayer] addChild:charSprite z:Z_CHARACTERS];
        [self setTag:CHARACTER_RIVAL];
        [self turnSprite:currentDirection];
        turnedAround = [[rivalData objectForKey:@"TurnedAround"]boolValue];
        currentState = [[rivalData objectForKey:@"CurrentState"]intValue];
        cloudActive = NO;
    }
    
    return self;
}

+(id) rivalWithParentNode:(CCNode *)parentNode
{
    return [[[self alloc] initWithParentNode:parentNode] autorelease];
}

+(id) rivalwithSaveState:(NSMutableDictionary *)saveData parentNode:(CCNode *)parentNode
{
    return [[[self alloc] initWithSaveState:saveData parentNode:parentNode] autorelease];
}
-(void) turnSprite:(enum DIRECTION)direction
{
    //stop current animation
    [charSprite stopAllActions];
    CCAnimation *anim;
    if (direction == DIR_LEFT)
    {
        //CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Rival/rivalleft.png"];
        //[charSprite setTexture:sprite];
        anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"RivalLeft"];
        
    }
    else if (direction == DIR_RIGHT)
    {
        //CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Rival/rivalright.png"];
        //[charSprite setTexture:sprite];
        anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"RivalRight"];
    }
    else if (direction == DIR_UP)
    {
        //CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Rival/rivalrear.png"];
        //[charSprite setTexture:sprite];
        anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"RivalRear"];
    }
    else // (direction == DIR_DOWN)
    {
        //CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Rival/rivalfront.png"];
        //[charSprite setTexture:sprite];
        anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"RivalFront"];
    }
    CCAnimate *animAction = [CCAnimate actionWithAnimation:anim];
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:animAction];
    [charSprite runAction:repeat];
    //repeat.tag = 2011;
}

-(void)determineNextMove
{
    if ([self checkIfCanTurn])
    {
        nextDirection = [levelPtr findNearestGem:mapPosition];
        if (currentDirection != nextDirection)
        {
            [self turnSprite:nextDirection];
        }
        currentDirection = nextDirection;
    }
}

-(void) update:(ccTime)time
{
    if (currentState == RIVAL_LOADING)
    {
        [self enterAliveState];
    }
    else if (currentState == RIVAL_PAUSED)
    {
        return;
    }
    else if (currentState == RIVAL_ALIVE)
    {
        [levelPtr rivalCheckForCopCollision:[charSprite position]];
    }
    [super update:time];
}

-(void) enterPausedState
{
    if (currentState == RIVAL_ALIVE)
    {
        [self leaveAliveState];
    }
    currentState = RIVAL_PAUSED;
}

-(void) leavePausedState
{
    [self enterAliveState];
}

-(void) enterAliveState
{
    currentState = RIVAL_ALIVE;
    //[self turnSprite:currentDirection];
}

-(void) leaveAliveState
{
    
}

-(void) enterRetreatState
{
    if (cloudActive == YES)
    {
        rivalCloud.position = [charSprite position];
        
    }
    else
    {
        rivalCloud = [CCSprite spriteWithFile:@"Graphics/Rival/rivalcloud.png"];
        rivalCloud.position = [charSprite position];
        rivalCloud.anchorPoint = ccp(0.25,0);
        rivalCloud.scale = 2.0;
        [[levelPtr mapLayer] addChild:rivalCloud z:Z_EFFECTS tag:ITEM_TAG_RIVAL_SMOKE];
        cloudActive = YES;
    }
    [self scheduleOnce:@selector(removeCloud) delay:2.0];
    
}

-(void) leaveRetreatState
{
    
}

-(void) saveState: (NSMutableDictionary *)saveData
{
    NSMutableDictionary *rivalData = [[NSMutableDictionary alloc]init];
    [rivalData setValue:[NSNumber numberWithInt:currentState] forKey:@"CurrentState"];
    [rivalData setValue:NSStringFromCGPoint(mapPosition) forKey:@"MapPosition"];
    [rivalData setValue:NSStringFromCGPoint(charSprite.position) forKey:@"SpritePosition"];
    [rivalData setValue:[NSNumber numberWithInt:currentDirection] forKey:@"CurrentDirection"];
    [rivalData setValue:[NSNumber numberWithInt:nextDirection] forKey:@"NextDirection"];
    [rivalData setValue:[NSNumber numberWithFloat:distanceToNextTile] forKey:@"DistanceToNextTile"];
    [rivalData setValue:[NSNumber numberWithBool:turnedAround] forKey:@"TurnedAround"];
    
    [saveData setValue:rivalData forKey:@"RivalData"];
    [rivalData release];
}

-(void) removeCloud
{
    [[levelPtr mapLayer] removeChildByTag:ITEM_TAG_RIVAL_SMOKE cleanup:NO];
    cloudActive = NO;
}

@end
