//
//  AppDelegate.m
//  CopsnRobbersTest
//
//  Created by John Markle on 5/24/12.
//  Copyright Silver Moonfire LLC 2012. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "HelloWorldLayer.h"
#import "RootViewController.h"
#import "Flurry/Flurry.h"
#import "TestFlightSDK1/TestFlight.h"
#import "GameKit/GameKit.h"


@implementation AppDelegate

@synthesize window, viewController;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController

//	CC_ENABLE_DEFAULT_GL_STATES();
//	CCDirector *director = [CCDirector sharedDirector];
//	CGSize size = [director winSize];
//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.position = ccp(size.width/2, size.height/2);
//	sprite.rotation = -90;
//	[sprite visit];
//	[[director openGLView] swapBuffers];
//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}
- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	//window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSString *uuidString;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"] == nil)
    {
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        CFStringRef string = CFUUIDCreateString(NULL, theUUID);
        CFRelease(theUUID);
        uuidString = [NSString stringWithString:(NSString *)string];
    }
    else
    {
        uuidString = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"]stringValue];
    }
    [Flurry setUserID:uuidString];
    [Flurry setDebugLogEnabled:NO];
	[Flurry startSession:@""];
    //[TestFlight takeOff:@""];
    

	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
/*
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
*/	
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
//	if( ! [director enableRetinaDisplay:YES] )
//		CCLOG(@"Retina Display Not supported");
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:YES];
	
	
	// make the OpenGLView a child of the view controller
//	[viewController setView:glView];
	
    [director enableRetinaDisplay:YES];
    
	// make the View Controller a child of the main window
//	[window addSubview: viewController.view];
	
//	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	
	// Removes the startup flicker
	[self removeStartupFlicker];
	
	// Run the intro Scene
//	[[CCDirector sharedDirector] runWithScene: [HelloWorldLayer scene]];
    
    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {}];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
    
    [viewController saveState];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    BOOL pausedState = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PausedState"]boolValue];
    if (pausedState)
    {
        [[CCDirector sharedDirector] pause];
    }
    else
    {
        [[CCDirector sharedDirector] resume];
    }
	
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    // Your application should implement these two methods.
    int lives = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Lives"]intValue];
    NSString *productID = [[transaction payment] productIdentifier];
    if ([productID isEqualToString:@"CnR5Lives"])
    {
        lives = lives + 5;
        [[NSUserDefaults standardUserDefaults] setInteger:lives forKey:@"Lives"];
    }
    else if ([productID isEqualToString:@"CnR15Lives"])
    {
        lives = lives + 15;
        [[NSUserDefaults standardUserDefaults] setInteger:lives forKey:@"Lives"];
    }
    else if ([productID isEqualToString:@"CnR30Lives"])
    {
        lives = lives + 30;
        [[NSUserDefaults standardUserDefaults] setInteger:lives forKey:@"Lives"];
    }
    else if ([productID isEqualToString:@"CnR50Lives"])
    {
        lives = lives + 50;
        [[NSUserDefaults standardUserDefaults] setInteger:lives forKey:@"Lives"];
    }
    else if ([productID isEqualToString:@"CnR96Lives"])
    {
        lives = lives + 96;
        [[NSUserDefaults standardUserDefaults] setInteger:lives forKey:@"Lives"];
    }
    
    
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank you!" message:[NSString stringWithFormat:@"Thank you for your purchase! Current Lives: %i", lives] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    int lives = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Lives"]intValue];
    NSString *productID = [[transaction payment] productIdentifier];
    if ([productID isEqualToString:@"CnR5Lives"])
    {
        lives = lives + 5;
        [[NSUserDefaults standardUserDefaults] setInteger:lives forKey:@"Lives"];
    }
    else if ([productID isEqualToString:@"CnR15Lives"])
    {
        lives = lives + 15;
        [[NSUserDefaults standardUserDefaults] setInteger:lives forKey:@"Lives"];
    }
    else if ([productID isEqualToString:@"CnR30Lives"])
    {
        lives = lives + 30;
        [[NSUserDefaults standardUserDefaults] setInteger:lives forKey:@"Lives"];
    }
    else if ([productID isEqualToString:@"CnR50Lives"])
    {
        lives = lives + 50;
        [[NSUserDefaults standardUserDefaults] setInteger:lives forKey:@"Lives"];
    }
    else if ([productID isEqualToString:@"CnR96Lives"])
    {
        lives = lives + 96;
        [[NSUserDefaults standardUserDefaults] setInteger:lives forKey:@"Lives"];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // Optionally, display an error here.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Transaction Failed" message:transaction.error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

@end
