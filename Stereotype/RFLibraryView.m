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
    /*self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.allowsSelection = YES;
    self.collectionView.allowsMultipleSelection = YES;
    self.collectionView.allowsDragging = YES;
    
    [self.collectionView registerForDraggedTypes:@[NSFilenamesPboardType]];*/
}

- (void)dealloc
{
    /*[[NSNotificationCenter defaultCenter] removeObserver:observer];

    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
    self.collectionView = nil;*/
}

- (void)setSearchString:(NSString *)searchString
{
    _searchString = searchString;
}

- (void)setItems:(NSArray *)items
{
    _items = items;
    //[self.collectionView reloadData];
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

#pragma mark drag and drop stuff

- (NSArray *)selectedPaths
{
    return nil;
}

- (BOOL)copyItemsToPasteboard
{
    // Write data to the pasteboard
    NSArray *fileList = [self selectedPaths];
    if (fileList && fileList.count > 0)
    {
        NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
        [pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:nil];
        [pboard setPropertyList:fileList forType:NSFilenamesPboardType];
        return TRUE;
    }
    
    return FALSE;
}

- (NSDragOperation)collectionView:(JUCollectionView *)collectionView draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context;
{
    if (context == NSDraggingContextOutsideApplication)
    {
        NSLog(@"drag outside the application occurred.");
        return NSDragOperationDelete;
    }
    else
    if (context == NSDraggingContextWithinApplication)
    {
        NSLog(@"drag inside the application occurred.");
        if ([self copyItemsToPasteboard])
            return NSDragOperationCopy;
        return NSDragOperationNone;
    }
    else
        NSLog(@"some unknown drag context was sent.");
    return NSDragOperationCopy;
}


@end
