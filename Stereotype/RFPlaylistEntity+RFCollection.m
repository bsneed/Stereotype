//
//  RFPlaylistEntity+RFCollection.m
//  Stereotype
//
//  Created by Brandon Sneed on 5/27/13.
//  Copyright (c) 2013 redf.net. All rights reserved.
//

#import "RFPlaylistEntity+RFCollection.h"
#import "RFCollectionView.h"
#import "NSImage+QuickLook.h"

@implementation RFPlaylistEntity (RFCollection)


- (id)imageRepresentation
{
    NSImage *image = nil;
    
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
            image = [NSImage imageFromAlbum:firstItem.track.albumTitle artist:firstItem.track.artist url:[NSURL URLWithString:url]];
    }
    return image;
}

- (NSString *)imageRepresentationType
{
    return IKImageBrowserNSImageRepresentationType;
}

- (NSString *)imageSubtitle
{
    return nil;
}

- (NSString *)imageTitle
{
    return self.name;
}

- (NSString *)imageUID
{
    NSString *name = @"unknown";
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    NSArray *items = [[self.items allObjects] sortedArrayUsingDescriptors:sortDescriptors];
    
    NSUInteger count = [items count];
    if (count > 0)
    {
        RFItemEntity *firstItem = [items objectAtIndex:0];
        name = [NSString stringWithFormat:@"%lu.tiff", [[firstItem.track.url lastPathComponent] hash]];
    }
    
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
