//
//  NSURL+RFExtensions.m
//  Stereotype
//
//  Created by brandon on 11/8/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "NSURL+RFExtensions.h"

@implementation NSURL (RFExtensions)

- (NSURL*)URLByResolvingSymlinksAndAliases
{
    NSURL* resultURL = [self URLByResolvingSymlinksInPath];
    
    NSError* error = nil;
    NSNumber* isAliasFile = nil;
    BOOL success = [resultURL getResourceValue:&isAliasFile
                                        forKey:NSURLIsAliasFileKey
                                         error:&error];
    if (success && [isAliasFile boolValue])
    {
        NSData* bookmarkData = [NSURL bookmarkDataWithContentsOfURL:resultURL
                                                              error:&error];
        if (bookmarkData)
        {
            BOOL isStale = NO;
            NSURLBookmarkResolutionOptions options =
            (NSURLBookmarkResolutionWithoutUI |
             NSURLBookmarkResolutionWithoutMounting);
            
            NSURL* resolvedURL = [NSURL URLByResolvingBookmarkData:bookmarkData
                                                           options:options
                                                     relativeToURL:nil
                                               bookmarkDataIsStale:&isStale
                                                             error:&error];
            if (resolvedURL)
            {
                resultURL = resolvedURL;
            }
        }
    }
    
    return resultURL;
}

@end
