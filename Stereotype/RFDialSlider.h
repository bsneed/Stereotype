//
//  RFDialSlider.h
//  Stereotype
//
//  Created by Brandon Sneed on 12/26/11.
//  Copyright (c) 2011 redf.net. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface RFDialSlider : NSControl
{
    CALayer *dialLayer;
    float value;
}

@property (nonatomic, assign) float value;
@property (nonatomic, assign) float maxValue;
@property (nonatomic, assign) float minValue;

@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) id target;

- (void)setVolume:(float)value;
- (float)volume;
- (float)floatValue;
- (void)setFloatValue:(float)aFloat;

@end
