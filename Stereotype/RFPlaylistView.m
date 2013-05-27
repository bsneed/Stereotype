//
//  RFPlaylistView.m
//  Stereotype
//
//  Created by brandon on 12/18/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFPlaylistView.h"
#import "RFSongsView.h"
#import "RFLibraryViewController.h"
#import "NSImage+QuickLook.h"

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
    self.collectionView.allowsMultipleSelection = YES;

    [self loadPlaylists];
    [self setupNotificationListening];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
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
    RFPlaylistEntity *selectedItem = (RFPlaylistEntity *)[self.items objectAtIndex:index];
    
    RFSongsView *playlistView = [RFSongsView loadFromNib];
    playlistView.title = selectedItem.name;
    [self.navigationController pushView:playlistView];
    playlistView.playlist = selectedItem;
    playlistView.viewStyle = RFSongsViewStylePlaylist;
}

@end
