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

@interface RFPlaylistEntity (PlaylistView)

@end

@implementation RFPlaylistEntity (PlaylistView)

- (NSString *)imageTitle
{
    return self.name;
}

- (NSString *)imageSubtitle
{
    return nil;
}

- (NSString *)imageRepresentationType
{
	return IKImageBrowserNSImageRepresentationType;
}

- (id)imageRepresentation
{
    NSImage *result = nil;
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    NSArray *items = [[self.items allObjects] sortedArrayUsingDescriptors:sortDescriptors];
    
    NSUInteger count = [items count];
    if (count > 0)
    {
        RFItemEntity *firstItem = [items objectAtIndex:0];
        NSString *url = firstItem.track.url;
        if (url && [url length] > 0)
            result = [NSImage imageFromAlbum:firstItem.track.albumTitle artist:firstItem.track.artist url:[NSURL URLWithString:url]];
    }

    return result;
}

- (NSString *)imageUID
{
    return [self.objectID.URIRepresentation absoluteString];
}

@end

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

    self.collectionView.animates = YES;
    self.collectionView.delegate = self;
    //self.collectionView.zoomValue = 0.55;
    self.collectionView.cellSize = CGSizeMake(134, 134);
    //self.collectionView.intercellSpacing = CGSizeMake(20, 20);
    self.collectionView.containerBackgroundColor = [NSColor clearColor];
    self.collectionView.imageOutlineColor = [NSColor lightGrayColor];
    self.collectionView.cellsStyleMask = IKCellsStyleShadowed | IKCellsStyleOutlined | IKCellsStyleTitled;

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
    [self.collectionView reloadData];
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

- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *)view
{
    return [self.items count];
}

- (id)imageBrowser:(IKImageBrowserView *)view itemAtIndex:(NSUInteger)index
{
    return [self.items objectAtIndex:index];
}

- (RFCollectionViewCell *)collectionView:(RFCollectionView *)collectionView cellForItem:(id)item
{
    return [[RFCoverViewCell alloc] init];
}

- (CALayer *)collectionView:(RFCollectionView *)collectionView selectionLayerToModify:(CALayer *)layer
{
    layer.shadowColor = [NSColor blackColor].CGColor;
    layer.shadowOffset = CGSizeMake(0, -1);
    layer.shadowRadius = 3.0;
    layer.shadowOpacity = 0.5;
    
    return layer;
}

/*- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView cellForObject:(id)object
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
}*/

- (void)imageBrowser:(IKImageBrowserView *)aBrowser cellWasDoubleClickedAtIndex:(NSUInteger)index
{
    RFPlaylistEntity *selectedItem = [self.items objectAtIndex:index];
    
    RFSongsView *playlistView = [RFSongsView loadFromNib];
    playlistView.title = selectedItem.name;
    [self.navigationController pushView:playlistView];
    playlistView.playlist = selectedItem;
    playlistView.viewStyle = RFSongsViewStylePlaylist;
}

@end
