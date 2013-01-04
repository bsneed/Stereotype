//
//  NSFileManager+RFExtensions.m
//  Stereotype
//
//  Created by Brandon Sneed on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSFileManager+RFExtensions.h"

@implementation NSFileManager (RFExtensions)

- (BOOL)findOrCreateDirectory:(NSURL *)directoryURL
{
    BOOL isDirectory = NO;
    if ([self fileExistsAtPath:directoryURL.path isDirectory:&isDirectory])
    {
        if (!isDirectory)
            return NO;
        return YES;
    }
    else
    {
        return [self createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return NO;
}

- (NSString *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory inDomain:(NSSearchPathDomainMask)domainMask appendPathComponent:(NSString *)appendComponent error:(NSError **)errorOut
{
    // Search for the path
    NSArray* paths = NSSearchPathForDirectoriesInDomains(searchPathDirectory, domainMask, YES);
    if ([paths count] == 0)
    {
        // *** creation and return of error object omitted for space
        return nil;
    }
    
    // Normally only need the first path
    NSString *resolvedPath = [paths objectAtIndex:0];
    
    if (appendComponent)
        resolvedPath = [resolvedPath stringByAppendingPathComponent:appendComponent];
    
    // Create the path if it doesn't exist
    NSError *error = nil;
    BOOL success = [self createDirectoryAtPath:resolvedPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) 
    {
        if (errorOut)
            *errorOut = error;
        return nil;
    }
    
    // If we've made it this far, we have a success
    if (errorOut)
        *errorOut = nil;

    return resolvedPath;
}

- (NSString *)executableName
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];    
}

- (NSURL *)applicationSupportDirectory
{
    NSError *error = nil;
    NSString *result = [self findOrCreateDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appendPathComponent:[self executableName] error:&error];
    if (error)
        NSLog(@"Unable to find or create application support directory:\n%@", error);
    return [NSURL fileURLWithPath:result];
}

- (NSURL *)applicationMusicDirectory
{
    NSError *error = nil;
    NSString *result = [self findOrCreateDirectory:NSMusicDirectory inDomain:NSUserDomainMask appendPathComponent:[self executableName] error:&error];
    if (error)
        NSLog(@"Unable to find or create application music directory:\n%@", error);
    return [NSURL fileURLWithPath:result];
}

@end
