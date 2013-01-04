//
//  RFAppDelegate.h
//  Stereotype
//
//  Created by brandon on 7/5/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RFTabView.h"
#import "RFSlider.h"
#import "RFDialSlider.h"
#import "RFPlayerView.h"
#import "RFArtworkView.h"
#import "RFLibraryViewController.h"
#import "RFSettingsModel.h"
#import "RFSettingsViewController.h"
#import "RFWindow.h"
#import "RFAudioDevices.h"
#import "RFAudioPlayer.h"
#import "LBProgressBar.h"
#import "SPMediaKeyTap.h"

@interface RFAppDelegate : NSObject <NSApplicationDelegate, AudioDevicesChangedProtocol, RFAudioPlayerDelegate>
{
}

@property (unsafe_unretained) IBOutlet NSPanel *importPanel;
@property (weak) IBOutlet LBProgressBar *importProgress;
@property (weak) IBOutlet NSTextField *importLabel;

@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet RFArtworkView *artworkView;

@property (weak) IBOutlet RFPlayerView *playerView;
@property (weak) IBOutlet RFTabView *drawerTabView;

@property (weak) IBOutlet NSButton *settingsButton;
@property (weak) IBOutlet NSButton *libraryButton;
@property (weak) IBOutlet NSButton *repeatButton;
@property (weak) IBOutlet NSButton *shuffleButton;

@property (weak) IBOutlet NSButton *prevButton;
@property (weak) IBOutlet NSButton *playButton;
@property (weak) IBOutlet NSButton *nextButton;
@property (weak) IBOutlet RFDialSlider *volumeSlider;

@property (weak) IBOutlet NSTextField *trackTextField;
@property (weak) IBOutlet NSTextField *artistTextField;
@property (weak) IBOutlet NSTextField *albumTextField;

@property (weak) IBOutlet RFSlider *timeSlider;
@property (weak) IBOutlet NSTextField *timeTextField;
@property (weak) IBOutlet NSTextField *durationTextField;

@property (nonatomic, weak) RFLibraryViewController *libraryViewController;
@property (nonatomic, weak) RFSettingsViewController *settingsViewController;

@property (nonatomic, assign) BOOL useVisualizer;

@property (weak) IBOutlet NSMenuItem *spaceMenuItem;

+ (RFAppDelegate *)sharedInstance;

- (float)elapsedTime;
- (float)duration;

- (IBAction)playPauseTrackAction:(id)sender;

- (void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event;

@end
