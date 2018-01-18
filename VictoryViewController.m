//
//  VictoryViewController.m
//  Cops 'n Robbers
//
//  Created by John Markle on 7/14/13.
//  Copyright (c) 2013 Silver Moonfire LLC. All rights reserved.
//

#import "VictoryViewController.h"
#import "SimpleAudioEngine.h"

@interface VictoryViewController ()

@end

@implementation VictoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initwithScoreData:(NSDictionary *)scoreData
{
    levelData = [NSMutableDictionary dictionaryWithDictionary:scoreData];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if ([[UIScreen mainScreen] bounds].size.height == 568)
        {
            [self initWithNibName:@"VictoryViewController-iPhone5" bundle:nil];
        }
        else
        {
            [self initWithNibName:@"VictoryViewController" bundle:nil];
        }
        
    }
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self initWithNibName:@"VictoryViewController-iPad" bundle:nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_finalScore setText:[[levelData objectForKey:@"TotalScore"]stringValue]];
    [_bonusScore setText:[[levelData objectForKey:@"RivalScore"]stringValue]];
    [UIView beginAnimations:@"fadeIn" context:nil];
    [UIView setAnimationDuration:4.0];
    _backgroundImage.alpha = 1.0;
    [UIView commitAnimations];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Sound/Music/Ocean Ambience.mp3" loop:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_backgroundImage release];
    [_finalScore release];
    [_bonusScore release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackgroundImage:nil];
    [self setFinalScore:nil];
    [self setBonusScore:nil];
    [super viewDidUnload];
}
- (IBAction)continuePressed:(id)sender
{
    [self.view removeFromSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LevelCompleteButton" object:nil];

}

- (IBAction)quitGamePressed:(id)sender
{
    [self.view removeFromSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QuitButton" object:nil];
}
@end
