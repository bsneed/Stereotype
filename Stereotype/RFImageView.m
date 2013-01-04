//
//  RFImageView.m
//  Stereotype
//
//  Created by brandon on 1/1/13.
//  Copyright (c) 2013 redf.net. All rights reserved.
//

#import "RFImageView.h"

@implementation RFImageView

enum {
    GTMScaleProportionally = 0,   // Fit proportionally
    GTMScaleToFit,                // Forced fit (distort if necessary)
    GTMScaleNone                  // Don't scale (clip)
};
typedef NSUInteger GTMScaling;

CGRect GTMCGRectScale(CGRect inRect, CGFloat xScale, CGFloat yScale)
{
    return CGRectMake(inRect.origin.x, inRect.origin.y,
                      inRect.size.width * xScale, inRect.size.height * yScale);
}

CGRect GTMCGScaleRectangleToSize(CGRect scalee, CGSize size, GTMScaling scaling)
{
    switch (scaling) {
        case GTMScaleProportionally: {
            CGFloat height = CGRectGetHeight(scalee);
            CGFloat width = CGRectGetWidth(scalee);
            if (isnormal(height) && isnormal(width) && (height > size.height || width > size.width))
            {
                CGFloat horiz = size.width / width;
                CGFloat vert = size.height / height;
                CGFloat newScale = horiz < vert ? horiz : vert;
                scalee = GTMCGRectScale(scalee, newScale, newScale);
            }
            break;
        }
            
        case GTMScaleToFit:
            scalee.size = size;
            break;
            
        case GTMScaleNone:
        default:
            // Do nothing
            break;
    }
    return scalee;
}

- (NSRect) centerRect: (NSRect) smallRect
               inRect: (NSRect) bigRect
{
    NSRect centerRect;
    centerRect.size = smallRect.size;
    
    centerRect.origin.x = (bigRect.size.width - smallRect.size.width) / 2.0;
    centerRect.origin.y = (bigRect.size.height - smallRect.size.height) / 2.0;
    
    return (centerRect);
    
} // centerRect

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    
    CGRect imageRect = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    CGRect drawRect = GTMCGScaleRectangleToSize(imageRect, self.bounds.size, GTMScaleProportionally);
    NSRect centeredRect = NSIntegralRect([self centerRect:drawRect inRect:self.bounds]);
    [self.image drawInRect:centeredRect fromRect:imageRect operation:NSCompositeCopy fraction:1.0];
    
    NSRect rect = centeredRect;
    rect.origin.x += 0.5;
    rect.origin.y += 0.5;
    rect.size.width -= 1;
    rect.size.height -= 1;
    NSBezierPath* rectanglePath = [NSBezierPath bezierPathWithRect:rect];
    [[NSColor blackColor] setStroke];
    [rectanglePath setLineWidth: 1];
    [rectanglePath stroke];

    NSBezierPath *line = [NSBezierPath bezierPath];
    [line moveToPoint:NSMakePoint(centeredRect.origin.x + 1, centeredRect.origin.y + (centeredRect.size.height - 1.5))];
    [line lineToPoint:NSMakePoint(centeredRect.origin.x + (centeredRect.size.width - 1), centeredRect.origin.y + (centeredRect.size.height - 1.5))];
    [line setLineWidth:1.0]; /// Make it easy to see
    [[NSColor colorWithCalibratedWhite:1.0 alpha:0.25] set]; /// Make future drawing the color of lineColor.
    [line stroke];
}

@end
