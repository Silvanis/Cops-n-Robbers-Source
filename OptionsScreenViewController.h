//
//  OptionsScreenViewController.h
//  Cops 'n Robbers
//
//  Created by John Markle on 4/29/13.
//  Copyright (c) 2013 Silver Moonfire LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionsScreenViewController : UIViewController
{
    float previousMasterVolume;
    float currentMasterVolume;
    float previousMusicVolume;
    float currentMusicVolume;
    float previousSoundVolume;
    float currentSoundVolume;
    BOOL previousMasterMute;
    BOOL currentMasterMute;
    BOOL previousMusicMute;
    BOOL currentMusicMute;
    BOOL previousSoundMute;
    BOOL currentSoundMute;
    BOOL changed;
}

- (IBAction)OKButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)quitButtonPressed:(id)sender;
- (IBAction)masterVolumeMute:(id)sender;
- (IBAction)musicVolumeMute:(id)sender;
- (IBAction)soundVolumeMute:(id)sender;
- (IBAction)masterVolumeSliderMoved:(id)sender;
- (IBAction)musicVolumeSliderMoved:(id)sender;
- (IBAction)soundVolumeSliderMoved:(id)sender;


@property (retain, nonatomic) IBOutlet UISwitch *masterVolumeState;
@property (retain, nonatomic) IBOutlet UISwitch *musicVolumeState;
@property (retain, nonatomic) IBOutlet UISwitch *soundVolumeState;
@property (retain, nonatomic) IBOutlet UISlider *masterVolumeSlider;
@property (retain, nonatomic) IBOutlet UISlider *musicVolumeSlider;
@property (retain, nonatomic) IBOutlet UISlider *soundVolumeSlider;


@end
