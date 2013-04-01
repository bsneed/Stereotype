//
//  RFPlaylistEditor.m
//  Stereotype
//
//  Created by brandon on 1/6/13.
//  Copyright (c) 2013 redf.net. All rights reserved.
//

#import "RFPlaylistEditor.h"
#import "RFSongViewCell.h"
#import "NSImage+QuickLook.h"

@implementation RFPlaylistEditor
{
    NSMutableArray *items;
    NSImage *blankArtImage;
}

- (void)awakeFromNib
{
    blankArtImage = [NSImage imageNamed:@"albumArt"];
    items = [[NSMutableArray alloc] init];
    
    /*self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.allowsSelection = YES;
    self.collectionView.allowsMultipleSelection = YES;
    self.collectionView.allowsDragging = YES;
    
    self.collectionView.cellSize = NSMakeSize(406, 33);
    self.collectionView.desiredNumberOfColumns = 1;
    
    [self.collectionView registerForDraggedTypes:@[NSFilenamesPboardType]];
    
    [self.collectionView reloadData];*/
}

/*- (NSUInteger)numberOfCellsInCollectionView:(JUCollectionView *)collectionView
{
    return 10;//items.count;
}

- (JUCollectionViewCell *)collectionView:(JUCollectionView *)collectionView cellForIndex:(NSUInteger)index
{
    RFSongViewCell *cell = (RFSongViewCell *)[collectionView dequeueReusableCellWithIdentifier:@"playlistEditorCell"];
    if (!cell)
        cell = [RFSongViewCell loadFromNibNamed:@"RFSongViewCellSmall"];
    
    cell.imageView.image = blankArtImage;
    
    //RFTrackEntity *track = [items objectAtIndex:index];
    //NSString *name = playlist.name;
    
    //[cell.textLabel setStringValue:@""];
    //[cell.detailTextLabel setStringValue:@""];
    //[cell.playlistLabel setStringValue:name];
    
    return cell;
}*/

/*- (void)collectionView:(JUCollectionView *)collectionView didDoubleClickedCellAtIndex:(NSUInteger)index
{
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
        return NSDragOperationCopy;
    }
    else
        NSLog(@"some unknown drag context was sent.");
    return NSDragOperationNone;
}

NSCursor *lastCursor = nil;

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
    if (operation == NSDragOperationDelete)
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
        NSLog(@"item rearranged or copied");
    
    [collectionView showNormalCursor];
    lastCursor = nil;
}

- (NSDragOperation)collectionView:(JUCollectionView *)collectionView draggingEntered:(id < NSDraggingInfo >)sender
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
    {
        NSLog(@"rearranged or add items.");
    }
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
    NSLog(@"prepare");
    return YES;
}

- (BOOL)collectionView:(JUCollectionView *)collectionView performDragOperation:(id < NSDraggingInfo >)sender
{
    NSLog(@"perform");
    
    //get the file URLs from the pasteboard
    NSPasteboard* pb = sender.draggingPasteboard;
    
    //list the file type UTIs we want to accept
    NSArray* acceptedTypes = [NSArray arrayWithObject:(NSString*)kUTTypeAudio];
    NSArray* urls = [pb readObjectsForClasses:[NSArray arrayWithObject:[NSURL class]]
                                      options:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithBool:YES],NSPasteboardURLReadingFileURLsOnlyKey,
                                               acceptedTypes, NSPasteboardURLReadingContentsConformToTypesKey,
                                               nil]];
    
    // do something with the url's.
    NSLog(@"we got %@", urls);

    return YES;
}*/

@end
