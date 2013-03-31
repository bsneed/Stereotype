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
#import "RFTableRowView.h"

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
    
    [self.tableView setDoubleAction:@selector(tableDoubleClick:)];
    
    [self setupNotificationListening];
}

- (void)setItems:(NSArray *)items
{
    [super setItems:items];
    [self.tableView reloadData];
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

- (void)tableDoubleClick:(id)sender
{
    NSInteger index = self.tableView.clickedRow;
    NSString *selectedItem = [self.items objectAtIndex:index];
    
    RFSongsView *songsView = [RFSongsView loadFromNib];
    songsView.title = selectedItem;
    [self.navigationController pushView:songsView];
    songsView.artist = selectedItem;
    songsView.viewStyle = RFSongsViewStyleArtist;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return self.items.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    RFArtistViewCell *cell = (RFArtistViewCell *)[tableView makeViewWithIdentifier:@"artistViewCell" owner:self];
    if (!cell)
        cell = [[RFArtistViewCell alloc] initWithFrame:NSZeroRect];
    
    cell.imageView.image = blankArtImage;
    
    NSString *artist = [self.items objectAtIndex:row];
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

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    RFTableRowView *rowView = [tableView makeViewWithIdentifier:@"rowView" owner:self];
    if (!rowView)
        rowView = [[RFTableRowView alloc] initWithFrame:NSMakeRect(0, 0, 403, 64)];
    
    return rowView;
}

@end
