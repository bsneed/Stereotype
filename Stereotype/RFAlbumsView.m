//
//  RFArtistsView.m
//  Stereotype
//
//  Created by brandon on 12/23/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFAlbumsView.h"
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
    self.collectionView.allowsMultipleSelection = YES;
    blankArtImage = [NSImage imageNamed:@"albumArt"];

    [self loadAlbums];
    [self setupNotificationListening];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
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
    [self.collectionView reloadData];
}

- (void)setSearchString:(NSString *)searchString
{
    if ([_searchString isEqualToString:searchString])
        return;
    
    _searchString = searchString;
    
    [self loadAlbums];
}

#pragma mark - CollectionView delegate/datasource

- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *)aBrowser
{
    return self.items.count;
}

- (id)imageBrowser:(IKImageBrowserView *)aBrowser itemAtIndex:(NSUInteger)index
{
    return [self.items objectAtIndex:index];
}

- (void)imageBrowser:(IKImageBrowserView *)aBrowser cellWasDoubleClickedAtIndex:(NSUInteger)index;
{
    RFTrackEntity *selectedItem = (RFTrackEntity *)[self.items objectAtIndex:index];
    
    RFSongsView *songsView = [RFSongsView loadFromNib];
    songsView.title = selectedItem.albumTitle;
    [self.navigationController pushView:songsView];
    songsView.album = selectedItem.albumTitle;
    songsView.viewStyle = RFSongsViewStyleAlbum;
}

@end
