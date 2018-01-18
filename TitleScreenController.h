//
//  TitleScreenController.h
//  Cops 'n Robbers
//
//  Created by John Markle on 12/27/12.
//  Copyright (c) 2012 Silver Moonfire LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "GameKit/GameKit.h"

@interface TitleScreenController : UIViewController <GKLeaderboardViewControllerDelegate, GKGameCenterControllerDelegate, UIWebViewDelegate>
{
    RootViewController *_rootViewController;
}
- (IBAction)newGameTapped:(id)sender;
- (IBAction)levelSelectTapped:(id)sender;
- (IBAction)continueTapped:(id)sender;
- (IBAction)returnToMenuTapped:(id)sender;
- (IBAction)creditsButtonTapped:(id)sender;
- (IBAction)highScoresButtonTapped:(id)sender;
- (IBAction)storeButtonTapped:(id)sender;
- (void) quitToMainMenu: (NSNotification *)notification;
@property (retain, nonatomic) IBOutlet UIView *creditsView;
@property (retain, nonatomic) IBOutlet UIButton *continueButton;
@property (retain) RootViewController *rootViewController;
@property (retain, nonatomic) IBOutlet UIWebView *webView;
@end
