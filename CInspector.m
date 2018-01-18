//
//  CInspector.m
//  CopsnRobbersTest
//
//  Created by John Markle on 10/21/12.
//  Copyright 2012 Silver Moonfire LLC. All rights reserved.
//

#import "CInspector.h"
#import "CLevel.h"
#import "CCAnimationHelper.h"
#import "SimpleAudioEngine.h"

@implementation CInspector

-(id)initWithParentNode:(CCNode *)parentNode
{
    if (self = [super init])
    {
        [super initWithParentNode:parentNode];
        [parentNode addChild:self];
        charSprite = [CCSprite spriteWithFile:@"Graphics/Inspector/inspector.png"];
        CCAnimation *frontAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Inspector/inspectorfront"];
        CCAnimation *rearAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Inspector/inspectorrear"];
        CCAnimation *rightAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Inspector/inspectorright"];
        CCAnimation *leftAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Inspector/inspectorleft"];
        CCAnimation *sickAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Inspector/inspectorsick"];
        CCAnimation *deadAnim = [CCAnimation animationWithFile:@"Graphics/Inspector/inspectordead"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:frontAnim name:@"InspectorFront"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rearAnim name:@"InspectorRear"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rightAnim name:@"InspectorRight"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:leftAnim name:@"InspectorLeft"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:sickAnim name:@"InspectorSick"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:deadAnim name:@"InspectorDead"];
        charSprite.anchorPoint = ccp(0.25,0);
        charSprite.position = ccp(((gridPosition.x * tileSize)), (gridPosition.y * tileSize));
        currentDirection = DIR_DOWN;
        nextDirection = DIR_LEFT;
        thresholdAI = 100;
        sightThreshold = 6;
        chaseStepsThreshold = 7;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            velocity = 28;
            chaseVelocity = 32;
        }
        else
        {
            velocity = 56;
            chaseVelocity = 64;
        }
        //velocity = (tileSize * 2) - (tileSize / 4); //28 on iPhone, 56 on iPad
        //chaseVelocity = (tileSize * 2) - (tileSize / 8); //30 on iPhone, 60 on iPad
        [[levelPtr mapLayer] addChild:charSprite z:Z_CHARACTERS tag:CHARACTER_INSPECTOR];
        CCAnimate *anim = [CCAnimate actionWithAnimation:frontAnim];
        CCRepeatForever *repeat = [CCRepeatForever actionWithAction:anim];
        [charSprite runAction:repeat];
    }
    
    return self;
}

-(id) initWithSaveState:(NSMutableDictionary *)saveData parentNode:(CCNode *)parentNode
{
    if (self = [super init])
    {
        [super initWithParentNode:parentNode];
        NSMutableDictionary *inspectorData = [saveData objectForKey:@"InspectorData"];
        [parentNode addChild:self];
        charSprite = [CCSprite spriteWithFile:@"Graphics/Inspector/inspector.png"];
        CCAnimation *frontAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Inspector/inspectorfront"];
        CCAnimation *rearAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Inspector/inspectorrear"];
        CCAnimation *rightAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Inspector/inspectorright"];
        CCAnimation *leftAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Inspector/inspectorleft"];
        CCAnimation *sickAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Inspector/inspectorsick"];
        CCAnimation *deadAnim = [CCAnimation animationWithFile:@"Graphics/Inspector/inspectordead"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:frontAnim name:@"InspectorFront"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rearAnim name:@"InspectorRear"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rightAnim name:@"InspectorRight"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:leftAnim name:@"InspectorLeft"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:sickAnim name:@"InspectorSick"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:deadAnim name:@"InspectorDead"];
        charSprite.anchorPoint = ccp(0.25,0);
        charSprite.position = CGPointFromString([inspectorData objectForKey:@"SpritePosition"]);
        mapPosition = CGPointFromString([inspectorData objectForKey:@"MapPosition"]);
        gridPosition = CGPointFromString([inspectorData objectForKey:@"MapPosition"]);
        currentDirection = [[inspectorData objectForKey:@"CurrentDirection"]intValue];
        nextDirection = [[inspectorData objectForKey:@"NextDirection"]intValue];
        thresholdAI = 100;
        sightThreshold = 5;
        chaseStepsThreshold = 7;
        currentChaseSteps = [[inspectorData objectForKey:@"CurrentChaseSteps"]intValue];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            velocity = 28;
            chaseVelocity = 32;
        }
        else
        {
            velocity = 56;
            chaseVelocity = 64;
        }
        //velocity = (tileSize * 2) - (tileSize / 4); //28 on iPhone, 56 on iPad
        //chaseVelocity = (tileSize * 2) - (tileSize / 8); //30 on iPhone, 60 on iPad
        currentVelocity = velocity;
        [[levelPtr mapLayer] addChild:charSprite z:Z_CHARACTERS tag:CHARACTER_INSPECTOR];
        [self turnSprite:currentDirection];
        currentState = [[inspectorData objectForKey:@"CurrentState"]intValue];
        attractedItemPosition = CGPointFromString([inspectorData objectForKey:@"AttractedItemPosition"]);
        
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

+(id) inspectorWithParentNode:(CCNode *)parentNode
{
    return [[[self alloc] initWithParentNode:parentNode] autorelease];
}

+(id) inspectorWithSaveState:(NSMutableDictionary *)saveData parentNode:(CCNode *)parentNode
{
    return [[[self alloc] initWithSaveState:saveData parentNode:parentNode] autorelease];
}

-(void) turnSprite:(enum DIRECTION)direction
{
    [charSprite stopAllActions];
    CCAnimation *anim;
    
    if (currentState == COP_SICK)
    {
        CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Inspector/inspectorsick.png"];
        [charSprite setTexture:sprite];
        anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"InspectorSick"];
    }
    else if (currentState == COP_DYING)
    {
        CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Inspector/inspectordead.png"];
        [charSprite setTexture:sprite];
        anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"InspectorDead"];
    }
    else
    {
        if (direction == DIR_LEFT)
        {
            CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Inspector/inspectorleft.png"];
            [charSprite setTexture:sprite];
            anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"InspectorLeft"];
        }
        else if (direction == DIR_RIGHT)
        {
            CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Inspector/inspectorright.png"];
            [charSprite setTexture:sprite];
            anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"InspectorRight"];
        }
        else if (direction == DIR_UP)
        {
            CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Inspector/inspectorrear.png"];
            [charSprite setTexture:sprite];
            anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"InspectorRear"];
        }
        else // (direction == DIR_DOWN)
        {
            CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Inspector/inspectorfront.png"];
            [charSprite setTexture:sprite];
            anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"InspectorFront"];
        }

    }
        
    CCAnimate *animAction = [CCAnimate actionWithAnimation:anim];
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:animAction];
    [charSprite runAction:repeat];
}

-(void)saveState:(NSMutableDictionary *)saveData
{
    NSMutableDictionary *inspectorData = [[[NSMutableDictionary alloc]init]autorelease];
    [inspectorData setValue:[NSNumber numberWithInt:currentState] forKey:@"CurrentState"];
    [inspectorData setValue:NSStringFromCGPoint(mapPosition) forKey:@"MapPosition"];
    [inspectorData setValue:NSStringFromCGPoint(charSprite.position) forKey:@"SpritePosition"];
    [inspectorData setValue:[NSNumber numberWithInt:currentDirection] forKey:@"CurrentDirection"];
    [inspectorData setValue:[NSNumber numberWithInt:nextDirection] forKey:@"NextDirection"];
    [inspectorData setValue:[NSNumber numberWithFloat:distanceToNextTile] forKey:@"DistanceToNextTile"];
    [inspectorData setValue:[NSNumber numberWithBool:turnedAround] forKey:@"TurnedAround"];
    [inspectorData setValue:[NSNumber numberWithInt:currentChaseSteps] forKey:@"CurrentChaseSteps"];
    [inspectorData setValue:NSStringFromCGPoint(attractedItemPosition) forKey:@"AttractedItemPosition"];

    [saveData setValue:inspectorData forKey:@"InspectorData"];
}

-(void) resumeMoving
{
    if (currentState != COP_BLINDED_RIVAL) //attacked robber, time to proclaim victory!
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/inspector victory.caf"];
    }
    [super resumeMoving];
    
}

-(void) enterChasingState
{
    if (alertCycle == NO)
    {
        alertCycle = YES;
        [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/inspector alert.caf"];
    }
    [super enterChasingState];
}

-(void) update:(ccTime)time
{
    if (currentState == COP_LOADING)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/inspector spawn.caf"];
    }
    [super update:time];
}

-(void)showCop
{
    [super showCop];
    [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/inspector spawn.caf"];
}
@end
