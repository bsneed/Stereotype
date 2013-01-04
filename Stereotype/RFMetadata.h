//
//  RFMetadata.h
//  Stereotype
//
//  Created by brandon on 11/22/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RFMetadata : NSObject

- (id)initWithURL:(NSURL *)url;

- (NSString *)getTitle;
- (NSString *)getAlbumTitle;
- (NSString *)getAlbumArtist;
- (NSString *)getArtist;
- (NSString *)getGenre;
- (NSString *)getComposer;
- (NSString *)getReleaseDate;
- (NSNumber *)getCompilation;
- (NSNumber *)getTrackNumber;
- (NSNumber *)getTrackTotal;
- (NSNumber *)getDiscNumber;
- (NSNumber *)getDiscTotal;
- (NSNumber *)getBPM;
- (NSNumber *)getRating;
- (NSString *)getComment;
- (NSImage *)getAlbumArt;
- (NSNumber *)getDuration;
- (NSNumber *)getSampleRate;
- (NSNumber *)getBitRate;
- (NSString *)getFormat;

- (BOOL)handlesFileExtension;

@end
