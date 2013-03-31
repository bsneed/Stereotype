//
//  RFSongViewself.m
//  Stereotype
//
//  Created by brandon on 12/18/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFSongViewCell.h"
#import "NSImage+QuickLook.h"

@interface RFSongViewCell ()

@end

@implementation RFSongViewCell
{
    NSImage *blankArtImage;
}

- (void)dealloc
{
    if (_trackObject)
        [_trackObject removeObserver:self forKeyPath:@"url"];
}

- (void)hideIndexLabel
{
    [self.indexLabel setHidden:YES];
    self.contentView.frame = self.bounds;
}

- (void)setTrackObject:(RFTrackEntity *)trackObject
{
    if (_trackObject == trackObject)
        return;
    
    if (_trackObject)
        [_trackObject removeObserver:self forKeyPath:@"url"];
    
    _trackObject = trackObject;
    [_trackObject addObserver:self forKeyPath:@"url" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setTime:(double)seconds textField:(NSTextField *)textField
{
    if (seconds == 0)
    {
        [textField setStringValue:@""];
        return;
    }
    
    int sec = 0, min = 0, hr = 0;
	
	sec = seconds + 0.5;
	min = sec/ 60;
	sec -= min * 60;
	hr = min / 60;
	min -= hr * 60;
    
    if (hr > 0)
        [textField setStringValue:[NSString stringWithFormat:@"%02d:%02d:%02d", hr, min, sec]];
    else
        [textField setStringValue:[NSString stringWithFormat:@"%02d:%02d", min, sec]];
}

- (void)configureCellWithItemEntity:(RFItemEntity *)item
{
    self.trackObject = item.track;
    
    self.imageView.image = blankArtImage;
    
    NSUInteger index = [item.index integerValue] + 1;
    [self.indexLabel setStringValue:[NSString stringWithFormat:@"%lu", index]];

    [self configureCellWithTrackEntity:item.track];
}

- (void)configureCellWithTrackEntity:(RFTrackEntity *)track displayIndex:(NSUInteger)displayIndex
{
    self.trackObject = track;
    
    self.imageView.image = blankArtImage;
    
    NSUInteger index = [track.trackNumber integerValue];
    [self.indexLabel setStringValue:[NSString stringWithFormat:@"%lu", index]];
    
    [self configureCellWithTrackEntity:track];
}

- (void)configureCellWithTrackEntity:(RFTrackEntity *)track
{
    self.trackObject = track;
    
    self.imageView.image = blankArtImage;
    
    NSString *artist = track.artist;
    NSString *albumTitle = track.albumTitle;
    
    if (artist && artist.length == 0)
        artist = nil;
    if (albumTitle && albumTitle.length == 0)
        albumTitle = nil;
    
    [self.titleLabel setStringValue:track.title];
    if (artist && albumTitle)
        [self.detailLabel setStringValue:[NSString stringWithFormat:@"%@ / %@", artist, albumTitle]];
    else
    if (artist && !albumTitle)
        [self.detailLabel setStringValue:[NSString stringWithFormat:@"%@", artist]];
    else
    if (!artist && albumTitle)
        [self.detailLabel setStringValue:[NSString stringWithFormat:@"-- / %@", albumTitle]];
    else
        [self.detailLabel setStringValue:@""];
    
    NSURL *url = [NSURL URLWithString:track.url];
    if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"])
        [self.detail2Label setStringValue:@"Double-click to download"];
    else
        [self.detail2Label setStringValue:[NSString stringWithFormat:@"%.01f kHz", [track.sampleRate doubleValue] / 1000]];
    
    [self setTime:[track.duration doubleValue] textField:self.timeLabel];
    
    NSString *urlString = track.url;
    if (urlString && [urlString length] > 0)
        self.imageView.image = [NSImage imageFromAlbum:track.albumTitle artist:track.artist url:[NSURL URLWithString:urlString]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"url"])
    {
        [self configureCellWithTrackEntity:self.trackObject];
    }
}

@end
