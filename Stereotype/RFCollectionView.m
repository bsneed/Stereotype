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
        RFCollectionViewItem *item = [(NSObject<RFCollectionViewDelegate> *)self.delegate collectionView:self cellForObject:object];
        //RFCollectionViewCellView *cellView = [[RFCollectionViewCellView alloc] initWithFrame:NSMakeRect(0, 0, 203, 212)];

        item.view.collectionView = self;
        item.view.collectionItem = item;
        item.view.representedObject = object;
        
        //item.view = cellView;
        return item;
    }

    return nil;
}

/*- (void)setSelectionIndexes:(NSIndexSet *)indexes
{
    [super setSelectionIndexes:indexes];
    
    [self.content enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        RFCollectionViewItem *item = (RFCollectionViewItem *)[self itemAtIndex:idx];
        [(RFCollectionViewCellView *)item.view setSelected:NO];
    }];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        RFCollectionViewItem *item = (RFCollectionViewItem *)[self itemAtIndex:idx];
        [(RFCollectionViewCellView *)item.view setSelected:YES];
    }];
}*/

@end

@implementation RFCollectionViewItem

- (id)initWithSize:(NSSize)size
{
    self = [super init];
    
    _size = size;
    [self view];

    return self;
}

- (void)loadView
{
    [self setView:[[RFCollectionViewCellView alloc] initWithFrame:NSMakeRect(0, 0, _size.width, _size.height)]];
}

- (void)setView:(RFCollectionViewCellView *)view
{
    [super setView:view];
}

- (RFCollectionViewCellView *)view
{
    return (RFCollectionViewCellView *)[super view];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [(RFCollectionViewCellView *)self.view setSelected:selected];
    [self.view setNeedsDisplay:YES];
}

@end

@implementation RFCollectionViewCellView

- (void)setSelected:(BOOL)selected
{
    if (selected != _selected)
    {
        _selected = selected;
        [self setNeedsDisplay:YES];
    }
}
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

- (void)drawRect:(NSRect)dirtyRect
{
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:collectionItem:drawRectForObject:dirtyRect:)])
    {
        [(NSObject<RFCollectionViewDelegate> *)self.collectionView.delegate collectionView:self.collectionView collectionItem:self.collectionItem drawRectForObject:self.representedObject dirtyRect:dirtyRect];
    }
    else
        [super drawRect:dirtyRect];
}

@end
