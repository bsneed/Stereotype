//
//  AudioDevice.h
//  SFBAudioEngine
//
//  Created by brandon on 11/21/12.
//  Copyright (c) 2012 sbooth.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <CoreAudio/AudioHardware.h>
#import <AudioToolbox/AudioToolbox.h>

#pragma mark -- Device Format

@interface RFAudioDeviceFormat : NSObject
@property (nonatomic, readonly) Float64 sampleRate;
@property (nonatomic, readonly) UInt32 channels;
@property (nonatomic, readonly) UInt32 bits;
@property (nonatomic, readonly) BOOL isIntegerMode;
@property (nonatomic, readonly) AudioStreamBasicDescription *streamDescription;
@end

#pragma mark -- Device

@interface RFAudioDevice : NSObject

@property (nonatomic, readonly) AudioDeviceID deviceID;
@property (nonatomic, readonly) NSString *deviceName;
@property (nonatomic, readonly) NSString *uniqueDeviceID;
@property (nonatomic, readonly) NSArray *sampleRates;
@property (nonatomic, readonly) BOOL isInput;
@property (nonatomic, readonly) Float64 currentSampleRate;
@property (nonatomic, readonly) RFAudioDeviceFormat *currentFormat;
@property (nonatomic, readonly) RFAudioDeviceFormat *currentVirtualFormat;
@property (nonatomic, readonly) NSArray *allVirtualFormats;

- (id)initWithDeviceID:(AudioDeviceID)deviceID isInput:(BOOL)isInput;
- (NSArray *)formatsForSampleRate:(Float64)sampleRate;
- (BOOL)selectFormat:(RFAudioDeviceFormat *)newFormat;

@end

#pragma mark -- Device List

@class RFAudioDeviceList;
@protocol AudioDevicesChangedProtocol <NSObject>
- (void)audioDevicesChanged:(RFAudioDeviceList *)deviceList;
@end

@interface RFAudioDeviceList : NSObject

@property (nonatomic, readonly) RFAudioDevice *defaultInputDevice;
@property (nonatomic, readonly) RFAudioDevice *defaultOutputDevice;
@property (nonatomic, weak) id<AudioDevicesChangedProtocol> delegate;

+ (RFAudioDeviceList *)sharedInstance;

+ (NSArray *)outputDevices;
+ (NSArray *)inputDevices;

- (NSArray *)devices:(BOOL)forInput;

- (RFAudioDevice *)outputDeviceByName:(NSString *)deviceName;
- (RFAudioDevice *)inputDeviceByName:(NSString *)deviceName;

@end
