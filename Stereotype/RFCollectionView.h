//
//  RFCollectionView.h
//  Stereotype
//
//  Created by Brandon Sneed on 3/27/13.
//  Copyright (c) 2013 redf.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RFCollectionView;
@class RFCollectionViewItem;
@class RFCollectionViewCellView;


@protocol RFCollectionViewDelegate<NSObject>
@optional
- (RFCollectionViewItem *)collectionView:(RFCollectionView *)collectionView cellForObject:(id)object;
- (void)collectionView:(RFCollectionView *)collectionView doubleClickOnObject:(id)object;
- (void)collectionView:(RFCollectionView *)collectionView collectionItem:(RFCollectionViewItem *)item drawRectForObject:(id)object dirtyRect:(NSRect)dirtyRect;
@end


@interface RFCollectionViewItem : NSCollectionViewItem
{
    NSSize _size;
}

@property (nonatomic, strong) RFCollectionViewCellView *view;

- (id)initWithSize:(NSSize)size;

@end


@interface RFCollectionViewCellView : NSView
@property (weak) RFCollectionView *collectionView;
@property (weak) RFCollectionViewItem *collectionItem;
@property (weak) id representedObject;
@property (nonatomic, assign) BOOL selected;
@end

@interface RFCollectionView : NSCollectionView

@end
