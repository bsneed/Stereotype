//
//  RFSpacebarMenuItem.m
//  Stereotype
//
//  Created by brandon on 12/26/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFSpacebarMenuItem.h"

@implementation RFSpacebarMenuItem

- (void)drawKeyEquivalentWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSRect titleRect = [self keyEquivalentRectForBounds:cellFrame];
    NSString *title = @"space";
    NSColor *textColor = [NSColor blackColor];
    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                self.font, NSFontAttributeName,
                                textColor, NSForegroundColorAttributeName, nil];
    [title drawInRect:titleRect withAttributes:attributes];
}

@end
