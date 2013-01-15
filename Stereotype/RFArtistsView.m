//
//  RFArtistsView.m
//  Stereotype
//
//  Created by brandon on 12/23/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFArtistsView.h"
#import "RFArtistViewCell.h"
#import "RFSongsView.h"
#import "RFLibraryViewController.h"

@implementation RFArtistsView
{
    NSUInteger selectedTrackIndex;
    NSImage *blankArtImage;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.title = @"Artists";
    blankArtImage = [NSImage imageNamed:@"albumArt"];
    
    self.collectionView.cellSize = NSMakeSize(406, 64);
    self.collectionView.desiredNumberOfColumns = 1;
    
    [self loadArtists];
    [self setupNotificationListening];
}

- (void)setupNotificationListening
{
    __weak RFArtistsView *weakSelf = self;
    
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:kLibraryUpdatedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [weakSelf loadArtists];
    }];
}

- (void)loadArtists
{
    NSArray *tracks = [database allObjectsForEntity:@"RFTrackEntity" sortDescriptors:nil filteredBy:nil];
    NSArray *items = [tracks valueForKeyPath:@"@distinctUnionOfObjects.albumArtist"];
    if (self.searchString && self.searchString.length > 0)
    {
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", self.searchString];
        items = [items filteredArrayUsingPredicate:filterPredicate];
    }
    
    NSArray *filteredItems = [items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != %@ AND SELF != nil", @""]];
    self.items = [filteredItems sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (void)setSearchString:(NSString *)searchString
{
    if ([_searchString isEqualToString:searchString])
        return;
    
    _searchString = searchString;
    
    [self loadArtists];
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
    RFArtistViewCell *cell = (RFArtistViewCell *)[collectionView dequeueReusableCellWithIdentifier:@"artistViewCell"];
    if (!cell)
    {
        cell = [RFArtistViewCell loadFromNib];
        cell.cellIdentifier = @"artistViewCell";
    }
    
    cell.imageView.image = blankArtImage;
    
    NSString *artist = [self.items objectAtIndex:index];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"albumArtist == %@", artist];
    RFTrackEntity *track = [database findObjectFromEntity:@"RFTrackEntity" withPredicate:predicate];
    
    [cell.titleLabel setStringValue:@""];
    if (artist && artist.length > 0)
        [cell.titleLabel setStringValue:artist];

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
    NSString *selectedItem = [self.items objectAtIndex:index];
    
    RFSongsView *songsView = [RFSongsView loadFromNib];
    songsView.title = selectedItem;
    [self.navigationController pushView:songsView];
    songsView.artist = selectedItem;
    songsView.viewStyle = RFSongsViewStyleArtist;
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
