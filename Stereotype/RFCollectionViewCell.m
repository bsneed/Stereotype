//
//  RFCollectionViewCell.m
//  image-browser
//
//  Created by Brandon Sneed on 3/30/13.
//
//

#import "RFCollectionViewCell.h"
#import "RFCollectionView.h"
#import <QuartzCore/QuartzCore.h>

@interface NSView (LayerFix)
- (void)_updateLayerGeometryFromView;
@end

NSString *const RFCollectionViewCellLayerSelection = @"RFCollectionViewCellLayerSelection";
NSString *const RFCollectionViewCellLayerForeground = @"RFCollectionViewCellLayerForeground";
NSString *const RFCollectionViewCellLayerBackground = @"RFCollectionViewCellLayerBackground";
NSString *const RFCollectionViewCellLayerPlaceholder = @"RFCollectionViewCellLayerPlaceholder";

@implementation RFCollectionViewCell
{
    CALayer *selectionLayer;
}

- (id)init
{
    self = [super init];
    
    return self;
}

/*- (NSRect)imageFrame
{
    NSRect imageFrame = [super imageFrame];
    imageFrame.origin.x -= 30;
    return imageFrame;
}*/

/*- (NSRect)selectionFrame
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
}*/

- (CALayer *)layerForType:(NSString *)type
{
    CAGradientLayer *layer = nil;
    
    NSRect frame = self.frame;
    
    if (type == IKImageBrowserCellSelectionLayer)
    {
//        layer = [CALayer layer];
//        layer.delegate = self;
//        layer.name = RFCollectionViewCellLayerSelection;
//        layer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
//        
//        if ([self.imageBrowserView.delegate respondsToSelector:@selector(collectionView:selectionLayerToModify:)])
//            layer = [self.imageBrowserView.delegate collectionView:(RFCollectionView *)self.imageBrowserView selectionLayerToModify:layer];
//
//        [layer setNeedsDisplay];

        layer = [CAGradientLayer layer];
        //layer.delegate = self;
        //layer.name = RFCollectionViewCellLayerSelection;
        layer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        //if ([self.imageBrowserView.delegate respondsToSelector:@selector(collectionView:selectionLayerToModify:)])
        //    layer = [self.imageBrowserView.delegate collectionView:(RFCollectionView *)self.imageBrowserView selectionLayerToModify:layer];
        
        NSColor* startColor = [NSColor colorWithCalibratedRed: 0.644 green: 0 blue: 0.367 alpha: 1];
        NSColor* endColor = [NSColor colorWithCalibratedRed: 0.306 green: 0.07 blue: 0.203 alpha: 1];

        layer.colors = @[(id)startColor.CGColor, (id)endColor.CGColor];
        
        //[layer setNeedsDisplay];
    }
    
    return layer;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    [NSGraphicsContext saveGraphicsState];
    NSGraphicsContext *currentContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
    [NSGraphicsContext setCurrentContext:currentContext];

    if (layer.name == RFCollectionViewCellLayerSelection)
        [self drawSelection:context];
    else
    if (layer.name == RFCollectionViewCellLayerForeground)
        [self drawForeground:context];
    
    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawSelection:(CGContextRef)context
{
    
}

- (void)drawForeground:(CGContextRef)context
{
    
}


@end
