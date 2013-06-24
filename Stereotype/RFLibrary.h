//
//  RFLibrary.h
//  frequence
//
//  Created by Brandon Sneed on 11/26/11.
//  Copyright (c) 2011 redf.net. All rights reserved.
//

#import "RFURLDownloader.h"

@class RFLibrary;

extern NSString *kLibraryUpdatedNotification;

typedef void(^RFLibraryImportProgressBlock)(NSString *text, float percentDone);

@interface RFLibrary : NSObject

+ (id)sharedInstance;

- (NSURL *)iTunesLibraryURL;
- (NSURL *)iTunesMusicPathURL;
- (NSURL *)iTunesPodcastPathURL;

- (NSArray *)urlArrayToStringArray:(NSArray *)urlArray;

- (NSUInteger)totalTrackCount;

- (void)importFile:(NSURL *)fileURL skipExisting:(BOOL)skipExisting saveAfter:(BOOL)saveAfter;
- (void)importFiles:(NSArray *)urlArray progressBlock:(RFLibraryImportProgressBlock)progressBlock doneBlock:(NSObjectPerformBlock)doneBlock;
- (void)importDirectories:(NSArray *)directories progressBlock:(RFLibraryImportProgressBlock)progressBlock doneBlock:(NSObjectPerformBlock)doneBlock;
- (void)importiTunesPlaylistsWithProgressBlock:(RFLibraryImportProgressBlock)progressBlock doneBlock:(NSObjectPerformBlock)doneBlock;

@end
