//
//  RFTrackEntity+RFCollection.m
//  Stereotype
//
//  Created by Brandon Sneed on 5/25/13.
//  Copyright (c) 2013 redf.net. All rights reserved.
//

#import "RFTrackEntity+RFCollection.h"
#import "NSImage+QuickLook.h"
#import <Quartz/Quartz.h>

@implementation RFTrackEntity (RFCollection)

- (id)imageRepresentation
{
    NSImage *image = nil;
    NSString *url = self.url;
    if (url && [url length] > 0)
        image = [NSImage imageFromAlbum:self.albumTitle artist:self.artist url:[NSURL URLWithString:url]];
    return image;
}

- (NSString *)imageRepresentationType
{
    return IKImageBrowserNSImageRepresentationType;
}

- (NSString *)imageSubtitle
{
    return self.albumArtist;
}

- (NSString *)imageTitle
{
    return self.albumTitle;
}

- (NSString *)imageUID
{
    NSString *name = [NSString stringWithFormat:@"%lu.tiff", [[self.url lastPathComponent] hash]];
    return name;
}

- (NSString *)imageVersion
{
    return @"1";
}

- (BOOL)isSelectable
{
    return YES;
}

@end
