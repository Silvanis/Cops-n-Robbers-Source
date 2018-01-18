//
//  CFatCop.m
//  CopsnRobbersTest
//
//  Created by John Markle on 10/27/12.
//  Copyright 2012 Silver Moonfire LLC. All rights reserved.
//

#import "CFatCop.h"
#import "CLevel.h"
#import "CCAnimationHelper.h"
#import "SimpleAudioEngine.h"

@implementation CFatCop

-(id)initWithParentNode:(CCNode *)parentNode
{
    if (self = [super init])
    {
        [super initWithParentNode:parentNode];
        [parentNode addChild:self];
        charSprite = [CCSprite spriteWithFile:@"Graphics/Fat Cop/fatcopfront.png"];
        CCAnimation *frontAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Fat Cop/fatcopfront"];
        CCAnimation *rearAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Fat Cop/fatcoprear"];
        CCAnimation *rightAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Fat Cop/fatcopright"];
        CCAnimation *leftAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Fat Cop/fatcopleft"];
        CCAnimation *sickAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Fat Cop/fatcopsick"];
        CCAnimation *deadAnim = [CCAnimation animationWithFile:@"Graphics/Fat Cop/fatcopdead"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:frontAnim name:@"FatCopFront"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rearAnim name:@"FatCopRear"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rightAnim name:@"FatCopRight"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:leftAnim name:@"FatCopLeft"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:sickAnim name:@"FatCopSick"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:deadAnim name:@"FatCopDead"];
        charSprite.anchorPoint = ccp(0.25,0);
        charSprite.position = ccp(((gridPosition.x * tileSize)), (gridPosition.y * tileSize));
        currentDirection = DIR_DOWN;
        nextDirection = DIR_LEFT;
        thresholdAI = 50;
        sightThreshold = 5;
        chaseStepsThreshold = 5;
        [[levelPtr mapLayer] addChild:charSprite z:Z_CHARACTERS tag:CHARACTER_FAT_COP];
        CCAnimate *anim = [CCAnimate actionWithAnimation:frontAnim];
        CCRepeatForever *repeat = [CCRepeatForever actionWithAction:anim];
        [charSprite runAction:repeat];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            velocity = 20;
            chaseVelocity = 28;
        }
        else
        {
            velocity = 40;
            chaseVelocity = 56;
        }
        //velocity = (tileSize * 2) * 0.8125; //26 on iPhone, 52 on iPad
        //chaseVelocity = (tileSize * 2) - (tileSize /4); //28 on iPhone, 56 on iPad
        currentVelocity = velocity;

    }
        return self;
}

-(id) initWithSaveState:(NSMutableDictionary *)saveData parentNode:(CCNode *)parentNode
{
    if (self = [super init])
    {
        [super initWithParentNode:parentNode];
        NSMutableDictionary *fatCopData = [saveData objectForKey:@"FatCopData"];
        [parentNode addChild:self];
        charSprite = [CCSprite spriteWithFile:@"Graphics/Fat Cop/fatcopfront.png"];
        CCAnimation *frontAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Fat Cop/fatcopfront"];
        CCAnimation *rearAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Fat Cop/fatcoprear"];
        CCAnimation *rightAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Fat Cop/fatcopright"];
        CCAnimation *leftAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Fat Cop/fatcopleft"];
        CCAnimation *sickAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Fat Cop/fatcopsick"];
        CCAnimation *deadAnim = [CCAnimation animationWithFile:@"Graphics/Fat Cop/fatcopdead"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:frontAnim name:@"FatCopFront"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rearAnim name:@"FatCopRear"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:rightAnim name:@"FatCopRight"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:leftAnim name:@"FatCopLeft"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:sickAnim name:@"FatCopSick"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:deadAnim name:@"FatCopDead"];
        charSprite.anchorPoint = ccp(0.25,0);
        charSprite.position = CGPointFromString([fatCopData objectForKey:@"SpritePosition"]);
        mapPosition = CGPointFromString([fatCopData objectForKey:@"MapPosition"]);
        gridPosition = CGPointFromString([fatCopData objectForKey:@"MapPosition"]);
        currentDirection = [[fatCopData objectForKey:@"CurrentDirection"]intValue];
        nextDirection = [[fatCopData objectForKey:@"NextDirection"]intValue];
        thresholdAI = 50;
        sightThreshold = 4;
        chaseStepsThreshold = 5;
        currentChaseSteps = [[fatCopData objectForKey:@"CurrentChaseSteps"]intValue];
        [[levelPtr mapLayer] addChild:charSprite z:Z_CHARACTERS tag:CHARACTER_FAT_COP];
        [self turnSprite:currentDirection];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            velocity = 20;
            chaseVelocity = 26;
        }
        else
        {
            velocity = 40;
            chaseVelocity = 52;
        }
        //velocity = (tileSize * 2) * 0.8125; //26 on iPhone, 52 on iPad
        //chaseVelocity = (tileSize * 2) - (tileSize /4); //28 on iPhone, 56 on iPad
        currentVelocity = velocity;
        currentState = [[fatCopData objectForKey:@"CurrentState"]intValue];
        attractedItemPosition = CGPointFromString([fatCopData objectForKey:@"AttractedItemPosition"]);
        
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

+(id) fatCopWithParentNode:(CCNode *)parentNode
{
    return [[[self alloc] initWithParentNode:parentNode] autorelease];
}

+(id) fatCopWithSaveState:(NSMutableDictionary *)saveData parentNode:(CCNode *)parentNode
{
    return [[[self alloc] initWithSaveState:saveData parentNode:parentNode] autorelease];
}

-(void) turnSprite:(enum DIRECTION)direction
{
    [charSprite stopAllActions];
    CCAnimation *anim;
    if (currentState == COP_SICK)
    {
        CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Fat Cop/fatcopsick.png"];
        [charSprite setTexture:sprite];
        anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"FatCopSick"];
    }
    else if (currentState == COP_DYING)
    {
        CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Fat Cop/fatcopdead.png"];
        [charSprite setTexture:sprite];
        anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"FatCopDead"];
    }
    else
    {
        if (direction == DIR_LEFT)
        {
            CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Fat Cop/fatcopleft.png"];
            [charSprite setTexture:sprite];
            anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"FatCopLeft"];
        }
        else if (direction == DIR_RIGHT)
        {
            CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Fat Cop/fatcopright.png"];
            [charSprite setTexture:sprite];
            anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"FatCopRight"];
        }
        else if (direction == DIR_UP)
        {
            CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Fat Cop/fatcoprear.png"];
            [charSprite setTexture:sprite];
            anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"FatCopRear"];
        }
        else // (direction == DIR_DOWN)
        {
            CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Fat Cop/fatcopfront.png"];
            [charSprite setTexture:sprite];
            anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"FatCopFront"];
        }
    }
        
    CCAnimate *animAction = [CCAnimate actionWithAnimation:anim];
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:animAction];
    [charSprite runAction:repeat];
}

-(void)saveState:(NSMutableDictionary *)saveData
{
    NSMutableDictionary *fatCopData = [[NSMutableDictionary alloc]init];
    [fatCopData setValue:[NSNumber numberWithInt:currentState] forKey:@"CurrentState"];
    [fatCopData setValue:NSStringFromCGPoint(mapPosition) forKey:@"MapPosition"];
    [fatCopData setValue:NSStringFromCGPoint(charSprite.position) forKey:@"SpritePosition"];
    [fatCopData setValue:[NSNumber numberWithInt:currentDirection] forKey:@"CurrentDirection"];
    [fatCopData setValue:[NSNumber numberWithInt:nextDirection] forKey:@"NextDirection"];
    [fatCopData setValue:[NSNumber numberWithFloat:distanceToNextTile] forKey:@"DistanceToNextTile"];
    [fatCopData setValue:[NSNumber numberWithBool:turnedAround] forKey:@"TurnedAround"];
    [fatCopData setValue:[NSNumber numberWithInt:currentChaseSteps] forKey:@"CurrentChaseSteps"];
    [fatCopData setValue:NSStringFromCGPoint(attractedItemPosition) forKey:@"AttractedItemPosition"];

    [saveData setValue:fatCopData forKey:@"FatCopData"];
    [fatCopData release];
}

-(void)enterAttractedDoughnutState:(CGPoint)itemPosition
{
    [super enterAttractedDoughnutState:itemPosition];
    currentVelocity = tileSize * 4.0;
}

-(void) resumeMoving
{
    [super resumeMoving];
    [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/fat cop victory.caf"];
}

-(void) enterChasingState
{
    if (alertCycle == NO)
    {
        alertCycle = YES;
        [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/fat cop alert.caf"];
    }
    [super enterChasingState];
}

-(void) update:(ccTime)time
{
    if (currentState == COP_LOADING)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/fat cop spawn.caf"];
    }
    [super update:time];
}

-(void)showCop
{
    [super showCop];
    [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/fat cop spawn.caf"];
}
@end
