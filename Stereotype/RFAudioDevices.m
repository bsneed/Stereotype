//
//  AudioDevice.m
//  SFBAudioEngine
//
//  Created by brandon on 11/21/12.
//  Copyright (c) 2012 sbooth.org. All rights reserved.
//

#import "RFAudioDevices.h"

#pragma mark -- Device Format

@implementation RFAudioDeviceFormat
{
    AudioStreamBasicDescription streamDesc;
}

+ (RFAudioDeviceFormat *)formatForDescription:(AudioStreamBasicDescription *)aDescription
{
    RFAudioDeviceFormat *format = [[RFAudioDeviceFormat alloc] init];
    memcpy(&format->streamDesc, aDescription, sizeof(AudioStreamBasicDescription));
    return format;
}

- (NSString*)description
{
    NSString *mixable = @"";
    NSString *linearPCM = @"linear PCM ";
    NSString *interleaved = @"";
    NSString *bits = @"";
    NSString *endianness = @"";
    NSString *floatOrInt = @"";
    NSString *alignedLow = @"";
    NSString *sampleRate = @"";
    
    UInt32 flags = streamDesc.mFormatFlags;
    if (flags & kAudioFormatFlagIsNonMixable)
        mixable = @"Non-mixable ";
    else
        mixable = @"Mixable ";
    
    if (flags & kAudioFormatFlagIsNonInterleaved)
        interleaved = @"Non-interleaved ";
    else
        interleaved = @"Interleaved ";
    
    if (flags & kAudioFormatFlagIsBigEndian)
        endianness = @"big endian ";
    else
        endianness = @"little endian ";
    
    if (flags & kAudioFormatFlagIsAlignedHigh)
        alignedLow = @"aligned high ";
    else
        alignedLow = @"aligned low ";
    
    if (flags & kAudioFormatFlagIsFloat)
        floatOrInt = @"Float ";
    else
    if (flags & kAudioFormatFlagIsSignedInteger)
        floatOrInt = @"Signed Integer ";
    else
        floatOrInt = @"Unsigned Integer ";
    
    bits = [NSString stringWithFormat:@"%dbits ", streamDesc.mBitsPerChannel];
    sampleRate = [NSString stringWithFormat:@"@ %fkHz ", streamDesc.mSampleRate];
    
    NSString *longDesc = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", mixable, linearPCM, interleaved, bits, endianness, floatOrInt, alignedLow, sampleRate];
    //NSLog(@"%@", longDesc);
    
    if (streamDesc.mFormatFlags & kAudioFormatFlagIsFloat)
        return [NSString stringWithFormat:@"%dch-%dbit Float", streamDesc.mChannelsPerFrame, streamDesc.mBitsPerChannel];
	return [NSString stringWithFormat:@"%dch-%dbit Integer", streamDesc.mChannelsPerFrame, streamDesc.mBitsPerChannel];
}

- (AudioStreamBasicDescription *)streamDescription
{
    return &streamDesc;
}

- (UInt32)channels
{
    return streamDesc.mChannelsPerFrame;
}

- (UInt32)bits
{
    return streamDesc.mBitsPerChannel;
}

- (Float64)sampleRate
{
    return streamDesc.mSampleRate;
}

- (BOOL)isIntegerMode
{
    if (streamDesc.mFormatFlags & kAudioFormatFlagIsFloat)
        return NO;
    return YES;
}

@end

#pragma mark -- Device

@implementation RFAudioDevice
{
    AudioObjectPropertyScope scope;
}

- (id)initWithDeviceID:(AudioDeviceID)deviceID isInput:(BOOL)isInput
{
    self = [super init];
    
    _deviceID = deviceID;
    _isInput = isInput;
    
    scope = kAudioDevicePropertyScopeOutput;
    if (_isInput)
        scope = kAudioDevicePropertyScopeInput;

    AudioStreamBasicDescription physicalFormat;
    OSStatus error = [self getPhysicalFormatForDevice:&physicalFormat];
    if (error == noErr)
    {
        CFStringRef stringRef = nil;
        UInt32 size = sizeof(CFStringRef);
        AudioObjectPropertyAddress nameProperty = { kAudioObjectPropertyName, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMaster };
        
        error = AudioObjectGetPropertyData(deviceID, &nameProperty, 0, nil, &size, &stringRef);
        if (error == noErr)
        {
            _deviceName = [NSString stringWithString:(__bridge NSString *)stringRef];
            CFRelease(stringRef);
        }
    
        AudioObjectPropertyAddress uniqueNameProperty = { kAudioDevicePropertyDeviceUID, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMaster };
        error = AudioObjectGetPropertyData(deviceID, &uniqueNameProperty, 0, nil, &size, &stringRef);
        if (error == noErr)
        {
            _uniqueDeviceID = [NSString stringWithString:(__bridge NSString *)stringRef];
            CFRelease(stringRef);
        }
    }
    
    return self;
}

- (OSStatus)getPhysicalFormatForDevice:(AudioStreamBasicDescription *)physicalFormat
{
	AudioObjectPropertyAddress formatProperty = { kAudioStreamPropertyPhysicalFormat, scope, kAudioObjectPropertyElementMaster };
	UInt32 size = sizeof(AudioStreamBasicDescription);
    
	return AudioObjectGetPropertyData(self.deviceID, &formatProperty, 0, nil, &size, physicalFormat);
}

- (OSStatus)getVirtualFormatForStream:(AudioStreamBasicDescription *)streamFormat
{
	AudioObjectPropertyAddress formatProperty = { kAudioStreamPropertyVirtualFormat, scope, kAudioObjectPropertyElementMaster } ;
	UInt32 size ;
    
	size = sizeof( AudioStreamBasicDescription ) ;
	return AudioObjectGetPropertyData(self.deviceID, &formatProperty, 0, nil, &size, streamFormat);
}

- (Float64)currentSampleRate
{
    AudioStreamBasicDescription physicalFormat;
    OSStatus error = [self getPhysicalFormatForDevice:&physicalFormat];
    if (error == noErr)
        return physicalFormat.mSampleRate;
    return 0;
}

- (RFAudioDeviceFormat *)currentFormat
{
    AudioStreamBasicDescription physicalFormat;
    OSStatus error = [self getPhysicalFormatForDevice:&physicalFormat];
    if (error == noErr)
        return [RFAudioDeviceFormat formatForDescription:&physicalFormat];
    return nil;
}

- (RFAudioDeviceFormat *)currentVirtualFormat
{
    AudioStreamBasicDescription virtualFormat;
    OSStatus error = [self getVirtualFormatForStream:&virtualFormat];
    if (error == noErr)
        return [RFAudioDeviceFormat formatForDescription:&virtualFormat];
    return nil;
}

- (NSArray *)sampleRates
{
    // Determine if this will actually be a change
    AudioObjectPropertyAddress propertyAddress = {
        .mSelector	= kAudioDevicePropertyAvailableNominalSampleRates,
        .mScope		= kAudioObjectPropertyScopeGlobal,
        .mElement	= kAudioObjectPropertyElementMaster
    };
    
    NSMutableArray *sampleRateArray = [[NSMutableArray alloc] init];
    
    UInt32 size = 0;
    
    OSStatus result = AudioObjectGetPropertyDataSize(self.deviceID, &propertyAddress, 0, nil, &size);
    if (result != noErr)
    {
        [sampleRateArray addObject:[NSNumber numberWithInteger:44100]];
        return sampleRateArray;
    }
    
    NSUInteger itemCount = size / sizeof(AudioValueRange);
    AudioValueRange *ranges = (AudioValueRange *)malloc(size);
    result = AudioObjectGetPropertyData(self.deviceID, &propertyAddress, 0, NULL, &size, ranges);
    if(result == noErr)
    {
        for (int i = 0; i < itemCount; i++)
        {
            AudioValueRange range = ranges[i];
            [sampleRateArray addObject:[NSNumber numberWithInteger:range.mMaximum]];
        }
    }
    free(ranges);
    return sampleRateArray;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"deviceName = %@, uniqueDeviceID = %@", self.deviceName, self.uniqueDeviceID];
}

- (NSArray *)allVirtualFormats
{
    NSMutableArray *supportedFormats = [[NSMutableArray alloc] init];
    AudioObjectPropertyAddress property = { kAudioStreamPropertyAvailableVirtualFormats, scope, kAudioObjectPropertyElementMaster };
    
    UInt32 size = 0 ;
    OSStatus status = AudioObjectGetPropertyDataSize(_deviceID, &property, 0, nil, &size);
    if (status == noErr && size > 0)
    {
        AudioStreamRangedDescription *rangedFormats = (AudioStreamRangedDescription *)malloc(size);
        status = AudioObjectGetPropertyData(_deviceID, &property, 0, nil, &size, rangedFormats);
        if (status == noErr)
        {
            int ranges = size / sizeof( AudioStreamRangedDescription);
            for (int i = 0; i < ranges; i++)
            {
                AudioStreamRangedDescription *range = &rangedFormats[i];
                [supportedFormats addObject:[RFAudioDeviceFormat formatForDescription:&range->mFormat]];
            }
        }
        free(rangedFormats);
    }
    
    return supportedFormats;
}

- (NSArray *)formatsForSampleRate:(Float64)sampleRate
{
    NSMutableArray *supportedFormats = [[NSMutableArray alloc] init];
    AudioObjectPropertyAddress property = { kAudioStreamPropertyAvailablePhysicalFormats, scope, kAudioObjectPropertyElementMaster };
    
	UInt32 size = 0 ;
	OSStatus status = AudioObjectGetPropertyDataSize(_deviceID, &property, 0, nil, &size);
	if (status == noErr && size > 0)
    {
        AudioStreamRangedDescription *rangedFormats = (AudioStreamRangedDescription *)malloc(size);
		status = AudioObjectGetPropertyData(_deviceID, &property, 0, nil, &size, rangedFormats);
		if (status == noErr)
        {
			int ranges = size / sizeof( AudioStreamRangedDescription);
			for (int i = 0; i < ranges; i++)
            {
				AudioStreamRangedDescription *range = &rangedFormats[i];
                if (range->mFormat.mSampleRate == sampleRate)
                    [supportedFormats addObject:[RFAudioDeviceFormat formatForDescription:&range->mFormat]];
			}
		}
		free(rangedFormats);
	}
    
    return supportedFormats;
}

- (BOOL)selectVirtualFormat:(RFAudioDeviceFormat *)newFormat
{
    /*
     -- audirvana's integer mode sets this.
     Printing description of virtualFormat->streamDesc:
     (AudioStreamBasicDescription) streamDesc = {
     mSampleRate = 96000
     mFormatID = 1819304813 // kAudioFormatLinearPCM
     mFormatFlags = 76 // kAudioFormatFlagIsNonMixable | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked
     mBytesPerPacket = 6
     mFramesPerPacket = 1
     mBytesPerFrame = 6
     mChannelsPerFrame = 2
     mBitsPerChannel = 24
     mReserved = 0
     }

     */

    AudioObjectPropertyAddress formatProperty = { kAudioStreamPropertyVirtualFormat, scope, kAudioObjectPropertyElementMaster };
    UInt32 size = sizeof(AudioStreamBasicDescription);
    AudioStreamBasicDescription *streamDesc = newFormat.streamDescription;
    
    OSStatus error = AudioObjectSetPropertyData(_deviceID, &formatProperty, 0, nil, size, streamDesc);

    if (error == noErr)
        return YES;
	return NO;

}

- (BOOL)selectFormat:(RFAudioDeviceFormat *)newFormat
{
	AudioObjectPropertyAddress formatProperty = { kAudioStreamPropertyPhysicalFormat, scope, kAudioObjectPropertyElementMaster };
    UInt32 size = sizeof(AudioStreamBasicDescription);
    AudioStreamBasicDescription *streamDesc = newFormat.streamDescription;
    OSStatus error = AudioObjectSetPropertyData(_deviceID, &formatProperty, 0, nil, size, streamDesc);

    //[self selectVirtualFormat:newFormat];
    
    if (error == noErr)
        return YES;
	return NO;
}

@end

#pragma mark -- Device List

@implementation RFAudioDeviceList

static AudioObjectPropertyAddress hardwareProperty = { kAudioHardwarePropertyDevices, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMaster } ;

+ (RFAudioDeviceList *)sharedInstance
{
    static dispatch_once_t onceToken;
    static RFAudioDeviceList *__instance = nil;
    dispatch_once(&onceToken, ^{
        __instance = [[RFAudioDeviceList alloc] init];
        [__instance registerForDeviceChanges];
    });
    return __instance;
}

+ (NSArray *)outputDevices
{
    RFAudioDeviceList *list = [[RFAudioDeviceList alloc] init];
    return [list devices:NO];
}

+ (NSArray *)inputDevices
{
    RFAudioDeviceList *list = [[RFAudioDeviceList alloc] init];
    return [list devices:YES];
}

static OSStatus hardwareChangeProc(AudioObjectID property, UInt32 addresses, const AudioObjectPropertyAddress address[], void *data)
{
    if (property == kAudioObjectSystemObject)
    {
        RFAudioDeviceList *deviceList = (__bridge RFAudioDeviceList *)data;
        [deviceList performSelectorOnMainThread:@selector(hardwareChanged) withObject:nil waitUntilDone:NO];
    }
    return noErr;
}

- (void)hardwareChanged
{
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(AudioDevicesChangedProtocol)])
        [self.delegate audioDevicesChanged:self];
}

- (void)registerForDeviceChanges
{
    AudioObjectAddPropertyListener(kAudioObjectSystemObject, &hardwareProperty, hardwareChangeProc, (__bridge void *)(self));
}

- (void)unregisterForDeviceChanges
{
    AudioObjectRemovePropertyListener(kAudioObjectSystemObject, &hardwareProperty, hardwareChangeProc, (__bridge void *)(self));
}

- (NSArray *)devices:(BOOL)forInput
{
    AudioObjectPropertyAddress property = { kAudioHardwarePropertyDevices, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMaster };
	
	NSMutableArray *deviceList = [[NSMutableArray alloc] init];

	UInt32 size = 0;
	AudioObjectGetPropertyDataSize( kAudioObjectSystemObject, &property, 0, nil, &size );
	
    NSUInteger deviceCount = size / sizeof(AudioDeviceID);
	AudioDeviceID *deviceIDArray = (AudioDeviceID *)malloc(size);
	AudioObjectGetPropertyData( kAudioObjectSystemObject, &property, 0, nil, &size, deviceIDArray);
    
    for (NSUInteger i = 0; i < deviceCount; i++)
    {
        RFAudioDevice *device = [[RFAudioDevice alloc] initWithDeviceID:deviceIDArray[i] isInput:forInput];
        if (device)
        {
            if (device.deviceName && [device.deviceName length] > 0 && device.deviceID != 0 && ![device.deviceName isEqualToString:@"AirPlay"])
                [deviceList addObject:device];
        }
	}
    
    free(deviceIDArray);
    
    //NSLog(@"devices = %@", deviceList);
    return deviceList;
}

- (RFAudioDevice *)defaultDevice:(BOOL)isInput
{
    AudioObjectPropertyAddress property = { kAudioHardwarePropertyDefaultInputDevice, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMaster } ;
    AudioDeviceID deviceID ;
    UInt32 size ;
    
    if ( isInput == NO ) property.mSelector = kAudioHardwarePropertyDefaultOutputDevice ;
    
    deviceID = 0 ;
    size = sizeof( AudioDeviceID ) ;
    AudioObjectGetPropertyData( kAudioObjectSystemObject, &property, 0, nil, &size, &deviceID ) ;
    
    RFAudioDevice *defaultDevice = [[RFAudioDevice alloc] initWithDeviceID:deviceID isInput:isInput];
    return defaultDevice;
}

- (RFAudioDevice *)defaultOutputDevice
{
    return [self defaultDevice:NO];
}

- (RFAudioDevice *)defaultInputDevice
{
    return [self defaultDevice:YES];
}

- (RFAudioDevice *)outputDeviceByName:(NSString *)deviceName
{
    NSArray *devices = [self devices:NO];
    for (RFAudioDevice *device in devices)
    {
        if ([device.deviceName isEqualToString:deviceName])
            return device;
    }
    return [self defaultOutputDevice];
}

- (RFAudioDevice *)inputDeviceByName:(NSString *)deviceName
{
    NSArray *devices = [self devices:YES];
    //NSLog(@"devices = %@", devices);
    for (RFAudioDevice *device in devices)
    {
        if ([device.deviceName isEqualToString:deviceName])
            return device;
    }
    return [self defaultOutputDevice];
}

@end
