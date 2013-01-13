//
//  RFLibrary.m
//  frequence
//
//  Created by Brandon Sneed on 11/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RFLibrary.h"
#import "NSURL+RFExtensions.h"
#import "RFMetadata.h"
#import "NSDictionary+SDExtensions.h"

#import "VPPCoreData.h"
#import "RFTrackEntity.h"
#import "RFPlaylistEntity.h"

NSString *kLibraryUpdatedNotification = @"kLibraryUpdatedNotification";

@implementation RFLibrary
{
    VPPCoreData *database;
}

+ (id)sharedInstance
{
	static dispatch_once_t oncePred;
	static id sharedInstance = nil;
	dispatch_once(&oncePred, ^{ sharedInstance = [[[self class] alloc] init]; });
	return sharedInstance;
}

- (id)init
{
	self = [super init];
	
    database = [VPPCoreData sharedInstance];
    
	return self;
}

- (void)dealloc
{
}

- (RFPlaylistEntity *)masterPlaylist
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"masterLibrary == YES"];
    RFPlaylistEntity *masterPlaylist = [database findObjectFromEntity:@"RFPlaylistEntity" withPredicate:predicate];
    if (!masterPlaylist)
    {
        RFPlaylistEntity *masterPlaylist = [database getNewObjectForEntity:@"RFPlaylistEntity"];
        masterPlaylist.masterLibrary = [NSNumber numberWithBool:YES];
        masterPlaylist.smartPlaylistQuery = @"ANY url != nil";
        masterPlaylist.name = @"Library";
        [[VPPCoreData sharedInstance] saveAllChanges];
    }
    return masterPlaylist;
}

- (NSArray *)masterPlaylistItems
{
    return nil;
}

- (NSUInteger)totalTrackCount
{
    return [database countObjectsForEntity:@"RFTrackEntity" filteredBy:nil];
}

- (NSURL *)iTunesLibraryURL
{
    NSString *normalLibraryPath = [@"~/Music/iTunes/iTunes Music Library.xml" stringByExpandingTildeInPath];
    NSString *olderLibraryPath = [@"~/Documents/iTunes/iTunes Music Library.xml" stringByExpandingTildeInPath];
	
    NSURL *libraryURL = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:normalLibraryPath])
        libraryURL = [self resolvedFileURLWithPath:normalLibraryPath];
    else
        if ([[NSFileManager defaultManager] fileExistsAtPath:olderLibraryPath])
            libraryURL = [self resolvedFileURLWithPath:olderLibraryPath];
    
    return libraryURL;
}

- (NSURL *)iTunesMusicPathURL
{
    NSString *normalLibraryPath = [@"~/Music/iTunes/iTunes Media/Music" stringByExpandingTildeInPath];
	
    NSURL *libraryURL = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:normalLibraryPath])
        libraryURL = [self resolvedFileURLWithPath:normalLibraryPath];
    
    return libraryURL;
}

- (NSURL *)iTunesPodcastPathURL
{
    NSString *normalLibraryPath = [@"~/Music/iTunes/iTunes Media/Podcasts" stringByExpandingTildeInPath];
	
    NSURL *libraryURL = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:normalLibraryPath])
        libraryURL = [self resolvedFileURLWithPath:normalLibraryPath];
    
    return libraryURL;
}

- (void)importFile:(NSURL *)fileURL skipExisting:(BOOL)skipExisting saveAfter:(BOOL)saveAfter
{
    NSURL *actualURL = [fileURL URLByResolvingSymlinksAndAliases];
    RFTrackEntity *entity = nil;
    if (skipExisting)
    {
        //NSPredicate *predicate = [trackPredicate predicateWithSubstitutionVariables:@{@"TRACKURL" : [actualURL absoluteString]}];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url == %@", [actualURL absoluteString]];
        entity = [database findObjectFromEntity:@"RFTrackEntity" withPredicate:predicate];
    }
    
    if (!entity)
    {
        RFMetadata *metadata = [[RFMetadata alloc] initWithURL:actualURL];
        if (metadata && [metadata handlesFileExtension])
        {
            NSString *title = [metadata getTitle];
            if ([title length] < 1)
                title = nil;
            
            //NSLog(@"Importing: %@", actualURL);
            
            entity = [database getNewObjectForEntity:@"RFTrackEntity"];
            entity.url = [actualURL absoluteString];
            
            if (!title)
                entity.title = [actualURL lastPathComponent];
            else
                entity.title = title;
            
            entity.artist = [metadata getArtist];
            entity.albumTitle = [metadata getAlbumTitle];
            entity.albumArtist = [metadata getAlbumArtist];
            entity.genre = [metadata getGenre];
            entity.releaseDate = [metadata getReleaseDate];
            entity.trackNumber = [metadata getTrackNumber];
            entity.trackTotal = [metadata getTrackTotal];
            entity.bpm = [metadata getBPM];
            entity.rating = [metadata getRating];
            entity.discNumber = [metadata getDiscNumber];
            entity.duration = [metadata getDuration];
            entity.composer = [metadata getComposer];
            entity.compilation = [metadata getCompilation];
            entity.discTotal = [metadata getDiscTotal];
            entity.sampleRate = [metadata getSampleRate];
            entity.format = [metadata getFormat];
        }
    }
    
    if (saveAfter)
        [database saveAllChanges];
}

- (void)importFiles:(NSArray *)urlArray progressBlock:(RFLibraryImportProgressBlock)progressBlock doneBlock:(NSObjectPerformBlock)doneBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger urlCount = urlArray.count;
        for (NSUInteger i = 0; i < urlCount; i++)
        {
            NSURL *theURL = [urlArray objectAtIndex:i];
            //NSURL *actualURL = [theURL URLByResolvingSymlinksAndAliases];
            
            if (progressBlock)
            {
                NSString *text = [NSString stringWithFormat:@"Scanning %@", [theURL lastPathComponent]];
                float progressValue = (i * 100) / urlCount;
                if (progressValue < 0)
                    progressValue = 0;
                if (progressValue > 100)
                    progressValue = 100;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    progressBlock(text, progressValue);
                });
            }
            
            [self importFile:theURL skipExisting:YES saveAfter:NO];
        }
        
        [database saveAllChanges];
        
        [self performBlockOnMainThread:doneBlock];
    });
}

- (void)importDirectories:(NSArray *)directories progressBlock:(RFLibraryImportProgressBlock)progressBlock doneBlock:(NSObjectPerformBlock)doneBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSURL *directory in directories)
            [self scanDirectory:directory skipExisting:YES progressBlock:progressBlock];
        
        [self performBlockOnMainThread:doneBlock];
    });
}

- (void)importiTunesPlaylistsWithProgressBlock:(RFLibraryImportProgressBlock)progressBlock doneBlock:(NSObjectPerformBlock)doneBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self importiTunesPlaylists:progressBlock];
        
        [self performBlockOnMainThread:doneBlock];
    });
}

- (void)scanDirectory:(NSURL *)directoryToScan skipExisting:(BOOL)skipExisting progressBlock:(RFLibraryImportProgressBlock)progressBlock
{
    // Create a local file manager instance
    NSFileManager *localFileManager=[[NSFileManager alloc] init];
    
    // Enumerate the directory (specified elsewhere in your code)
    // Request the two properties the method uses, name and isDirectory
    // Ignore hidden files
    // The errorHandler: parameter is set to nil. Typically you'd want to present a panel
    NSDirectoryEnumerator *dirEnumerator = [localFileManager enumeratorAtURL:directoryToScan
                                                  includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLNameKey,
                                                                              NSURLIsDirectoryKey,nil]
                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                errorHandler:nil];
    
    NSMutableArray *allURLs = [[NSMutableArray alloc] init];
    
    if (progressBlock)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            progressBlock(@"Scanning directory...", 0);
        });
    }
    
    // Enumerate the dirEnumerator results, each value is stored in allURLs
    for (NSURL *theURL in dirEnumerator) {
        @autoreleasepool
        {
            // Retrieve the file name. From NSURLNameKey, cached during the enumeration.
            NSString *fileName;
            [theURL getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
            
            // Retrieve whether a directory. From NSURLIsDirectoryKey, also
            // cached during the enumeration.
            NSNumber *isDirectory;
            [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
            
            // Ignore files under the _extras directory
            if (([fileName caseInsensitiveCompare:@"_extras"]==NSOrderedSame) &&
                ([isDirectory boolValue]==YES))
            {
                [dirEnumerator skipDescendants];
            }
            else
            {
                // Add full path for non directories
                if ([isDirectory boolValue]==NO)
                {
                    [allURLs addObject:theURL];
                }
            }
        }
    }
    
    NSUInteger urlCount = [allURLs count];
    
    NSLog(@"Found %lu items to process.", urlCount);
    
    for (NSUInteger i = 0; i < urlCount; i++)
    {
        NSURL *theURL = [allURLs objectAtIndex:i];

        if (progressBlock)
        {
            NSString *text = [NSString stringWithFormat:@"Scanning %@", [theURL lastPathComponent]];
            float progressValue = (i * 100) / urlCount;
            if (progressValue < 0)
                progressValue = 0;
            if (progressValue > 100)
                progressValue = 100;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                progressBlock(text, progressValue);
            });
        }
        
        [self importFile:theURL skipExisting:skipExisting saveAfter:NO];
    }
    
    [database saveAllChanges];
}

- (void)importiTunesPlaylists:(RFLibraryImportProgressBlock)progressBlock
{
    NSURL *libraryURL = [self iTunesLibraryURL];
    if (!libraryURL)
        return;
    
    NSDictionary *masterLibrary = [NSDictionary dictionaryWithContentsOfURL:libraryURL];
	NSDictionary *tracks = [masterLibrary dictionaryForKey:@"Tracks"];
	NSArray *masterPlaylists = [masterLibrary arrayForKey:@"Playlists"];
    
	NSMutableArray *userPlaylists = [[NSMutableArray alloc] init];
	
    if (progressBlock)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            progressBlock(@"Scanning playlists...", 0);
        });
    }
    
	// now remove the invisible ones
	for (NSDictionary *item in masterPlaylists)
	{
		NSNumber *visible = [item numberForKey:@"Visible"];
		if (!visible || [visible boolValue])
		{
			NSNumber *kindObject = [item numberForKey:@"Distinguished Kind"];
			int kind = [kindObject intValue];
			switch (kind)
			{
				case 2: // movies
				case 3: // tv shows
				case 4: // music
				case 19: // purchased
                case 22: // iTunes DJ
				case 26: // Genius
                case 31: // iTunes U
                    // don't import these.
                    break;
                    
                case 200: // smart playlist or 90's music, 200+ are smart playlists i think.
                case 204: // "" or Recently Added
                case 10: // podcasts
				default:
					[userPlaylists addObject:item];
					break;
			}
		}
	}
    
    NSPredicate *trackPredicate = [NSPredicate predicateWithFormat:@"url == $TRACKURL"];
    NSPredicate *playlistPredicate = [NSPredicate predicateWithFormat:@"itunesPlaylistID == $PLAYLISTID"];

    NSUInteger playlistCount = [userPlaylists count];
    for (NSUInteger i = 0; i < playlistCount; i++)
    {
        @autoreleasepool
        {
            NSDictionary *playlist = [userPlaylists objectAtIndex:i];
            NSString *name = [playlist stringForKey:@"Name"];
            NSArray *items = [playlist arrayForKey:@"Playlist Items"];
            NSMutableArray *urls = [[NSMutableArray alloc] init];
            
            //if ([name isEqualToString:@"ADELE"])
            //    NSLog(@"found it");

            if (progressBlock)
            {
                NSString *text = [NSString stringWithFormat:@"Importing %@", name];
                float progressValue = (i * 100) / playlistCount;
                if (progressValue < 0)
                    progressValue = 0;
                if (progressValue > 100)
                    progressValue = 100;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    progressBlock(text, progressValue);
                });
            }
            
            for (NSUInteger i = 0; i < [items count]; i++)
            {
                NSDictionary *item = [items objectAtIndex:i];
                NSNumber *trackKey = [item numberForKey:@"Track ID"];
                NSDictionary *trackDictionary = [tracks dictionaryForKey:[trackKey stringValue]];
                
                if (trackDictionary)
                {
                    NSString *url = [trackDictionary stringForKey:@"Location"];
                    BOOL isRemote = [[trackDictionary stringForKey:@"Track Type"] isEqualToString:@"Remote"];
                    if (!isRemote)
                    {
                        if ([url rangeOfString:@"http"].location == 0 || [url rangeOfString:@"https"].location == 0)
                        {
                            [urls addObject:url];
                            
                            RFTrackEntity *entity = [database getNewObjectForEntity:@"RFTrackEntity"];
                            entity.url = url;
                            entity.title = [trackDictionary stringForKey:@"Name"];
                            entity.artist = [trackDictionary stringForKey:@"Artist"];
                            entity.albumTitle = [trackDictionary stringForKey:@"Album"];
                            entity.genre = [trackDictionary stringForKey:@"Genre"];
                            entity.releaseDate = [trackDictionary stringForKey:@"Year"];
                            entity.trackNumber = [trackDictionary numberForKey:@"Track Number"];
                        }
                        else
                            [urls addObject:url];
                    }
                }
            }
            
            if ([urls count] > 0)
            {
                NSString *persistentID = [playlist objectForKey:@"Playlist Persistent ID"];
                RFPlaylistEntity *playlistEntity = nil;
                if (persistentID)
                {
                    NSPredicate *predicate = [playlistPredicate predicateWithSubstitutionVariables:@{@"PLAYLISTID" : persistentID}];
                    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itunesPlaylistID == %@", persistentID];
                    playlistEntity = [database findObjectFromEntity:@"RFPlaylistEntity" withPredicate:predicate];
                }
                
                // we've imported this one already, continue on.
                if (playlistEntity)
                    continue;
                
                NSMutableSet *itemSet = [NSMutableSet set];
                for (NSUInteger i = 0; i < [urls count]; i++)
                {
                    NSString *url = [urls objectAtIndex:i];
                    NSURL *playlistItemURL = [NSURL URLWithString:url];
                    NSURL *actualURL = [playlistItemURL URLByResolvingSymlinksAndAliases];
                    
                    NSPredicate *predicate = [trackPredicate predicateWithSubstitutionVariables:@{@"TRACKURL" : [actualURL absoluteString]}];
                    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url == %@", [actualURL absoluteString]];
                    RFTrackEntity *track = [database findObjectFromEntity:@"RFTrackEntity" withPredicate:predicate];
                    
                    if (track)
                    {
                        RFItemEntity *item = [database getNewObjectForEntity:@"RFItemEntity"];
                        item.index = [NSNumber numberWithLongLong:[itemSet count]];
                        item.track = track;
                        [itemSet addObject:item];
                    }
                }
                
                if (itemSet.count > 0)
                {
                    playlistEntity = [database getNewObjectForEntity:@"RFPlaylistEntity"];
                    
                    playlistEntity.itunesPlaylistID = persistentID;
                    playlistEntity.name = name;
                    playlistEntity.items = itemSet;
                }
            }
            
            [database saveAllChanges];
        }
    }
}

- (NSArray *)urlArrayToStringArray:(NSArray *)urlArray
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:urlArray.count];
    for (int i = 0; i < urlArray.count; i++)
    {
        NSURL *url = [urlArray objectAtIndex:i];
        [array addObject:url.absoluteString];
    }
    return [NSArray arrayWithArray:array];
}

- (NSURL *)resolvedFileURLWithPath:(NSString *)path
{
    NSURL *result = [[NSURL fileURLWithPath:path] URLByResolvingSymlinksAndAliases];
    return result;
}

#pragma mark - Downloader delegates

// fired when one or more downloads are ready. The array contains a dictionary
// with URLs as the keys, and the local file paths as the keys.
- (void)downloadsReady:(NSDictionary *)downloads
{
    [downloads enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSURL *actualURL = [NSURL URLWithString:key];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url == %@", [actualURL absoluteString]];
        RFTrackEntity *entity = [[VPPCoreData sharedInstance] findObjectFromEntity:@"RFTrackEntity" withPredicate:predicate];
        
        if (entity)
        {
            actualURL = [NSURL fileURLWithPath:obj];
            
            RFMetadata *metadata = [[RFMetadata alloc] initWithURL:actualURL];
            if (metadata && [metadata handlesFileExtension])
            {
                NSString *title = [metadata getTitle];
                if ([title length] < 1)
                    title = nil;
                
                if (title)
                {
                    entity.title = [metadata getTitle];
                    entity.artist = [metadata getArtist];
                    entity.albumTitle = [metadata getAlbumTitle];
                    entity.genre = [metadata getGenre];
                    entity.releaseDate = [metadata getReleaseDate];
                    entity.trackNumber = [metadata getTrackNumber];
                    entity.trackTotal = [metadata getTrackTotal];
                    entity.bpm = [metadata getBPM];
                    entity.rating = [metadata getRating];
                    entity.discNumber = [metadata getDiscNumber];
                    entity.duration = [metadata getDuration];
                    entity.composer = [metadata getComposer];
                    entity.compilation = [metadata getCompilation];
                    entity.discTotal = [metadata getDiscTotal];
                    entity.sampleRate = [metadata getSampleRate];
                    entity.format = [metadata getFormat];

                    // set this last since updates are triggered by it.
                    entity.url = [actualURL absoluteString];

                    [[VPPCoreData sharedInstance] saveAllChanges];
                }
            }
            
        }
    }];
}

// array of URLs that could not be downloaded.
- (void)downloadsFailed:(NSArray *)downloads
{
    
}

@end
