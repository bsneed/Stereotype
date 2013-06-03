//
//  RFCollectionViewCell.m
//  image-browser
//
//  Created by Brandon Sneed on 3/30/13.
//
//

#import "RFCollectionViewCell.h"
#import "NSImage+QuickLook.h"

@interface RFCollectionViewCellLayer : CALayer
@property (nonatomic, weak) id testDelegate;
@end

@implementation RFCollectionViewCellLayer

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    //[self setNeedsDisplay];
}

- (void)setContentsScale:(CGFloat)contentsScale
{
    [super setContentsScale:contentsScale];
    [self setNeedsDisplay];
}

@end

/*enum {
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
}*/

//- (NSRect) centerRect: (NSRect) smallRect
//inRect: (NSRect) bigRect
//{
//    NSRect centerRect;
//    centerRect.size = smallRect.size;
//    
//    centerRect.origin.x = (bigRect.size.width - smallRect.size.width) / 2.0;
//    centerRect.origin.y = (bigRect.size.height - smallRect.size.height) / 2.0;
//    
//    return (centerRect);
//    
//} // centerRect



@implementation RFCollectionViewCell

- (CALayer *) layerForType:(NSString*) type
{
	NSRect frame = [self frame];
    
	//if (type == IKImageBrowserCellPlaceHolderLayer)
	//if (type == IKImageBrowserCellBackgroundLayer)
	if (type == IKImageBrowserCellForegroundLayer)
    {
		//no foreground layer on place holders
		if([self cellState] != IKImageStateReady)
			return nil;
        
        RFCollectionViewCellLayer *foregroundLayer = [RFCollectionViewCellLayer layer];
        foregroundLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        foregroundLayer.delegate = self;
        foregroundLayer.name = IKImageBrowserCellForegroundLayer;
        [foregroundLayer setNeedsDisplay];
        
        return foregroundLayer;
    }
    
	/* selection layer */
	if (type == IKImageBrowserCellSelectionLayer)
    {
        RFCollectionViewCellLayer *selectionLayer = [RFCollectionViewCellLayer layer];
        selectionLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        selectionLayer.shadowOpacity = 0.75;
        selectionLayer.shadowColor = [NSColor blackColor].CGColor;
        selectionLayer.shadowOffset = CGSizeMake(0, -1);
        selectionLayer.shadowRadius = 2;
        selectionLayer.delegate = self;
        selectionLayer.name = IKImageBrowserCellSelectionLayer;
        [selectionLayer setNeedsDisplay];
		
		return selectionLayer;
	}

	return [super layerForType:type];
}

- (NSRect)selectionFrame
{
	NSRect frame = NSInsetRect([self imageFrame], -8, -8);
    return frame;
}

- (NSRect)titleFrame
{
    NSRect titleFrame = [super titleFrame];
    titleFrame.origin.x -= 20;
    titleFrame.size.width += 40;
    return titleFrame;
}

- (NSRect)subtitleFrame
{
    NSRect titleFrame = [super subtitleFrame];
    titleFrame.origin.x -= 20;
    titleFrame.size.width += 40;
    return titleFrame;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    [NSGraphicsContext saveGraphicsState];
    NSGraphicsContext *currentContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
    [NSGraphicsContext setCurrentContext:currentContext];

    if (layer.name == IKImageBrowserCellSelectionLayer)
    {
        NSRect selectionFrame = self.selectionFrame;
        selectionFrame.origin.x = 0;
        selectionFrame.origin.y = 0;
        [self drawSelectionInContext:context inRect:selectionFrame];
    }
    else
    if (layer.name == IKImageBrowserCellForegroundLayer)
    {
        NSRect imageFrame = self.imageContainerFrame;
        imageFrame.origin.x = 0;
        imageFrame.origin.y = 40;
        [self drawForegroundInContext:context layer:layer inRect:imageFrame];
    }
    
    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawSelectionInContext:(CGContextRef)context inRect:(NSRect)selectionRect
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
    NSRect containerRect = selectionRect;
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

CGRect CGRectIntegralCenteredInRect(CGRect innerRect, CGRect outerRect)
{
    CGFloat originX = floorf((outerRect.size.width - innerRect.size.width) * 0.5f);
    CGFloat originY = floorf((outerRect.size.height - innerRect.size.height) * 0.5f);
    return CGRectIntegral(CGRectMake(originX, originY, innerRect.size.width, innerRect.size.height));
}

- (void)drawForegroundInContext:(CGContextRef)context layer:(CALayer *)layer inRect:(NSRect)rect
{
    NSRect imageFrame = self.imageFrame;
    CGRect imageRect = CGRectIntegralCenteredInRect(imageFrame, rect);
    imageRect.origin.y += 39.5;
    
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line moveToPoint:NSMakePoint(imageRect.origin.x, imageRect.origin.y + (imageRect.size.height))];
    [line lineToPoint:NSMakePoint(imageRect.origin.x + (imageRect.size.width), imageRect.origin.y + (imageRect.size.height))];
    [line setLineWidth:1.0]; /// Make it easy to see
    [[NSColor colorWithCalibratedWhite:1.0 alpha:0.2] set]; /// Make future drawing the color of lineColor.
    [line stroke];
}

@end
