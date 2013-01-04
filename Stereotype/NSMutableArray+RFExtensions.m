//
//  NSMutableArray+RFExtensions.m
//  Stereotype
//
//  Created by Brandon Sneed on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSMutableArray+RFExtensions.h"

@implementation NSMutableArray (RFExtensions)

- (void)shuffle
{
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) 
    {
        // Select a random element between i and end of array to swap with.
        NSUInteger nElements = count - i;
        NSUInteger n = (arc4random() % nElements) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

- (void)shufflePreservingIndex:(NSUInteger)index
{
    NSUInteger count = [self count];
    id object = nil;
    if (count > index)
        object = [self objectAtIndex:index];
    
    for (NSUInteger i = 0; i < count; ++i)
    {
        // Select a random element between i and end of array to swap with.
        NSUInteger nElements = count - i;
        NSUInteger n = (arc4random() % nElements) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    [self removeObject:object];
    [self insertObject:object atIndex:index];
}


@end
