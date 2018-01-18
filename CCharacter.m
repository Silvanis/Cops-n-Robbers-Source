//
//  CCharacter.m
//  CopsnRobbersTest
//
//  Created by John Markle on 9/12/12.
//  Copyright 2012 Silver Moonfire LLC. All rights reserved.
//

#import "CCharacter.h"
#import "CRobber.h"
#import "CLevel.h"

@implementation CCharacter
@synthesize charSprite, mapPosition;
-(id) initWithParentNode:(CCNode*)parentNode
{
    if (self = [super init]) 
    {
        levelPtr = (CLevel *)parentNode;
        tileSize = getTileSize();
        currentVelocity = velocity;
        distanceToNextTile = 0.0;
        currentDirection = DIR_RIGHT;
        nextDirection = DIR_RIGHT;
        [self scheduleUpdate];
        turnedAround = NO;
        mapPosition = [levelPtr copStart];
        gridPosition = [levelPtr copStart];
        
    }
    
    return self;
}

-(void) update:(ccTime) time
{
        
    CGPoint position = charSprite.position;
    distanceIncrement = currentVelocity * time;
    
    [self moveCharacter:&position];
    
}

-(void) moveCharacter:(CGPoint *)position
{
    CGPoint charPosition = charSprite.position;
    
    distanceToNextTile = distanceToNextTile + distanceIncrement;
    if (distanceToNextTile > (tileSize - (tileSize / 16)))
    {
        //NSLog(@"Current Direection: %d", currentDirection);
        //NSLog(@"Grid Position: %f , %f",gridPosition.x, gridPosition.y);
        
        //close enough to tile; set position on tile
        if (currentDirection == DIR_RIGHT)
        {
            if (gridPosition.x < 23.0 && !turnedAround && [levelPtr verifyMove:(mapPosition.x + 1) :mapPosition.y])
            {
                gridPosition.x = gridPosition.x + 1;
                mapPosition.x = mapPosition.x + 1;
            }
            charPosition.x = (gridPosition.x * tileSize);
            
        }
        else if (currentDirection == DIR_LEFT)
        {
            if (gridPosition.x > 0.0 && !turnedAround && [levelPtr verifyMove:(mapPosition.x - 1) :mapPosition.y])
            {
                gridPosition.x = gridPosition.x - 1;
                mapPosition.x = mapPosition.x - 1;
            }
            charPosition.x = (gridPosition.x * tileSize);
            
        }
        else if (currentDirection == DIR_UP)
        {
            if (gridPosition.y < [levelPtr mapHeight] && !turnedAround && [levelPtr verifyMove:mapPosition.x :(mapPosition.y + 1)])
            {
                gridPosition.y = gridPosition.y + 1;
                mapPosition.y = mapPosition.y + 1;
                
                if ([self isKindOfClass:[CRobber class]] )
                {
                    if ((mapPosition.y > 7) && ([levelPtr mapHeight] > 16) && (([levelPtr mapHeight] - 7.5) > mapPosition.y))
                    {
                        //[levelPtr moveMap:(distanceIncrement - tileSize - (tileSize / 16))];
                        [levelPtr moveMap:(distanceIncrement)];
                    }
                }
            }
            
            charPosition.y = (gridPosition.y * tileSize);
            
            
            
        }
        else if (currentDirection == DIR_DOWN)
        {
            if (gridPosition.y > 0.0 && !turnedAround && [levelPtr verifyMove:mapPosition.x :(mapPosition.y -1)])
            {
                gridPosition.y = gridPosition.y - 1;
                mapPosition.y = mapPosition.y -1;
                
                if ([self isKindOfClass:[CRobber class]] )
                {
                    if ((mapPosition.y < ([levelPtr mapHeight] - 7.5)) && ([levelPtr mapHeight] > 16) && (mapPosition.y > 7))
                    {
                        //[levelPtr moveMap:-(distanceIncrement - (tileSize - (tileSize / 16)))];
                        [levelPtr moveMap:-(distanceIncrement)];
                    }
                }
            }
            charPosition.y = (gridPosition.y * tileSize);
            
            
            
        }
        charSprite.position = charPosition;
        [levelPtr enteringSquare:mapPosition.x y:mapPosition.y sender:self];
        
        [self determineNextMove];
        
        
        distanceToNextTile = 0.0;
        turnedAround = NO;
    }
    else
    {
        if (currentDirection == DIR_LEFT)
        {
            if (gridPosition.x >= 1 && [levelPtr verifyMove:(mapPosition.x - 1) :mapPosition.y])
            {
                charPosition.x -= distanceIncrement;
            }
            
        }
        else if (currentDirection == DIR_RIGHT && [levelPtr verifyMove:(mapPosition.x + 1) :mapPosition.y])
        {
            if (gridPosition.x <= 23)
            {
                charPosition.x += distanceIncrement;
            }
        }
        else if (currentDirection == DIR_UP && [levelPtr verifyMove:mapPosition.x :(mapPosition.y + 1)])
        {
            if (gridPosition.y < [levelPtr mapHeight])
            {
                charPosition.y += distanceIncrement;
                
                if ([self isKindOfClass:[CRobber class]] )
                {
                    if ((mapPosition.y > 7) && ([levelPtr mapHeight] > 16) && (([levelPtr mapHeight] - 7.5) > mapPosition.y))
                    {
                        [levelPtr moveMap:distanceIncrement];
                    }
                }
            }
        }
        else if (currentDirection == DIR_DOWN && [levelPtr verifyMove:mapPosition.x :(mapPosition.y - 1)])
        {
            if (gridPosition.y >= 1)
            {
                charPosition.y -= distanceIncrement;
                if ([self isKindOfClass:[CRobber class]] )
                {
                    if (([levelPtr mapHeight] > 16) && (mapPosition.y > 7) && (mapPosition.y < ([levelPtr mapHeight] - 7.5)))
                    {
                        [levelPtr moveMap:-distanceIncrement];
                    }
                }
            }
        }
        else {
            //NSLog(@"Cannot move in that direction.");
        }
        charSprite.position = charPosition;
    }

}

-(void) turnSprite:(enum DIRECTION)direction
{
    //override in child class
}


-(BOOL) checkIfCanTurn
{
    BOOL canTurn = NO;
    if ((currentDirection == DIR_LEFT) || (currentDirection == DIR_RIGHT))
    {
        if ([levelPtr verifyMove:mapPosition.x :(mapPosition.y + 1)] || [levelPtr verifyMove:mapPosition.x :(mapPosition.y - 1)])
        {
            canTurn = YES;
        }
    }
    else if ((currentDirection == DIR_UP) || (currentDirection == DIR_DOWN))
    {
        if ([levelPtr verifyMove:(mapPosition.x + 1) :mapPosition.y] || [levelPtr verifyMove:(mapPosition.x - 1) :mapPosition.y])
        {
            canTurn = YES;
        }
    }
    else
    {
        canTurn = NO;
    }
    return canTurn;

}



-(CGPoint) getPosition
{
    return charSprite.position;
}

-(void) determineNextMove
{
    
}

@end
