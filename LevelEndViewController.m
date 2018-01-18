//
//  LevelEndViewController.m
//  Cops 'n Robbers
//
//  Created by John Markle on 12/27/12.
//  Copyright (c) 2012 Silver Moonfire LLC. All rights reserved.
//

#import "LevelEndViewController.h"
#import "CLevel.h"

@interface LevelEndViewController ()

@end

@implementation LevelEndViewController
@synthesize queueTimer;
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
    levelEndData = [NSMutableDictionary dictionaryWithDictionary:scoreData];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self initWithNibName:nil bundle:nil];
    }
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self initWithNibName:@"LevelEndViewController-iPad" bundle:nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [[self timeScoreLabel] setFont:[UIFont fontWithName:@"Brush Strokefast" size:18.0]];
        [[self livesScoreLabel] setFont:[UIFont fontWithName:@"Brush Strokefast" size:18.0]];
        [[self totalScoreLabel] setFont:[UIFont fontWithName:@"Brush Strokefast" size:28.0]];
        [[self itemScoreLabel] setFont:[UIFont fontWithName:@"Brush Strokefast" size:18.0]];
        [[self LevelCompeteTitle] setFont:[UIFont fontWithName:@"Brush Strokefast" size:36.0]];
        [[self timeBonusText] setFont:[UIFont fontWithName:@"Brush Strokefast" size:18.0]];
        [[self livesText] setFont:[UIFont fontWithName:@"Brush Strokefast" size:18.0]];
        [[self itemsText] setFont:[UIFont fontWithName:@"Brush Strokefast" size:18.0]];
        [[self totalScoreText] setFont:[UIFont fontWithName:@"Brush Strokefast" size:28.0]];
        self.buttonText.titleLabel.font = [UIFont fontWithName:@"Brush Strokefast" size:18.0];
        self.quitGameButtonText.titleLabel.font = [UIFont fontWithName:@"Brush Strokefast" size:18.0];
        [[self rivalBonusText] setFont:[UIFont fontWithName:@"Brush Strokefast" size:18.0]];
        [[self rivalScoreLabel] setFont:[UIFont fontWithName:@"Brush Strokefast" size:18.0]];
        [[self levelScoreLabel] setFont:[UIFont fontWithName:@"Brush Strokefast" size:24.0]];
        [[self levelScoreText] setFont:[UIFont fontWithName:@"Brush Strokefast" size:24.0]];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [[self timeScoreLabel] setFont:[UIFont fontWithName:@"Brush Strokefast" size:36.0]];
        [[self livesScoreLabel] setFont:[UIFont fontWithName:@"Brush Strokefast" size:36.0]];
        [[self totalScoreLabel] setFont:[UIFont fontWithName:@"Brush Strokefast" size:56.0]];
        [[self itemScoreLabel] setFont:[UIFont fontWithName:@"Brush Strokefast" size:36.0]];
        [[self LevelCompeteTitle] setFont:[UIFont fontWithName:@"Brush Strokefast" size:72.0]];
        [[self timeBonusText] setFont:[UIFont fontWithName:@"Brush Strokefast" size:36.0]];
        [[self livesText] setFont:[UIFont fontWithName:@"Brush Strokefast" size:36.0]];
        [[self itemsText] setFont:[UIFont fontWithName:@"Brush Strokefast" size:36.0]];
        [[self totalScoreText] setFont:[UIFont fontWithName:@"Brush Strokefast" size:56.0]];
        self.buttonText.titleLabel.font = [UIFont fontWithName:@"Brush Strokefast" size:36.0];
        self.quitGameButtonText.titleLabel.font = [UIFont fontWithName:@"Brush Strokefast" size:36.0];
        [[self rivalBonusText] setFont:[UIFont fontWithName:@"Brush Strokefast" size:36.0]];
        [[self rivalScoreLabel] setFont:[UIFont fontWithName:@"Brush Strokefast" size:36.0]];
        [[self levelScoreLabel] setFont:[UIFont fontWithName:@"Brush Strokefast" size:48.0]];
        [[self levelScoreText] setFont:[UIFont fontWithName:@"Brush Strokefast" size:48.0]];
    }
    if ([[levelEndData objectForKey:@"LevelType"] isEqualToString:@"RIVAL"])
    {
        [[self rivalScoreLabel] setText:[[levelEndData objectForKey:@"RivalScore"] stringValue]];
    }
    _timeScoreLabel.text = [[levelEndData objectForKey:@"TimeBonus"] stringValue];
    _livesScoreLabel.text = [[levelEndData objectForKey:@"Lives"] stringValue];
    _totalScoreLabel.text = [[levelEndData objectForKey:@"TotalScore"] stringValue];
    [[self levelScoreLabel] setText:[[levelEndData objectForKey:@"LevelScore"] stringValue]];
    NSArray *itemsKept = [NSArray arrayWithArray:[levelEndData objectForKey:@"ItemsKept"]];
    if ([itemsKept count] > 0)
    {
        NSString *filePath = [[NSBundle mainBundle]pathForResource:[itemsKept objectAtIndex:0] ofType:@".png"];
        [_itemBox1 setImage:[UIImage imageWithContentsOfFile:filePath]];
    }
    if ([itemsKept count] > 1)
    {
        NSString *filePath = [[NSBundle mainBundle]pathForResource:[itemsKept objectAtIndex:1] ofType:@".png"];
        [_itemBox2 setImage:[UIImage imageWithContentsOfFile:filePath]];
    }
    if ([itemsKept count] > 2)
    {
        NSString *filePath = [[NSBundle mainBundle]pathForResource:[itemsKept objectAtIndex:2] ofType:@".png"];
        [_itemBox3 setImage:[UIImage imageWithContentsOfFile:filePath]];
    }
    if ([itemsKept count] > 3)
    {
        NSString *filePath = [[NSBundle mainBundle]pathForResource:[itemsKept objectAtIndex:3] ofType:@".png"];
        [_itemBox4 setImage:[UIImage imageWithContentsOfFile:filePath]];
    }
    _itemScoreLabel.text = [[levelEndData objectForKey:@"ItemScore"]stringValue];
    queueArray = [[[NSMutableArray alloc] initWithObjects:@"TIME", @"ITEMS", @"LIVES", nil]retain];
    if ([[levelEndData objectForKey:@"LevelType"] isEqualToString:@"RIVAL"])
    {
        [queueArray addObject:@"RIVAL"];
    }
    [queueArray addObject:@"TOTAL"];
    queueTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateScreen:) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)continueTapped:(id)sender
{
    if (queueTimer)
    {
        return;
    }
    [self.view removeFromSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LevelCompleteButton" object:nil];
    
}
- (void)dealloc {
    [_timeScoreLabel release];
    [_itemScoreLabel release];
    [_livesScoreLabel release];
    [_totalScoreLabel release];
    [_itemBox1 release];
    [_itemBox2 release];
    [_itemBox3 release];
    [_itemBox4 release];
    [_LevelCompeteTitle release];
    [_timeBonusText release];
    [_itemsText release];
    [_livesText release];
    [_totalScoreText release];
    [_buttonText release];
    [_rivalBonusText release];
    [_rivalScoreLabel release];
    [queueArray release];
    [_levelScoreLabel release];
    [_levelScoreText release];
    [_quitGameButtonText release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTimeScoreLabel:nil];
    [self setItemScoreLabel:nil];
    [self setLivesScoreLabel:nil];
    [self setTotalScoreLabel:nil];
    [self setItemBox1:nil];
    [self setItemBox2:nil];
    [self setItemBox3:nil];
    [self setItemBox4:nil];
    [self setLevelCompeteTitle:nil];
    [self setTimeBonusText:nil];
    [self setItemsText:nil];
    [self setLivesText:nil];
    [self setTotalScoreText:nil];
    [self setButtonText:nil];
    [self setRivalBonusText:nil];
    [self setRivalScoreLabel:nil];
    [self setLevelScoreLabel:nil];
    [self setLevelScoreText:nil];
    [self setQuitGameButtonText:nil];
    [super viewDidUnload];
}

-(void)updateScreen: (NSTimer *)timer
{
    if ([queueArray count] != 0)
    {
        NSString *queueStep = [queueArray objectAtIndex:0];
        [queueArray removeObjectAtIndex:0];
        if ([queueStep isEqualToString:@"TIME"])
        {
            [[self timeBonusText]setHidden:NO];
            [[self timeScoreLabel]setHidden:NO];
        }
        else if ([queueStep isEqualToString:@"ITEMS"])
        {
            [[self itemScoreLabel]setHidden:NO];
            [[self itemsText]setHidden:NO];
            [[self itemBox1]setHidden:NO];
            [[self itemBox2]setHidden:NO];
            [[self itemBox3]setHidden:NO];
            [[self itemBox4]setHidden:NO];
        }
        else if ([queueStep isEqualToString:@"LIVES"])
        {
            [[self livesScoreLabel]setHidden:NO];
            [[self livesText]setHidden:NO];
        }
        else if ([queueStep isEqualToString:@"RIVAL"])
        {
            [[self rivalScoreLabel]setHidden:NO];
            [[self rivalBonusText]setHidden:NO];
        }
        else if ([queueStep isEqualToString:@"TOTAL"])
        {
            [[self levelScoreText]setHidden:NO];
            [[self levelScoreLabel]setHidden:NO];
            [[self totalScoreLabel]setHidden:NO];
            [[self totalScoreText]setHidden:NO];
        }
        
    }
    else
    {
        [queueTimer invalidate];
        queueTimer = nil;
    }
}
- (IBAction)quitGameTapped:(id)sender
{
    [self.view removeFromSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QuitButton" object:nil];
}
@end
