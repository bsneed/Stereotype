//
//  RFURLDownloader.m
//  Stereotype
//
//  Created by brandon on 12/21/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

/* This code is licensed in the Public Domain. Please contribute any fixes back to hakan@konstochvanligasaker.se
 See http://konstochvanligasaker.se/code for det latest version. */

#import "RFURLDownloader.h"
#import "NSFileManager+RFExtensions.h"
#import "RFLibrary.h"

@interface NSObject (PtrValueUtils)
- (NSValue *)ptrValue;
@end

@implementation NSObject (PtrValueUtils)
- (NSValue *)ptrValue
{
    return [NSValue valueWithPointer:(__bridge const void *)(self)];
}
@end

@interface RFURLDownloader (Private)
- (void)removeAllTracesOfDownload:(NSURLDownload *)download URL:(NSString *)URL;
@end

@implementation RFURLDownloader

+ (RFURLDownloader *)sharedInstance
{
    static dispatch_once_t onceToken;
    static RFURLDownloader *__instance = nil;
    dispatch_once(&onceToken, ^{
        NSURL *destinationPath = [[[NSFileManager defaultManager] applicationMusicDirectory] URLByAppendingPathComponent:@"Podcasts"];
        __instance = [[RFURLDownloader alloc] initWithDestinationFolderURL:destinationPath delegate:[RFLibrary sharedInstance]];
    });
    
    return __instance;
}

- (id)init
{
    if ((self = [super init])) {
        downloadPtrsToURLs = [NSMutableDictionary new];
        downloadURLsToObjects = [NSMutableDictionary new];
        downloadURLsToLocalPaths = [NSMutableDictionary new];
    }
    return self;
}

- (id)initWithDestinationFolderURL:(NSURL *)pathURL delegate:(id)theDelegate
{
    if ((self = [self init])) {
        delegate = theDelegate;
        
        BOOL exists = [[NSFileManager defaultManager] findOrCreateDirectory:pathURL];

        if (!exists)
        {
            NSLog(@"download failed");
            // TODO: throw (or something) on failure
        }
        
        destinationFolder = [pathURL.path copy];
    }
    return self;
}

- (void)dealloc
{
    delegate = nil;
    destinationFolder = nil;
    
    downloadURLsToObjects = nil;
    downloadPtrsToURLs = nil;
    downloadURLsToLocalPaths = nil;
}

#pragma mark -

- (void)addDownload:(NSString *)URL
{
    NSURLDownload *download = [[NSURLDownload alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]] delegate:self];
    
    NSString *destPath = [destinationFolder stringByAppendingPathComponent:[URL lastPathComponent]];
    [download setDestination:destPath allowOverwrite:NO];
    
    [downloadURLsToObjects setObject:download forKey:URL];
    [downloadPtrsToURLs setObject:URL forKey:[download ptrValue]];
}

- (void)addDownloads:(NSArray *)downloadPaths
{
    // TODO: start notification timer so we can report back in batches as well
    
    // start downloading
    NSString *URL = nil;
    NSEnumerator *downloadEnumerator = [downloadPaths objectEnumerator];
    while ((URL = [downloadEnumerator nextObject])) {
        [self addDownload:URL];
    }
}

- (void)removeAllTracesOfDownload:(NSURLDownload *)download URL:(NSString *)URL
{
    [downloadPtrsToURLs removeObjectForKey:[download ptrValue]];
    [downloadURLsToObjects removeObjectForKey:URL];
    [downloadURLsToLocalPaths removeObjectForKey:URL];
}

#pragma mark -

- (void)download:(NSURLDownload *)download didCreateDestination:(NSString *)path
{
    [downloadURLsToLocalPaths setObject:path forKey:[downloadPtrsToURLs objectForKey:[download ptrValue]]];
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
    NSString *URL = [downloadPtrsToURLs objectForKey:[download ptrValue]];
    
    // notify delegate
    // TODO: batch these notifications
    if (delegate && [delegate respondsToSelector:@selector(downloadsFailed:)]) {
        [delegate downloadsFailed:[NSArray arrayWithObject:URL]];
    }
    
    [self removeAllTracesOfDownload:download URL:URL];
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
    NSString *URL = [downloadPtrsToURLs objectForKey:[download ptrValue]];
    
    // notify delegate
    // TODO: batch these notifications
    if (delegate && [delegate respondsToSelector:@selector(downloadsReady:)]) {
        NSString *destPath = [downloadURLsToLocalPaths objectForKey:URL];
        [delegate downloadsReady:[NSDictionary dictionaryWithObject:destPath forKey:URL]];
    }
    
    [self removeAllTracesOfDownload:download URL:URL];
}

@end