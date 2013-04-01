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
    
    _imageQueue = [[NSOperationQueue alloc] init];
    _imageQueue.maxConcurrentOperationCount = 4;
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

/*
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
*/

@end
