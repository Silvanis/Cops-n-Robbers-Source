//
//  HelloWorldLayer.m
//  CopsnRobbersTest
//
//  Created by John Markle on 5/24/12.
//  Copyright Silver Moonfire LLC 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "CRobber.h"
#import "CScore.h"
#import "OptionsScreenViewController.h"
#import "InstructionsViewController.h"
#import "AppDelegate.h"
#import "RootViewController.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
    layer.tag = 5555;

	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        
        CCSprite *bg;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            if ([[UIScreen mainScreen] bounds].size.height == 568)
            {
                bg = [CCSprite spriteWithFile:@"main UI iPhone5.png"];
            }
            else
            {
                bg = [CCSprite spriteWithFile:@"main UI.png"];
            }
            
        }
        else
        {
            bg = [CCSprite spriteWithFile:@"main UI-ipad.png"];
        }
        
        bg.anchorPoint = ccp(0,0);
        [bg setPosition:ccp(0,0)];
        [self addChild:bg z:Z_UI];
        BOOL continuePressed = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ContinuePressed"]boolValue];
        if (continuePressed)
        {
            level = [CLevel levelWithSaveStateParentNode:self];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ContinuePressed"];
        }
        else
        {
            level = [CLevel levelWithParentNode:self];
        }
        
        
        self.isAccelerometerEnabled = NO;
        self.isTouchEnabled = YES;
        gameState = GAME_STATE_RUNNING;
        [self schedule:@selector(showInstructions)];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"PausedState"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endPausedState) name:@"ExitPauseScreen" object:nil];
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ExitPauseScreen" object:nil];
	// don't forget to call "super dealloc"
	[super dealloc];
}

-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    CRobber *robber = (CRobber *)[level getChildByTag:CHARACTER_ROBBER];
    BOOL shouldMove = NO;
    
    enum DIRECTION direction;
    //since game is in landscape mode, x and y are reversed. Accelerometer x is game y
    if (acceleration.x > 0.05) 
    {
        //UP
        shouldMove = YES;
        direction = DIR_UP;
    } 
    else if(acceleration.x < -0.35)
    {
        //DOWN
        shouldMove = YES;
        direction = DIR_DOWN;
    }
    else if(acceleration.y > 0.25)
    {
        //LEFT
        shouldMove = YES;
        direction = DIR_LEFT;
    }
    else if(acceleration.y < -0.25)
    {
        //RIGHT
        shouldMove = YES;
        direction = DIR_RIGHT;
    }
    
    if (shouldMove) 
    {
            [robber turnCharacter:direction];
    }
    
}

-(void) registerWithTouchDispatcher
{
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN + 1 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CRobber *robber = (CRobber *)[level getChildByTag:CHARACTER_ROBBER];
    if (gameState == GAME_STATE_INSTRUCTIONS)
    {
        
        [[CCDirector sharedDirector] resume];
        gameState = GAME_STATE_RUNNING;
        
    }
    
    if (gameState == GAME_STATE_PAUSED)
    {
        return YES;
    }
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    firstTouch = touchLocation;
    CGRect joystickBoundingBox;
    CGRect pauseBoundingBox;
    CGRect item1BoundingBox;
    CGRect item2BoundingBox;
    CGRect item3BoundingBox;
    CGRect item4BoundingBox;
    int joystickZonePoint;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        joystickBoundingBox = CGRectMake(0.0, 0.0, 100.0, 100.0);
        
        if ([[UIScreen mainScreen] bounds].size.height == 568)
        {
            pauseBoundingBox = CGRectMake(495.0, 0.0, 60.0, 60.0);
            item1BoundingBox = CGRectMake(270, 8, 40, 40);
            item2BoundingBox = CGRectMake(318, 8, 40, 40);
            item3BoundingBox = CGRectMake(364, 8, 40, 40);
            item4BoundingBox = CGRectMake(412, 8, 40, 40);
        }
        else
        {
            pauseBoundingBox = CGRectMake(420.0, 0.0, 60.0, 60.0);
            item1BoundingBox = CGRectMake(220, 8, 40, 40);
            item2BoundingBox = CGRectMake(268, 8, 40, 40);
            item3BoundingBox = CGRectMake(314, 8, 40, 40);
            item4BoundingBox = CGRectMake(362, 8, 40, 40);
        }
        
        joystickZonePoint = 45;
    }
    else
    {
        joystickBoundingBox = CGRectMake(14.0, 10.0, 200.0, 200.0);
        pauseBoundingBox = CGRectMake(660.0, 40.0, 128.0, 128.0);
        item1BoundingBox = CGRectMake(816, 108, 88, 88);
        item2BoundingBox = CGRectMake(916, 108, 88, 88);
        item3BoundingBox = CGRectMake(816, 8, 88, 88);
        item4BoundingBox = CGRectMake(916, 8, 88, 88);
        joystickZonePoint = 95;
    }
    
    if (CGRectContainsPoint(joystickBoundingBox, touchLocation))
    {
        int xDifference, yDifference;
        xDifference = touchLocation.x - joystickZonePoint;
        yDifference = touchLocation.y - joystickZonePoint;
        if (yDifference >= 0)
        {
            //upper half
            if (abs(xDifference) > yDifference)
            {
                //left or right
                if (xDifference >= 0)
                {
                    //right
                    [robber turnCharacter:DIR_RIGHT];
                }
                else
                {
                    //left
                    [robber turnCharacter:DIR_LEFT];
                }
            }
            else
            {
                //up
                [robber turnCharacter:DIR_UP];
            }
        }
        else
        {
            //lower half
            if (abs(xDifference) > abs(yDifference))
            {
                //left or right
                if (xDifference >= 0)
                {
                    //right
                    [robber turnCharacter:DIR_RIGHT];
                }
                else
                {
                    //left
                    [robber turnCharacter:DIR_LEFT];
                }
            }
            else
            {
                //down
                [robber turnCharacter:DIR_DOWN];
            }
        }
        return YES;
    }
    else if(CGRectContainsPoint(pauseBoundingBox, touchLocation))
    {
        [self schedule:@selector(pauseGame)];
        return YES;
    }
    else if(CGRectContainsPoint(item1BoundingBox, touchLocation))
    {
        //first item box
        NSLog(@"1st item box pressed");
        [level useItem:0];
        return YES;
    }
    else if(CGRectContainsPoint(item2BoundingBox, touchLocation))
    {
        //second item box
        NSLog(@"2nd item box pressed");
        [level useItem:1];
        return YES;
    }
    else if(CGRectContainsPoint(item3BoundingBox, touchLocation))
    {
        //third item box
        NSLog(@"3rd item box pressed");
        [level useItem:2];
        return YES;
    }
    else if (CGRectContainsPoint(item4BoundingBox, touchLocation))
    {
        //fourth item box
        NSLog(@"4th item box pressed");
        [level useItem:3];
        return YES;
    }
    else
    {
        return YES;
    }

}



-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CRobber *robber = (CRobber *)[level getChildByTag:CHARACTER_ROBBER];
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    lastTouch = touchLocation;
    CGRect joystickBoundingBox;
    int joystickZonePoint;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        joystickBoundingBox = CGRectMake(0.0, 0.0, 100.0, 100.0);
        joystickZonePoint = 45;
    }
    else
    {
        joystickBoundingBox = CGRectMake(14.0, 10.0, 200.0, 200.0);
        joystickZonePoint = 95;
    }
    
    if (CGRectContainsPoint(joystickBoundingBox, touchLocation))
    {
        int xDifference, yDifference;
        xDifference = touchLocation.x - joystickZonePoint;
        yDifference = touchLocation.y - joystickZonePoint;
        if (yDifference >= 0)
        {
            //upper half
            if (abs(xDifference) > yDifference)
            {
                //left or right
                if (xDifference >= 0)
                {
                    //right
                    [robber turnCharacter:DIR_RIGHT];
                }
                else
                {
                    //left
                    [robber turnCharacter:DIR_LEFT];
                }
            }
            else
            {
                //up
                [robber turnCharacter:DIR_UP];
            }
        }
        else
        {
            //lower half
            if (abs(xDifference) > abs(yDifference))
            {
                //left or right
                if (xDifference >= 0)
                {
                    //right
                    [robber turnCharacter:DIR_RIGHT];
                }
                else
                {
                    //left
                    [robber turnCharacter:DIR_LEFT];
                }
            }
            else
            {
                //down
                [robber turnCharacter:DIR_DOWN];
            }
        }
        
    }
    else
    {
        //check for swipe
        float swipeLength = ccpDistance(firstTouch, lastTouch);
        
        if (swipeLength > 60)
        {
            //get direction
            if (abs(firstTouch.x - lastTouch.x) > abs(firstTouch.y - lastTouch.y))
            {
                if (firstTouch.x > lastTouch.x)
                {
                    //left
                    [robber turnCharacter:DIR_LEFT];
                }
                else if (lastTouch.x > firstTouch.x)
                {
                    //right
                    [robber turnCharacter:DIR_RIGHT];
                }
                
            }
            else
            {
                if (firstTouch.y > lastTouch.y)
                {
                    //down
                    [robber turnCharacter:DIR_DOWN];
                }
                else if (lastTouch.y > firstTouch.y)
                {
                    //up
                    [robber turnCharacter:DIR_UP];
                }
            }
            firstTouch = lastTouch;
        }

    }
}

-(BOOL)checkForValidMove:(int)x :(int)y
{
    return [level verifyMove:x :y];
}

-(void)pauseGame
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PausedState"];
    [[CCDirector sharedDirector] pause];
    OptionsScreenViewController *pauseScreen;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        pauseScreen = [[OptionsScreenViewController alloc] initWithNibName:@"OptionsScreenViewController-iPad" bundle:[NSBundle mainBundle]];
    }
    else
    {
        
        pauseScreen = [[OptionsScreenViewController alloc] init];
        if ([[UIScreen mainScreen] bounds].size.height == 568)
        {
            pauseScreen.view.frame = CGRectMake(42, 0, 480, 320);
        }
    }
    
    
    UIView *glView = [CCDirector sharedDirector].openGLView;
    [glView addSubview:pauseScreen.view];
    //[pauseScreen release];
    gameState = GAME_STATE_PAUSED;
    [self unschedule:@selector(pauseGame)];
}

-(void)showInstructions
{
    gameState = GAME_STATE_INSTRUCTIONS;
    InstructionsViewController *instructionsView;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        instructionsView = [[InstructionsViewController alloc] init];
    }
    else
    {
        instructionsView = [[InstructionsViewController alloc] initWithNibName:@"InstructionsViewController-iPad" bundle:[NSBundle mainBundle]];
    }
    if ([[UIScreen mainScreen] bounds].size.height == 568)
    {
        instructionsView.view.frame = CGRectMake(42.0, 0, 480, 320);
    }
    UIView *glView = [CCDirector sharedDirector].openGLView;
    [glView addSubview:instructionsView.view];
    //[instructionsView release];
    [[CCDirector sharedDirector] pause];
    [self unschedule:@selector(showInstructions)];
}

-(void)saveState
{
    [level saveState];
}

-(void)endPausedState
{
    gameState = GAME_STATE_RUNNING;
}
@end
