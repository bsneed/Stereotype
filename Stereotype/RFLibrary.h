//
//  RFLibrary.h
//  frequence
//
//  Created by Brandon Sneed on 11/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RFURLDownloader.h"

@class RFLibrary;

extern NSString *kLibraryUpdatedNotification;

typedef void(^RFLibraryImportProgressBlock)(NSString *text, float percentDone);

@interface RFLibrary : NSObject

+ (id)sharedInstance;

- (NSURL *)iTunesLibraryURL;
- (NSURL *)iTunesPathURL;

- (RFPlaylistEntity *)masterPlaylist;
//- (NSArray *)masterPlaylistTracks;
- (NSUInteger)totalTrackCount;


- (void)importDirectory:(NSURL *)directory progressBlock:(RFLibraryImportProgressBlock)progressBlock doneBlock:(NSObjectPerformBlock)doneBlock;
- (void)importiTunesPlaylistsWithProgressBlock:(RFLibraryImportProgressBlock)progressBlock doneBlock:(NSObjectPerformBlock)doneBlock;

@end
