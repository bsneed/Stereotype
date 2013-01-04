//
//  NSImageView+RFExtensions.m
//  Stereotype
//
//  Created by brandon on 11/7/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "NSImageView+RFExtensions.h"
#import <objc/runtime.h>

@implementation NSImageView (RFExtensions)

- (void)setImageURL:(NSString *)imageURL
{
    objc_setAssociatedObject(self, "imageURL", imageURL, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)imageURL
{
    id result = objc_getAssociatedObject(self, "imageURL");
    return result;
}

@end
