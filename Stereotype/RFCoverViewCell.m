//
//  RFCoverViewCell.m
//  Stereotype
//
//  Created by brandon on 12/18/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFCoverViewCell.h"
#import "NSImage+QuickLook.h"

@interface RFCoverViewCellView : NSView
@property (nonatomic, weak) RFCoverViewCell *cell;
@end

@implementation RFCoverViewCell

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    self.drawSelection = NO;
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    //// General Declarations
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    
    //// Color Declarations
    NSColor* startColor = [NSColor colorWithCalibratedRed: 0.644 green: 0 blue: 0.367 alpha: 1];
    NSColor* endColor = [NSColor colorWithCalibratedRed: 0.306 green: 0.07 blue: 0.203 alpha: 1];
    NSColor* topHighlightColor = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 0.399];
    NSColor* bottomShadowColor = [NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha: 0.3];
    NSColor* nameTextColor = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 1];
    NSColor* subtitleColor = [NSColor colorWithCalibratedRed: 0.653 green: 0.648 blue: 0.648 alpha: 1];
    
    //// Gradient Declarations
    NSGradient* gradient = [[NSGradient alloc] initWithStartingColor: startColor endingColor: endColor];
    
    //// Shadow Declarations
    NSShadow* highlightShadow = [[NSShadow alloc] init];
    [highlightShadow setShadowColor: topHighlightColor];
    [highlightShadow setShadowOffset: NSMakeSize(0.1, -1.1)];
    [highlightShadow setShadowBlurRadius: 0];
    NSShadow* backgroundShadow = [[NSShadow alloc] init];
    [backgroundShadow setShadowColor: bottomShadowColor];
    [backgroundShadow setShadowOffset: NSMakeSize(0.1, -2.1)];
    [backgroundShadow setShadowBlurRadius: 8.5];
    NSShadow* textShadow = [[NSShadow alloc] init];
    [textShadow setShadowColor: bottomShadowColor];
    [textShadow setShadowOffset: NSMakeSize(0.1, -1.0)];
    [textShadow setShadowBlurRadius: 1.0];
    
    //// Abstracted Attributes
    NSString* nameTextContent = self.albumTitle;
    NSString* subtitleTextContent = self.artistName;
    NSString* textContent = self.playlistName;
    
    if (self.selected)
    {
        //// selectionRectangle Drawing
        NSBezierPath* selectionRectanglePath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(28, 45, 146, 146) xRadius: 9 yRadius: 9];
        [NSGraphicsContext saveGraphicsState];
        [backgroundShadow set];
        CGContextBeginTransparencyLayer(context, NULL);
        [gradient drawInBezierPath: selectionRectanglePath angle: -90];
        CGContextEndTransparencyLayer(context);
        
        ////// selectionRectangle Inner Shadow
        NSRect selectionRectangleBorderRect = NSInsetRect([selectionRectanglePath bounds], -highlightShadow.shadowBlurRadius, -highlightShadow.shadowBlurRadius);
        selectionRectangleBorderRect = NSOffsetRect(selectionRectangleBorderRect, -highlightShadow.shadowOffset.width, -highlightShadow.shadowOffset.height);
        selectionRectangleBorderRect = NSInsetRect(NSUnionRect(selectionRectangleBorderRect, [selectionRectanglePath bounds]), -1, -1);
        
        NSBezierPath* selectionRectangleNegativePath = [NSBezierPath bezierPathWithRect: selectionRectangleBorderRect];
        [selectionRectangleNegativePath appendBezierPath: selectionRectanglePath];
        [selectionRectangleNegativePath setWindingRule: NSEvenOddWindingRule];
        
        [NSGraphicsContext saveGraphicsState];
        {
            NSShadow* highlightShadowWithOffset = [highlightShadow copy];
            CGFloat xOffset = highlightShadowWithOffset.shadowOffset.width + round(selectionRectangleBorderRect.size.width);
            CGFloat yOffset = highlightShadowWithOffset.shadowOffset.height;
            highlightShadowWithOffset.shadowOffset = NSMakeSize(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset));
            [highlightShadowWithOffset set];
            [[NSColor grayColor] setFill];
            [selectionRectanglePath addClip];
            NSAffineTransform* transform = [NSAffineTransform transform];
            [transform translateXBy: -round(selectionRectangleBorderRect.size.width) yBy: 0];
            [[transform transformBezierPath: selectionRectangleNegativePath] fill];
        }
        [NSGraphicsContext restoreGraphicsState];
        
        [NSGraphicsContext restoreGraphicsState];
    }
    
    
    if (self.image)
    {
        //// imageRectangle Drawing
        [NSGraphicsContext saveGraphicsState];
        [backgroundShadow set];
        CGContextBeginTransparencyLayer(context, NULL);
        //[gradient drawInBezierPath: imageRectanglePath angle: -90];
        
        // image Drawing code here.
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        CGRect imageRect = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
        NSRect imageRectangleFromPath = NSMakeRect(34, 51, 134, 134);
        CGRect drawRect = GTMCGScaleRectangleToSize(imageRect, imageRectangleFromPath.size, GTMScaleProportionally);
        NSRect centeredRect = NSIntegralRect([self.image centerRect:drawRect inRect:imageRectangleFromPath]);
        centeredRect.origin.x += 34;
        centeredRect.origin.y += 51;
        [self.image drawInRect:centeredRect fromRect:imageRect operation:NSCompositeCopy fraction:1.0];
        
        
        CGContextEndTransparencyLayer(context);
        
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
        
        [NSGraphicsContext restoreGraphicsState];
    }
    else
    {
        //// Color Declarations
        NSColor* fillColor = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 0.035];
        NSColor* strokeColor = [NSColor colorWithCalibratedRed: 1 green: 0.998 blue: 0.998 alpha:0.161];
        
        //// imageRectangle Drawing
        NSRect imageRectangleRect = NSMakeRect(34, 51, 134, 134);
        NSBezierPath* imageRectanglePath = [NSBezierPath bezierPathWithRoundedRect: imageRectangleRect xRadius: 12 yRadius: 12];
        [fillColor setFill];
        [imageRectanglePath fill];
        [strokeColor setStroke];
        [imageRectanglePath setLineWidth: 3.5];
        CGFloat imageRectanglePattern[] = {5, 5, 5, 5};
        [imageRectanglePath setLineDash: imageRectanglePattern count: 4 phase: 0.3];
        [imageRectanglePath stroke];
        NSMutableParagraphStyle* imageRectangleStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [imageRectangleStyle setAlignment: NSCenterTextAlignment];
        
        NSDictionary* imageRectangleFontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [NSFont fontWithName: @"Helvetica" size: 12], NSFontAttributeName,
                                                      strokeColor, NSForegroundColorAttributeName,
                                                      imageRectangleStyle, NSParagraphStyleAttributeName, nil];
        
        [@"loading..." drawInRect: NSInsetRect(imageRectangleRect, 0, 58) withAttributes: imageRectangleFontAttributes];
    }

    if (!textContent || [textContent length] == 0)
    {
        //// nameText Drawing
        NSRect nameTextRect = NSMakeRect(10, 22, 182, 20);
        [NSGraphicsContext saveGraphicsState];
        [textShadow set];
        NSMutableParagraphStyle* nameTextStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [nameTextStyle setAlignment: NSCenterTextAlignment];
        [nameTextStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        
        
        NSDictionary* nameTextFontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [NSFont controlContentFontOfSize: [NSFont systemFontSize]], NSFontAttributeName,
                                                nameTextColor, NSForegroundColorAttributeName,
                                                nameTextStyle, NSParagraphStyleAttributeName, nil];
        
        [nameTextContent drawInRect: nameTextRect withAttributes: nameTextFontAttributes];
        [NSGraphicsContext restoreGraphicsState];
        
        
        
        //// subtitleText Drawing
        NSRect subtitleTextRect = NSMakeRect(10, 3, 182, 20);
        [NSGraphicsContext saveGraphicsState];
        [textShadow set];
        NSMutableParagraphStyle* subtitleTextStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [subtitleTextStyle setAlignment: NSCenterTextAlignment];
        [subtitleTextStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        
        NSDictionary* subtitleTextFontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    [NSFont controlContentFontOfSize: [NSFont smallSystemFontSize]], NSFontAttributeName,
                                                    subtitleColor, NSForegroundColorAttributeName,
                                                    subtitleTextStyle, NSParagraphStyleAttributeName, nil];
        
        [subtitleTextContent drawInRect: subtitleTextRect withAttributes: subtitleTextFontAttributes];
        [NSGraphicsContext restoreGraphicsState];
    }
    else
    {
        //// Text Drawing
        NSRect textRect = NSMakeRect(10, 5, 182, 37);
        [NSGraphicsContext saveGraphicsState];
        [textShadow set];
        NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [textStyle setAlignment: NSCenterTextAlignment];
        [textStyle setLineBreakMode:NSLineBreakByWordWrapping];
        
        NSDictionary* textFontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSFont controlContentFontOfSize: [NSFont systemFontSize]], NSFontAttributeName,
                                            nameTextColor, NSForegroundColorAttributeName,
                                            textStyle, NSParagraphStyleAttributeName, nil];
        
        [textContent drawWithRect: textRect options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes: textFontAttributes];
        [NSGraphicsContext restoreGraphicsState];
    }
}

@end

