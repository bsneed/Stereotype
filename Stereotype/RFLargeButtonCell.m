//
//  RFRoundButtonCell.m
//  Stereotype
//
//  Created by Brandon Sneed on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RFLargeButtonCell.h"

@implementation RFLargeButtonCell

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{
    NSImage *backgroundImage = [NSImage imageNamed:@"largeButton"];
	if ([self isHighlighted])
		backgroundImage = [NSImage imageNamed:@"largeButtonPressed"];
	
	[backgroundImage setFlipped: YES];
	[backgroundImage setScalesWhenResized: YES];
	[backgroundImage setSize:frame.size];
	[backgroundImage drawInRect:frame fromRect:frame operation: NSCompositeSourceOver fraction: 1.0];
    
    /*if (![self isHighlighted])
    {
        //// Color Declarations
        NSColor* strokeColor = [NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha: 1];
        NSColor* gradientStartColor = [NSColor colorWithCalibratedRed: 0.141 green: 0.141 blue: 0.141 alpha: 1];
        NSColor* gradientStopColor = [NSColor colorWithCalibratedRed: 0.081 green: 0.081 blue: 0.081 alpha: 1];
        NSColor* innerShadowColor = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 0.233];
        
        //// Gradient Declarations
        NSGradient* buttonGradient = [[NSGradient alloc] initWithStartingColor: gradientStopColor endingColor: gradientStartColor];
        
        //// Shadow Declarations
        NSShadow* innerShadow = [[NSShadow alloc] init];
        [innerShadow setShadowColor: innerShadowColor];
        [innerShadow setShadowOffset: NSMakeSize(0.1, -2.5)];
        [innerShadow setShadowBlurRadius: 0];
        
        //// Abstracted Attributes
        NSRect ovalRect = NSMakeRect(1.5, 1.5, frame.size.width - 3, frame.size.width - 3);
        
        
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
    }
    else
    {
        //// Color Declarations
        NSColor* strokeColor = [NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha: 1];
        NSColor* gradientStartColor = [NSColor colorWithCalibratedRed: 0.141 green: 0.141 blue: 0.141 alpha: 1];
        NSColor* gradientStopColor = [NSColor colorWithCalibratedRed: 0.081 green: 0.081 blue: 0.081 alpha: 1];
        NSColor* innerShadowPressedColor = [NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha: 0.164];
        
        //// Gradient Declarations
        NSGradient* buttonGradient = [[NSGradient alloc] initWithStartingColor: gradientStopColor endingColor: gradientStartColor];
        
        //// Shadow Declarations
        NSShadow* innerShadowPressed = [[NSShadow alloc] init];
        [innerShadowPressed setShadowColor: innerShadowPressedColor];
        [innerShadowPressed setShadowOffset: NSMakeSize(0.1, -6.1)];
        [innerShadowPressed setShadowBlurRadius: 0];
        
        //// Abstracted Attributes
        NSRect ovalRect = NSMakeRect(1.5, 1.5, frame.size.width - 3, frame.size.height - 3);
        
        
        //// Oval Drawing
        NSBezierPath* ovalPath = [NSBezierPath bezierPathWithOvalInRect: ovalRect];
        [buttonGradient drawInBezierPath: ovalPath angle: -90];
        
        ////// Oval Inner Shadow
        NSRect ovalBorderRect = NSInsetRect([ovalPath bounds], -innerShadowPressed.shadowBlurRadius, -innerShadowPressed.shadowBlurRadius);
        ovalBorderRect = NSOffsetRect(ovalBorderRect, -innerShadowPressed.shadowOffset.width, +(innerShadowPressed.shadowOffset.height - 2)); // need this to get the shadow to stop getting clipped
        ovalBorderRect = NSInsetRect(NSUnionRect(ovalBorderRect, [ovalPath bounds]), -1, -1);
        
        NSBezierPath* ovalNegativePath = [NSBezierPath bezierPathWithRect: ovalBorderRect];
        [ovalNegativePath appendBezierPath: ovalPath];
        [ovalNegativePath setWindingRule: NSEvenOddWindingRule];
        
        [NSGraphicsContext saveGraphicsState];
        {
            NSShadow* innerShadowPressedWithOffset = [innerShadowPressed copy];
            CGFloat xOffset = innerShadowPressedWithOffset.shadowOffset.width + round(ovalBorderRect.size.width);
            CGFloat yOffset = innerShadowPressedWithOffset.shadowOffset.height;
            innerShadowPressedWithOffset.shadowOffset = NSMakeSize(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset));
            [innerShadowPressedWithOffset set];
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
    }*/
	
	[[self attributedTitle] drawInRect:[self titleRectForBounds:frame]];
}

- (void)drawInteriorWithFrame:(NSRect)rect inView:(NSView *)controlView
{
	if ([self image])
	{
		NSImage *fgImage = [self image];
		if ([self state] == NSOnState)
			fgImage = [self alternateImage];
		
		[fgImage setFlipped: [[self controlView] isFlipped]];
		NSRect centeredRect = NSMakeRect(((rect.size.width / 2) - (fgImage.size.width / 2)) + 2, (rect.size.height / 2) - (fgImage.size.height / 2), fgImage.size.width, fgImage.size.height);
        if ([self isHighlighted])
            centeredRect.origin.y += 1;
		[fgImage drawInRect:centeredRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	}
}

@end
