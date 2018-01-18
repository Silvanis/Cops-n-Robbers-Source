//
//  GameOverViewController.m
//  Cops 'n Robbers
//
//  Created by John Markle on 6/19/13.
//  Copyright (c) 2013 Silver Moonfire LLC. All rights reserved.
//

#import "GameOverViewController.h"
#import "StoreKit/StoreKit.h"
#import "StoreViewController.h"
#import "cocos2d.h"

@interface GameOverViewController ()

@end

@implementation GameOverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(id)initWithScoreData:(int)score
{
    if (self = [super init])
    {
        scoreForLabel = score;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [self initWithNibName:@"GameOverViewController-iPad" bundle:[NSBundle mainBundle]];
        }
        else
        {
            [self initWithNibName:@"GameOverViewController" bundle:[NSBundle mainBundle]];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissScreen:) name:@"ResetLives" object:nil];
    }
    
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _scoreLabel.text = [NSString stringWithFormat:@"%d", scoreForLabel];
    // Update Game Center scores
    NSString *category;

    category = @"grp.CNRGLobalLeaderboad";
    
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        GKScore *scoreReporter = [[GKScore alloc] initWithCategory:category];
        scoreReporter.value = scoreForLabel;
        scoreReporter.context = 0;
        scoreReporter.shouldSetDefaultLeaderboard = YES;
        
        [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
            // Do something interesting here.
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_scoreLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setScoreLabel:nil];
    [super viewDidUnload];
}
- (IBAction)quitGamePressed:(id)sender
{
    [self.view removeFromSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QuitButton" object:nil];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"Lives"]intValue] == 0)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"Lives"];
    }
}

- (IBAction)highScoresPressed:(id)sender
{
    NSString *leaderboardID;
    
    leaderboardID = @"grp.CNRGLobalLeaderboad";

    
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        if ([GKGameCenterViewController class]) {
            GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
            if (gameCenterController != nil)
            {
                gameCenterController.gameCenterDelegate = self;
                gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
                gameCenterController.leaderboardTimeScope = GKLeaderboardTimeScopeToday;
                gameCenterController.leaderboardCategory = leaderboardID;
                [self presentViewController: gameCenterController animated: YES completion:nil];
            }
        }
        else {
            GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
            if (leaderboardController != nil)
            {
                leaderboardController.leaderboardDelegate = self;
                leaderboardController.timeScope = GKLeaderboardTimeScopeToday;
                leaderboardController.category = leaderboardID;
                [self presentViewController: leaderboardController animated: YES completion:nil];
            }
        }
    }
    else {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:nil message:@"Please log in to Game Center to view scores." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] autorelease];
        [alertView show];
    }

}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)leaderboardViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)restartLevelPressed:(id)sender
{
    [self.view removeFromSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RestartLevelPressed" object:nil];
}

- (IBAction)buyLivesPressed:(id)sender
{
    if ([SKPaymentQueue canMakePayments])
    {
        // Display a store to the user.
        StoreViewController *controller;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            controller = [[StoreViewController alloc] initWithNibName:@"StoreViewController-ipad" bundle:nil parent:@"GameOver"];
        }
        else
        {
            controller = [[StoreViewController alloc] initWithNibName:@"StoreViewController" bundle:nil parent:@"GameOver"];
        }
        UIView *glView = [CCDirector sharedDirector].openGLView;
        [glView addSubview:controller.view];
        //[self presentViewController:controller animated:YES completion:nil];
        //[controller release];
    }
    else
    {
        // Warn the user that purchases are disabled.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Disabled Purchases" message:@"In App Purchases have been disabled on this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    
}

-(void)dismissScreen:(NSNotification *)notification
{
    [self.view removeFromSuperview];
    
}
@end
