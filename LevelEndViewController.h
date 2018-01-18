//
//  LevelEndViewController.h
//  Cops 'n Robbers
//
//  Created by John Markle on 12/27/12.
//  Copyright (c) 2012 Silver Moonfire LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LevelEndViewController : UIViewController
{
    NSMutableDictionary *levelEndData;
    //NSTimer *queueTimer;
    NSMutableArray *queueArray;
}
@property (retain, nonatomic) IBOutlet UILabel *totalScoreText;
@property (retain, nonatomic) IBOutlet UILabel *livesText;
@property (retain, nonatomic) IBOutlet UILabel *itemsText;
@property (retain, nonatomic) IBOutlet UILabel *timeBonusText;
@property (retain, nonatomic) IBOutlet UILabel *LevelCompeteTitle;
@property (retain, nonatomic) IBOutlet UILabel *itemScoreLabel;
@property (retain, nonatomic) IBOutlet UILabel *livesScoreLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeScoreLabel;
@property (retain, nonatomic) IBOutlet UILabel *totalScoreLabel;
@property (retain, nonatomic) IBOutlet UIImageView *itemBox1;
@property (retain, nonatomic) IBOutlet UIImageView *itemBox2;
@property (retain, nonatomic) IBOutlet UIImageView *itemBox3;
@property (retain, nonatomic) IBOutlet UIImageView *itemBox4;
@property (retain, nonatomic) IBOutlet UIButton *buttonText;
@property (retain, nonatomic) IBOutlet UIButton *quitGameButtonText;
@property (retain, nonatomic) IBOutlet UILabel *rivalBonusText;
@property (retain, nonatomic) IBOutlet UILabel *rivalScoreLabel;
@property (retain, nonatomic) IBOutlet UILabel *levelScoreLabel;
@property (retain, nonatomic) IBOutlet UILabel *levelScoreText;

@property (retain, nonatomic) NSTimer *queueTimer;

- (IBAction)quitGameTapped:(id)sender;
- (IBAction)continueTapped:(id)sender;
-(id) initwithScoreData: (NSDictionary *)scoreData;
-(void) updateScreen: (NSTimer *)timer;
@end
