//
//  RFSongsView.m
//  Stereotype
//
//  Created by brandon on 12/18/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFSongsView.h"
#import "RFSongViewCell.h"
#import "RFSettingsModel.h"
#import "RFURLDownloader.h"
#import "RFLibraryViewController.h"

@implementation RFSongsView
{
    NSUInteger selectedTrackIndex;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.title = @"Playlists";
    self.collectionView.cellSize = NSMakeSize(406, 64);
    
    [self setupNotificationListening];
}

- (void)setPlaylist:(RFPlaylistEntity *)playlist
{
    if (playlist == _playlist)
        return;
    
    _playlist = playlist;
    
    [self loadPlaylist];
}

- (void)setArtist:(NSString *)artist
{
    if ([artist isEqualToString:_artist])
        return;
    
    _artist = artist;
    
    [self loadArtist];
}

- (void)setAlbum:(NSString *)album
{
    if ([album isEqualToString:_album])
        return;
    
    _album = album;
    
    [self loadAlbum];
}

- (void)setupNotificationListening
{
    __weak RFSongsView *weakSelf = self;
    
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:kLibraryUpdatedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if (weakSelf.playlist)
            [weakSelf loadPlaylist];
        else
            [weakSelf loadAllSongs];
    }];
}

- (void)loadPlaylist
{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    NSArray *items = [[self.playlist.items allObjects] sortedArrayUsingDescriptors:sortDescriptors];
    if (self.searchString && self.searchString.length > 0)
    {
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"track.title contains[cd] %@ || track.artist contains[cd] %@ || track.albumTitle contains[cd] %@ || track.composer contains[cd] %@ || track.genre contains[cd] %@",
                                            self.searchString, self.searchString, self.searchString, self.searchString, self.searchString];
        items = [items filteredArrayUsingPredicate:filterPredicate];
    }
    
    self.items = items;
}

- (void)loadAllSongs
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"artist" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"albumTitle" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"trackNumber" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor1, sortDescriptor2, sortDescriptor3];
    
    NSPredicate *filterPredicate = nil;
    if (self.searchString && self.searchString.length > 0)
    {
        filterPredicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@ || albumArtist contains[cd] %@ || albumTitle contains[cd] %@ || composer contains[cd] %@ || genre contains[cd] %@ || releaseDate contains %@",
                                        self.searchString, self.searchString, self.searchString, self.searchString, self.searchString, self.searchString];
    }

    self.items = [database allObjectsForEntity:@"RFTrackEntity" sortDescriptors:sortDescriptors filteredBy:filterPredicate];
}

- (void)loadArtist
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"albumTitle" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"trackNumber" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor1, sortDescriptor2];
    
    NSPredicate *filterPredicate = nil;
    if (self.searchString && self.searchString.length > 0)
    {
        filterPredicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@ || artist contains[cd] %@ || albumTitle contains[cd] %@ || composer contains[cd] %@ || genre contains[cd] %@",
                           self.searchString, self.searchString, self.searchString, self.searchString, self.searchString];
    }
    
    NSPredicate *artistPredicate = [NSPredicate predicateWithFormat:@"albumArtist == %@", self.artist];
    NSArray *tracks = [database allObjectsForEntity:@"RFTrackEntity" sortDescriptors:sortDescriptors filteredBy:artistPredicate];
    if (filterPredicate)
        tracks = [tracks filteredArrayUsingPredicate:filterPredicate];
    self.items = tracks;
}

- (void)loadAlbum
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"trackNumber" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor1];
    
    NSPredicate *filterPredicate = nil;
    if (self.searchString && self.searchString.length > 0)
    {
        filterPredicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@ || artist contains[cd] %@ || albumTitle contains[cd] %@ || composer contains[cd] %@ || genre contains[cd] %@",
                           self.searchString, self.searchString, self.searchString, self.searchString, self.searchString];
    }
    
    NSPredicate *albumPredicate = [NSPredicate predicateWithFormat:@"albumTitle == %@", self.album];
    NSArray *tracks = [database allObjectsForEntity:@"RFTrackEntity" sortDescriptors:sortDescriptors filteredBy:albumPredicate];
    if (filterPredicate)
        tracks = [tracks filteredArrayUsingPredicate:filterPredicate];
    self.items = tracks;
}

- (void)setSearchString:(NSString *)searchString
{
    if ([_searchString isEqualToString:searchString])
        return;
    
    _searchString = searchString;
    
    if (self.playlist)
        [self loadPlaylist];
    else
    if (self.album)
        [self loadAlbum];
    else
    if (self.artist)
        [self loadArtist];
    else
        [self loadAllSongs];
}

- (NSArray *)arrayOfItemURLs
{
    NSManagedObject *item = [self.items objectAtIndex:0];
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:self.items.count];
    
    if ([item isKindOfClass:[RFTrackEntity class]])
    {
        for (int i = 0; i < self.items.count; i++)
        {
            RFTrackEntity *item = [self.items objectAtIndex:i];
            [result addObject:item.url];
        }
    }
    else
    if ([item isKindOfClass:[RFItemEntity class]])
    {
        for (int i = 0; i < self.items.count; i++)
        {
            RFItemEntity *item = [self.items objectAtIndex:i];
            [result addObject:item.track.url];
        }
    }
    
    return [NSArray arrayWithArray:result];
}

#pragma mark - CollectionView delegate/datasource

/**
 * This method is involed to ask the data source for a cell to display at the given index. You should first try to dequeue an old cell before creating a new one!
 **/
- (JUCollectionViewCell *)collectionView:(JUCollectionView *)collectionView cellForIndex:(NSUInteger)index
{
    RFSongViewCell *cell = (RFSongViewCell *)[collectionView dequeueReusableCellWithIdentifier:@"songViewCell"];
    if (!cell)
    {
        cell = [RFSongViewCell loadFromNib];
        cell.cellIdentifier = @"songViewCell";
    }
    
    id anItem = [self.items objectAtIndex:index];
    if ([anItem isKindOfClass:[RFItemEntity class]])
    {
        [cell configureCellWithItemEntity:anItem];
    }
    else
    if (self.artist || self.album)
    {
        [cell configureCellWithTrackEntity:anItem displayIndex:index];
    }
    else
    {
        [cell hideIndexLabel];
        [cell configureCellWithTrackEntity:anItem];
    }
    
    return cell;
}

/**
 * Invoked when the user double clicked on the given cell.
 **/
- (void)collectionView:(JUCollectionView *)collectionView didDoubleClickedCellAtIndex:(NSUInteger)index
{
    selectedTrackIndex = [collectionView.selection firstIndex];
    id item = [self.items objectAtIndex:selectedTrackIndex];
    
    RFTrackEntity *track = nil;
    if ([item isKindOfClass:[RFTrackEntity class]])
        track = item;
    else
    if ([item isKindOfClass:[RFItemEntity class]])
    {
        RFItemEntity *theItem = item;
        track = theItem.track;
    }
    
    NSURL *url = [NSURL URLWithString:track.url];
    if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"])
    {
        [[RFURLDownloader sharedInstance] addDownload:url.absoluteString];
        RFSongViewCell *cell = (RFSongViewCell *)[self.collectionView cellAtIndex:index];
        [cell.detail2Label setStringValue:@"Downloading..."];
        return;
    }
    
    [RFSettingsModel sharedInstance].urlQueue = [self arrayOfItemURLs];
    [RFSettingsModel sharedInstance].urlQueueIndex = selectedTrackIndex;
    
    [RFSettingsModel save];
}


- (NSDragOperation)collectionView:(JUCollectionView *)collectionView draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context;
{
    if (context == NSDraggingContextOutsideApplication)
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
        NSLog(@"some unknown drag context was sent.");
    return NSDragOperationNone;
}


@end
