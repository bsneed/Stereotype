//
//  RFSliderCell.m
//  frequence
//
//  Created by Brandon Sneed on 11/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RFSliderCell.h"

@implementation RFSliderCell

- (void)awakeFromNib
{
	knobImage = [NSImage imageNamed:@"scrubberKnob"];
	[self setKnobThickness:22];
	[[self controlView] setNeedsDisplay:YES];
}

- (void)drawKnob:(NSRect)knobRect
{
	[knobImage drawAtPoint:NSMakePoint(knobRect.origin.x, knobRect.origin.y - 1) fromRect:CGRectMake(0, 0, knobImage.size.width, knobImage.size.height) operation:NSCompositeSourceOver fraction:1.0];
}

- (void)dealloc
{
	knobImage = nil;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView 
{
	cellFrame = [self drawingRectForBounds: cellFrame];
	
	_trackRect = cellFrame;
	
	[self drawBarInside: cellFrame flipped: [controlView isFlipped]];
	[self drawKnob];
}

- (void)drawBarInside:(NSRect)rect flipped:(BOOL)flipped
{
	NSImage *background = [NSImage imageNamed:@"scrubberBackground"];
	[background drawInRect:NSMakeRect(5, 0, rect.size.width - 8, background.size.height) fromRect:CGRectMake(0, 0, background.size.width, background.size.height) operation:NSCompositeSourceOver fraction:1.0];

	CGFloat max = [self maxValue];
	CGFloat cur = [self floatValue];
	
	CGFloat width = ((rect.size.width - 8) * cur) / max;
	NSImage *fill = [NSImage imageNamed:@"scrubberFill"];
	[fill drawInRect:NSMakeRect(5, 0, width, background.size.height) fromRect:CGRectMake(0, 0, width, background.size.height) operation:NSCompositeSourceOver fraction:1.0];
}

- (CGFloat)knobThickness
{
	return 22;
}

@end
