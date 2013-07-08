//
//  RFAudioUnitContainer
//  Stereotype
//
//  Created by brandon on 11/23/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFAudioUnitContainer.h"
#import <AudioUnit/AUCocoaUIView.h>

@implementation RFAudioUnitContainer
{
    NSWindow *_unitWindow;
}

- (id)initWithName:(NSString *)name audioUnit:(AudioUnit)audioUnit
{
    self = [super init];
    _name = name;
    _audioUnit = audioUnit;
    return self;
}

- (void)dealloc
{
    [_unitWindow setDelegate:nil];
    [_unitWindow close];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [[[_unitWindow.contentView subviews] objectAtIndex:0] removeFromSuperview];
    _unitWindow = nil;
}

- (NSWindow *)unitWindow
{
    if (_unitWindow)
        return _unitWindow;
    
    _unitWindow = [[NSWindow alloc] initWithContentRect:NSZeroRect styleMask:NSTitledWindowMask | NSClosableWindowMask backing:NSBackingStoreBuffered defer:YES];
    [_unitWindow setReleasedWhenClosed:NO];
    [_unitWindow setDelegate:self];
    
    UInt32 dataSize = 0;
    Boolean isWritable = 0;
    AudioUnitCocoaViewInfo *cocoaViewInfo;
    
    OSStatus error = AudioUnitGetPropertyInfo(_audioUnit, kAudioUnitProperty_CocoaUI, kAudioUnitScope_Global, 0, &dataSize, &isWritable);
    if(error != noErr) {
        //NSLog(@"%@:%s No Cocoa View Exists: %s\n", [self class], (char *) _cmd, GetMacOSStatusErrorString(error));
        return nil;
    }
    
    cocoaViewInfo = (AudioUnitCocoaViewInfo *)malloc(dataSize);
    AudioUnitGetProperty(_audioUnit, kAudioUnitProperty_CocoaUI, kAudioUnitScope_Global, 0, cocoaViewInfo, &dataSize);
    
    unsigned numberOfClasses = (dataSize - sizeof(CFURLRef)) / sizeof (CFStringRef);
    NSURL *cocoaViewBundlePath = (__bridge NSURL *)cocoaViewInfo->mCocoaAUViewBundleLocation;
    NSBundle *cocoaViewBundle = [NSBundle bundleWithPath:[cocoaViewBundlePath path]];
    NSString *factoryClassName = (__bridge NSString *)cocoaViewInfo->mCocoaAUViewClass[0];
    Class factoryClass = [cocoaViewBundle classNamed:factoryClassName];
    
    id factoryInstance = [[factoryClass alloc] init];
    NSView *unitView = [factoryInstance uiViewForAudioUnit:_audioUnit withSize:NSZeroSize];
    
    if(cocoaViewInfo) {
        int i;
        for(i = 0; i < numberOfClasses; ++i) {
            CFRelease(cocoaViewInfo->mCocoaAUViewClass[i]);
        }
        
        free(cocoaViewInfo);
    }
    
    [_unitWindow setFrame:unitView.frame display:NO];
    [_unitWindow.contentView setBounds:unitView.frame];
    [_unitWindow.contentView addSubview:unitView];
    
    return _unitWindow;
}

- (AudioUnitParameterValue)valueForParameterID:(AudioUnitParameterID)parameterID scope:(AudioUnitScope)scope
{
    AudioUnitParameterValue result = 0.0;
    OSStatus error = AudioUnitGetParameter(_audioUnit, parameterID, scope, 0, &result);
    if (error != noErr)
        result = 0.0;

    return result;
}

- (void)setValue:(AudioUnitParameterValue)value parameterID:(AudioUnitParameterID)parameterID scope:(AudioUnitScope)scope
{
    OSStatus error = AudioUnitSetParameter(_audioUnit, parameterID, scope, 0, value, 0);
    if (error != noErr)
        NSLog(@"there was an error setting the parameters for: %@", _name);
}


@end
