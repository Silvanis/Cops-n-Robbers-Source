//
//  OptionsScreenViewController.m
//  Cops 'n Robbers
//
//  Created by John Markle on 4/29/13.
//  Copyright (c) 2013 Silver Moonfire LLC. All rights reserved.
//

#import "OptionsScreenViewController.h"
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

@interface OptionsScreenViewController ()

@end

@implementation OptionsScreenViewController
@synthesize masterVolumeState, masterVolumeSlider;
@synthesize musicVolumeState, musicVolumeSlider;
@synthesize soundVolumeState, soundVolumeSlider;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        changed = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Master Volume"])
    {
        previousMasterVolume = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Master Volume"] floatValue];
        currentMasterVolume = previousMasterVolume;
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setFloat:1.0 forKey:@"Master Volume"];
        previousMasterVolume = 1.0;
        currentMasterVolume = 1.0;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Master Volume Mute"])
    {
        previousMasterMute = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Master Volume Mute"] boolValue];
        currentMasterMute = previousMasterMute;
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Master Volume Mute"];
        previousMasterMute = YES;
        currentMasterMute = YES;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Music Volume"])
    {
        previousMusicVolume = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Music Volume"] floatValue];
        currentMusicVolume = previousMusicVolume;
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setFloat:1.0 forKey:@"Music Volume"];
        previousMusicVolume = 0.4;
        currentMusicVolume = 0.4;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Music Volume Mute"])
    {
        previousMusicMute = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Music Volume Mute"] boolValue];
        currentMusicMute = previousMusicMute;
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Music Volume Mute"];
        previousMusicMute = YES;
        currentMusicMute = YES;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Sound Volume"])
    {
        previousSoundVolume = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Sound Volume"] floatValue];
        currentSoundVolume = previousSoundVolume;
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setFloat:1.0 forKey:@"Sound Volume"];
        previousSoundVolume = 1.0;
        currentSoundVolume = 1.0;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Sound Volume Mute"])
    {
        previousSoundMute = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Sound Volume Mute"] boolValue];
        currentSoundMute = previousSoundMute;
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Sound Volume Mute"];
        previousSoundMute = YES;
        currentSoundMute = YES;
    }
    
    [[self masterVolumeState] setOn:currentMasterMute];
    [[self musicVolumeState] setOn:currentMusicMute];
    [[self soundVolumeState] setOn:currentSoundMute];
    [[self masterVolumeSlider] setValue:currentMasterVolume];
    [[self musicVolumeSlider] setValue:currentMusicVolume];
    [[self soundVolumeSlider] setValue:currentSoundVolume];
    [[self soundVolumeSlider] setContinuous:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)OKButtonPressed:(id)sender
{
    
    if (changed)
    {
        [[NSUserDefaults standardUserDefaults] setFloat:currentMasterVolume forKey:@"Master Volume"];
        [[NSUserDefaults standardUserDefaults] setBool:currentMasterMute forKey:@"Master Volume Mute"];
        [[NSUserDefaults standardUserDefaults] setFloat:currentMusicVolume forKey:@"Music Volume"];
        [[NSUserDefaults standardUserDefaults] setBool:currentMusicMute forKey:@"Music Volume Mute"];
        [[NSUserDefaults standardUserDefaults] setFloat:currentSoundVolume forKey:@"Sound Volume"];
        [[NSUserDefaults standardUserDefaults] setBool:currentSoundMute forKey:@"Sound Volume Mute"];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PausedState"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitPauseScreen" object:nil];
    [[CCDirector sharedDirector] resume];
    [self.view removeFromSuperview];
    

}

- (IBAction)cancelButtonPressed:(id)sender
{
    if (changed)
    {
        [[NSUserDefaults standardUserDefaults] setFloat:previousMasterVolume forKey:@"Master Volume"];
        [[NSUserDefaults standardUserDefaults] setBool:previousMasterMute forKey:@"Master Volume Mute"];
        [[NSUserDefaults standardUserDefaults] setFloat:previousMusicVolume forKey:@"Music Volume"];
        [[NSUserDefaults standardUserDefaults] setBool:previousMusicMute forKey:@"Music Volume Mute"];
        [[NSUserDefaults standardUserDefaults] setFloat:previousSoundVolume forKey:@"Sound Volume"];
        [[NSUserDefaults standardUserDefaults] setBool:previousSoundMute forKey:@"Sound Volume Mute"];
        
        [[SimpleAudioEngine sharedEngine] setMute:!(previousMasterMute)];
        if (previousMusicMute == YES)
        {
            
            [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
        }
        else
        {
            
            [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
        }
        
        if (previousSoundMute == YES)
        {
            
            [[SimpleAudioEngine sharedEngine] setEffectsVolume:(previousMasterVolume * previousSoundVolume)];
        }
        else
        {
            
            [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.0];
        }
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:(previousMasterVolume * previousSoundVolume)];
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:(previousMasterVolume * previousMusicVolume)];
    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"PausedState"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitPauseScreen" object:nil];
    [[CCDirector sharedDirector] resume];
    [self.view removeFromSuperview];
}

- (IBAction)quitButtonPressed:(id)sender
{
    [self.view removeFromSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitPauseScreen" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QuitButton" object:nil];
}

- (IBAction)masterVolumeMute:(id)sender
{
    changed = YES;
    if ([masterVolumeState isOn])
    {
        currentMasterMute = YES;
    }
    else
    {
        currentMasterMute = NO;
    }
    [[NSUserDefaults standardUserDefaults] setBool:currentMasterMute forKey:@"Master Volume Mute"];
    [[SimpleAudioEngine sharedEngine] setMute:!(currentMasterMute)];
}

- (IBAction)musicVolumeMute:(id)sender
{
    changed = YES;
    if ([musicVolumeState isOn])
    {
        currentMusicMute = YES;
        [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
    }
    else
    {
        currentMusicMute = NO;
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
    }
    [[NSUserDefaults standardUserDefaults] setBool:currentMusicMute forKey:@"Music Volume Mute"];
    
}

- (IBAction)soundVolumeMute:(id)sender
{
    changed = YES;
    if ([soundVolumeState isOn])
    {
        currentSoundMute = YES;
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:(currentMasterVolume * currentSoundVolume)];
    }
    else
    {
        currentSoundMute = NO;
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.0];
    }
    [[NSUserDefaults standardUserDefaults] setBool:currentSoundMute forKey:@"Sound Volume Mute"];
}

- (IBAction)masterVolumeSliderMoved:(id)sender
{
    changed = YES;
    UISlider *slider = (UISlider *)sender;
    float val = slider.value;
    currentMasterVolume = val;
    [[NSUserDefaults standardUserDefaults] setFloat:currentMasterVolume forKey:@"Master Volume"];
    [[SimpleAudioEngine sharedEngine] setEffectsVolume:(currentMasterVolume * currentSoundVolume)];
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:(currentMasterVolume * currentMusicVolume)];
}

- (IBAction)musicVolumeSliderMoved:(id)sender
{
    changed = YES;
    UISlider *slider = (UISlider *)sender;
    float val = slider.value;
    currentMusicVolume = val;
    [[NSUserDefaults standardUserDefaults] setFloat:currentMusicVolume forKey:@"Music Volume"];
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:(currentMasterVolume * currentMusicVolume)];
}

- (IBAction)soundVolumeSliderMoved:(id)sender
{
    changed = YES;
    UISlider *slider = (UISlider *)sender;
    float val = slider.value;
    currentSoundVolume = val;
    [[NSUserDefaults standardUserDefaults] setFloat:currentSoundVolume forKey:@"Sound Volume"];
    [[SimpleAudioEngine sharedEngine] setEffectsVolume:(currentMasterVolume * currentSoundVolume)];
    [[SimpleAudioEngine sharedEngine] playEffect:@"Sound/Sound Effects/coinpickup2.caf"];
}

- (void)dealloc
{
    [masterVolumeState release];
    [musicVolumeState release];
    [soundVolumeState release];
    [masterVolumeSlider release];
    [musicVolumeSlider release];
    [soundVolumeSlider release];
    [super dealloc];
}
- (void)viewDidUnload
{
    [self setMasterVolumeState:nil];
    [self setMusicVolumeState:nil];
    [self setSoundVolumeState:nil];
    [self setMasterVolumeSlider:nil];
    [self setMusicVolumeSlider:nil];
    [self setSoundVolumeSlider:nil];
    [super viewDidUnload];
}
@end
