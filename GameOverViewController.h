//
//  GameOverViewController.h
//  Cops 'n Robbers
//
//  Created by John Markle on 6/19/13.
//  Copyright (c) 2013 Silver Moonfire LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameKit/GameKit.h"

@interface GameOverViewController : UIViewController <GKLeaderboardViewControllerDelegate, GKGameCenterControllerDelegate>
{
    int scoreForLabel;
}
- (IBAction)quitGamePressed:(id)sender;
- (IBAction)highScoresPressed:(id)sender;
- (IBAction)restartLevelPressed:(id)sender;
- (IBAction)buyLivesPressed:(id)sender;
-(id) initWithScoreData:(int) score;
-(void) dismissScreen: (NSNotification *)notification;
@property (retain, nonatomic) IBOutlet UILabel *scoreLabel;
@end
