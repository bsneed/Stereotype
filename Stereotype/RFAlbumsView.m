//
//  RFArtistsView.m
//  Stereotype
//
//  Created by brandon on 12/23/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFAlbumsView.h"
#import "RFCoverViewCell.h"
#import "RFSongsView.h"
#import "RFLibraryViewController.h"

@implementation RFAlbumsView
{
    NSUInteger selectedTrackIndex;
    NSImage *blankArtImage;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.title = @"Albums";
    blankArtImage = [NSImage imageNamed:@"albumArt"];
    
    self.collectionView.cellSize = NSMakeSize(203, 212);
    self.collectionView.desiredNumberOfColumns = 2;
    
    [self loadAlbums];
    [self setupNotificationListening];
}

- (void)setupNotificationListening
{
    __weak RFAlbumsView *weakSelf = self;
    
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:kLibraryUpdatedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [weakSelf loadAlbums];
    }];
}

- (void)loadAlbums
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"compilation" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"albumArtist" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"albumTitle" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[sortDescriptor1, sortDescriptor2, sortDescriptor3];
    
    __block NSString *albumTitle = nil;
    __block NSString *albumArtist = nil;
    NSMutableArray *albumTracks = [[NSMutableArray alloc] init];
    NSArray *tracks = [database allObjectsForEntity:@"RFTrackEntity" sortDescriptors:sortDescriptors filteredBy:nil];
    
    [tracks enumerateObjectsUsingBlock:^(RFTrackEntity *obj, NSUInteger idx, BOOL *stop) {
        if (![obj.albumTitle isEqualToString:albumTitle] || ![obj.albumArtist isEqualToString:albumArtist])
            if ((obj.albumTitle != nil && obj.albumTitle.length > 0))
                [albumTracks addObject:obj];
        albumTitle = obj.albumTitle;
        albumArtist = obj.albumArtist;
    }];
    
    NSArray *items = albumTracks;
    if (self.searchString && self.searchString.length > 0)
    {
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"albumTitle contains[cd] %@ OR albumArtist contains[cd] %@", self.searchString, self.searchString];
        items = [items filteredArrayUsingPredicate:filterPredicate];
    }
    
    NSArray *filteredItems = [items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"albumArtist != nil"]];
    
    self.items = filteredItems;
}

- (void)setSearchString:(NSString *)searchString
{
    if ([_searchString isEqualToString:searchString])
        return;
    
    _searchString = searchString;
    
    [self loadAlbums];
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
    RFCoverViewCell *cell = (RFCoverViewCell *)[collectionView dequeueReusableCellWithIdentifier:@"artistViewCell"];
    if (!cell)
    {
        cell = [RFCoverViewCell loadFromNib];
        cell.cellIdentifier = @"artistViewCell";
    }
    
    cell.imageView.image = blankArtImage;
    
    RFTrackEntity *track = [self.items objectAtIndex:index];
    
    [cell.textLabel setStringValue:@"Unknown Album"];
    [cell.detailTextLabel setStringValue:@"Unknown Artist"];
    [cell.playlistLabel setStringValue:@""];
    
    if (track.albumTitle && track.albumTitle.length > 0)
        [cell.textLabel setStringValue:track.albumTitle];
    
    if (track.compilation.boolValue)
        [cell.detailTextLabel setStringValue:@"Various Artists"];
    else
    if (track.albumArtist && track.albumArtist.length > 0)
        [cell.detailTextLabel setStringValue:track.albumArtist];
    else
    if (track.artist && track.artist.length > 0)
        [cell.detailTextLabel setStringValue:track.artist];
    
    
    NSString *url = track.url;
    if (url && [url length] > 0)
        cell.imageView.image = [NSImage imageFromAlbum:track.albumTitle artist:track.artist url:[NSURL URLWithString:url]];
    
    return cell;
}

/**
 * Invoked when the user double clicked on the given cell.
 **/
- (void)collectionView:(JUCollectionView *)collectionView didDoubleClickedCellAtIndex:(NSUInteger)index
{
    RFTrackEntity *selectedItem = [self.items objectAtIndex:index];
    
    RFSongsView *songsView = [RFSongsView loadFromNib];
    songsView.title = selectedItem.albumTitle;
    [self.navigationController pushView:songsView];
    songsView.album = selectedItem.albumTitle;
    songsView.viewStyle = RFSongsViewStyleAlbum;
}

- (NSArray *)selectedPaths
{
    // Write data to the pasteboard
    NSMutableArray *fileList = [[NSMutableArray alloc] init];
    
    NSArray *items = [self.items objectsAtIndexes:self.collectionView.selection];
    for (NSUInteger i = 0; i < items.count; i++)
    {
        RFTrackEntity *track = [items objectAtIndex:i];
        NSString *filePath = [[NSURL URLWithString:track.url] path];
        [fileList addObject:filePath];
    }
    
    return fileList;
}


@end
