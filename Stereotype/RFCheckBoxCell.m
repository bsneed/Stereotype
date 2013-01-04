//
//  RFCheckBoxCell.m
//  Stereotype
//
//  Created by brandon on 10/27/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFCheckBoxCell.h"

@implementation RFCheckBoxCell

static NSImage *checkboxOffN, *checkboxOffP, *checkboxOnN, *checkboxOnP;

+ (void)initialize;
{
    NSBundle *bundle = [NSBundle bundleForClass:[RFCheckBoxCell class]];
    
    checkboxOffN = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"checkboxUnchecked"]];
    checkboxOffP = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"checkboxUnchecked"]];
    checkboxOnN = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"checkboxChecked"]];
    checkboxOnP = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"checkboxChecked"]];
    
    [checkboxOffN setFlipped:YES];
    [checkboxOffP setFlipped:YES];
    [checkboxOnN setFlipped:YES];
    [checkboxOnP setFlipped:YES];
}

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSRect titleRect = [self titleRectForBounds:cellFrame];
    NSString *plainTitle = [title string];
    
    titleRect.origin.x -= 10;
    titleRect.origin.y += 1;
    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                self.font, NSFontAttributeName,
                                [NSColor lightGrayColor], NSForegroundColorAttributeName, nil];
    [plainTitle drawInRect:titleRect withAttributes:attributes];
    
    return titleRect;
}

- (void)drawImage:(NSImage*)image withFrame:(NSRect)frame inView:(NSView*)controlView
{
    NSPoint point = NSMakePoint(0, 2);
    
    CGFloat alpha = [self isEnabled] ? 1.0 : 0.6;
    
    if ([self isHighlighted] && [self intValue])
        [checkboxOnP drawAtPoint:point fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:alpha];
    else if (![self isHighlighted] && [self intValue])
        [checkboxOnN drawAtPoint:point fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:alpha];
    else if (![self isHighlighted] && ![self intValue])
        [checkboxOffN drawAtPoint:point fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:alpha];
    else if ([self isHighlighted] && ![self intValue])
        [checkboxOffP drawAtPoint:point fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:alpha];
}

@end
