//
//  VictoryViewController.h
//  Cops 'n Robbers
//
//  Created by John Markle on 7/14/13.
//  Copyright (c) 2013 Silver Moonfire LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VictoryViewController : UIViewController
{
    NSMutableDictionary *levelData;
}
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (retain, nonatomic) IBOutlet UILabel *finalScore;
@property (retain, nonatomic) IBOutlet UILabel *bonusScore;
- (IBAction)continuePressed:(id)sender;
- (IBAction)quitGamePressed:(id)sender;
-(id) initwithScoreData: (NSDictionary *)scoreData;
@end
