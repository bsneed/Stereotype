//
//  NSMutableArray+RFExtensions.h
//  Stereotype
//
//  Created by Brandon Sneed on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (RFExtensions)

- (void)shuffle;
- (void)shufflePreservingIndex:(NSUInteger)index;

@end
