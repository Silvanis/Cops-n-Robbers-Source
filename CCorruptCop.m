//
//  CCorruptCop.m
//  CopsnRobbersTest
//
//  Created by John Markle on 10/28/12.
//  Copyright 2012 Silver Moonfire LLC. All rights reserved.
//

#import "CCorruptCop.h"
#import "CLevel.h"
#import "CCAnimationHelper.h"
#import "SimpleAudioEngine.h"

@implementation CCorruptCop

-(id)initWithParentNode:(CCNode *)parentNode
{
    if (self = [super init])
    {
        [super initWithParentNode:parentNode];
        [parentNode addChild:self];
        charSprite = [CCSprite spriteWithFile:@"Graphics/CorruptCop/corruptcopfront.png"];
        CCAnimation *frontAnim = [CCAnimation animationWithFile4Frames:@"Graphics/CorruptCop/corruptcopfront"];
        CCAnimation *rearAnim = [CCAnimation animationWithFile4Frames:@"Graphics/CorruptCop/corruptcoprear"];
        CCAnimation *rightAnim = [CCAnimation animationWithFile4Frames:@"Graphics/CorruptCop/corruptcopright"];
        CCAnimation *leftAnim = [CCAnimation animationWithFile4Frames:@"Graphics/CorruptCop/corruptcopleft"];
        CCAnimation *sickAnim = [CCAnimation animationWithFile4Frames:@"Graphics/CorruptCop/corruptcopsick"];
        CCAnimation *deadAnim = [CCAnimation animationWithFile:@"Graphics/CorruptCop/corruptcopdead"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:frontAnim name:@"CorruptCopFront"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rearAnim name:@"CorruptCopRear"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rightAnim name:@"CorruptCopRight"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:leftAnim name:@"CorruptCopLeft"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:sickAnim name:@"CorruptCopSick"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:deadAnim name:@"CorruptCopDead"];
        charSprite.anchorPoint = ccp(0.25,0);
        charSprite.position = ccp((gridPosition.x * tileSize), (gridPosition.y * tileSize));
        currentDirection = DIR_DOWN;
        nextDirection = DIR_LEFT;
        thresholdAI = 30;
        sightThreshold = 6;
        chaseStepsThreshold = 5;
        [[levelPtr mapLayer] addChild:charSprite z:Z_CHARACTERS tag:CHARACTER_CORRUPT_COP];
        CCAnimate *anim = [CCAnimate actionWithAnimation:frontAnim];
        CCRepeatForever *repeat = [CCRepeatForever actionWithAction:anim];
        [charSprite runAction:repeat];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            velocity = 31;
            chaseVelocity = 36;
        }
        else
        {
            velocity = 62;
            chaseVelocity = 72;
        }
        //velocity = (tileSize * 2) - (tileSize / 16); //31 on iPhone, 62 on iPad
        //chaseVelocity = (tileSize * 2) + (tileSize / 8); //34 on iPhone, 68 on iPad
        currentState = COP_LOADING;
    }
    
    return self;
}

-(id)initWithSaveState:(NSMutableDictionary *)saveData parentNode:(CCNode *)parentNode
{
    if (self = [super init])
    {
        [super initWithParentNode:parentNode];
        NSMutableDictionary *corruptCopData = [saveData objectForKey:@"CorruptCopData"];
        [parentNode addChild:self];
        charSprite = [CCSprite spriteWithFile:@"Graphics/CorruptCop/corruptcopfront.png"];
        CCAnimation *frontAnim = [CCAnimation animationWithFile4Frames:@"Graphics/CorruptCop/corruptcopfront"];
        CCAnimation *rearAnim = [CCAnimation animationWithFile4Frames:@"Graphics/CorruptCop/corruptcoprear"];
        CCAnimation *rightAnim = [CCAnimation animationWithFile4Frames:@"Graphics/CorruptCop/corruptcopright"];
        CCAnimation *leftAnim = [CCAnimation animationWithFile4Frames:@"Graphics/CorruptCop/corruptcopleft"];
        CCAnimation *sickAnim = [CCAnimation animationWithFile4Frames:@"Graphics/CorruptCop/corruptcopsick"];
        CCAnimation *deadAnim = [CCAnimation animationWithFile:@"Graphics/CorruptCop/corruptcopdead"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:frontAnim name:@"CorruptCopFront"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rearAnim name:@"CorruptCopRear"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rightAnim name:@"CorruptCopRight"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:leftAnim name:@"CorruptCopLeft"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:sickAnim name:@"CorruptCopSick"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:deadAnim name:@"CorruptCopDead"];
        charSprite.anchorPoint = ccp(0.25,0);
        charSprite.position = CGPointFromString([corruptCopData objectForKey:@"SpritePosition"]);
        mapPosition = CGPointFromString([corruptCopData objectForKey:@"MapPosition"]);
        gridPosition = CGPointFromString([corruptCopData objectForKey:@"MapPosition"]);
        currentDirection = [[corruptCopData objectForKey:@"CurrentDirection"]intValue];
        nextDirection = [[corruptCopData objectForKey:@"NextDirection"]intValue];
        thresholdAI = 30;
        sightThreshold = 4;
        chaseStepsThreshold = 5;
        currentChaseSteps = [[corruptCopData objectForKey:@"CurrentChaseSteps"]intValue];
        [[levelPtr mapLayer] addChild:charSprite z:Z_CHARACTERS tag:CHARACTER_CORRUPT_COP];
        [self turnSprite:currentDirection];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            velocity = 31;
            chaseVelocity = 36;
        }
        else
        {
            velocity = 62;
            chaseVelocity = 72;
        }
        //velocity = (tileSize * 2) - (tileSize / 16); //31 on iPhone, 62 on iPad
        //chaseVelocity = (tileSize * 2) + (tileSize / 8); //34 on iPhone, 68 on iPad
        currentVelocity = velocity;
        currentState = [[corruptCopData objectForKey:@"CurrentState"]intValue];
        attractedItemPosition = CGPointFromString([corruptCopData objectForKey:@"AttractedItemPosition"]);
        
        switch (currentState)
        {
            case COP_ALIVE:
                [self enterAliveState];
                break;
            case COP_ATTACKING:
                [self resumeMoving];
                break;
            case COP_ATTRACTED_BONUS:
                [self enterAttractedBonusState:attractedItemPosition];
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

+(id) corruptCopWithParentNode:(CCNode *)parentNode
{
    return [[[self alloc] initWithParentNode:parentNode] autorelease];
}

+(id) corruptCopWithSaveState:(NSMutableDictionary *)saveData parentNode:(CCNode *)parentNode
{
    return [[[self alloc] initWithSaveState:saveData parentNode:parentNode] autorelease];
}

-(void) turnSprite:(enum DIRECTION)direction
{
    [charSprite stopAllActions];
    CCAnimation *anim;
    
    if (currentState == COP_SICK)
    {
        CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/CorruptCop/corruptcopsick.png"];
        [charSprite setTexture:sprite];
        anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"CorruptCopSick"];
    }
    else if (currentState == COP_DYING)
    {
        CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/CorruptCop/corruptcopdead.png"];
        [charSprite setTexture:sprite];
        anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"CorruptCopDead"];
    }
    else
    {
        if (direction == DIR_LEFT)
        {
            CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/CorruptCop/corruptcopleft.png"];
            [charSprite setTexture:sprite];
            anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"CorruptCopLeft"];
        }
        else if (direction == DIR_RIGHT)
        {
            CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/CorruptCop/corruptcopright.png"];
            [charSprite setTexture:sprite];
            anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"CorruptCopRight"];
        }
        else if (direction == DIR_UP)
        {
            CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/CorruptCop/corruptcoprear.png"];
            [charSprite setTexture:sprite];
            anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"CorruptCopRear"];
        }
        else // (direction == DIR_DOWN)
        {
            CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/CorruptCop/corruptcopfront.png"];
            [charSprite setTexture:sprite];
            anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"CorruptCopFront"];
        }

    }
        
    CCAnimate *animAction = [CCAnimate actionWithAnimation:anim];
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:animAction];
    [charSprite runAction:repeat];
}

-(void) enterAttractedBonusState: (CGPoint)itemPosition
{
    if (currentState == COP_CHASING)
    {
        [self leaveChasingState];
    }
    else if (currentState == COP_CONFUSED)
    {
        [self leaveConfusedState];
    }
    NSLog(@"%@ attracted to bonus", [self class]);
    attractedItemPosition = itemPosition;
    currentState = COP_ATTRACTED_BONUS;
    attractEmote = [CCSprite spriteWithFile:@"Graphics/Emotes/attracted.png"];
    CGPoint position = [self getPosition];
    attractEmote.position = ccp((position.x + tileSize / 2), (position.y + tileSize * 2 + (tileSize / 4)));
    [[levelPtr mapLayer] addChild:attractEmote z:Z_CHARACTERS];
}

-(void) leaveAttractedBonusState
{
    NSLog(@"%@ no longer attracted to bonus", [self class]);
    [[levelPtr mapLayer] removeChild:attractEmote cleanup:YES];
}

-(void) saveState:(NSMutableDictionary *)saveData
{
    NSMutableDictionary *corruptCopData = [[NSMutableDictionary alloc]init];
    [corruptCopData setValue:[NSNumber numberWithInt:currentState] forKey:@"CurrentState"];
    [corruptCopData setValue:NSStringFromCGPoint(mapPosition) forKey:@"MapPosition"];
    [corruptCopData setValue:NSStringFromCGPoint(charSprite.position) forKey:@"SpritePosition"];
    [corruptCopData setValue:[NSNumber numberWithInt:currentDirection] forKey:@"CurrentDirection"];
    [corruptCopData setValue:[NSNumber numberWithInt:nextDirection] forKey:@"NextDirection"];
    [corruptCopData setValue:[NSNumber numberWithFloat:distanceToNextTile] forKey:@"DistanceToNextTile"];
    [corruptCopData setValue:[NSNumber numberWithBool:turnedAround] forKey:@"TurnedAround"];
    [corruptCopData setValue:[NSNumber numberWithInt:currentChaseSteps] forKey:@"CurrentChaseSteps"];
    [corruptCopData setValue:NSStringFromCGPoint(attractedItemPosition) forKey:@"AttractedItemPosition"];
    
    [saveData setValue:corruptCopData forKey:@"CorruptCopData"];
    [corruptCopData release];
}

-(void) resumeMoving
{
    if (currentState != COP_BLINDED_RIVAL) //attacked robber, time to proclaim victory!
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/corrupt cop victory.caf"];
    }
    [super resumeMoving];
    
}

-(void) enterChasingState
{
    if (alertCycle == NO)
    {
        alertCycle = YES;
        [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/corrupt cop alert.caf"];
    }
    [super enterChasingState];
}

-(void) update:(ccTime)time
{
    if (currentState == COP_LOADING)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/corrupt cop spawn.caf"];
    }
    [super update:time];
}

-(void)showCop
{
    [super showCop];
    [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/corrupt cop spawn.caf"];
}
@end
