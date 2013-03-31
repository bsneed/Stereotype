//
//  RFCoverViewCell.m
//  Stereotype
//
//  Created by brandon on 12/18/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFCoverViewCell.h"

@implementation RFCoverViewCell

- (NSRect)selectionFrame
{
    return NSInsetRect(self.imageFrame, -6, -6);
}

- (NSRect)imageContainerFrame
{
    NSRect container = [super frame];
    container.origin.y += 15;
    container.origin.x += 15;
    container.size.width -= 15;
    container.size.height -= 15;
    
    return container;
}

- (NSRect)titleFrame
{
    NSRect titleFrame = [super titleFrame];
    titleFrame.origin.x = self.frame.origin.x;
    titleFrame.size.width = self.frame.size.width + 15;
    return titleFrame;
}

- (void)drawSelection:(CGContextRef)context
{
    //// Color Declarations
    NSColor* startColor = [NSColor colorWithCalibratedRed: 0.644 green: 0 blue: 0.367 alpha: 1];
    NSColor* endColor = [NSColor colorWithCalibratedRed: 0.306 green: 0.07 blue: 0.203 alpha: 1];
    NSColor* topHighlightColor = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 0.5];
    
    //// Gradient Declarations
    NSGradient* gradient = [[NSGradient alloc] initWithStartingColor: startColor endingColor: endColor];
    
    //// Shadow Declarations
    NSShadow* highlightShadow = [[NSShadow alloc] init];
    [highlightShadow setShadowColor: topHighlightColor];
    [highlightShadow setShadowOffset: NSMakeSize(0.1, -1.1)];
    [highlightShadow setShadowBlurRadius: 0];
    
    //// Rounded Rectangle Drawing
    NSRect containerRect = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
    NSBezierPath* roundedRectanglePath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(containerRect.origin.x, containerRect.origin.y, containerRect.size.width, containerRect.size.height) xRadius:5 yRadius: 5];
    [NSGraphicsContext saveGraphicsState];
    CGContextBeginTransparencyLayer(context, NULL);
    [gradient drawInBezierPath: roundedRectanglePath angle: -90];
    CGContextEndTransparencyLayer(context);
    
    ////// Rounded Rectangle Inner Shadow
    NSRect roundedRectangleBorderRect = NSInsetRect([roundedRectanglePath bounds], -highlightShadow.shadowBlurRadius, -highlightShadow.shadowBlurRadius);
    roundedRectangleBorderRect = NSOffsetRect(roundedRectangleBorderRect, -highlightShadow.shadowOffset.width, -highlightShadow.shadowOffset.height);
    roundedRectangleBorderRect = NSInsetRect(NSUnionRect(roundedRectangleBorderRect, [roundedRectanglePath bounds]), -1, -1);
    
    NSBezierPath* roundedRectangleNegativePath = [NSBezierPath bezierPathWithRect: roundedRectangleBorderRect];
    [roundedRectangleNegativePath appendBezierPath: roundedRectanglePath];
    [roundedRectangleNegativePath setWindingRule: NSEvenOddWindingRule];
    
    [NSGraphicsContext saveGraphicsState];
    {
        NSShadow* highlightShadowWithOffset = [highlightShadow copy];
        CGFloat xOffset = highlightShadowWithOffset.shadowOffset.width + round(roundedRectangleBorderRect.size.width);
        CGFloat yOffset = highlightShadowWithOffset.shadowOffset.height;
        highlightShadowWithOffset.shadowOffset = NSMakeSize(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset));
        [highlightShadowWithOffset set];
        [[NSColor grayColor] setFill];
        [roundedRectanglePath addClip];
        NSAffineTransform* transform = [NSAffineTransform transform];
        [transform translateXBy: -round(roundedRectangleBorderRect.size.width) yBy: 0];
        [[transform transformBezierPath: roundedRectangleNegativePath] fill];
    }
    [NSGraphicsContext restoreGraphicsState];
    
    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawForeground:(CGContextRef)context
{
    
}

@end
