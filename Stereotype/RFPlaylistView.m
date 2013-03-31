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

    self.collectionView.itemPrototype = [RFCoverViewCell loadFromNib];
    self.collectionView.delegate = self;
    
    [self loadPlaylists];
    [self setupNotificationListening];
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
    self.collectionView.content = self.items;
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

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView cellForObject:(id)object
{
    RFCoverViewCell *cell = [RFCoverViewCell loadFromNib];
    
    cell.imageView.image = blankArtImage;
    
    RFPlaylistEntity *playlist = object;
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

- (void)collectionView:(RFCollectionView *)collectionView doubleClickOnObject:(id)object;
{
    RFPlaylistEntity *selectedItem = (RFPlaylistEntity *)object;
    
    RFSongsView *playlistView = [RFSongsView loadFromNib];
    playlistView.title = selectedItem.name;
    [self.navigationController pushView:playlistView];
    playlistView.playlist = selectedItem;
    playlistView.viewStyle = RFSongsViewStylePlaylist;
}

@end
