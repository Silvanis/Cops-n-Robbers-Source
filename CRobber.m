//
//  CRobber.m
//  CopsnRobbersTest
//
//  Created by John Markle on 6/21/12.
//  Copyright 2012 Silver Moonfire LLC. All rights reserved.
//

#import "CRobber.h"
#import "cnrLibraryFunctions.h"
#import "CLevel.h"
#import "CCAnimationHelper.h"
#import "SimpleAudioEngine.h"

@implementation CRobber
@synthesize currentState;

- (id) initWithParentNode:(CCNode *)parentNode
{
    if (self = [super init])
    {
        [super initWithParentNode:parentNode];
        currentState = ROBBER_LOADING;
        tileSize = getTileSize();
        [parentNode addChild:self];
        charSprite = [CCSprite spriteWithFile:@"Graphics/Robber/robberfront.png"];
        CCAnimation *robberFrontAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Robber/robberfront"];
        CCAnimation *robberRearAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Robber/robberrear"];
        CCAnimation *robberRightAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Robber/robberright"];
        CCAnimation *robberLeftAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Robber/robberleft"];
        CCAnimation *dyingAnim = [CCAnimation animationWithFile:@"Graphics/Robber/robbercloud"];
        CCAnimation *deadAnim = [CCAnimation animationWithFile:@"Graphics/Robber/robberdead"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:robberFrontAnim name:@"RobberFront"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:robberRearAnim name:@"RobberRear"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:robberRightAnim name:@"RobberRight"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:robberLeftAnim name:@"RobberLeft"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:dyingAnim name:@"RobberDying"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:deadAnim name:@"RobberDead"];
        gridPosition = [levelPtr robberStart];
        mapPosition = [levelPtr robberStart];
        velocity = tileSize * 2.0;
        currentVelocity = velocity;
        distanceToNextTile = 0.0;
        charSprite.anchorPoint = ccp(0.25,0);
        charSprite.position = ccp(((gridPosition.x * tileSize)), (gridPosition.y * tileSize));
        currentDirection = DIR_DOWN;
        nextDirection = DIR_DOWN;
        [[levelPtr mapLayer] addChild:charSprite z:Z_CHARACTERS];
        [self setTag:CHARACTER_ROBBER];
        CCAnimate *anim = [CCAnimate actionWithAnimation:robberFrontAnim];
        CCRepeatForever *repeat = [CCRepeatForever actionWithAction:anim];
        [charSprite runAction:repeat];
        repeat.tag = 2010;
        turnedAround = NO;

    }
    
    return self;
}

-(id) initWithSaveState:(NSMutableDictionary *)saveData parentNode:(CCNode *)parentNode
{
    if (self = [super init])
    {
        [super initWithParentNode:parentNode];
        NSMutableDictionary *robberData = [saveData objectForKey:@"RobberData"];
        currentState = [[robberData objectForKey:@"CurrentState"]intValue];
        tileSize = getTileSize();
        [parentNode addChild:self];
        charSprite = [CCSprite spriteWithFile:@"Graphics/Robber/robberfront.png"];
        CCAnimation *robberFrontAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Robber/robberfront"];
        CCAnimation *robberRearAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Robber/robberrear"];
        CCAnimation *robberRightAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Robber/robberright"];
        CCAnimation *robberLeftAnim = [CCAnimation animationWithFile4Frames:@"Graphics/Robber/robberleft"];
        CCAnimation *dyingAnim = [CCAnimation animationWithFile:@"Graphics/Robber/robbercloud"];
        CCAnimation *deadAnim = [CCAnimation animationWithFile:@"Graphics/Robber/robberdead"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:robberFrontAnim name:@"RobberFront"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:robberRearAnim name:@"RobberRear"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:robberRightAnim name:@"RobberRight"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:robberLeftAnim name:@"RobberLeft"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:dyingAnim name:@"RobberDying"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:deadAnim name:@"RobberDead"];
        gridPosition = CGPointFromString([robberData objectForKey:@"MapPosition"]);
        mapPosition = CGPointFromString([robberData objectForKey:@"MapPosition"]);
        velocity = tileSize * 2.0;
        currentVelocity = velocity;
        distanceToNextTile = [[robberData objectForKey:@"DistanceToNextTile"]floatValue];
        charSprite.anchorPoint = ccp(0.25,0);
        charSprite.position = CGPointFromString([robberData objectForKey:@"SpritePosition"]);
        currentDirection = [[robberData objectForKey:@"CurrentDirection"]intValue];
        nextDirection = [[robberData objectForKey:@"NextDirection"]intValue];
        [[levelPtr mapLayer] addChild:charSprite z:Z_CHARACTERS];
        [self setTag:CHARACTER_ROBBER];
        [self turnSprite:currentDirection];
        turnedAround = [[robberData objectForKey:@"TurnedAround"]boolValue];
        if (currentState == ROBBER_DYING || currentState == ROBBER_DEAD)
        {
            [self resetRobber];
        }

    }
        return self;
}

+(id) robberWithParentNode:(CCNode *)parentNode
{
    return [[[self alloc] initWithParentNode:parentNode] autorelease];
}

+(id) robberWithSaveState: (NSMutableDictionary*)saveData parentNode:(CCNode *)parentNode
{
    return [[[self alloc] initWithSaveState:saveData parentNode:parentNode] autorelease];
}

-(void) update:(ccTime) time
{
    CGPoint position = charSprite.position;
    
    if (currentState == ROBBER_ALIVE)
    {
        if ([levelPtr checkForCopCollision: position])
        {
            currentState = ROBBER_DYING;
            return;
        }
    }
    
    else if (currentState == ROBBER_DYING)
    {
        //show dying animation
        [charSprite stopAllActions];
        CCAnimation *dyingAnim = [[CCAnimationCache sharedAnimationCache] animationByName:@"RobberDying"];
        CCTexture2D *deadRobberSprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Robber/robberdead.png"];
        [charSprite setTexture:deadRobberSprite];
        CCAnimation *deadAnim = [[CCAnimationCache sharedAnimationCache] animationByName:@"RobberDead"];
        CCAnimate *dyingAction = [CCAnimate actionWithAnimation:dyingAnim];
        CCRepeat *repeatAction = [CCRepeat actionWithAction:dyingAction times:4];
        CCAnimate *deadAction = [CCAnimate actionWithAnimation:deadAnim];
        CCRepeat *repeatDeadAction = [CCRepeat actionWithAction:deadAction times:4];
        CCAction *resetRobberAction = [CCCallFunc actionWithTarget:self selector:@selector(resetRobber)];
        CCAction *waitAction = [CCDelayTime actionWithDuration:1.0];
        CCSequence *dyingSequence = [CCSequence actions:repeatAction, repeatDeadAction, waitAction, resetRobberAction, nil];
        currentState = ROBBER_DEAD;
        [charSprite runAction:dyingSequence];
        [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/knockdown.caf"];
    }
    
    else if (currentState == ROBBER_DEAD || currentState == ROBBER_PAUSED)
    {
        return;
    }
    
    else if (currentState == ROBBER_LOADING)
    {
        return;
    }
    
    [super update:time];
    
    

    
}

-(void) resetRobber
{
    mapPosition = [levelPtr robberStart];
    gridPosition = [levelPtr robberStart];
    [levelPtr resetMapPosition];
    distanceToNextTile = 0.0;
    [self turnSprite:DIR_DOWN];
    currentDirection = DIR_DOWN;
    charSprite.position = ccp(((gridPosition.x * tileSize)), (gridPosition.y * tileSize));
    CScore *score = (CScore *)[levelPtr getChildByTag:1500];
    [score updateLives:-1];
    //[self schedule:@selector(endInvuln:) interval:3.0];
    currentState = ROBBER_LOADING;
}

-(void) endInvuln: (ccTime) dt
{
    currentState = ROBBER_LOADING;
    [self unschedule:@selector(endInvuln:)];
}

-(void) turnSprite:(enum DIRECTION)direction
{
    //stop current animation
    [charSprite stopActionByTag:2010];
    CCAnimation *anim;
    if (direction == DIR_LEFT)
    {
        CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Robber/robberleft.png"];
        [charSprite setTexture:sprite];
        anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"RobberLeft"];
        [levelPtr moveEyesLeft];
    }
    else if (direction == DIR_RIGHT)
    {
        CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Robber/robberright.png"];
        [charSprite setTexture:sprite];
        anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"RobberRight"];
        [levelPtr moveEyesRight];
    }
    else if (direction == DIR_UP)
    {
        CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Robber/robberrear.png"];
        [charSprite setTexture:sprite];
        anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"RobberRear"];
        [levelPtr moveEyesUp];
    }
    else //(direction == DIR_DOWN)
    {
        CCTexture2D *sprite = [[CCTextureCache sharedTextureCache] addImage:@"Graphics/Robber/robberfront.png"];
        [charSprite setTexture:sprite];
        anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"RobberFront"];
        [levelPtr moveEyesDown];
    }
    CCAnimate *animAction = [CCAnimate actionWithAnimation:anim];
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:animAction];
    [charSprite runAction:repeat];
    repeat.tag = 2010;
}

-(void) turnCharacter:(enum DIRECTION) direction
{
    if (currentState == ROBBER_DYING || currentState == ROBBER_DEAD || currentState == ROBBER_PAUSED)
    {
        // do nothing
    }
    else
    {
        if ((direction == DIR_LEFT && currentDirection == DIR_RIGHT) || (direction == DIR_RIGHT && currentDirection == DIR_LEFT) || (direction == DIR_DOWN && currentDirection == DIR_UP) || (direction == DIR_UP && currentDirection == DIR_DOWN))
        {
            //turn around
            currentDirection = direction;
            distanceToNextTile = tileSize - distanceToNextTile;
            turnedAround = YES;
            nextDirection = direction;
            [self turnSprite:direction];
            //adjust for turning around from a wall
            
            if (nextDirection == DIR_LEFT && ![levelPtr verifyMove:mapPosition.x + 1 :mapPosition.y])
            {
                distanceToNextTile = 0;
                mapPosition.x = mapPosition.x - 1;
                gridPosition.x = gridPosition.x - 1;
            }
            else if (nextDirection == DIR_RIGHT && ![levelPtr verifyMove:mapPosition.x - 1 :mapPosition.y])
            {
                distanceToNextTile = 0;
                mapPosition.x = mapPosition.x + 1;
                gridPosition.x = gridPosition.x + 1;
            }
            else if (nextDirection == DIR_UP && ![levelPtr verifyMove:mapPosition.x :mapPosition.y - 1])
            {
                distanceToNextTile = 0;
                mapPosition.y = mapPosition.y + 1;
                gridPosition.y = gridPosition.y + 1;
            }
            else if (nextDirection == DIR_DOWN && ![levelPtr verifyMove:mapPosition.x :mapPosition.y + 1])
            {
                distanceToNextTile = 0;
                mapPosition.y = mapPosition.y - 1;
                gridPosition.y = gridPosition.y - 1;
            }
            
        }
        else if (direction != currentDirection)
        {
            //check if against wall
            if (currentDirection == DIR_RIGHT && ![levelPtr verifyMove:mapPosition.x + 1 :mapPosition.y])
            {
                distanceToNextTile = 15;
            }
            else if (currentDirection == DIR_LEFT && ![levelPtr verifyMove:mapPosition.x - 1 :mapPosition.y])
            {
                distanceToNextTile = 15;
            }
            else if (currentDirection == DIR_DOWN && ![levelPtr verifyMove:mapPosition.x :mapPosition.y - 1])
            {
                distanceToNextTile = 15;
            }
            else if (currentDirection == DIR_UP && ![levelPtr verifyMove:mapPosition.x :mapPosition.y + 1])
            {
                distanceToNextTile = 15;
            }
            //queue up direction for next turn
            nextDirection = direction;
        }

    }
    if (currentState == ROBBER_LOADING)
    {
        currentState = ROBBER_ALIVE;
    }
}

-(void) determineNextMove
{
    if ([self checkIfCanTurn])
    {
        bool canNext = NO;
        if (nextDirection == DIR_DOWN && [levelPtr verifyMove:mapPosition.x :mapPosition.y - 1])
        {
            canNext = YES;
        }
        else if (nextDirection == DIR_UP && [levelPtr verifyMove:mapPosition.x :mapPosition.y + 1])
        {
            canNext = YES;
        }
        else if (nextDirection == DIR_LEFT && [levelPtr verifyMove:mapPosition.x - 1 :mapPosition.y])
        {
            canNext = YES;
        }
        else if (nextDirection == DIR_RIGHT && [levelPtr verifyMove:mapPosition.x + 1 :mapPosition.y])
        {
            canNext = YES;
        }
        if (canNext)
        {
            if (currentDirection != nextDirection)
            {
                [self turnSprite:nextDirection];
            }
            currentDirection = nextDirection;
        }
        
    }
    
}

-(void) enterPausedState
{
    if (currentState == ROBBER_ALIVE)
    {
        [self leaveAliveState];
    }
    currentState = ROBBER_PAUSED;
}

-(void) leavePausedState
{
    [self enterAliveState];
}

-(void) enterDyingState
{
    
}

-(void) leaveDyingState
{
    
}

-(void) enterDeadState
{
    
}

-(void) leaveDeadState
{
    
}

-(void) enterAliveState
{
    currentState = ROBBER_ALIVE;
}

-(void) leaveAliveState
{
    
}

-(void) enterInvulnState
{
    
}

-(void) leaveInvulnState
{
    
}

-(enum DIRECTION)getDirection
{
    return currentDirection;
}

-(void) saveState: (NSMutableDictionary *)saveData
{
    NSMutableDictionary *robberData = [[[NSMutableDictionary alloc]init]autorelease];
    [robberData setValue:[NSNumber numberWithInt:currentState] forKey:@"CurrentState"];
    [robberData setValue:NSStringFromCGPoint(mapPosition) forKey:@"MapPosition"];
    [robberData setValue:NSStringFromCGPoint(charSprite.position) forKey:@"SpritePosition"];
    [robberData setValue:[NSNumber numberWithInt:currentDirection] forKey:@"CurrentDirection"];
    [robberData setValue:[NSNumber numberWithInt:nextDirection] forKey:@"NextDirection"];
    [robberData setValue:[NSNumber numberWithFloat:distanceToNextTile] forKey:@"DistanceToNextTile"];
    [robberData setValue:[NSNumber numberWithBool:turnedAround] forKey:@"TurnedAround"];
    
    [saveData setValue:robberData forKey:@"RobberData"];
}
@end
