//
//  RFCollectionView.m
//  image-browser
//
//  Created by Brandon Sneed on 3/27/13.
//
//

#import "RFCollectionView.h"
#import "RFCollectionViewCell.h"

@interface NSView (LayerFix)
- (void)_updateLayerGeometryFromView;
@end

@implementation RFCollectionView

//@synthesize backgroundColor (setter = internalSetBackgroundColor, getter = internalBackgroundColor);

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)setContainerBackgroundColor:(NSColor *)color
{
    [self setValue:color forKey:IKImageBrowserBackgroundColorKey];
}

- (NSColor *)containerBackgroundColor
{
    return [self valueForKey:IKImageBrowserBackgroundColorKey];
}

- (void)setImageOutlineColor:(NSColor *)color
{
    [self setValue:[NSColor blackColor] forKey:IKImageBrowserCellsOutlineColorKey];
}

- (NSColor *)imageOutlineColor
{
    return [self valueForKey:IKImageBrowserCellsOutlineColorKey];
}

- (IKImageBrowserCell *)newCellForRepresentedItem:(id)anItem
{
    RFCollectionViewCell *cell = nil;
    
    if ([self.delegate respondsToSelector:@selector(collectionView:cellForItem:)])
        cell = [self.delegate collectionView:self cellForItem:anItem];
    else
        cell = [[RFCollectionViewCell alloc] init];

    return cell;
}

@end
