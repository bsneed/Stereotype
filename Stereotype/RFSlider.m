//
//  RFSlider.m
//  frequence
//
//  Created by Brandon Sneed on 11/25/11.
//  Copyright (c) 2011 redf.net. All rights reserved.
//

#import "RFSlider.h"

@implementation RFSlider

- (void)setNeedsDisplayInRect:(NSRect)invalidRect
{
    [super setNeedsDisplayInRect:[self bounds]];
}

- (BOOL)isFlipped
{
	return NO;
}

@end
