//
//  RFDialSlider.m
//  Stereotype
//
//  Created by Brandon Sneed on 12/26/11.
//  Copyright (c) 2011 redf.net. All rights reserved.
//

#import "RFDialSlider.h"
#import "NSImage+QuickLook.h"

@implementation RFDialSlider

@synthesize value;
@synthesize minValue;
@synthesize maxValue;
@synthesize action;
@synthesize target;

#define VOLUME_STEP 0.00357
#define DEGREE_RANGE 280

#define degreesToRadians(x) (M_PI * x / 180.0)

- (BOOL)becomeFirstResponder {
    BOOL okToChange = [super becomeFirstResponder];
    if (okToChange) [self setKeyboardFocusRingNeedsDisplayInRect: [self bounds]];
    return okToChange;
}

- (BOOL)resignFirstResponder {
    BOOL okToChange = [super resignFirstResponder];
    if (okToChange) [self setKeyboardFocusRingNeedsDisplayInRect: [self bounds]];
    return okToChange;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)setVolume:(float)volume
{
    // step = 0.00357
    // deg steps = 280;
    if (volume > 1.0)
        volume = 1.0;
    if (volume < 0)
        volume = 0;
    
    value = 320 - ((volume * DEGREE_RANGE) / 1.0);// *  360 - (40 + (volume * DEGREE_RANGE));
    [self setNeedsDisplay];
    
    //[self sendAction:[self action] to:[self target]];
}

- (float)volume
{
    float result = ((320 - value) * 1.0) / DEGREE_RANGE;
    if (result > 1.0)
        result = 1.0;
    if (result < 0)
        result = 0;
    return result;
}

- (float)floatValue
{
    return [self volume];
}

- (void)setFloatValue:(float)volume
{
    [self setVolume:volume];
}

- (BOOL)wantsLayer
{
    return YES;
}

- (void)awakeFromNib
{
    [self setWantsLayer:YES];
    
    dialLayer = [CALayer layer];
    [self.layer addSublayer:dialLayer];

    NSImage *image = [NSImage imageNamed:@"largeButton"];//[images objectAtIndex:0];
    self.layer.contents = (id)[image CGImage];
    self.layer.delegate = self;
    
    NSImage *dotImage = [NSImage imageNamed:@"volumeDot"];//[images objectAtIndex:0];
    dialLayer.contents = (id)[dotImage CGImage];
    
    dialLayer.frame = CGRectMake(0, 0, dotImage.size.width, dotImage.size.height);
    
    minValue = 40;
    maxValue = 320;
    
    //self.volume = 0;
    
    [self sendActionOn:NSLeftMouseDraggedMask];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    //NSLog(@"event = %@", theEvent);
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    //NSPoint cursorPoint = [self convertPoint:theEvent.locationInWindow fromView:[self superview]];
    //NSLog(@"drag = %@", theEvent);
    //NSLog(@"point = %f, %f", cursorPoint.x, cursorPoint.y);
    
    //NSRect trackingRect = NSMakeRect(0, 0, 45, 45);
    //if (NSPointInRect(cursorPoint, trackingRect))
    {
        float offset = theEvent.deltaY * 4;// * 0.1;
        value += offset;
        
        if (value < minValue)
            value = minValue;
        
        if (value > maxValue)
            value = maxValue;
        
        [self setNeedsDisplay];
        //NSLog(@"value = %f", value);
        //NSLog(@"volume = %f", [self volume]);
        [self sendAction:[self action] to:[self target]];
    }
}

- (void)scrollLineUp:(id)sender
{
    float offset = 0.1;
    value += offset;
    
    if (value < minValue)
        value = minValue;
    
    if (value > maxValue)
        value = maxValue;
    
    [self setNeedsDisplay];
    [self sendAction:[self action] to:[self target]];
}

- (void)scrollLineDown:(id)sender
{
    float offset = 0.1;
    value -= offset;
    
    if (value < minValue)
        value = minValue;
    
    if (value > maxValue)
        value = maxValue;
    
    [self setNeedsDisplay];
    [self sendAction:[self action] to:[self target]];
}

- (void)scrollWheel:(NSEvent *)theEvent
{
    float offset = theEvent.deltaY * 4;
    value += offset;
    
    if (value < minValue)
        value = minValue;
    
    if (value > maxValue)
        value = maxValue;
    
    [self setNeedsDisplay];
    [self sendAction:[self action] to:[self target]];
}

/*- (void)rotateWithEvent:(NSEvent *)event
{
    NSLog(@"Rotation in degree is %f", [event rotation]);
    if (event.rotation < 0)
        value -= 1.0;
    else
    if (event.rotation > 0)
        value += 1.0;

    if (value < minValue)
        value = minValue;
    
    if (value > maxValue)
        value = maxValue;
    
    [self setNeedsDisplay];
    [self sendAction:[self action] to:[self target]];
}*/

- (void)dealloc
{
}

- (BOOL)_usesCustomTrackImage
{
    return YES;
}

- (BOOL)isFlipped
{
    return NO;
}

- (void)displayLayer:(CALayer *)layer
{
    dialLayer.affineTransform = CGAffineTransformMakeRotation(degreesToRadians(value));
}


@end
