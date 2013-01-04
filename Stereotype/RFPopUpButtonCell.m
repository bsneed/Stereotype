//
//  RFPopUpButtonCell.m
//  Stereotype
//
//  Created by brandon on 10/27/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFPopUpButtonCell.h"
#import "BFImage.h"

@implementation RFPopUpButtonCell

//- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
- (void)drawBorderAndBackgroundWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSImage *bgImage = [NSImage imageNamed:@"popupBg"];
    NSImage *stretchedBg = [bgImage stretchableImageWithLeftCapWidth:20 topCapHeight:4];
    [stretchedBg setFlipped:YES];
    if (self.isEnabled)
        [stretchedBg drawInRect:cellFrame fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    else
        [stretchedBg drawInRect:cellFrame fromRect:NSZeroRect operation:NSCompositeCopy fraction:0.5];
}

- (void)drawTitleWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSRect titleRect = [self titleRectForBounds:cellFrame];
    NSString *title = self.title;
    NSColor *textColor = [NSColor lightGrayColor];
    if (!self.isEnabled)
        textColor = [NSColor darkGrayColor];
    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                self.font, NSFontAttributeName,
                                textColor, NSForegroundColorAttributeName, nil];
    [title drawInRect:titleRect withAttributes:attributes];
}

@end

@implementation RFPopUpButtonNoBgCell

//- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
/*- (void)drawBorderAndBackgroundWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSImage *bgImage = [NSImage imageNamed:@"popupBg"];
    NSImage *stretchedBg = [bgImage stretchableImageWithLeftCapWidth:20 topCapHeight:4];
    [stretchedBg setFlipped:YES];
    if (self.isEnabled)
        [stretchedBg drawInRect:cellFrame fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    else
        [stretchedBg drawInRect:cellFrame fromRect:NSZeroRect operation:NSCompositeCopy fraction:0.5];
}*/

- (void)drawTitleWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSRect titleRect = [self titleRectForBounds:cellFrame];
    NSString *title = self.title;
    NSColor *textColor = [NSColor whiteColor];
    if (!self.isEnabled)
        textColor = [NSColor darkGrayColor];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];

    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                self.font, NSFontAttributeName,
                                style, NSParagraphStyleAttributeName,
                                textColor, NSForegroundColorAttributeName, nil];
    [title drawInRect:titleRect withAttributes:attributes];
}

@end
