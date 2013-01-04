//
//  RFAppDelegate.m
//  Stereotype
//
//  Created by brandon on 7/5/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFAppDelegate.h"
#import "NSObject+RFExtensions.h"
#import "NSImage+QuickLook.h"
#import "AUHostController.h"
#import "RFPlayerView.h"
#import "RFCompositionView.h"
#import "RFMetadata.h"

#import "VPPCoreData.h"

@implementation RFAppDelegate
{
    RFAudioPlayer *audioPlayer;
    
    RFLibrary *library;

    NSArray *playlist;
    NSInteger trackIndex;
    
    NSTimer *updateTimer;

    RFCompositionView *visualizer;
    NSTimeInterval currentTime;
    
    BOOL movedWhenDrawerOpen;
    CGFloat lastXPosition;
    CGFloat openXPosition;
    BOOL drawerOpen;
    
    RFSettingsModel *settings;
    
    NSDictionary *currentTrackInfo;
    
    NSMutableArray *urlArray;
    
    NSArray *outputDevices;
    
    BOOL importing;
    
    SPMediaKeyTap *keyTap;
}

static RFAppDelegate *__appDelegateInstance = nil;

+ (RFAppDelegate *)sharedInstance
{
    return __appDelegateInstance;
}

+ (void)initialize
{
	if([self class] != [RFAppDelegate class]) return;
	
	// Register defaults for the whitelist of apps that want to use media keys
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [SPMediaKeyTap defaultMediaKeyUserBundleIdentifiers], kMediaKeyUsingBundleIdentifiersDefaultsKey,
                                                             nil]];
}

- (void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event
{
	NSAssert([event type] == NSSystemDefined && [event subtype] == SPSystemDefinedEventMediaKeys, @"Unexpected NSEvent in mediaKeyTap:receivedMediaKeyEvent:");
	// here be dragons...
	int keyCode = (([event data1] & 0xFFFF0000) >> 16);
	int keyFlags = ([event data1] & 0x0000FFFF);
	BOOL keyIsPressed = (((keyFlags & 0xFF00) >> 8)) == 0xA;
	//int keyRepeat = (keyFlags & 0x1);
	
	if (keyIsPressed)
    {
		switch (keyCode)
        {
			case NX_KEYTYPE_PLAY:
                [self playPauseTrackAction:nil];
				break;
				
			case NX_KEYTYPE_FAST:
                [self nextTrackAction:nil];
				break;
				
			case NX_KEYTYPE_REWIND:
                [self prevTrackAction:nil];
				break;
            
            /*
                We dont want to handle these keys.  If they're playing via the default device, it'll
                just work anyway.  If they're not, the default device's volume settings will get changed
                anyway.  So why bother trying.  :(
             */
                
            /*case NX_KEYTYPE_SOUND_UP:
                debugString = [@"VolumeUp pressed" stringByAppendingString:debugString];
                break;

            case NX_KEYTYPE_SOUND_DOWN:
                debugString = [@"VolumeDown pressed" stringByAppendingString:debugString];
                break;
            
            case NX_KEYTYPE_MUTE:
                debugString = [@"Mute pressed" stringByAppendingString:debugString];
                break;*/

			default:
				break;
                // More cases defined in hidsystem/ev_keymap.h
		}
	}
}

- (void)awakeFromNib
{
    __appDelegateInstance = self;
    
    [self.spaceMenuItem setTitleWithMnemonic:@"Play/Pause               "];
    
    [VPPCoreData sharedInstance].dbFilename = @"StereotypeDB";
    
    settings = [RFSettingsModel sharedInstance];    
    audioPlayer = [RFAudioPlayer sharedInstance];
    audioPlayer.delegate = self;
    [audioPlayer setEffects:settings.filterNames];
    audioPlayer.exclusiveMode = settings.exclusiveMode;
    
    [self registerForAudioPlayerChanges];

    // setup initial position
    NSRect newFrame = self.window.frame;
    newFrame.size.width = 202;
    movedWhenDrawerOpen = NO;
    drawerOpen = NO;
    [self.window setFrame:newFrame display:YES animate:YES];

    // set the some user prefs
    self.volumeSlider.volume = settings.volume;
    
    [self.trackTextField setStringValue:@""];
    [self.artistTextField setStringValue:@""];
    [self.albumTextField setStringValue:@""];
    [self setTime:0 textField:self.durationTextField];
    [self setTime:0 textField:self.timeTextField];
    
    
    self.timeSlider.minValue = 0.0;
    self.timeSlider.maxValue = 0.0;
    
    self.settingsViewController = [RFSettingsViewController loadFromNib];
    self.libraryViewController = [RFLibraryViewController loadFromNib];
    self.libraryViewController.viewStyle = settings.libraryViewStyle;
    self.libraryViewController.selectionBlock = ^{
        BOOL isRunning = [audioPlayer isPlaying];
        if (isRunning)
            [audioPlayer stop];
        [self updatePlayButtonState];
    };

    self.drawerTabView.viewControllers = @[self.libraryViewController, self.settingsViewController];
    
    [RFAudioDeviceList sharedInstance].delegate = self;
    audioPlayer.outputDevice = [[RFAudioDeviceList sharedInstance] outputDeviceByName:settings.preferredDevice];
    audioPlayer.upsampling = settings.upsampling;
    [audioPlayer setManagedOutputDevicePopup:self.settingsViewController.outputDevicePopup];
    [audioPlayer setManagedOutputSampleRatePopup:self.settingsViewController.sampleRatePopup];
    [audioPlayer setManagedOutputFormatPopup:self.settingsViewController.formatPopup];
    [self.settingsViewController refreshDisplay];
    
    self.useVisualizer = settings.useVisualizer;
    
    [self setShuffle:settings.shuffle];
    [self setRepeatMode:settings.repeatMode];
    
    [self updateDisplayInfo:nil];
    
    library = [RFLibrary sharedInstance];
    
    [self loadPlaylistFromSettings];
    
    self.useVisualizer = YES;
    visualizer.enabled = YES;
}

- (void)loadPlaylistFromSettings
{
    NSArray *queue = settings.urlQueue;
    if (queue)
    {
        NSMutableArray *urlQueue = [[NSMutableArray alloc] initWithCapacity:queue.count];
        for (int i = 0; i < queue.count; i++)
            [urlQueue addObject:[NSURL URLWithString:[queue objectAtIndex:i]]];
        [audioPlayer setQueue:urlQueue startAtIndex:settings.urlQueueIndex];
    }
}

- (void)registerForAudioPlayerChanges
{
    [audioPlayer addObserver:self forKeyPath:@"currentURL" options:NSKeyValueObservingOptionNew context:nil];
    [audioPlayer addObserver:self forKeyPath:@"playing" options:NSKeyValueObservingOptionNew context:nil];
    [settings addObserver:self forKeyPath:@"urlQueueIndex" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentURL"])
    {
        NSURL *url = [audioPlayer currentURL];
        RFMetadata *metadata = [[RFMetadata alloc] initWithURL:url];
        
        NSString *name = [metadata getTitle];
        NSString *artist = [metadata getArtist];
        NSString *album = [metadata getAlbumTitle];
        
        if (!name)
            name = @"";
        if (!artist)
            artist = @"";
        if (!album)
            album = @"";
        
        [self.trackTextField setStringValue:name];
        [self.artistTextField setStringValue:artist];
        [self.albumTextField setStringValue:album];
        
        NSImage *albumArt = [NSImage imageFromAlbum:album artist:artist url:url];
        if (!albumArt)
            albumArt = [NSImage imageNamed:@"albumArt"];
        
        self.artworkView.albumArtImage = albumArt;
        
        NSNumber *duration = [metadata getDuration];
        if (!duration)
            duration = [NSNumber numberWithFloat:0];
        
        currentTrackInfo = @{ @"name" : name, @"artist" : artist, @"album" : album, @"artwork" : albumArt, @"duration" : duration };
        visualizer.trackInfo = currentTrackInfo;
    }
    else
    if ([keyPath isEqualToString:@"urlQueueIndex"])
    {
        [audioPlayer stop];        
        [self loadPlaylistFromSettings];
        [audioPlayer play];
    }
}

- (void)audioPlayerDidStop:(RFAudioPlayer *)player
{
    [self updatePlayButtonState];

    [self.trackTextField setStringValue:@""];
    [self.artistTextField setStringValue:@""];
    [self.albumTextField setStringValue:@""];
    [self.timeTextField setStringValue:@""];
    [self.durationTextField setStringValue:@""];

    self.timeSlider.maxValue = 0;
    self.timeSlider.minValue = 0;
    self.timeSlider.doubleValue = 0;
}

- (void)audioPlayerQueueEmpty:(RFAudioPlayer *)player
{
    [self audioPlayerDidStop:player];
}

- (void)audioPlayer:(RFAudioPlayer *)player didChangeToDevice:(RFAudioDevice *)device
{
    [self.settingsViewController refreshDisplay];
}

- (void)audioDevicesChanged:(RFAudioDeviceList *)deviceList
{
    [audioPlayer pause];
    [self updatePlayButtonState];
    
    RFAudioDevice *device = [[RFAudioDeviceList sharedInstance] outputDeviceByName:settings.preferredDevice];
    if ([device.deviceName isEqualToString:settings.preferredDevice])
        audioPlayer.outputDevice = device;
    
    [self.settingsViewController refreshDisplay];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
	if([SPMediaKeyTap usesGlobalMediaKeyTap])
		[keyTap startWatchingMediaKeys];
	else
		NSLog(@"Media key monitoring disabled");

    self.volumeSlider.volume = settings.volume;

    NSInteger activeDrawer = settings.activeDrawer;
    if (activeDrawer != RFDrawerClosedIndex)
        [self toggleDrawerForTabIndex:activeDrawer];

    [self.window makeKeyAndOrderFront:nil];
    [self.window makeFirstResponder:self.playerView];
    
    updateTimer = [NSTimer timerWithTimeInterval:0.25 target:self selector:@selector(updateDisplayInfo:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:updateTimer forMode:NSRunLoopCommonModes];
    
    [self checkLibrarySetup];
    
}

- (void)checkLibrarySetup
{
    [library masterPlaylist];
    
    NSUInteger trackCount = [library totalTrackCount];
    if (!trackCount)
    {
        NSAlert *alert = [NSAlert alertWithMessageText:@"There are no tracks in your library."
                                         defaultButton:@"Not now"
                                       alternateButton:@"Directory"
                                           otherButton:@"iTunes"
                             informativeTextWithFormat:@"Would you like to import from a directory or iTunes?"];
        [alert setAlertStyle:NSInformationalAlertStyle];
        NSUInteger value = [alert runModal];
        switch (value)
        {
            case NSAlertDefaultReturn:
                break;
                
            case NSAlertAlternateReturn:
                [self importDirectory:nil];
                break;
                
            case NSAlertOtherReturn:
                [self importiTunes:nil];
                break;
            default:
                break;
        }
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    if (importing)
        return NSTerminateCancel;
    return NSTerminateNow;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [settings save];
    [self.window orderOut:nil];
}

- (void)applicationWillBecomeActive:(NSNotification *)aNotification
{
    if ([self.window isVisible])
        [self.artworkView adjustChildWindow:NO];
}

- (void)setTime:(double)seconds textField:(NSTextField *)textField
{
    if (seconds == 0)
    {
        [textField setStringValue:@""];
        return;
    }
    
    int sec = 0, min = 0, hr = 0;
	
	sec = seconds + 0.5;
	min = sec/ 60;
	sec -= min * 60;
	hr = min / 60;
	min -= hr * 60;
    
    if (hr > 0)
        [textField setStringValue:[NSString stringWithFormat:@"%02d:%02d:%02d", hr, min, sec]];
    else
        [textField setStringValue:[NSString stringWithFormat:@"%02d:%02d", min, sec]];
}

- (float)elapsedTime
{
    return [audioPlayer elapsedTime];
}

- (float)duration
{
    return [audioPlayer totalTime];
}

- (void)updateDisplayInfo:(id)sender
{
    if ([audioPlayer isPlaying])
    {
        CFTimeInterval elapsedTime = [audioPlayer elapsedTime];
        CFTimeInterval totalTime = [audioPlayer totalTime];
        
        [self setTime:elapsedTime textField:self.timeTextField];
        [self setTime:totalTime textField:self.durationTextField];
        
        if ([[NSRunLoop currentRunLoop].currentMode isEqualToString:NSDefaultRunLoopMode])
        {
            self.timeSlider.maxValue = totalTime;
            self.timeSlider.minValue = 0;
            self.timeSlider.doubleValue = elapsedTime;
        }
    }
    
    [self updatePlayButtonState];
    
    self.useVisualizer = settings.useVisualizer;
}

- (void)setUseVisualizer:(BOOL)value
{
    if (_useVisualizer == value)
        return;
    
    _useVisualizer = value;
    if (_useVisualizer)
    {
        NSString *vizPath = [[NSBundle mainBundle] pathForResource:@"Occluded Light" ofType:@"qtz"];
        visualizer = [[RFCompositionView alloc] initWithFrame:NSMakeRect(0, 202, 202, 202)];
        [visualizer loadCompositionAtPath:vizPath];
        audioPlayer.visualizer = visualizer;
        if ([audioPlayer isPlaying])
            visualizer.enabled = YES;
        [self.artworkView setCompositionView:visualizer];
        visualizer.trackInfo = currentTrackInfo;
    }
    else
    {
        [self.artworkView setCompositionView:nil];
        visualizer.enabled = NO;
        audioPlayer.visualizer = nil;
        [visualizer loadCompositionAtPath:nil];
    }
    
    [self updateDisplayInfo:nil];
}

- (void)toggleDrawerForTabIndex:(NSUInteger)index;
{
    NSWindow *window = self.window;
    NSRect newFrame = window.frame;
    
    NSScreen *screen = window.screen;
    
    NSUInteger currentIndex = self.drawerTabView.activeViewControllerIndex;
    
    if (drawerOpen && (index != currentIndex))
    {
        [self toggleDrawerForTabIndex:currentIndex];
        [self toggleDrawerForTabIndex:index];
    }
    else
    if (!drawerOpen)
    {
        lastXPosition = newFrame.origin.x;
        if (lastXPosition + 608 > screen.visibleFrame.origin.x + screen.visibleFrame.size.width)
        {
            newFrame.origin.x = (screen.visibleFrame.origin.x + screen.visibleFrame.size.width) - (608 + 10);
            movedWhenDrawerOpen = YES;
            [self.artworkView adjustChildWindow:YES];
        }
        openXPosition = newFrame.origin.x;
        newFrame.size.width = 608;
        drawerOpen = YES;
        [[self.drawerTabView animator] setAlphaValue:1.0];
    }
    else
    {
        if (movedWhenDrawerOpen && newFrame.origin.x == openXPosition)
            newFrame.origin.x = lastXPosition;
        newFrame.size.width = 202;
        movedWhenDrawerOpen = NO;
        drawerOpen = NO;
        [[self.drawerTabView animator] setAlphaValue:0];
    }
    
    if (drawerOpen)
    {
        [self.drawerTabView setActiveControllerAtIndex:index];
        settings.activeDrawer = index;
    }
    else
        settings.activeDrawer = RFDrawerClosedIndex;

    [window setFrame:newFrame display:YES animate:YES];
    [self.artworkView adjustChildWindow:NO];
}

- (void)updatePlayButtonState
{
    if ([audioPlayer isPlaying])
        [self.playButton setState:NSOnState];
    else
        [self.playButton setState:NSOffState];
}

- (void)setShuffle:(BOOL)shuffle
{
    audioPlayer.shuffle = shuffle;
    settings.shuffle = shuffle;
    NSImage *image = nil;
    if (shuffle)
        image = [NSImage imageNamed:@"shuffleIconOn"];
    else
        image = [NSImage imageNamed:@"shuffleIcon"];
    [self.shuffleButton setImage:image];
}

- (void)setRepeatMode:(RepeatMode)mode
{
    audioPlayer.repeatMode = mode;
    settings.repeatMode = mode;
    NSImage *image = nil;
    switch (mode)
    {
        default:
        case eRepeatModeOff:
            image = [NSImage imageNamed:@"repeatIcon"];
            break;
            
        case eRepeatModeOn:
            image = [NSImage imageNamed:@"repeatIconOn"];
            break;
            
        case eRepeatModeSingle:
            image = [NSImage imageNamed:@"repeatIconOn1"];
            break;
    }
    [self.repeatButton setImage:image];
}

#pragma mark - Actions
- (IBAction)repeatAction:(id)sender
{
    RepeatMode currentMode = audioPlayer.repeatMode;
    currentMode++;
    if (currentMode > eRepeatModeSingle)
        currentMode = eRepeatModeOff;
    [self setRepeatMode:currentMode];
}

- (IBAction)shuffleAction:(id)sender
{
    [self setShuffle:!audioPlayer.shuffle];
}

- (IBAction)openSettingsAction:(id)sender
{
    [self toggleDrawerForTabIndex:1];
}

- (IBAction)openLibraryAction:(id)sender
{
    [self toggleDrawerForTabIndex:0];
    //[backstageController toggleViewState];
}

- (IBAction)prevTrackAction:(id)sender
{
    //NSLog(@"firstResponder = %@", [self.window firstResponder]);
    [audioPlayer previous];
}

- (IBAction)playPauseTrackAction:(id)sender
{
    [audioPlayer playPause];
}

- (IBAction)nextTrackAction:(id)sender
{
    [audioPlayer next];
}

- (IBAction)sliderMovedAction:(id)sender
{
    [audioPlayer seekToTime:self.timeSlider.doubleValue];
}

- (IBAction)volumeSliderAction:(id)sender
{
    [audioPlayer setVolume:self.volumeSlider.volume];
    settings.volume = self.volumeSlider.volume;
}

- (IBAction)decreaseVolumeAction:(id)sender
{
    self.volumeSlider.volume -= 0.1;
    settings.volume = self.volumeSlider.volume;
    [audioPlayer setVolume:self.volumeSlider.volume];
}

- (IBAction)increaseVolumeAction:(id)sender
{
    self.volumeSlider.volume += 0.1;
    settings.volume = self.volumeSlider.volume;
    [audioPlayer setVolume:self.volumeSlider.volume];
}

- (IBAction)importDirectory:(id)sender
{
    NSURL *directory = nil;
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setAllowsMultipleSelection:NO];
    
    NSInteger value = [openPanel runModal];
    
    if (value == NSFileHandlingPanelCancelButton)
        return;
    
    if ([[openPanel URLs] count] == 0)
        return;
    
    importing = YES;

    directory = [[openPanel URLs] objectAtIndex:0];
    
    // hide the player
    [audioPlayer stop];
    [self.window orderOut:nil];
    
    // show the import window
    [self.importPanel makeKeyAndOrderFront:nil];
    [self.importProgress setDoubleValue:100];
    [self.importProgress startAnimation:nil];

    [library importDirectory:directory progressBlock:^(NSString *text, float percentDone) {
        [self.importProgress setDoubleValue:percentDone];
        [self.importLabel setStringValue:text];
    } doneBlock:^{
        [self.importPanel orderOut:nil];
        [self.window makeKeyAndOrderFront:nil];
        [self.artworkView adjustChildWindow:NO];
        importing = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kLibraryUpdatedNotification object:nil];
    }];
}

- (IBAction)importiTunes:(id)sender
{
    NSURL *directory = [library iTunesPathURL];
    
    importing = YES;
    
    // hide the player
    [audioPlayer stop];
    [self.window orderOut:nil];
    
    // show the import window
    [self.importPanel makeKeyAndOrderFront:nil];
    [self.importProgress setDoubleValue:100];
    [self.importProgress startAnimation:nil];
    
    NSLog(@"Looking for iTunes data in %@", directory);
    
    RFLibraryImportProgressBlock progressBlock = ^(NSString *text, float percentDone) {
        [self.importProgress setDoubleValue:percentDone];
        [self.importLabel setStringValue:text];
    };
    
    [library importDirectory:directory progressBlock:progressBlock doneBlock:^{
        [library importiTunesPlaylistsWithProgressBlock:progressBlock doneBlock:^{
            [self.importPanel orderOut:nil];
            [self.window makeKeyAndOrderFront:nil];
            [self.artworkView adjustChildWindow:NO];
            importing = NO;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kLibraryUpdatedNotification object:nil];
        }];
    }];
}

@end
