//
//  RFDialSlider.m
//  Stereotype
//
//  Created by Brandon Sneed on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
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
    
    value = 320 - ((volume * DEGREE_RANGE) / 1.0);
    [self setNeedsDisplay];
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

- (void)awakeFromNib
{
    minValue = 40;
    maxValue = 320;

    [self sendActionOn:NSLeftMouseDraggedMask];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    context.shouldAntialias = YES;

    //// Color Declarations
    NSColor* strokeColor = [NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha: 1];
    NSColor* gradientStartColor = [NSColor colorWithCalibratedRed: 0.141 green: 0.141 blue: 0.141 alpha: 1];
    NSColor* gradientStopColor = [NSColor colorWithCalibratedRed: 0.081 green: 0.081 blue: 0.081 alpha: 1];
    NSColor* innerShadowColor = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 0.233];

    //// Gradient Declarations
    NSGradient* buttonGradient = [[NSGradient alloc] initWithStartingColor: gradientStartColor endingColor: gradientStopColor];

    //// Shadow Declarations
    NSShadow* innerShadow = [[NSShadow alloc] init];
    [innerShadow setShadowColor: innerShadowColor];
    [innerShadow setShadowOffset: NSMakeSize(0.1, -2.5)];
    [innerShadow setShadowBlurRadius: 0];

    //// Abstracted Attributes
    NSRect ovalRect = NSMakeRect(1.5, 1.5, self.frame.size.width - 3, self.frame.size.width - 3);


    //// Oval Drawing
    NSBezierPath* ovalPath = [NSBezierPath bezierPathWithOvalInRect: ovalRect];
    [buttonGradient drawInBezierPath: ovalPath angle: -90];

    ////// Oval Inner Shadow
    NSRect ovalBorderRect = NSInsetRect([ovalPath bounds], -innerShadow.shadowBlurRadius, -innerShadow.shadowBlurRadius);
    ovalBorderRect = NSOffsetRect(ovalBorderRect, -innerShadow.shadowOffset.width, -innerShadow.shadowOffset.height);
    ovalBorderRect = NSInsetRect(NSUnionRect(ovalBorderRect, [ovalPath bounds]), -1, -1);

    NSBezierPath* ovalNegativePath = [NSBezierPath bezierPathWithRect: ovalBorderRect];
    [ovalNegativePath appendBezierPath: ovalPath];
    [ovalNegativePath setWindingRule: NSEvenOddWindingRule];

    [NSGraphicsContext saveGraphicsState];
    {
        NSShadow* innerShadowWithOffset = [innerShadow copy];
        CGFloat xOffset = innerShadowWithOffset.shadowOffset.width + round(ovalBorderRect.size.width);
        CGFloat yOffset = innerShadowWithOffset.shadowOffset.height;
        innerShadowWithOffset.shadowOffset = NSMakeSize(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset));
        [innerShadowWithOffset set];
        [[NSColor grayColor] setFill];
        [ovalPath addClip];
        NSAffineTransform* transform = [NSAffineTransform transform];
        [transform translateXBy: -round(ovalBorderRect.size.width) yBy: 0];
        [[transform transformBezierPath: ovalNegativePath] fill];
    }
    [NSGraphicsContext restoreGraphicsState];

    [strokeColor setStroke];
    [ovalPath setLineWidth: 3];
    [ovalPath stroke];

    // now draw the dot.
    //// Color Declarations
    strokeColor = [NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha: 1];
    NSColor* color2 = [NSColor colorWithCalibratedRed: 0.455 green: 0.133 blue: 0.31 alpha: 1];
    NSColor* color3 = [NSColor colorWithCalibratedRed: 0.702 green: 0.141 blue: 0.443 alpha: 1];

    //// Gradient Declarations
    NSGradient* gradient = [[NSGradient alloc] initWithColorsAndLocations:
                            color2, 0.0,
                            [NSColor colorWithCalibratedRed: 0.578 green: 0.137 blue: 0.376 alpha: 1], 0.50,
                            color3, 1.0, nil];

    //// Oval 2 Drawing
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:(self.frame.size.width / 2) yBy:(self.frame.size.height / 2)];
    [transform rotateByRadians:degreesToRadians(value)];
    [transform translateXBy:-(self.frame.size.width / 2) yBy:-(self.frame.size.width / 2)];

    NSBezierPath* oval2Path = [transform transformBezierPath:[NSBezierPath bezierPathWithOvalInRect: NSMakeRect(19.5, 5.5, 7, 7)]];
    [gradient drawInBezierPath: oval2Path angle: 135];
    [strokeColor setStroke];
    [oval2Path setLineWidth: 1];
    [oval2Path stroke];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    float offset = theEvent.deltaY * 4;// * 0.1;
    value += offset;
    
    if (value < minValue)
        value = minValue;
    
    if (value > maxValue)
        value = maxValue;
    
    [self setNeedsDisplay];
    [self sendAction:[self action] to:[self target]];
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

- (BOOL)_usesCustomTrackImage
{
    return YES;
}

@end
