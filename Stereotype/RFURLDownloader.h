//
//  RFURLDownloader.h
//  Stereotype
//
//  Created by brandon on 12/21/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

/* This code is licensed in the Public Domain. Please contribute any fixes back to hakan@konstochvanligasaker.se
 See http://konstochvanligasaker.se/code for det latest version. */


#import <Foundation/Foundation.h>

@protocol RFURLDownloaderDelegate

// fired when one or more downloads are ready. The array contains a dictionary
// with URLs as the keys, and the local file paths as the keys.
- (void)downloadsReady:(NSDictionary *)downloads;

// array of URLs that could not be downloaded.
- (void)downloadsFailed:(NSArray *)downloads;

@end


@interface RFURLDownloader : NSObject<NSURLDownloadDelegate>
{
    // fast (constant-time) lookup for a URL, just given a download object.
    // unfortunately we can't just use a dictionary with NSURLDownloads as keys, because it doesn't
    // implement the NSCopying protocol.
    NSMutableDictionary *downloadPtrsToURLs;
    
    // URL => NSURLDownload
    NSMutableDictionary *downloadURLsToObjects;
    
    // URL => local file path
    NSMutableDictionary *downloadURLsToLocalPaths;
    
    id delegate;
    
    NSString *destinationFolder;
}

+ (RFURLDownloader *)sharedInstance;

// will try to create dest folder if it doesn't exist.
- (id)initWithDestinationFolderURL:(NSURL *)pathURL delegate:(id)theDelegate;

- (void)addDownload:(NSString *)URL;
- (void)addDownloads:(NSArray *)URLs;

@end