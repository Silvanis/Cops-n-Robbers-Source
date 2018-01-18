//
//  LevelSelectViewController.m
//  Cops 'n Robbers
//
//  Created by John Markle on 5/20/13.
//  Copyright (c) 2013 Silver Moonfire LLC. All rights reserved.
//

#import "LevelSelectViewController.h"
#import "CLevel.h"
#import "RootViewController.h"

@interface LevelSelectViewController ()

@end

@implementation LevelSelectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        levelToLoad = 1;
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Level Packs" ofType:@"plist" inDirectory:@"Levels"];
        NSArray *bundleArray = [[[NSArray alloc] initWithContentsOfFile:bundlePath]autorelease];
        NSDictionary *bundleData = [bundleArray objectAtIndex:0];
        maxLevel = [[bundleData objectForKey:@"Number of Levels"]intValue];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //defaults to levels 1-5, so fill in buttons
    NSString *level1Location = [[NSBundle mainBundle] pathForResource:@"level1" ofType:@"png" inDirectory:@"Levels/Standard"];
    UIImage *level1Image = [[[UIImage alloc] initWithContentsOfFile:level1Location] autorelease];
    UIImage *level2Image = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level2" ofType:@"png" inDirectory:@"Levels/Standard"]] autorelease];
    UIImage *level3Image = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level3" ofType:@"png" inDirectory:@"Levels/Standard"]] autorelease];
    UIImage *level4Image = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level4" ofType:@"png" inDirectory:@"Levels/Standard"]] autorelease];
    UIImage *level5Image = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level5" ofType:@"png" inDirectory:@"Levels/Standard"]] autorelease];
    [_level1Button setBackgroundImage:level1Image forState:UIControlStateNormal];
    [_level2Button setBackgroundImage:level2Image forState:UIControlStateNormal];
    [_level3Button setBackgroundImage:level3Image forState:UIControlStateNormal];
    [_level4Button setBackgroundImage:level4Image forState:UIControlStateNormal];
    [_level5Button setBackgroundImage:level5Image forState:UIControlStateNormal];
    [_levelLabel setText:@"Level 1"];
    
    UIImage *robberImage = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"robberfront-hd" ofType:@"png" inDirectory:@"Graphics/Robber"]] autorelease];
    [_robberImageView initWithImage:robberImage];
    
    UIImage *copsImage = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1cops" ofType:@"png"]] autorelease];
    [_copsImageView initWithImage:copsImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)levelSegmentChanged:(id)sender
{
    int levelGroup = _segmentControl.selectedSegmentIndex;
    int level = (1 + (levelGroup * 5));
    
    if (level <= maxLevel)
    {
        UIImage *level1Image = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"level%d", level] ofType:@"png" inDirectory:@"Levels/Standard"]] autorelease];
        [_level1Button setBackgroundImage:level1Image forState:UIControlStateNormal];
        [_level1Button setTitle:[NSString stringWithFormat:@"%d", level] forState:UIControlStateNormal];
    }
    else
    {
        UIImage *levelImage = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"noLevel" ofType:@"png"]] autorelease];
        [_level1Button setBackgroundImage:levelImage forState:UIControlStateNormal];
        [_level1Button setTitle:[NSString stringWithFormat:@"%d", level] forState:UIControlStateNormal];
    }
    
    level++;
    
    if (level <= maxLevel)
    {
        UIImage *levelImage = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"level%d", level] ofType:@"png" inDirectory:@"Levels/Standard"]] autorelease];
        [_level2Button setBackgroundImage:levelImage forState:UIControlStateNormal];
        [_level2Button setTitle:[NSString stringWithFormat:@"%d", level] forState:UIControlStateNormal];
    }
    else
    {
        UIImage *levelImage = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"noLevel" ofType:@"png"]] autorelease];
        [_level2Button setBackgroundImage:levelImage forState:UIControlStateNormal];
        [_level2Button setTitle:[NSString stringWithFormat:@"%d", level] forState:UIControlStateNormal];
    }
    
    level++;
    
    if (level <= maxLevel)
    {
        UIImage *levelImage = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"level%d", level] ofType:@"png" inDirectory:@"Levels/Standard"]] autorelease];
        [_level3Button setBackgroundImage:levelImage forState:UIControlStateNormal];
        [_level3Button setTitle:[NSString stringWithFormat:@"%d", level] forState:UIControlStateNormal];
    }
    else
    {
        UIImage *levelImage = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"noLevel" ofType:@"png"]] autorelease];
        [_level3Button setBackgroundImage:levelImage forState:UIControlStateNormal];
        [_level3Button setTitle:[NSString stringWithFormat:@"%d", level] forState:UIControlStateNormal];
    }
    
    level++;
    
    if (level <= maxLevel)
    {
        UIImage *levelImage = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"level%d", level] ofType:@"png" inDirectory:@"Levels/Standard"]] autorelease];
        [_level4Button setBackgroundImage:levelImage forState:UIControlStateNormal];
        [_level4Button setTitle:[NSString stringWithFormat:@"%d", level] forState:UIControlStateNormal];
    }
    else
    {
        UIImage *levelImage = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"noLevel" ofType:@"png"]] autorelease];
        [_level4Button setBackgroundImage:levelImage forState:UIControlStateNormal];
        [_level4Button setTitle:[NSString stringWithFormat:@"%d", level] forState:UIControlStateNormal];
    }
    
    level++;
    
    if (level <= maxLevel)
    {
        UIImage *levelImage = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"level%d", level] ofType:@"png" inDirectory:@"Levels/Standard"]] autorelease];
        [_level5Button setBackgroundImage:levelImage forState:UIControlStateNormal];
        [_level5Button setTitle:[NSString stringWithFormat:@"%d", level] forState:UIControlStateNormal];
    }
    else
    {
        UIImage *levelImage = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"noLevel" ofType:@"png"]] autorelease];
        [_level5Button setBackgroundImage:levelImage forState:UIControlStateNormal];
        [_level5Button setTitle:[NSString stringWithFormat:@"%d", level] forState:UIControlStateNormal];
    }

}

- (IBAction)level1Pressed:(id)sender
{
    levelToLoad = 1 + (_segmentControl.selectedSegmentIndex * 5);
    //brute forcing the cop pictures, this should be changed to load the .plist for the level.
    UIImage *copImage;
    NSString *copImageName;
    switch (levelToLoad) {
        case 1:
            copImageName = @"1cops";
            break;
        case 6:
            copImageName = @"2cops";
            break;
        case 11:
            copImageName = @"3cops";
            break;
        case 16:
            copImageName = @"4cops";
            break;
        default:
            copImageName = @"1cops";
            break;
    }
    copImage = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:copImageName ofType:@"png"]] autorelease];
    [_copsImageView setImage:copImage];
    [_levelLabel setText:[NSString stringWithFormat:@"Level %i", levelToLoad]];
}

- (IBAction)level2Pressed:(id)sender
{
    levelToLoad = 2 + (_segmentControl.selectedSegmentIndex * 5);
    //brute forcing the cop pictures, this should be changed to load the .plist for the level.
    UIImage *copImage;
    NSString *copImageName;
    switch (levelToLoad) {
        case 2:
            copImageName = @"2cops";
            break;
        case 7:
            copImageName = @"3cops";
            break;
        case 12:
            copImageName = @"4cops";
            break;
        case 17:
            copImageName = @"4cops";
            break;
        default:
            copImageName = @"1cops";
            break;
    }
    copImage = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:copImageName ofType:@"png"]] autorelease];
    [_copsImageView setImage:copImage];
    [_levelLabel setText:[NSString stringWithFormat:@"Level %i", levelToLoad]];
}

- (IBAction)level3Pressed:(id)sender
{
    levelToLoad = 3 + (_segmentControl.selectedSegmentIndex * 5);
    //brute forcing the cop pictures, this should be changed to load the .plist for the level.
    UIImage *copImage;
    NSString *copImageName;
    switch (levelToLoad) {
        case 3:
            copImageName = @"2cops";
            break;
        case 8:
            copImageName = @"3cops";
            break;
        case 13:
            copImageName = @"4cops";
            break;
        case 18:
            copImageName = @"4cops";
            break;
        default:
            copImageName = @"1cops";
            break;
    }
    copImage = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:copImageName ofType:@"png"]] autorelease];
    [_copsImageView setImage:copImage];
    [_levelLabel setText:[NSString stringWithFormat:@"Level %i", levelToLoad]];
}

- (IBAction)level4Pressed:(id)sender
{
    levelToLoad = 4 + (_segmentControl.selectedSegmentIndex * 5);
    //brute forcing the cop pictures, this should be changed to load the .plist for the level.
    UIImage *copImage;
    NSString *copImageName;
    switch (levelToLoad) {
        case 4:
            copImageName = @"2cops";
            break;
        case 9:
            copImageName = @"3cops";
            break;
        case 14:
            copImageName = @"4cops";
            break;
        case 19:
            copImageName = @"4cops";
            break;
        default:
            copImageName = @"1cops";
            break;
    }
    copImage = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:copImageName ofType:@"png"]] autorelease];
    [_copsImageView setImage:copImage];
    [_levelLabel setText:[NSString stringWithFormat:@"Level %i", levelToLoad]];
}

- (IBAction)level5Pressed:(id)sender
{
    levelToLoad = 5 + (_segmentControl.selectedSegmentIndex * 5);
    //brute forcing the cop pictures, this should be changed to load the .plist for the level.
    UIImage *copImage;
    NSString *copImageName = @"1rival";
    copImage = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:copImageName ofType:@"png"]] autorelease];
    [_copsImageView setImage:copImage];
    [_levelLabel setText:[NSString stringWithFormat:@"Level %i", levelToLoad]];
}

- (IBAction)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goToLevelPressed:(id)sender
{
    if (levelToLoad <= maxLevel)
    {
        NSArray *levelsEntered = [[NSUserDefaults standardUserDefaults] objectForKey:@"LevelsEntered"];
        if (levelsEntered == nil || [[levelsEntered objectAtIndex:(levelToLoad - 1)]boolValue] == NO)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Level Locked"
                                                            message:@"You can't enter a level you haven't been to yet."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        else
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectoryPath = [paths objectAtIndex:0];
            NSString *bundlePath = [NSString stringWithFormat:@"%@/savestate.plist", documentsDirectoryPath];
            if ([[NSFileManager defaultManager] fileExistsAtPath:bundlePath])
            {
                [[NSFileManager defaultManager] removeItemAtPath:bundlePath error:nil];
            }
            
            [[NSUserDefaults standardUserDefaults] setInteger:levelToLoad forKey:@"LevelToLoad"];
            
            RootViewController *rootViewController = [[[RootViewController alloc] initWithNibName:nil bundle:nil] autorelease];
            [self.navigationController pushViewController:rootViewController animated:YES];

        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Level Not Available"
                                                        message:@"Sorry, this level is not yet available. Be on the lookout for updates!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)dealloc {
    [_copsImageView release];
    [_level1Button release];
    [_level2Button release];
    [_level3Button release];
    [_level4Button release];
    [_level5Button release];
    [_segmentControl release];
    [_robberImageView release];
    [_levelLabel release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setCopsImageView:nil];
    [self setLevel1Button:nil];
    [self setLevel2Button:nil];
    [self setLevel3Button:nil];
    [self setLevel4Button:nil];
    [self setLevel5Button:nil];
    [self setSegmentControl:nil];
    [self setRobberImageView:nil];
    [self setLevelLabel:nil];
    [super viewDidUnload];
}
@end
