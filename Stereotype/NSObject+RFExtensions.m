//
//  NSObject+RFExtensions.m
//  Stereotype
//
//  Created by brandon on 6/17/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "NSObject+RFExtensions.h"

@implementation NSObject (RFExtensions)

+ (id)loadFromNib
{
    return [self loadFromNibNamed:[self className] owner:nil];
}

+ (id)loadFromNibNamed:(NSString *)nibName
{
    return [self loadFromNibNamed:nibName owner:nil];
}

+ (id)loadFromNibNamed:(NSString *)nibName owner:(NSObject *)owner
{
    NSNib *nib = [[NSNib alloc] initWithNibNamed:nibName bundle:nil];
    
    NSArray *objects = nil;
    [nib instantiateWithOwner:nil topLevelObjects:&objects];
    for (id object in objects)
    {
        if ([object isKindOfClass:self])
            return object;
    }
    
    id object = owner;
    if (!object)
        object = [[[self class] alloc] init];
    
    if (![NSBundle loadNibNamed:nibName owner:object])
        NSAssert1(NO, @"No view or controllers of class %@ found.", NSStringFromClass(self));
    else
        return object;
    return nil;    
}

- (id)loadFromNib
{
    return [[self class] loadFromNibNamed:[self className] owner:self];
}

- (id)loadFromNibNamed:(NSString *)nibName
{
    return [[self class] loadFromNibNamed:nibName owner:self];
}

- (void)performBlockInBackground:(NSObjectPerformBlock)performBlock completion:(NSObjectPerformBlock)completionBlock
{
    if (performBlock)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            performBlock();
            if (completionBlock)
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock();
                });
        });
}

- (void)performBlockOnMainThread:(NSObjectPerformBlock)block
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block)
            block();
    });
}

- (void)performUserBlockOnMainThread:(NSObjectPerformUserBlock)block userObject:(id)userObject
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block)
            block(userObject);
    });
}

- (void)performBlockInBackground:(NSObjectPerformUserBlock)performBlock completion:(NSObjectPerformUserBlock)completionBlock userObject:(id)userObject;
{
    if (performBlock)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            performBlock(userObject);
            if (completionBlock)
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(userObject);
                });
        });    
}

- (void)performReturnBlockInBackground:(NSObjectPerformReturnBlock)performBlock completion:(NSObjectPerformUserBlock)completionBlock;
{
    if (performBlock)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            id userObject = performBlock();
            if (completionBlock)
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(userObject);
                });
        });
    
}

- (void)__performBlockSelector:(NSObjectPerformBlock)block
{
    if (block)
        block();
}

- (void)performBlock:(NSObjectPerformBlock)performBlock afterDelay:(NSTimeInterval)delay
{
    /*dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
     dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
     if (performBlock)
     performBlock();
     });*/
    
    // ^^^ produces significant delay in just telling the block to execute.  when on the main queue, its less
    // performant to do this.
    
    if (performBlock)
        [self performSelector:@selector(__performBlockSelector:) withObject:[performBlock copy] afterDelay:delay];
}

@end
