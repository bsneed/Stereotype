//
//  RFCollectionView.m
//  Stereotype
//
//  Created by Brandon Sneed on 3/27/13.
//  Copyright (c) 2013 redf.net. All rights reserved.
//

#import "RFCollectionView.h"
#import "RFCoverViewCell.h"
#import "RFPlaylistEntity.h"
#import "NSImage+QuickLook.h"

@implementation RFCollectionView
{
    NSImage *blankArtImage;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    blankArtImage = [NSImage imageNamed:@"albumArt"];
    return self;
}

- (NSCollectionViewItem *)newItemForRepresentedObject:(id)object
{
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(RFCollectionViewDelegate)])
    {
        NSCollectionViewItem *item = [(NSObject<RFCollectionViewDelegate> *)self.delegate collectionView:self cellForObject:object];
        if ([item.view isKindOfClass:[RFCollectionViewCellView class]])
        {
            RFCollectionViewCellView *cellView = (RFCollectionViewCellView *)(item.view);

            cellView.collectionView = self;
            cellView.representedObject = object;
        }
        return item;
    }

    return nil;
}

@end

@implementation RFCollectionViewCellView

- (NSView *)hitTest:(NSPoint)aPoint
{
    // don't allow any mouse clicks for subviews in this view
	if (NSPointInRect(aPoint, [self convertRect:[self bounds] toView:[self superview]]))
    {
		return self;
	}
    else
    {
		return nil;
	}
}

- (void)mouseDown:(NSEvent *)theEvent
{
	[super mouseDown:theEvent];
	
	// check for click count above one, which we assume means it's a double click
	if ([theEvent clickCount] > 1)
    {
		if (self.collectionView.delegate && [self.collectionView.delegate conformsToProtocol:@protocol(RFCollectionViewDelegate)])
        {
            [(NSObject<RFCollectionViewDelegate> *)self.collectionView.delegate collectionView:self.collectionView doubleClickOnObject:self.representedObject];
		}
	}
}

@end
