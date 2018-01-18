//
//  CCopBase.m
//  Cops 'n Robbers
//
//  Created by John Markle on 1/19/13.
//  Copyright 2013 Silver Moonfire LLC. All rights reserved.
//

#import "CCopBase.h"
#import "CLevel.h"

@implementation CCopBase
@synthesize currentState;

-(id) initWithParentNode:(CCNode*)parentNode
{
    if (self = [super init])
    {
        [super initWithParentNode:parentNode];
        
        currentChaseSteps = 0;
        confusedEmote = [CCSprite spriteWithFile:@"Graphics/Emotes/confused.png"];
        attractEmote = [CCSprite spriteWithFile:@"Graphics/Emotes/attracted.png"];
        alertEmote = [CCSprite spriteWithFile:@"Graphics/Emotes/alert.png"];
        scaredEmote = [CCSprite spriteWithFile:@"Graphics/Emotes/scared.png"];
        confusedEmote.anchorPoint = ccp(0.5, 0.0);
        attractEmote.anchorPoint = ccp(0.5, 0.0);
        alertEmote.anchorPoint = ccp(0.5, 0.0);
        scaredEmote.anchorPoint = ccp(0.5, 0.0);
        mapPosition = [levelPtr copStart];
        gridPosition = [levelPtr copStart];
        alertCycle = NO;
    }
    
    
    return self;
}

-(id) initWithSaveState:(NSMutableDictionary *)saveData parentNode:(CCNode *)parentNode
{
    if (self = [super init])
    {
        [super initWithParentNode:parentNode];
        
        currentChaseSteps = 0;
        confusedEmote = [CCSprite spriteWithFile:@"Graphics/Emotes/confused.png"];
        attractEmote = [CCSprite spriteWithFile:@"Graphics/Emotes/attracted.png"];
        alertEmote = [CCSprite spriteWithFile:@"Graphics/Emotes/alert.png"];
        scaredEmote = [CCSprite spriteWithFile:@"Graphics/Emotes/scared.png"];
        confusedEmote.anchorPoint = ccp(0.5, 0.0);
        attractEmote.anchorPoint = ccp(0.5, 0.0);
        alertEmote.anchorPoint = ccp(0.5, 0.0);
        scaredEmote.anchorPoint = ccp(0.5, 0.0);
        mapPosition = [levelPtr copStart];
        gridPosition = [levelPtr copStart];
        alertCycle = NO;
    }
    
    return self;
}

-(void) update:(ccTime) time
{
    if (currentState == COP_ATTACKING || currentState == COP_DYING || currentState == COP_DEAD || currentState == COP_BLINDED_RIVAL)
    {
        return;
    }
    else if (currentState == COP_LOADING)
    {
        [self enterAliveState];
    }
    [super update:time];

    if (currentState == COP_ATTRACTED_DOUGHNUT || currentState == COP_ATTRACTED_SEXBOT || currentState == COP_ATTRACTED_BONUS)
    {
        attractEmote.position = ccp((charSprite.position.x + tileSize / 2), (charSprite.position.y + tileSize * 2 + (tileSize / 4)));
        attractSystem.position = attractEmote.position;
    }
    else if (currentState == COP_CHASING)
    {
        alertEmote.position = ccp((charSprite.position.x + tileSize / 2), (charSprite.position.y + tileSize * 2 + (tileSize / 4)));
    }
    else if (currentState == COP_CONFUSED)
    {
        confusedEmote.position = ccp((charSprite.position.x + tileSize / 2), (charSprite.position.y + tileSize * 2 + (tileSize / 4)));
    }
    else if (currentState == COP_SCARED)
    {
        scaredEmote.position = ccp((charSprite.position.x + tileSize / 2), (charSprite.position.y + tileSize * 2 + (tileSize / 4)));
        scaredSystem.position = scaredEmote.position;
    }

}

-(void) determineNextMove
{
    CGPoint robberPositon = [levelPtr getRobberMapPosition];
    enum ROBBER_STATE robberState = [levelPtr getRobberState];
    
    if (currentState == COP_ALIVE)
    {
        if ([self checkIfSeesRobber:robberPositon] && robberState == ROBBER_ALIVE)
        {
            if (currentState != COP_CHASING)
            {
                [self enterChasingState];
            }
            nextDirection = [levelPtr findPathToRobber:mapPosition];
            if (currentDirection != nextDirection)
            {
                [self turnSprite:nextDirection];
            }
            currentDirection = nextDirection;
            return;
        }
        //check for a turn
        
        if ([self checkIfCanTurn])
        {
            BOOL canMove = NO;
            enum DIRECTION tempDirection;
            if (currentState != COP_BLINDED)
            {
                int randomThreshold = arc4random_uniform(100);
                if (randomThreshold < thresholdAI && robberState == ROBBER_ALIVE)
                {
                    //persue robber
                    nextDirection = [levelPtr findPathToRobber:mapPosition];
                    if (currentDirection != nextDirection)
                    {
                        [self turnSprite:nextDirection];
                        currentDirection = nextDirection;
                    }
                    return;
                }
            }
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
    else if (currentState == COP_CHASING)
    {
        if (![self checkIfSeesRobber:robberPositon])
        {
            [self leaveChasingState];
            [self enterConfusedState];
            NSLog(@"%@ confused. Step %i", [self class], currentChaseSteps);
        }
        
        if (robberState == ROBBER_ALIVE)
        {
            nextDirection = [levelPtr findPathToRobber:mapPosition];
        }
        else
        {
            if (currentState == COP_CONFUSED)
            {
                [self leaveConfusedState];
            }
            else if (currentState == COP_CHASING)
            {
                [self leaveChasingState];
            }
            alertCycle = NO;
            [self enterAliveState];
        }
        
        if (currentDirection != nextDirection)
        {
            [self turnSprite:nextDirection];
        }
        currentDirection = nextDirection;
        return;
    }
    else if (currentState == COP_CONFUSED)
    {
        if (robberState == ROBBER_ALIVE)
        {
            if (![self checkIfSeesRobber:robberPositon])
            {
                currentChaseSteps++;
                NSLog(@"%@ confused. Step %i", [self class], currentChaseSteps);
                nextDirection = [levelPtr findPathToRobber:mapPosition];
                if (currentDirection != nextDirection)
                {
                    [self turnSprite:nextDirection];
                }
                currentDirection = nextDirection;
                if (currentChaseSteps >= chaseStepsThreshold)
                {
                    [self enterAliveState];
                    [self leaveConfusedState];
                    NSLog(@"%@ lost robber", [self class]);
                    currentChaseSteps = 0;
                    alertCycle = NO;
                }
                return;
            }
            else
            {
                [self leaveConfusedState];
                [self enterChasingState];
            }
        }
        else
        {
            [self leaveConfusedState];
            [self enterAliveState];
            alertCycle = NO;
        }
        
        
    }
    else if (currentState == COP_ATTRACTED_DOUGHNUT)
    {
        CGFloat distanceToItem = ccpDistance(attractedItemPosition, mapPosition);
        if (distanceToItem < 2)
        {
            //close enough to item
            if (currentState == COP_ATTRACTED_DOUGHNUT)
            {
                [self leaveAttractedDoughnutState];
                [self enterSickState];
            }
    
        }
        else
        {
            nextDirection = [levelPtr findPathToDoughnut:mapPosition];
            if (currentDirection != nextDirection)
            {
                [self turnSprite:nextDirection];
            }
            currentDirection = nextDirection;
            return;
        }
        
    }
    else if (currentState == COP_ATTRACTED_BONUS)
    {
        CGFloat distanceToItem = ccpDistance(attractedItemPosition, mapPosition);
        if (distanceToItem < 1)
        {
            if ([self isKindOfClass:[CCorruptCop class]])
            {
                [(CCorruptCop*)self leaveAttractedBonusState];
                [self enterAliveState];
            }

        }
        else
        {
            nextDirection = [levelPtr findPathToBonus:mapPosition];
            if (currentDirection != nextDirection)
            {
                [self turnSprite:nextDirection];
            }
            currentDirection = nextDirection;
            return;
        }

    }
    else if (currentState == COP_ATTRACTED_SEXBOT)
    {
        nextDirection = [levelPtr findPathToSexbot:mapPosition];
        if (currentDirection != nextDirection)
        {
            [self turnSprite:nextDirection];
        }
        currentDirection = nextDirection;
        return;

    }
    else if (currentState == COP_SICK)
    {
        CGFloat distanceToStation = ccpDistance([levelPtr copStart], mapPosition);
        CGPoint homeBase = [levelPtr copStart];
        homeBase.y = homeBase.y - 1;
        if (distanceToStation <= 1.5)
        {
            [self leaveSickState];
            [self removeCop];
        }
        if ([self checkIfCanTurn])
        {
            nextDirection = [levelPtr findPathToHome:mapPosition];
            if (currentDirection != nextDirection)
            {
                [self turnSprite:nextDirection];
            }
            currentDirection = nextDirection;
            return;
            
            
        }
    }
    else if (currentState == COP_SCARED)
    {
        nextDirection = [levelPtr findPathFromLawyer:mapPosition];
        if (currentDirection != nextDirection)
        {
            [self turnSprite:nextDirection];
        }
        currentDirection = nextDirection;
        return;
    }
    
}

-(void) stopMoving: (BOOL)rival
{
    if (currentState == COP_CHASING)
    {
        [self leaveChasingState];
    }
    else if (currentState == COP_CONFUSED)
    {
        [self leaveConfusedState];
    }
    if (rival == YES)
    {
        currentState = COP_BLINDED_RIVAL;
    }
    else
    {
        currentState = COP_ATTACKING;
    }
    
    [charSprite runAction:[CCHide action]];
    [self schedule:@selector(resumeMoving) interval:1.5];
}

-(void) resumeMoving
{
    [self enterAliveState];
    [self unschedule:@selector(resumeMoving)];
    [charSprite runAction:[CCShow action]];
    [self update:velocity/4];
}

-(BOOL) checkIfSeesRobber:(CGPoint)robberPosition
{
    BOOL canSee = NO;
    if (ccpDistance(robberPosition, mapPosition) < 1)
    {
        //on same tile
        return YES;
    }
    enum DIRECTION tempDirection;
    //does x or y values match?
    if (robberPosition.y == mapPosition.y) //robber left or right of cop
    {
        //rober in line with cop; is he close enough to see?
        if ((currentDirection == DIR_LEFT) && ((mapPosition.x - robberPosition.x) < sightThreshold) && ((mapPosition.x - robberPosition.x) >= 0))
        {
            canSee = YES;
            tempDirection = DIR_LEFT;
            for (int i = 1; i < sightThreshold; i++)
            {
                
                if (![levelPtr verifyMove:mapPosition.x - i :mapPosition.y]) //no path to Robber
                {
                    canSee = NO;
                    break;
                }
                if (mapPosition.x - i == robberPosition.x) //robber is closer than the farthest sightThreshold value
                {
                    break;
                }
            }
        }
        else if ((currentDirection == DIR_RIGHT) && ((robberPosition.x - mapPosition.x) < sightThreshold) && (robberPosition.x - mapPosition.x) >= 0)
        {
            canSee = YES;
            tempDirection = DIR_RIGHT;
            for (int i = 1; i < sightThreshold; i++)
            {
                
                if (![levelPtr verifyMove:mapPosition.x + i :mapPosition.y]) //no path to Robber
                {
                    canSee = NO;
                    break;
                }
                if (mapPosition.x + i == robberPosition.x) //robber is closer than the farthest sightThreshold value
                {
                    break;
                }
            }
        }
    }
    else if (robberPosition.x == mapPosition.x) //robber above or below cop
    {
        //rober in line with cop; is he close enough to see?
        if ((currentDirection == DIR_DOWN) && ((mapPosition.y - robberPosition.y) < sightThreshold) && (mapPosition.y - robberPosition.y) >= 0)
        {
            canSee = YES;
            tempDirection = DIR_DOWN;
            for (int i = 1; i < sightThreshold; i++)
            {
                
                if (![levelPtr verifyMove:mapPosition.x :(mapPosition.y - i)]) //no path to Robber
                {
                    canSee = NO;
                    break;
                }
                if (mapPosition.y - i == robberPosition.y) //robber is closer than the farthest sightThreshold value
                {
                    break;
                }
            }
        }
        else if ((currentDirection == DIR_UP) && ((robberPosition.y - mapPosition.y) < sightThreshold) && (robberPosition.y - mapPosition.y) >= 0)
        {
            canSee = YES;
            tempDirection = DIR_UP;
            for (int i = 1; i < sightThreshold; i++)
            {
                
                if (![levelPtr verifyMove:mapPosition.x :(mapPosition.y + i)]) //no path to Robber
                {
                    canSee = NO;
                    break;
                }
                if (mapPosition.x + i == robberPosition.x) //robber is closer than the farthest sightThreshold value
                {
                    break;
                }
            }
        }
    }
    
    if (canSee == YES)
    {
        nextDirection = tempDirection;
        if (currentDirection != nextDirection)
        {
            [self turnSprite:nextDirection];
        }
    }
    return canSee;
}

//state changes

-(void) enterChasingState
{
    currentState = COP_CHASING;
    NSLog(@"%@ chasing", [self class]);
    currentVelocity = chaseVelocity;
    CGPoint position = [self getPosition];
    alertEmote = [CCSprite spriteWithFile:@"Graphics/Emotes/alert.png"];
    alertEmote.position = ccp((position.x + tileSize / 2), (position.y + tileSize * 2 + (tileSize / 4)));
    [[levelPtr mapLayer] addChild:alertEmote z:Z_CHARACTERS];
    
    CCScaleTo *scaleUp = [CCScaleTo actionWithDuration:0.5 scale:2.0];
    CCScaleTo *scaleDown = [CCScaleTo actionWithDuration:0.5 scale:1.0];
    CCRepeatForever *scaleRepeat = [CCRepeatForever actionWithAction:[CCSequence actionOne:scaleUp two:scaleDown]];
    [alertEmote runAction:scaleRepeat];
    NSLog(@"velocity: %i", currentVelocity);
}

-(void) leaveChasingState
{
    [[levelPtr mapLayer] removeChild:alertEmote cleanup:YES];
}

-(void) enterConfusedState
{
    currentState = COP_CONFUSED;
    currentChaseSteps = 1;
    confusedEmote = [CCSprite spriteWithFile:@"Graphics/Emotes/confused.png"];
    CGPoint position = [self getPosition];
    confusedEmote.position = ccp((position.x + tileSize / 2), (position.y + tileSize * 2 + (tileSize / 4)));
    [[levelPtr mapLayer] addChild:confusedEmote z:Z_CHARACTERS];
}

-(void) leaveConfusedState
{
    [[levelPtr mapLayer] removeChild:confusedEmote cleanup:YES];
}

-(void) enterBlindedState
{
    if (currentState == COP_CHASING)
    {
        [self leaveChasingState];
        currentVelocity = velocity;
        NSLog(@"velocity: %i", currentVelocity);
    }
    else if (currentState == COP_CONFUSED)
    {
        [self leaveConfusedState];
        currentVelocity = velocity;
        NSLog(@"velocity: %i", currentVelocity);
    }
    else if (currentState == COP_SCARED)
    {
        [self leaveScaredState];
        currentVelocity = velocity;
        NSLog(@"velocity: %i", currentVelocity);
    }
    alertCycle = NO;
    currentState = COP_BLINDED;
    currentVelocity = currentVelocity / 2;
    NSLog(@"%@ blinded.", [self class]);
    NSLog(@"velocity: %i", currentVelocity);
    [levelPtr copBlinded];
}

-(void) leaveBlindedState
{
    [self enterAliveState];
    NSLog(@"%@ no longer blinded.", [self class]);
}

-(void) enterAttractedDoughnutState:(CGPoint)itemPosition
{
    if (currentState == COP_CHASING)
    {
        [self leaveChasingState];
    }
    else if (currentState == COP_CONFUSED)
    {
        [self leaveConfusedState];
    }
    alertCycle = NO;
    NSLog(@"%@ attracted to doughnut", [self class]);
    attractedItemPosition = itemPosition;
    currentVelocity = currentVelocity * 2;
    currentState = COP_ATTRACTED_DOUGHNUT;
    CGPoint position = [self getPosition];
    
    attractSystem = [[CCParticleSystemQuad alloc] initWithTotalParticles:50];
    [attractSystem setTexture:[[CCTextureCache sharedTextureCache] addImage:@"Graphics/Emotes/attracted.png"]];
    attractSystem.duration = -1;
    [attractSystem setGravity: CGPointZero];
    [attractSystem setSpeed:50];
    [attractSystem setSpeedVar:10];
    [attractSystem setLife:0.06];
    [attractSystem setLifeVar:1.0];
    [attractSystem setRadialAccel:0];
    [attractSystem setRadialAccelVar:0];
    [attractSystem setTangentialAccel:0];
    [attractSystem setTangentialAccelVar:0];
    [attractSystem setPosVar:ccp(0,0)];
    [attractSystem setAngle:90];
    [attractSystem setAngleVar:360];
    [attractSystem setStartColor:ccc4f(1.0, 1.0, 1.0, 0.8)];
    [attractSystem setEndColor:ccc4f(1.0, 1.0, 1.0, 0.5)];
    [attractSystem setEndColorVar:ccc4f(0.0, 0.0, 0.0, 0.5)];
    [attractSystem setStartSize:8];
    [attractSystem setEndSize:2];
    [attractSystem setEmissionRate:20];
    [attractSystem setPosition:ccp((position.x + tileSize / 2), (position.y + tileSize * 2 + (tileSize / 4)))];
    
    attractEmote = [CCSprite spriteWithFile:@"Graphics/Emotes/attracted.png"];
    attractEmote.position = ccp((position.x + tileSize / 2), (position.y + tileSize * 2 + (tileSize / 4)));
    
    [[levelPtr mapLayer] addChild:attractSystem z:Z_EFFECTS];
    [[levelPtr mapLayer] addChild:attractEmote z:Z_CHARACTERS];
    NSLog(@"velocity: %i", currentVelocity);
}

-(void) leaveAttractedDoughnutState
{
    NSLog(@"%@ no longer attracted to doughnut", [self class]);
    [[levelPtr mapLayer] removeChild:attractEmote cleanup:YES];
    [[levelPtr mapLayer] removeChild:attractSystem cleanup:YES];
    [self enterAliveState];
}

-(void) enterAliveState
{
    NSLog(@"%@ entering alive state.", [self class]);
    currentState = COP_ALIVE;
    currentVelocity = velocity;
    NSLog(@"velocity: %i", currentVelocity);
}

-(void) enterSickState
{
    if (currentState == COP_CHASING)
    {
        [self leaveChasingState];
    }
    else if (currentState == COP_CONFUSED)
    {
        [self leaveConfusedState];
    }
    alertCycle = NO;
    NSLog(@"%@ entering sick state.", [self class]);
    currentState = COP_SICK;
    currentVelocity = velocity * 3;
    NSLog(@"velocity: %i", currentVelocity);
    [levelPtr copSickened];
    [self turnSprite:currentDirection];
}

-(void) leaveSickState
{
    NSLog(@"%@ leaving sick state.", [self class]);
    [self turnSprite:currentDirection];
}

-(void) removeCop
{
    distanceToNextTile = 0;
    mapPosition = [levelPtr copStart];
    gridPosition = [levelPtr copStart];
    currentDirection = DIR_DOWN;
    nextDirection = DIR_LEFT;
    currentState = COP_DEAD;
    charSprite.visible = NO;
    [levelPtr schedule:@selector(respawnCops) interval:5.0];
}

-(void) showCop
{
    [self turnSprite:currentDirection];
    [self scheduleOnce:@selector(enterAliveState) delay:1.0];
    //CLevel *levelPtr = (CLevel *)[self parent];
    charSprite.position = ccp(((mapPosition.x * tileSize)), (mapPosition.y * tileSize));
    charSprite.visible = YES;
}

-(void) enterAttractedSexbotState: (CGPoint)itemPosition
{
    if (currentState == COP_CHASING)
    {
        [self leaveChasingState];
    }
    else if (currentState == COP_CONFUSED)
    {
        [self leaveConfusedState];
    }
    alertCycle = NO;
    NSLog(@"%@ attracted to sexbot", [self class]);
    attractedItemPosition = itemPosition;
    currentVelocity = currentVelocity * 2;
    currentState = COP_ATTRACTED_SEXBOT;
    CGPoint position = [self getPosition];
    
    attractSystem = [[CCParticleSystemQuad alloc] initWithTotalParticles:50];
    [attractSystem setTexture:[[CCTextureCache sharedTextureCache] addImage:@"Graphics/Emotes/attracted.png"]];
    attractSystem.duration = -1;
    [attractSystem setGravity: CGPointZero];
    [attractSystem setSpeed:50];
    [attractSystem setSpeedVar:10];
    [attractSystem setLife:0.06];
    [attractSystem setLifeVar:1.0];
    [attractSystem setRadialAccel:0];
    [attractSystem setRadialAccelVar:0];
    [attractSystem setTangentialAccel:0];
    [attractSystem setTangentialAccelVar:0];
    [attractSystem setPosVar:ccp(0,0)];
    [attractSystem setAngle:90];
    [attractSystem setAngleVar:360];
    [attractSystem setStartColor:ccc4f(1.0, 1.0, 1.0, 0.8)];
    [attractSystem setEndColor:ccc4f(1.0, 1.0, 1.0, 0.5)];
    [attractSystem setEndColorVar:ccc4f(0.0, 0.0, 0.0, 0.5)];
    [attractSystem setStartSize:8];
    [attractSystem setEndSize:2];
    [attractSystem setEmissionRate:20];
    [attractSystem setPosition:ccp((position.x + tileSize / 2), (position.y + tileSize * 2 + (tileSize / 4)))];
    
    attractEmote = [CCSprite spriteWithFile:@"Graphics/Emotes/attracted.png"];
    attractEmote.position = ccp((position.x + tileSize / 2), (position.y + tileSize * 2 + (tileSize / 4)));
    
    [[levelPtr mapLayer] addChild:attractEmote z:Z_CHARACTERS];
    [[levelPtr mapLayer] addChild:attractSystem z:Z_EFFECTS];
    NSLog(@"velocity: %i", currentVelocity);

}

-(void) leaveAttractedSexbotState
{
    NSLog(@"%@ no longer attracted to sexbot", [self class]);
    [[levelPtr mapLayer] removeChild:attractEmote cleanup:YES];
    [[levelPtr mapLayer] removeChild:attractSystem cleanup:YES];
    [self enterAliveState];
}

-(void) enteringScaredState: (CGPoint)itemPosition
{
    if (currentState == COP_CHASING)
    {
        [self leaveChasingState];
    }
    else if (currentState == COP_CONFUSED)
    {
        [self leaveConfusedState];
    }
    alertCycle = NO;
    NSLog(@"%@ running from lawyer", [self class]);
    attractedItemPosition = itemPosition;
    currentVelocity = currentVelocity * 2;
    currentState = COP_SCARED;
    scaredEmote = [CCSprite spriteWithFile:@"Graphics/Emotes/scared.png"];
    CGPoint position = [self getPosition];
    scaredEmote.position = ccp((position.x + tileSize / 2), (position.y + tileSize * 2 + (tileSize / 4)));
    [[levelPtr mapLayer] addChild:scaredEmote z:Z_CHARACTERS];
    
    scaredSystem = [[CCParticleSystemQuad alloc] initWithTotalParticles:50];
    [scaredSystem setTexture:[[CCTextureCache sharedTextureCache] addImage:@"Graphics/Emotes/scared.png"]];
    [scaredSystem setEmitterMode:kCCParticleModeRadius];
    scaredSystem.duration = -1;
    [scaredSystem setStartRadius:10.0];
    [scaredSystem setLife:0.06];
    [scaredSystem setLifeVar:1.0];
    [scaredSystem setPosVar:ccp(0,0)];
    [scaredSystem setAngle:90];
    [scaredSystem setAngleVar:360];
    [scaredSystem setStartColor:ccc4f(1.0, 1.0, 1.0, 0.2)];
    [scaredSystem setEndColor:ccc4f(1.0, 1.0, 1.0, 0.5)];
    [scaredSystem setEndColorVar:ccc4f(0.0, 0.0, 0.0, 1.0)];
    [scaredSystem setStartSize:12];
    [scaredSystem setEndSize:24];
    [scaredSystem setEmissionRate:40];
    [scaredSystem setPosition:ccp((position.x + tileSize / 2), (position.y + tileSize * 2 + (tileSize / 4)))];
    [[levelPtr mapLayer] addChild:scaredSystem z:Z_EFFECTS];
    
    NSLog(@"velocity: %i", currentVelocity);
    [levelPtr copScared];

}

-(void) leaveScaredState
{
    NSLog(@"%@ no longer scared", [self class]);
    [[levelPtr mapLayer] removeChild:scaredEmote cleanup:YES];
    [[levelPtr mapLayer] removeChild:scaredSystem cleanup:YES];
    [self enterAliveState];
}

-(void) enterDyingState
{
    switch (currentState)
    {
        case COP_ATTRACTED_DOUGHNUT:
            [self leaveAttractedDoughnutState];
            break;
        case COP_ATTRACTED_SEXBOT:
            [self leaveAttractedSexbotState];
            break;
        case COP_BLINDED:
            [self leaveBlindedState];
            break;
        case COP_CHASING:
            [self leaveChasingState];
            break;
        case COP_CONFUSED:
            [self leaveConfusedState];
            break;
        case COP_SCARED:
            [self leaveScaredState];
            break;
            
        default:
            break;
    }
    currentState = COP_DYING;
    [self scheduleOnce:@selector(removeCop) delay:5.0];
    [self turnSprite:DIR_DOWN];
    alertCycle = NO;
}

-(void) enterAttackingState
{
    
}

-(void) leaveAttackingState
{
    
}

-(void) saveState:(NSMutableDictionary *)saveData
{
    
}

@end
