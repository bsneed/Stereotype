//
//  RFPlaylistView.m
//  Stereotype
//
//  Created by brandon on 12/18/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFPlaylistView.h"
#import "RFCoverViewCell.h"
#import "RFSongsView.h"
#import "RFLibraryViewController.h"
#import "JUCollectionView+Dragging.h"

@implementation RFPlaylistView
{
    NSImage *blankArtImage;
    id observer;
    NSCursor *lastCursor;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    blankArtImage = [NSImage imageNamed:@"albumArt"];
    self.title = @"Playlists";

    self.collectionView.cellSize = NSMakeSize(203, 212);
    self.collectionView.desiredNumberOfColumns = 2;
    
    [self loadPlaylists];
    [self setupNotificationListening];
    
    NSString *uti = [[NSBundle mainBundle].bundleIdentifier stringByAppendingFormat:@".pasteboardItem"];
    [self.collectionView registerForDraggedTypes:@[uti]];
}

- (void)loadPlaylists
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    NSPredicate *filterPredicate = nil;
    if (self.searchString && self.searchString.length > 0)
    {
        filterPredicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", self.searchString];
    }
    self.items = [database allObjectsForEntity:@"RFPlaylistEntity" sortDescriptors:sortDescriptors filteredBy:filterPredicate];
}

- (void)setupNotificationListening
{
    __weak RFPlaylistView *weakSelf = self;
    
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:kLibraryUpdatedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [weakSelf loadPlaylists];
    }];
}

- (void)setSearchString:(NSString *)searchString
{
    if ([_searchString isEqualToString:searchString])
        return;
    
    _searchString = searchString;
    
    [self loadPlaylists];
}

#pragma mark - CollectionView delegate/datasource

/**
 * This method is invoked to ask the data source for the number of cells inside the collection view.
 **/
- (NSUInteger)numberOfCellsInCollectionView:(JUCollectionView *)collectionView { return self.items.count; }

/**
 * This method is involed to ask the data source for a cell to display at the given index. You should first try to dequeue an old cell before creating a new one!
 **/
- (JUCollectionViewCell *)collectionView:(JUCollectionView *)collectionView cellForIndex:(NSUInteger)index
{
    RFCoverViewCell *cell = (RFCoverViewCell *)[collectionView dequeueReusableCellWithIdentifier:@"coverViewCell"];
    if (!cell)
    {
        cell = [RFCoverViewCell loadFromNib];
        cell.cellIdentifier = @"coverViewCell";
    }
    
    cell.imageView.image = blankArtImage;
    
    RFPlaylistEntity *playlist = [self.items objectAtIndex:index];
    NSString *name = playlist.name;
    
    [cell.textLabel setStringValue:@""];
    [cell.detailTextLabel setStringValue:@""];
    [cell.playlistLabel setStringValue:name];
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    NSArray *items = [[playlist.items allObjects] sortedArrayUsingDescriptors:sortDescriptors];
    
    NSUInteger count = [items count];
    if (count > 0)
    {
        RFItemEntity *firstItem = [items objectAtIndex:0];
        NSString *url = firstItem.track.url;
        if (url && [url length] > 0)
            cell.imageView.image = [NSImage imageFromAlbum:firstItem.track.albumTitle artist:firstItem.track.artist url:[NSURL URLWithString:url]];
    }

    return cell;
}

/**
 * Invoked when the user double clicked on the given cell.
 **/
- (void)collectionView:(JUCollectionView *)collectionView didDoubleClickedCellAtIndex:(NSUInteger)index
{
    RFPlaylistEntity *selectedItem = [self.items objectAtIndex:index];
    
    RFSongsView *playlistView = [RFSongsView loadFromNib];
    playlistView.title = selectedItem.name;
    [self.navigationController pushView:playlistView];
    playlistView.playlist = selectedItem;
    playlistView.viewStyle = RFSongsViewStylePlaylist;
}


- (NSDragOperation)collectionView:(JUCollectionView *)collectionView draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context;
{
    /*if (context == NSDraggingContextOutsideApplication)
    {
        //NSLog(@"drag outside the application occurred.");
        return NSDragOperationDelete;
    }
    else
    if (context == NSDraggingContextWithinApplication)
    {
        //NSLog(@"drag inside the application occurred.");
        return NSDragOperationCopy;
    }
    else
        NSLog(@"some unknown drag context was sent.");*/
    return NSDragOperationCopy;
}

- (void)collectionView:(JUCollectionView *)collectionView draggingSession:(NSDraggingSession *)session movedToPoint:(NSPoint)screenPoint
{
    if (!NSPointInRect(screenPoint, self.window.frame))
    {
        if (!lastCursor)
            lastCursor = [NSCursor currentCursor];
        [collectionView showPoofCursor];
        session.animatesToStartingPositionsOnCancelOrFail = NO;
    }
    else
    {
        [lastCursor set];
        lastCursor = nil;
        //[collectionView showNormalCursor];
        session.animatesToStartingPositionsOnCancelOrFail = YES;
    }
}

- (void)collectionView:(JUCollectionView *)collectionView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation;
{
    /*if (operation == NSDragOperationDelete)
        NSLog(@"item deleted");
    else
    if (operation == NSDragOperationNone && !NSPointInRect(screenPoint, self.window.frame))
    {
        NSLog(@"item none'd.  lol.");
        [collectionView showPoofAnimation];
        [collectionView showNormalCursor];
    }
    else
    if (operation == NSDragOperationCopy)
        NSLog(@"item rearranged or copied");*/
    
    [collectionView showNormalCursor];
    lastCursor = nil;
}

/*- (NSDragOperation)collectionView:(JUCollectionView *)collectionView draggingEntered:(id < NSDraggingInfo >)sender
{
    NSLog(@"someone is dragging over us %@", sender);
    if ([sender draggingSourceOperationMask] == NSDragOperationNone)
    {
        NSLog(@"if drop happens, items will be deleted.");
    }
    else
    if ([sender draggingSourceOperationMask] == NSDragOperationCopy)
        NSLog(@"if drop happens, items will be rearranged or added.");
    
    return NSDragOperationCopy;
}

- (void)collectionView:(JUCollectionView *)collectionView draggingEnded:(id < NSDraggingInfo >)sender
{
    NSLog(@"someone dropped on us, %@", sender);
    if ([sender draggingSourceOperationMask] == NSDragOperationNone)
    {
        NSLog(@"will delete items.");
    }
    else
    if ([sender draggingSourceOperationMask] == NSDragOperationCopy)
        NSLog(@"rearranged or add items.");
}

- (void)collectionView:(JUCollectionView *)collectionView draggingExited:(id < NSDraggingInfo >)sender
{
    NSLog(@"someone stopped dragging over us");

    if ([sender draggingSourceOperationMask] == NSDragOperationNone)
    {
        NSLog(@"if drop happens, items will be deleted.");
    }
    else
    if ([sender draggingSourceOperationMask] == NSDragOperationCopy)
        NSLog(@"if drop happens, items will be rearranged or added.");
}


- (BOOL)collectionView:(JUCollectionView *)collectionView prepareForDragOperation:(id < NSDraggingInfo >)sender
{
    //NSLog(@"prepare");
    return YES;
}

- (BOOL)collectionView:(JUCollectionView *)collectionView performDragOperation:(id < NSDraggingInfo >)sender
{
    //NSLog(@"perform");
    return YES;
}
*/

@end
