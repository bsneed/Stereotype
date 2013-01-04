//
//  NSObject+RFExtensions.h
//  Stereotype
//
//  Created by brandon on 6/17/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^NSObjectPerformBlock)();
typedef void (^NSObjectPerformUserBlock)(id userObject);
typedef id (^NSObjectPerformReturnBlock)();

@interface NSObject (RFExtensions)

+ (id)loadFromNib;
+ (id)loadFromNibNamed:(NSString *)nibName;
+ (id)loadFromNibNamed:(NSString *)nibName owner:(NSObject *)owner;

- (id)loadFromNib;
- (id)loadFromNibNamed:(NSString *)nibName;

- (void)performBlockInBackground:(NSObjectPerformBlock)performBlock completion:(NSObjectPerformBlock)completionBlock;
- (void)performBlockInBackground:(NSObjectPerformUserBlock)performBlock completion:(NSObjectPerformUserBlock)completionBlock userObject:(id)userObject;
- (void)performReturnBlockInBackground:(NSObjectPerformReturnBlock)performBlock completion:(NSObjectPerformUserBlock)completionBlock;

- (void)performBlock:(NSObjectPerformBlock)performBlock afterDelay:(NSTimeInterval)delay;

- (void)performBlockOnMainThread:(NSObjectPerformBlock)block;
- (void)performUserBlockOnMainThread:(NSObjectPerformUserBlock)block userObject:(id)userObject;

@end
