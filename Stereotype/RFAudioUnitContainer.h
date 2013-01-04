//
//  RFAudioUnitContainer
//  Stereotype
//
//  Created by brandon on 11/23/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <CoreAudio/AudioHardware.h>
#import <AudioToolbox/AudioToolbox.h>

@interface RFAudioUnitContainer : NSObject<NSWindowDelegate>

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) AudioUnit audioUnit;
@property (weak, nonatomic, readonly) NSWindow *unitWindow;

- (id)initWithName:(NSString *)name audioUnit:(AudioUnit)audioUnit;

@end
