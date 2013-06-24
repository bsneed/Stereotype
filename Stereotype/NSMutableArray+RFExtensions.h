//
//  NSMutableArray+RFExtensions.h
//  Stereotype
//
//  Created by Brandon Sneed on 12/26/11.
//  Copyright (c) 2011 redf.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (RFExtensions)

- (void)shuffleWithAlbumMode:(BOOL)albumShuffleMode;
- (void)shufflePreservingIndex:(NSUInteger)index withAlbumMode:(BOOL)albumShuffleMode;

@end
