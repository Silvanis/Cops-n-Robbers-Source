//
//  LevelSelectViewController.h
//  Cops 'n Robbers
//
//  Created by John Markle on 5/20/13.
//  Copyright (c) 2013 Silver Moonfire LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LevelSelectViewController : UIViewController
{
    int levelToLoad;
    int maxLevel;
}
- (IBAction)levelSegmentChanged:(id)sender;
- (IBAction)level1Pressed:(id)sender;
- (IBAction)level2Pressed:(id)sender;
- (IBAction)level3Pressed:(id)sender;
- (IBAction)level4Pressed:(id)sender;
- (IBAction)level5Pressed:(id)sender;
- (IBAction)backButtonPressed:(id)sender;
- (IBAction)goToLevelPressed:(id)sender;

@property (retain, nonatomic) IBOutlet UIImageView *copsImageView;
@property (retain, nonatomic) IBOutlet UIButton *level1Button;
@property (retain, nonatomic) IBOutlet UIButton *level2Button;
@property (retain, nonatomic) IBOutlet UIButton *level3Button;
@property (retain, nonatomic) IBOutlet UIButton *level4Button;
@property (retain, nonatomic) IBOutlet UIButton *level5Button;
@property (retain, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (retain, nonatomic) IBOutlet UIImageView *robberImageView;
@property (retain, nonatomic) IBOutlet UILabel *levelLabel;

@end
