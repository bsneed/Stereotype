//
//  RFAudioPlayer.m
//  Stereotype
//
//  Created by brandon on 11/22/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFAudioPlayer.h"
#import "NSFileManager+RFExtensions.h"
#import "RFMetadata.h"
#import "NSMutableArray+RFExtensions.h"
#import "RFSpectrumAnalyzer.h"
#import "RFCompositionView.h"

#import <SFBAudioEngine/AudioPlayer.h>
#import <SFBAudioEngine/CoreAudioOutput.h>
#import <SFBAudioEngine/AudioFormat.h>
#import <SFBAudioEngine/InputSource.h>
#import <SFBAudioEngine/AudioDecoder.h>
#import <SFBAudioEngine/AudioMetadata.h>

#define MAXQUEUESIZE 2

@interface RFAudioPlayer()
@property (atomic, assign) BOOL rendering;
@property (atomic, assign) BOOL decoding;
@property (nonatomic, readonly) SFB::Audio::CoreAudioOutput *internalOutput;
@end

@implementation RFAudioPlayer
{
    SFB::Audio::Player *_player;
    SFB::Audio::CoreAudioOutput *_output;
    
    NSTimer *renderTimer;
    BOOL needsToPlay;
    BOOL canSkipNext;
    BOOL canSkipPrevious;
    
    BOOL queueShouldStop;
    BOOL shouldQueueNextTrackAfterCurrent;
    NSURL *nextURL;
    
    NSArray *originalQueue;
    NSMutableArray *workingQueue;
    
    NSMutableArray *decoderQueue;
    
    NSMutableArray *effectFilters;
    
    NSPopUpButton *managedInputDevicePopup;
    NSPopUpButton *managedOutputDevicePopup;
    NSPopUpButton *managedOutputSampleRatePopup;
    NSPopUpButton *managedOutputFormatPopup;
}

#pragma mark - Instantiation

+ (RFAudioPlayer *)sharedInstance
{
    static dispatch_once_t onceToken;
    static RFAudioPlayer *__instance = nil;
    dispatch_once(&onceToken, ^{
        __instance = [[RFAudioPlayer alloc] init];
    });
    
    return __instance;
}

- (id)init
{
    self = [super init];
    
    [RFSpectrumAnalyzer sharedInstance].pointNumber = 512;
    [RFSpectrumAnalyzer sharedInstance].bandType = 4;
    
    decoderQueue = [[NSMutableArray alloc] init];
    _player = new SFB::Audio::Player();
    _output = new SFB::Audio::CoreAudioOutput();
    
    _player->SetOutput((std::unique_ptr<SFB::Audio::Output>)_output);
    
    self.outputDevice = [RFAudioDeviceList sharedInstance].defaultOutputDevice;
    _output->SetDeviceID(self.outputDevice.deviceID);
    //_output->SetDeviceMasterVolume(1.0);
    _output->SetSampleRateConverterComplexity(kAudioUnitSampleRateConverterComplexity_Mastering);
    
    //_player->SetDeviceMasterVolume(1.0);
    //_player->SetSampleRateConverterComplexity(kAudioUnitSampleRateConverterComplexity_Mastering);
    
    _player->SetRenderingStartedBlock(^(const SFB::Audio::Decoder& decoder) {
        @autoreleasepool {
            self.currentURL = [(__bridge NSURL *)_player->GetPlayingURL() copy];
            _queueIndex = [self indexOfURLFromQueue:self.currentURL];
            NSLog(@"started playing %@", self.currentURL);
            
            [self queueNextTrack];

            _rendering = YES;
            _playing = YES;
        }
    });
    
    _player->SetRenderingFinishedBlock(^(const SFB::Audio::Decoder& decoder) {
        @autoreleasepool {
            _rendering = NO;
            _playing = NO;
            
            if (_repeatMode == eRepeatModeOff)
            {
                if (queueShouldStop)
                {
                    [self stop];
                    NSInteger nextQueueIndex = 0;
                    nextURL = [workingQueue objectAtIndex:nextQueueIndex];
                    shouldQueueNextTrackAfterCurrent = ![self enqueueURL:nextURL];
                }
                else
                if (_queueIndex+1 >= [workingQueue count])
                {
                    queueShouldStop = YES;
                }
            }
        }
    });
    
    _player->SetDecodingStartedBlock(^(const SFB::Audio::Decoder& decoder) {
        @autoreleasepool {
            _decoding = YES;
            canSkipNext = YES;
            canSkipPrevious = YES;
        }
    });
    
    _player->SetDecodingFinishedBlock(^(const SFB::Audio::Decoder& decoder) {
        @autoreleasepool {
            _decoding = NO;
        }
    });
    
    _player->SetFormatMismatchBlock(^(const SFB::Audio::AudioFormat& currentFormat, const SFB::Audio::AudioFormat& nextFormat) {
        @autoreleasepool {
            Float64 sampleRate = 0;
            _output->GetDeviceSampleRate(sampleRate);
            if (nextFormat.mSampleRate != sampleRate)
            {
                [self performBlockOnMainThread:^{
                    _player->Pause();
                    _output->SetDeviceSampleRate(nextFormat.mSampleRate);
                    _player->Play();
                }];
            }
        }
    });
    
    _player->SetPostRenderBlock(^(AudioBufferList *data, UInt32 frameCount) {
        @autoreleasepool {
            [[RFSpectrumAnalyzer sharedInstance] processAudioInput:data sampleRate:[self outputSampleRate]];
        }
    });

    effectFilters = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)dealloc
{
    [renderTimer invalidate];
    
    _player->Stop();
    _player->ClearQueuedDecoders();
    delete _player;
    _player = nullptr;
}

#pragma mark - Managed Output Menu

- (void)popupDidChange:(NSMenu *)menu
{
    // do nothing
}

- (NSMenu *)menuForDevices:(NSArray *)deviceList
{
    NSArray *devices = deviceList;
    
    NSMenu *menu = [[NSMenu alloc] init];
    
    for (int i = 0; i < [devices count]; i++)
    {
        RFAudioDevice *device = [devices objectAtIndex:i];
        NSString *title = device.deviceName;
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
        item.representedObject = device;
        //item.target = self;
        //item.action = @selector(deviceChanged:);
        [item setEnabled:YES];
        [menu addItem:item];
    }
    
    return menu;
}

- (NSInteger)indexOfDevice:(RFAudioDevice *)device inDeviceList:(NSArray *)deviceList
{
    for (NSUInteger i = 0; i < [deviceList count]; i++)
    {
        RFAudioDevice *aDevice = [deviceList objectAtIndex:i];
        if ([device.uniqueDeviceID isEqualToString:aDevice.uniqueDeviceID])
            return i;
    }
    return -1;
}

- (void)setManagedOutputDevicePopup:(NSPopUpButton *)popup
{
    if (managedOutputDevicePopup)
        [managedOutputDevicePopup setTarget:nil];

    managedOutputDevicePopup = popup;
    if (managedOutputDevicePopup)
    {
        NSArray *deviceList = [RFAudioDeviceList outputDevices];
        [managedOutputDevicePopup setMenu:[self menuForDevices:deviceList]];
        
        NSInteger index = [self indexOfDevice:self.outputDevice inDeviceList:deviceList];
        if (index < 0)
        {
            // this will reset the poup.
            [self setOutputDevice:[RFAudioDeviceList sharedInstance].defaultOutputDevice];
            return;
        }
        
        [managedOutputDevicePopup selectItemAtIndex:[self indexOfDevice:self.outputDevice inDeviceList:deviceList]];
        [managedOutputDevicePopup setTarget:self];
        [managedOutputDevicePopup setAction:@selector(managedOutputDevicePopupChanged:)];
        [managedOutputDevicePopup setEnabled:YES];
    }
}

- (void)managedOutputDevicePopupChanged:(NSPopUpButton *)button
{
    RFAudioDevice *device = (RFAudioDevice *)[button selectedItem].representedObject;
    [self setOutputDevice:device];
    if ([self.delegate conformsToProtocol:@protocol(RFAudioPlayerDelegate)])
        [self.delegate audioPlayer:self didChangeToDevice:device];
}

#pragma mark - Managed Input Menu

- (void)setManagedInputDevicePopup:(NSPopUpButton *)popup
{
    if (managedOutputDevicePopup)
        [managedOutputDevicePopup setTarget:nil];
    
    managedOutputDevicePopup = popup;
    if (managedOutputDevicePopup)
    {
        NSArray *deviceList = [RFAudioDeviceList inputDevices];
        [managedOutputDevicePopup setMenu:[self menuForDevices:deviceList]];
        
        NSInteger index = [self indexOfDevice:self.inputDevice inDeviceList:deviceList];
        if (index < 1)
        {
            // this will reset the poup.
            [self setOutputDevice:[RFAudioDeviceList sharedInstance].defaultInputDevice];
            return;
        }
        
        [managedOutputDevicePopup selectItemAtIndex:[self indexOfDevice:self.outputDevice inDeviceList:deviceList]];
        [managedOutputDevicePopup setTarget:self];
        [managedOutputDevicePopup setAction:@selector(managedInputDevicePopupChanged:)];
        [managedOutputDevicePopup setEnabled:YES];
    }
}

- (void)managedInputDevicePopupChanged:(NSPopUpButton *)button
{
    RFAudioDevice *device = (RFAudioDevice *)[button selectedItem].representedObject;
    [self setOutputDevice:device];
    if ([self.delegate conformsToProtocol:@protocol(RFAudioPlayerDelegate)])
        [self.delegate audioPlayer:self didChangeToDevice:device];
}

#pragma mark - Managed Output Sample Rate Menu

- (NSMenu *)menuForSampleRates:(NSArray *)sampleRates
{
    NSMenu *menu = [[NSMenu alloc] init];
    
    for (int i = 0; i < [sampleRates count]; i++)
    {
        NSNumber *sampleRate = [sampleRates objectAtIndex:i];
        NSString *title = [sampleRate stringValue];
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
        item.representedObject = sampleRate;
        [item setEnabled:YES];
        [menu addItem:item];
    }
    
    return menu;
}

- (NSInteger)indexOfSampleRate:(NSNumber *)sampleRate inSampleRatesList:(NSArray *)sampleRatesList
{
    for (NSUInteger i = 0; i < [sampleRatesList count]; i++)
    {
        NSNumber *aSampleRate = [sampleRatesList objectAtIndex:i];
        if ([aSampleRate isEqualToNumber:sampleRate])
            return i;
    }
    return -1;
}

- (void)setManagedOutputSampleRatePopup:(NSPopUpButton *)popup
{
    if (managedOutputSampleRatePopup)
        [managedOutputSampleRatePopup setTarget:nil];
    
    managedOutputSampleRatePopup = popup;
    if (managedOutputSampleRatePopup)
    {
        NSArray *sampleRates = self.outputDevice.sampleRates;
        [managedOutputSampleRatePopup setMenu:[self menuForSampleRates:sampleRates]];
        
        NSNumber *sampleRate = [NSNumber numberWithFloat:self.outputSampleRate];
        [managedOutputSampleRatePopup selectItemAtIndex:[self indexOfSampleRate:sampleRate inSampleRatesList:sampleRates]];
        [managedOutputSampleRatePopup setTarget:self];
        [managedOutputSampleRatePopup setAction:@selector(managedOutputSampleRatePopupChanged:)];
        [managedOutputSampleRatePopup setEnabled:YES];
    }
}

- (void)managedOutputSampleRatePopupChanged:(NSPopUpButton *)button
{
    self.upsampling = YES;
    NSNumber *sampleRate = (NSNumber *)[button selectedItem].representedObject;
    [self setOutputSampleRate:sampleRate.floatValue];
    //[self setOutputFormat:_outputDevice.currentFormat];
    if ([self.delegate conformsToProtocol:@protocol(RFAudioPlayerDelegate)])
        [self.delegate audioPlayer:self didChangeToDevice:nil];
}

#pragma mark - Managed Output Format Menu

- (NSMenu *)menuForFormats:(NSArray *)formats
{
    NSMenu *menu = [[NSMenu alloc] init];
    
    for (int i = 0; i < [formats count]; i++)
    {
        RFAudioDeviceFormat *format = [formats objectAtIndex:i];
        NSString *title = [format description];
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
        item.representedObject = format;
        [item setEnabled:YES];
        [menu addItem:item];
    }
    
    return menu;
}

- (NSInteger)indexOfFormat:(RFAudioDeviceFormat *)format inFormatList:(NSArray *)formatList
{
    for (NSUInteger i = 0; i < [formatList count]; i++)
    {
        RFAudioDeviceFormat *aFormat = [formatList objectAtIndex:i];

        AudioStreamBasicDescription *desc1 = format.streamDescription;
        AudioStreamBasicDescription *desc2 = aFormat.streamDescription;
        if (memcmp(desc1, desc2, sizeof(AudioStreamBasicDescription) - sizeof(UInt32)) == 0)
            return i;
    }
    return -1;
}

- (void)setManagedOutputFormatPopup:(NSPopUpButton *)popup
{
    if (managedOutputFormatPopup)
        [managedOutputFormatPopup setTarget:nil];
    
    managedOutputFormatPopup = popup;
    if (managedOutputFormatPopup)
    {
        NSArray *formats = [self.outputDevice formatsForSampleRate:self.outputSampleRate];
        [managedOutputFormatPopup setMenu:[self menuForFormats:formats]];
        
        RFAudioDeviceFormat *format = self.outputDevice.currentFormat;
        [managedOutputFormatPopup selectItemAtIndex:[self indexOfFormat:format inFormatList:formats]];
        [managedOutputFormatPopup setTarget:self];
        [managedOutputFormatPopup setAction:@selector(managedOutputFormatPopupChanged:)];
        [managedOutputFormatPopup setEnabled:YES];
    }
}

- (void)managedOutputFormatPopupChanged:(NSPopUpButton *)button
{
    RFAudioDeviceFormat *format = (RFAudioDeviceFormat *)[button selectedItem].representedObject;
    [self setOutputFormat:format];
    if ([self.delegate conformsToProtocol:@protocol(RFAudioPlayerDelegate)])
        [self.delegate audioPlayer:self didChangeToDevice:nil];
}


#pragma mark - Properties

- (void)setOutputDevice:(RFAudioDevice *)outputDevice
{
    BOOL playing = [self isPlaying];
    if (playing)
        [self pause];
    
    _outputDevice = outputDevice;
    _output->SetDeviceID(outputDevice.deviceID);
    
    [self setManagedOutputDevicePopup:managedOutputDevicePopup];
    [self setManagedOutputSampleRatePopup:managedOutputSampleRatePopup];
    [self setManagedOutputFormatPopup:managedOutputFormatPopup];    
}

- (void)setUpsampling:(BOOL)upsampling
{
    _upsampling = upsampling;
    //NSLog(@"Upsampling = %i", _upsampling);

    // set the best sample rate
    NSArray *sampleRates = [self.outputDevice sampleRates];
    NSNumber *highestRate = [NSNumber numberWithFloat:0];
    for (NSNumber *rate in sampleRates)
    {
        if (rate.floatValue > highestRate.floatValue)
            highestRate = rate;
    }
    
    // TODO:: fix this?
    //_player->SetInputOutputSampleRatesShouldMatch(!_upsampling);

    BOOL wasPlaying = [self isPlaying];
    if (wasPlaying)
        [self pause];
    
    if (_upsampling)
    {
        self.outputSampleRate = highestRate.floatValue;
    }
    else
    {
        RFMetadata *urlMetadata = [[RFMetadata alloc] initWithURL:self.currentURL];
        self.outputSampleRate = [urlMetadata getSampleRate].floatValue;
    }
    
    if (wasPlaying)
        [self play];

    /*if (_upsampling)
    {
        self.outputSampleRate = highestRate.floatValue;
    }
    else
    if (audioPlayer->IsPerformingSampleRateConversion())
    {
        // FIXME
        Float64 inputSampleRate = 0;
        if (audioPlayer->GetSampleRateForInput(inputSampleRate))
        {
            if (inputSampleRate > 0 && inputSampleRate < highestRate.floatValue)
                self.outputSampleRate = inputSampleRate;
            else
                self.outputSampleRate = highestRate.floatValue;
        }
    }*/
}

- (void)setExclusiveMode:(BOOL)exclusiveMode
{
    _exclusiveMode = exclusiveMode;
    
    BOOL playing = [self isPlaying];
    if (playing && _exclusiveMode)
        _output->StartHoggingDevice();
    else
    if (!_exclusiveMode)
        _output->StopHoggingDevice();
}

- (void)setOutputSampleRate:(Float64)outputSampleRate
{
    if (outputSampleRate > 0)
    {
        _output->SetDeviceSampleRate(outputSampleRate);
        [self setManagedOutputFormatPopup:managedOutputFormatPopup];
    }
}

- (Float64)outputSampleRate
{
    Float64 outputSampleRate = 0;
    _output->GetDeviceSampleRate(outputSampleRate);
    
    return outputSampleRate;
}

- (void)setOutputFormat:(RFAudioDeviceFormat *)format
{
    BOOL playing = [self isPlaying];
    if (playing)
        _player->Pause();
    [self.outputDevice selectFormat:format];
    if (playing)
        _player->Play();
}

- (void)setCurrentURL:(NSURL *)currentURL
{
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(setCurrentURL:) withObject:currentURL waitUntilDone:YES];
        return;
    }
    
    if ([[_currentURL absoluteString] isEqualToString:[currentURL absoluteString]])
        return;
    
    [self willChangeValueForKey:@"currentURL"];
    _currentURL = currentURL;
    [self didChangeValueForKey:@"currentURL"];
}

- (void)setShuffle:(BOOL)shuffle
{
    if (_shuffle == shuffle)
        return;
    
    _shuffle = shuffle;
    if (_shuffle)
    {
        [workingQueue shufflePreservingIndex:_queueIndex];
        _player->ClearQueuedDecoders();
        [self queueNextTrack];
    }
    else
    {
        id currentItem = [workingQueue objectAtIndex:_queueIndex];
        workingQueue = [originalQueue mutableCopy];
        _queueIndex = [workingQueue indexOfObject:currentItem];
        _player->ClearQueuedDecoders();
        [self queueNextTrack];
    }
}

- (void)setRepeatMode:(RepeatMode)repeatMode
{
    if (_repeatMode == repeatMode)
        return;
    
    _repeatMode = repeatMode;
    _player->ClearQueuedDecoders();
    [self queueNextTrack];
}

- (void)setQueue:(NSArray *)queue startAtIndex:(NSUInteger)index
{
    if (queue.count == 0)
        return;
    
    if (index >= queue.count)
        index = 0;
    
    originalQueue = [queue copy];
    workingQueue = [queue mutableCopy];
    if (self.shuffle)
        [workingQueue shufflePreservingIndex:index];
    _queueIndex = index;
    [self loadQueuedURLAtIndex:_queueIndex];
}

- (NSArray *)queue
{
    return [NSArray arrayWithArray:workingQueue];
}

- (NSUInteger)indexOfURLFromQueue:(NSURL *)url
{
    for (int i = 0; i < [workingQueue count]; i++)
    {
        NSURL *queueURL = [workingQueue objectAtIndex:i];
        NSString *url1 = [queueURL absoluteString];
        NSString *url2 = [url absoluteString];
        if ([url1 isEqualToString:url2])
            return i;
    }
    return NSNotFound;
}

- (void)queueNextTrack
{
    if (_repeatMode == eRepeatModeOn)
    {
        NSInteger nextQueueIndex = _queueIndex + 1;
        if (nextQueueIndex < 0)
            nextQueueIndex = 0;
        if (nextQueueIndex >= [workingQueue count])
            nextQueueIndex = 0;
        nextURL = [workingQueue objectAtIndex:nextQueueIndex];
        shouldQueueNextTrackAfterCurrent = ![self enqueueURL:nextURL];
    }
    else
    if (_repeatMode == eRepeatModeSingle)
    {
        NSInteger nextQueueIndex = _queueIndex;
        nextURL = [workingQueue objectAtIndex:nextQueueIndex];
        shouldQueueNextTrackAfterCurrent = ![self enqueueURL:nextURL];
    }
    if (_repeatMode == eRepeatModeOff)
    {
        NSInteger nextQueueIndex = _queueIndex + 1;
        if (nextQueueIndex < 0)
            nextQueueIndex = 0;
        if (nextQueueIndex >= [workingQueue count])
            return;
        nextURL = [workingQueue objectAtIndex:nextQueueIndex];
        shouldQueueNextTrackAfterCurrent = ![self enqueueURL:nextURL];
    }
}

#pragma mark - Rendering timer

- (void)renderTimerFired:(NSTimer*)timer
{
//    if (ePlayerFlagRenderingStarted & _playerFlags)
//    {
//		OSAtomicTestAndClearBarrier(7 /* ePlayerFlagRenderingStarted */, &_playerFlags);
//        
//        self.currentURL = [(__bridge NSURL *)audioPlayer->GetPlayingURL() copy];
//        _queueIndex = [self indexOfURLFromQueue:self.currentURL];//[_queue indexOfObjectIdenticalTo:self.currentURL];
//        //NSLog(@"started playing %@", self.currentURL);
//        
//        [self queueNextTrack];
//        
//        _rendering = YES;
//	}
//    else
//    if (ePlayerFlagRenderingFinished & _playerFlags)
//    {
//		OSAtomicTestAndClearBarrier(6 /* ePlayerFlagRenderingFinished */, &_playerFlags);
//        //NSLog(@"stopped playing");
//        _rendering = NO;
//        
//        if (_repeatMode == eRepeatModeOff)
//        {
//            if (queueShouldStop)
//            {
//                [self stop];
//                NSInteger nextQueueIndex = 0;
//                nextURL = [workingQueue objectAtIndex:nextQueueIndex];
//                shouldQueueNextTrackAfterCurrent = ![self enqueueURL:nextURL];
//            }
//            else
//            if (_queueIndex+1 >= [workingQueue count])
//            {
//                queueShouldStop = YES;
//            }
//        }
//	}
//    else
//    if (ePlayerFlagDecodingStarted & _playerFlags)
//    {
//        OSAtomicTestAndClearBarrier(5 /* ePlayerFlagDecodingStarted */, &_playerFlags);
//        //NSLog(@"started decoding %@", self.currentURL);
//        _decoding = YES;
//        canSkipNext = YES;
//        canSkipPrevious = YES;
//    }
//    else
//    if (ePlayerFlagDecodingFinished & _playerFlags)
//    {
//        OSAtomicTestAndClearBarrier(4 /* ePlayerFlagDecodingFinished */, &_playerFlags);
//        //NSLog(@"stopped decoding");
//        _decoding = NO;
//    }
    
    CFTimeInterval currentTime = 0;
    _player->GetCurrentTime(currentTime);
    
    NSUInteger currentTimeAsInt = currentTime;
    
    if (_elapsedTimeInSeconds != currentTimeAsInt)
    {
        [self willChangeValueForKey:@"elapsedTimeInSeconds"];
        _elapsedTimeInSeconds = currentTimeAsInt;
        [self didChangeValueForKey:@"elapsedTimeInSeconds"];
    }

    if (_rendering)
    {
        BOOL playing = [self isPlaying];
        if (playing != _playing)
        {
            [self willChangeValueForKey:@"playing"];
            _playing = playing;
            [self didChangeValueForKey:@"playing"];
        }
    }    
}

#pragma mark - Effects Utilities

- (NSWindow *)windowForEffectAtIndex:(NSUInteger)index
{
    RFAudioUnitContainer *container = [effectFilters objectAtIndex:index];
    return container.unitWindow;
}

- (NSWindow *)windowForEffectFilter:(NSString *)filterName
{
    for (int i = 0; i < [effectFilters count]; i++)
    {
        RFAudioUnitContainer *container = [effectFilters objectAtIndex:i];
        if ([filterName isEqualToString:container.name])
        {
            return [self windowForEffectAtIndex:i];
        }
    }
    return nil;
}

- (void)clearEffects;
{
    for (RFAudioUnitContainer *container in effectFilters)
    {
        _output->RemoveEffect(container.audioUnit);
    }
    [effectFilters removeAllObjects];
}

- (void)setEffects:(NSArray *)filterNames
{
    BOOL playing = [self isPlaying];
    if (playing)
        _player->Pause();
    
    [self clearEffects];
    
    for (NSUInteger i = 0; i < [filterNames count]; i++)
    {
        NSString *filterName = [filterNames objectAtIndex:i];
        [self addNodeForEffectFilterName:filterName];
    }

    if (_use432hzAdjustment)
        [self add432hzPitchAdjustment];

    if (playing)
        _player->Play();
}

- (void)add432hzPitchAdjustment
{
    NSString *filterName = @"Apple: AUNewTimePitch";
    //NSString *filterName = @"The DSP Dimension/Stephan Bernsee: DiracFxAU";

    //kAudioUnitSubType_Pitch
    
    if (!effectFilters)
        effectFilters = [[NSMutableArray alloc] init];

    if (filterName == nil || [filterName length] <= 0 || [filterName isEqualToString:@"None"])
        return;

    AudioComponentDescription fxDesc = { kAudioUnitType_FormatConverter, 0, 0, 0, 0 } ;
    AudioComponent component = AudioComponentFindNext(NULL, &fxDesc);
    while (component)
    {
        AudioComponentDescription componentDesc;
        AudioComponentGetDescription(component, &componentDesc);

        CFStringRef nameRef = nil;
        AudioComponentCopyName(component, &nameRef);
        NSLog(@"componentName = %@", nameRef);
        NSString *name = [(__bridge NSString *)nameRef copy];
        CFRelease(nameRef);

        if ([name isEqualToString:filterName])
        {
            AudioUnit effectUnit = nil;
            if (_output->AddEffect(componentDesc.componentType, componentDesc.componentSubType, componentDesc.componentManufacturer, componentDesc.componentFlags, componentDesc.componentFlagsMask, &effectUnit))
            {
                RFAudioUnitContainer *container = [[RFAudioUnitContainer alloc] initWithName:name audioUnit:effectUnit];

                AudioUnitParameterID parameterID = kNewTimePitchParam_Pitch;
                //AudioUnitParameterID parameterID = 0;
                
                [container setValue:-31.76665363342977 parameterID:parameterID scope:kAudioUnitScope_Global];
                [container setValue:1.0 parameterID:kNewTimePitchParam_Rate scope:kAudioUnitScope_Global];

                [effectFilters addObject:container];
            }
            break;
        }

        component = AudioComponentFindNext(component, &fxDesc);
    }
}

- (void)addNodeForEffectFilterName:(NSString *)filterName
{
    if (!effectFilters)
        effectFilters = [[NSMutableArray alloc] init];
    
    if (filterName == nil || [filterName length] <= 0 || [filterName isEqualToString:@"None"])
        return;
    
    AudioComponentDescription fxDesc = { kAudioUnitType_Effect, 0, 0, 0, 0 } ;
    AudioComponent component = AudioComponentFindNext(NULL, &fxDesc);
    while (component)
    {
        AudioComponentDescription componentDesc;
        AudioComponentGetDescription(component, &componentDesc);
        
        CFStringRef nameRef = nil;
        AudioComponentCopyName(component, &nameRef);
        //NSLog(@"componentName = %@", nameRef);
        NSString *name = [(__bridge NSString *)nameRef copy];
        CFRelease(nameRef);
        
        if ([name isEqualToString:filterName])
        {
            AudioUnit effectUnit = nil;
            if (_output->AddEffect(componentDesc.componentType, componentDesc.componentSubType, componentDesc.componentManufacturer, componentDesc.componentFlags, componentDesc.componentFlagsMask, &effectUnit))
            {
                RFAudioUnitContainer *container = [[RFAudioUnitContainer alloc] initWithName:name audioUnit:effectUnit];
                [effectFilters addObject:container];
            }
            break;
        }
        
        component = AudioComponentFindNext(component, &fxDesc);
    }
}

- (NSArray *)availableEffectsFilters
{
    NSMutableArray *result = [NSMutableArray array];
    AudioComponentDescription fxDesc = { kAudioUnitType_Effect, 0, 0, 0, 0 } ;
    AudioComponent component = AudioComponentFindNext(NULL, &fxDesc);
    while (component)
    {
        AudioComponentDescription componentDesc;
        AudioComponentGetDescription(component, &componentDesc);
        
        CFStringRef nameRef = nil;
        NSString *name = nil;
        AudioComponentCopyName(component, &nameRef);
        //NSLog(@"componentName = %@", nameRef);
        name = [(__bridge NSString *)nameRef copy];
        CFRelease(nameRef);
        
        BOOL inUse = NO;
        if (!inUse)
            [result addObject:name];
        
        component = AudioComponentFindNext(component, &fxDesc);
    }
    
    return result;
}


#pragma mark - Utility methods

- (void)changeSampleRate:(NSNumber *)sampleRate
{
    if (!self.upsampling)
    {
        if (self.outputSampleRate != sampleRate.floatValue)
        {
            self.outputSampleRate = sampleRate.floatValue;
            // this is only called from a sample rate change, which was paused previously.
            //audioPlayer->Play();
        }
    }
}

/*- (void)addToQueue:(NSArray *)items
{
    self.queue = [self.queue arrayByAddingObjectsFromArray:items];
}

- (void)addToQueueAndPlayNext:(NSArray *)items
{
    //NSMutableArray *combinedArray = [self.queue mutableCopy];
    //[combinedArray insertObjects:items atIndexes:nil];
}*/

- (BOOL)enqueueURL:(NSURL*)url
{
    if ([url.scheme isEqualToString:@"http"])
    {
        return NO;
    }
    
    BOOL useMemoryInputSource = YES;
    
    auto inputSource = SFB::InputSource::CreateInputSourceForURL((__bridge CFURLRef)url, useMemoryInputSource ? SFB::InputSource::LoadFilesInMemory : 0, nullptr);
    if (inputSource == nullptr)
    {
        return NO;
    }
    
    SFB::Audio::Decoder::SetAutomaticallyOpenDecoders(true);
    auto decoder = SFB::Audio::Decoder::CreateDecoderForInputSource(std::move(inputSource));
    if (decoder == nullptr)
    {
        inputSource = nullptr;
        return NO;
    }
    
	if ((_player->Enqueue(decoder)) == false)
    {
		decoder = nullptr;
        return NO;
	}
    
    return YES;
}

- (BOOL)isPlaying
{
    if (_player->IsPlaying() && !_player->IsPaused())
        return YES;
    return NO;
}

- (void)play
{
    if (_exclusiveMode)
        _output->StartHoggingDevice();
    //NSLog(@"virtual formats for %@ = %@", self.outputDevice.deviceName, self.outputDevice.allVirtualFormats);
    _player->Play();
}

- (void)pause
{
    _player->Pause();
    if (_exclusiveMode)
        _output->StopHoggingDevice();
}

- (void)playPause
{
    if (![self isPlaying])
    {
        if (_exclusiveMode)
            _output->StartHoggingDevice();
        [self.outputDevice selectFormat:self.outputDevice.currentFormat];
        //NSLog(@"virtual formats for %@ = %@", self.outputDevice.deviceName, self.outputDevice.allVirtualFormats);
    }
    _player->PlayPause();

    if (![self isPlaying])
    {
        if (_exclusiveMode)
            _output->StopHoggingDevice();
    }
}

- (void)stop
{
    queueShouldStop = NO;
    nextURL = nil;
    _player->Stop();
    _player->ClearQueuedDecoders();
    
    if (_exclusiveMode)
        _output->StopHoggingDevice();

    if ([self.delegate conformsToProtocol:@protocol(RFAudioPlayerDelegate)])
        [self.delegate audioPlayerDidStop:self];
}

- (void)loadQueuedURLAtIndex:(NSInteger)index
{
    _queueIndex = index;

    if (index >= [workingQueue count] || index < 0)
        _queueIndex = 0;
    
    if (workingQueue.count == 0)
        return;
    
    NSURL *url = [workingQueue objectAtIndex:_queueIndex];
    if (url)
    {
        if ([self enqueueURL:url])
            self.currentURL = url;
    }
}

- (void)next
{
    if (!canSkipNext)
        return;
    
    canSkipNext = NO;
    BOOL wasPlaying = [self isPlaying];
    
    [self stop];
    [self loadQueuedURLAtIndex:self.queueIndex + 1];
    if (wasPlaying)
        [self play];
}

- (void)previous
{
    if (!canSkipPrevious)
        return;
    
    canSkipPrevious = NO;
    BOOL wasPlaying = [self isPlaying];
    
    [self stop];
    [self loadQueuedURLAtIndex:self.queueIndex - 1];
    if (wasPlaying)
        [self play];
}

- (CFTimeInterval)elapsedTime
{
    CFTimeInterval result = 0;
    _player->GetCurrentTime(result);
    return result;
}

- (CFTimeInterval)totalTime
{
    CFTimeInterval result = 0;
    _player->GetTotalTime(result);
    return result;
}

- (void)seekToTime:(CFTimeInterval)time
{
    _player->SeekToTime(time);
}

- (void)setVolume:(Float32)volume
{
    _output->SetDeviceMasterVolume(volume);
    _output->SetVolume(volume);
}

@end
