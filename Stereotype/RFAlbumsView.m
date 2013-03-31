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

    self.collectionView.itemPrototype = [RFCoverViewCell loadFromNib];
    self.collectionView.delegate = self;

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
    self.collectionView.content = self.items;
}

- (void)setSearchString:(NSString *)searchString
{
    if ([_searchString isEqualToString:searchString])
        return;
    
    _searchString = searchString;
    
    [self loadAlbums];
}

#pragma mark - CollectionView delegate/datasource

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView cellForObject:(id)object
{
    RFCoverViewCell *cell = [RFCoverViewCell loadFromNib];
    
    cell.imageView.image = blankArtImage;
    
    RFTrackEntity *track = (RFTrackEntity *)object;
    
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

- (void)collectionView:(RFCollectionView *)collectionView doubleClickOnObject:(id)object
{
    RFTrackEntity *selectedItem = (RFTrackEntity *)object;
    
    RFSongsView *songsView = [RFSongsView loadFromNib];
    songsView.title = selectedItem.albumTitle;
    [self.navigationController pushView:songsView];
    songsView.album = selectedItem.albumTitle;
    songsView.viewStyle = RFSongsViewStyleAlbum;    
}

@end
