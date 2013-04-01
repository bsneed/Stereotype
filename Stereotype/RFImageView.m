//
//  RFImageView.m
//  Stereotype
//
//  Created by brandon on 1/1/13.
//  Copyright (c) 2013 redf.net. All rights reserved.
//

#import "RFImageView.h"
#import "NSImage+QuickLook.h"

@implementation RFImageView

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    
    CGRect imageRect = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    CGRect drawRect = GTMCGScaleRectangleToSize(imageRect, self.bounds.size, GTMScaleProportionally);
    NSRect centeredRect = NSIntegralRect([self.image centerRect:drawRect inRect:self.bounds]);
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
