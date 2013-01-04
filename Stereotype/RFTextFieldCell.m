//
//  RFTextFieldCell.m
//  Stereotype
//
//  Created by brandon on 11/16/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFTextFieldCell.h"

@implementation RFTextFieldCell

- (NSRect)titleRectForBounds:(NSRect)theRect
{
    NSRect titleFrame = [super titleRectForBounds:theRect];
    NSSize titleSize = [[self attributedStringValue] size];
    titleFrame.origin.y = theRect.origin.y + (theRect.size.height - titleSize.height) / 2.0;
    return titleFrame;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    //[super drawInteriorWithFrame:cellFrame inView:controlView];
    [self.backgroundColor setFill];
    NSRectFill(cellFrame);
    
    NSRect titleRect = [self titleRectForBounds:cellFrame];
    titleRect.origin.x += 4;
    titleRect.size.width -= 8;
    
    [[self attributedStringValue] drawInRect:titleRect];
}

@end
