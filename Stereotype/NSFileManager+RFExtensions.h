//
//  NSFileManager+RFExtensions.h
//  Stereotype
//
//  Created by Brandon Sneed on 12/31/11.
//  Copyright (c) 2011 redf.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (RFExtensions)

- (BOOL)findOrCreateDirectory:(NSURL *)directoryURL;

- (NSURL *)applicationSupportDirectory;
- (NSURL *)applicationMusicDirectory;

@end
