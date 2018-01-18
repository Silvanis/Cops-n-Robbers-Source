//
//  TitleScreenController.m
//  Cops 'n Robbers
//
//  Created by John Markle on 12/27/12.
//  Copyright (c) 2012 Silver Moonfire LLC. All rights reserved.
//

#import "TitleScreenController.h"
#import "LevelSelectViewController.h"
#import "SimpleAudioEngine.h"
#import "StoreViewController.h"
#import "StoreKit/StoreKit.h"

@interface TitleScreenController ()

@end

@implementation TitleScreenController

@synthesize rootViewController = _rootViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitToMainMenu:) name:@"quitToMainMenu" object:nil];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *bundlePath = [NSString stringWithFormat:@"%@/savestate.plist", documentsDirectoryPath];
    BOOL saveExists = [[[NSUserDefaults standardUserDefaults] objectForKey:@"SaveExists"]boolValue];
    if ([[NSFileManager defaultManager] fileExistsAtPath:bundlePath] && (saveExists == YES))
    {
        [_continueButton setEnabled:YES];
    }
    else
    {
        [_continueButton setEnabled:NO];
    }
    _webView.delegate = self;
    NSURL *newsURL = [NSURL URLWithString:@"http://silvermoonfire.com/CopsNRobbers/news.html"];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:newsURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *reponse, NSData *content, NSError *error) {
        if (content != nil) {
            NSDictionary *headers = [(NSHTTPURLResponse *)reponse allHeaderFields];
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"newsChanged"] == nil || ![[[NSUserDefaults standardUserDefaults] objectForKey:@"newsChanged"] isEqualToString:[headers objectForKey:@"Last-Modified"]])
            {
                [[NSUserDefaults standardUserDefaults] setObject:[headers objectForKey:@"Last-Modified"] forKey:@"newsChanged"];
                
                [_webView loadData:content MIMEType:[headers objectForKey:@"Content-Type"] textEncodingName:@"utf-8" baseURL:newsURL];
            }
            else
            {
                [_webView setHidden:YES];
            }
            
            
        }
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *bundlePath = [NSString stringWithFormat:@"%@/savestate.plist", documentsDirectoryPath];
    BOOL saveExists = [[[NSUserDefaults standardUserDefaults] objectForKey:@"SaveExists"]boolValue];
    if ([[NSFileManager defaultManager] fileExistsAtPath:bundlePath] && (saveExists == YES))
    {
        [_continueButton setEnabled:YES];
    }
    else
    {
        [_continueButton setEnabled:NO];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Master Volume"] == nil)
    {
        //setup volume levels/controls
        [[NSUserDefaults standardUserDefaults] setFloat:1.0 forKey:@"Master Volume"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Master Volume Mute"];
        [[NSUserDefaults standardUserDefaults] setFloat:0.4 forKey:@"Music Volume"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Music Volume Mute"];
        [[NSUserDefaults standardUserDefaults] setFloat:1.0 forKey:@"Sound Volume"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Sound Volume Mute"];
    }
    float backgroundVolume = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Master Volume"] floatValue] * [[[NSUserDefaults standardUserDefaults] objectForKey:@"Music Volume"] floatValue];
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:backgroundVolume];
    if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying])
    {
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Sound/Music/LLS - Fragments.mp3"];
    }
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"Master Volume Mute"] boolValue])
    {
        [[SimpleAudioEngine sharedEngine] setMute:YES];
    }
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"Music Volume Mute"] boolValue])
    {
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
    }
    

}
- (IBAction)newGameTapped:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"LevelToLoad"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ContinuePressed"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *bundlePath = [NSString stringWithFormat:@"%@/savestate.plist", documentsDirectoryPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:bundlePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:bundlePath error:nil];
    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"SaveExists"];
    if (_rootViewController == nil) {
        self.rootViewController = [[[RootViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    }
    [self.navigationController pushViewController:_rootViewController animated:YES];
}

- (IBAction)levelSelectTapped:(id)sender
{
    LevelSelectViewController *controller;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        controller = [[LevelSelectViewController alloc] initWithNibName:@"LevelSelectViewController-iPad" bundle:nil];
    }
    else
    {
        controller = [[LevelSelectViewController alloc] init];
    }
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (IBAction)continueTapped:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ContinuePressed"];
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"LevelToLoad"];
    if (_rootViewController == nil) {
        self.rootViewController = [[[RootViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    }
    [self.navigationController pushViewController:_rootViewController animated:YES];
}

- (IBAction)returnToMenuTapped:(id)sender
{
    [_creditsView removeFromSuperview];
}

- (IBAction)creditsButtonTapped:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        _creditsView.frame = CGRectMake(260, 0, 480, 768);
       
    }
    else
    {
        if ([[UIScreen mainScreen] bounds].size.height == 568)
        {
            _creditsView.frame = CGRectMake(172, 0, 248, 320);
        }
        else
        {
            _creditsView.frame = CGRectMake(130, 0, 248, 320);
        }
        
    }
    [self.view addSubview:_creditsView];
}

- (IBAction)highScoresButtonTapped:(id)sender
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

- (IBAction)storeButtonTapped:(id)sender
{
    if ([SKPaymentQueue canMakePayments])
    {
        // Display a store to the user.
        StoreViewController *controller;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            controller = [[StoreViewController alloc] initWithNibName:@"StoreViewController-ipad" bundle:nil parent:@"Title"];
        }
        else
        {
            controller = [[StoreViewController alloc] initWithNibName:@"StoreViewController" bundle:nil parent:@"Title"];
        }
        
        [self presentViewController:controller animated:YES completion:nil];
        [controller release];
    }
    else
    {
        // Warn the user that purchases are disabled.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Disabled Purchases" message:@"In App Purchases have been disabled on this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
}

- (void) quitToMainMenu: (NSNotification *)notification
{
    [self.navigationController popToViewController:self animated:NO];
    [_rootViewController release];
    _rootViewController = nil;
}

- (void)dealloc {
    [_continueButton release];
    [_creditsView release];
    [_webView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setContinueButton:nil];
    [self setCreditsView:nil];
    [self setWebView:nil];
    [super viewDidUnload];
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

@end
