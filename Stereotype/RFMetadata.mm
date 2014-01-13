//
//  RFMetadata.m
//  Stereotype
//
//  Created by brandon on 11/22/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFMetadata.h"
#import <SFBAudioEngine/AudioMetadata.h>

@implementation RFMetadata
{
    NSURL *_url;
    SFB::Audio::Metadata::unique_ptr metadata;
}

- (id)initWithURL:(NSURL *)url
{
    self = [super init];
    
    _url = url;
    metadata = SFB::Audio::Metadata::CreateMetadataForURL((__bridge CFURLRef)url);
    if (!metadata)
        return nil;
    return self;
}

- (void)dealloc
{
    metadata = nil;
}

- (NSString *)getTitle
{
    return (__bridge NSString *)metadata->GetTitle();
}

- (NSString *)getAlbumTitle
{
    return (__bridge NSString *)metadata->GetAlbumTitle();
}

- (NSString *)getGenre
{
    return (__bridge NSString *)metadata->GetGenre();
}

- (NSString *)getComposer
{
    return (__bridge NSString *)metadata->GetComposer();
}

- (NSString *)getReleaseDate
{
    return (__bridge NSString *)metadata->GetReleaseDate();
}

- (NSNumber *)getCompilation
{
    return (__bridge NSNumber *)metadata->GetCompilation();
}

- (NSNumber *)getTrackNumber
{
    return (__bridge NSNumber *)metadata->GetTrackNumber();
}

- (NSNumber *)getTrackTotal
{
    return (__bridge NSNumber *)metadata->GetTrackTotal();
}

- (NSNumber *)getDiscNumber
{
    return (__bridge NSNumber *)metadata->GetDiscNumber();
}

- (NSNumber *)getDiscTotal
{
    return (__bridge NSNumber *)metadata->GetDiscTotal();
}

- (NSNumber *)getBPM
{
    return (__bridge NSNumber *)metadata->GetBPM();
}

- (NSNumber *)getRating
{
    return (__bridge NSNumber *)metadata->GetRating();
}

- (NSString *)getComment
{
    return (__bridge NSString *)metadata->GetComment();
}

- (NSNumber *)getDuration
{
    return (__bridge NSNumber *)metadata->GetDuration();
}

- (NSNumber *)getSampleRate
{
    return (__bridge NSNumber *)metadata->GetSampleRate();
}

- (NSNumber *)getBitRate
{
    return (__bridge NSNumber *)metadata->GetBitrate();
}

- (NSString *)getFormat
{
    return (__bridge NSString *)metadata->GetFormatName();
}

// these two are special.  it varies which one or both of these get set by the creators.
- (NSString *)getAlbumArtist
{
    NSString *value = (__bridge NSString *)metadata->GetAlbumArtist();
    if (!value || value.length == 0)
        value = (__bridge NSString *)metadata->GetArtist();
    return value;
}

- (NSString *)getArtist
{
    NSString *value = (__bridge NSString *)metadata->GetArtist();
    if (!value || value.length == 0)
        value = (__bridge NSString *)metadata->GetAlbumArtist();
    return value;
}

- (NSImage *)getAlbumArt
{
    NSImage *result = nil;
    auto pictures = metadata->GetAttachedPictures();
    if (!pictures.empty())
        result = [[NSImage alloc] initWithData:(__bridge NSData *)pictures.front()->GetData()];
	return result;
}

- (BOOL)handlesFileExtension
{
    NSString *extension = [_url pathExtension];
    if (!metadata)
        return NO;
    
    return metadata->HandlesFilesWithExtension((__bridge CFStringRef)extension);
}

@end
