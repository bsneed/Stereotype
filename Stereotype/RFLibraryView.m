//
//  RFLibraryView.m
//  Stereotype
//
//  Created by brandon on 12/18/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFLibraryView.h"
#import "RFLibraryViewController.h"
#import "RFAppDelegate.h"

@implementation RFLibraryView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        database = [VPPCoreData sharedInstance];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        database = [VPPCoreData sharedInstance];
    }
    return self;
}

- (void)awakeFromNib
{
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.allowsSelection = YES;
    self.collectionView.allowsMultipleSelection = YES;
    self.collectionView.allowsDragging = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer];

    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
    self.collectionView = nil;
}

- (void)setSearchString:(NSString *)searchString
{
    _searchString = searchString;
}

- (void)setItems:(NSArray *)items
{
    _items = items;
    [self.collectionView reloadData];
}

#pragma mark - CollectionView delegate/datasource

/**
 * This method is invoked to ask the data source for the number of cells inside the collection view.
 **/
- (NSUInteger)numberOfCellsInCollectionView:(JUCollectionView *)collectionView
{
    return self.items.count;
}

/**
 * This method is involed to ask the data source for a cell to display at the given index. You should first try to dequeue an old cell before creating a new one!
 **/
- (JUCollectionViewCell *)collectionView:(JUCollectionView *)collectionView cellForIndex:(NSUInteger)index { return nil; }

/**
 * Invoked when the cell at the given index was selected.
 **/
- (void)collectionView:(JUCollectionView *)collectionView didSelectCellAtIndex:(NSUInteger)index {}
/**
 * Invoked when the user double clicked on the given cell.
 **/
- (void)collectionView:(JUCollectionView *)collectionView didDoubleClickedCellAtIndex:(NSUInteger)index {}
/**
 * Invoked when the cell at the given index was deselected.
 **/
- (void)collectionView:(JUCollectionView *)collectionView didDeselectCellAtIndex:(NSUInteger)index {}
/**
 * Invoked when there was an unhandled key event. The method will be invoked for every selected cell.
 * @remark Currently handled are the cursor keys.
 **/
- (void)collectionView:(JUCollectionView *)collectionView keyEvent:(NSEvent *)event forCellAtIndex:(NSUInteger)index {}


@end
