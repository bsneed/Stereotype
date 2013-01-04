//
//  RFAudioPlayer.h
//  Stereotype
//
//  Created by brandon on 11/22/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFAudioDevices.h"
#import "RFAudioUnitContainer.h"

@class RFAudioPlayer;

@protocol RFAudioPlayerVisualizationProtocol <NSObject>
- (void)setBuffers:(float **)aBuffer numberOfBuffers:(NSInteger)count samples:(NSInteger)sampleCount;
@end

@protocol RFAudioPlayerDelegate <NSObject>
- (void)audioPlayer:(RFAudioPlayer *)player didChangeToDevice:(RFAudioDevice *)device;
- (void)audioPlayerDidStop:(RFAudioPlayer *)player;
- (void)audioPlayerQueueEmpty:(RFAudioPlayer *)player;
@end

typedef enum
{
    eRepeatModeOff = 0,
    eRepeatModeOn = 1,
    eRepeatModeSingle = 2
} RepeatMode;

@interface RFAudioPlayer : NSObject

@property (nonatomic, strong) RFAudioDevice *outputDevice;
@property (nonatomic, strong) RFAudioDevice *inputDevice;
@property (nonatomic, assign) Float64 outputSampleRate;
@property (nonatomic, assign) BOOL exclusiveMode;
@property (nonatomic, assign) BOOL upsampling;

@property (nonatomic, readonly) NSArray *queue;
@property (nonatomic, readonly) NSInteger queueIndex;
@property (nonatomic, assign) RepeatMode repeatMode;
@property (nonatomic, assign) BOOL shuffle;
@property (nonatomic, readonly) NSURL *currentURL;
@property (nonatomic, readonly) BOOL playing;

@property (nonatomic, weak) NSObject<RFAudioPlayerVisualizationProtocol> *visualizer;
@property (nonatomic, weak) NSObject<RFAudioPlayerDelegate> *delegate;

+ (RFAudioPlayer *)sharedInstance;

- (void)setQueue:(NSArray *)queue startAtIndex:(NSUInteger)index;

//- (void)addToQueue:(NSArray *)items;
//- (void)addToQueueAndPlayNext:(NSArray *)items;

- (BOOL)isPlaying;

- (void)play;
- (void)pause;
- (void)playPause;
- (void)stop;
- (void)next;
- (void)previous;
- (CFTimeInterval)elapsedTime;
- (CFTimeInterval)totalTime;
- (void)seekToTime:(CFTimeInterval)time;
- (void)setVolume:(Float32)volume;

- (NSWindow *)windowForEffectAtIndex:(NSUInteger)index;
- (NSWindow *)windowForEffectFilter:(NSString *)filterName;
- (void)setEffects:(NSArray *)filterNames;
- (void)clearEffects;
- (void)addNodeForEffectFilterName:(NSString *)filterName;
- (NSArray *)availableEffectsFilters;

- (void)setManagedOutputDevicePopup:(NSPopUpButton *)popup;
- (void)setManagedOutputSampleRatePopup:(NSPopUpButton *)popup;
- (void)setManagedOutputFormatPopup:(NSPopUpButton *)popup;

@end
