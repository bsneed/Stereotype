//
//  RFSmallButtonCell.m
//  Stereotype
//
//  Created by Brandon Sneed on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RFBackButtonCell.h"

@implementation RFBackButtonCell

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{
    NSImage *backgroundImage = [NSImage imageNamed:@"backButton"];
	if ([self isHighlighted])
		backgroundImage = [NSImage imageNamed:@"backButtonPressed"];
	
	[backgroundImage setFlipped: YES];
	[backgroundImage setScalesWhenResized: YES];
	[backgroundImage setSize:frame.size];
	[backgroundImage drawInRect:frame fromRect:frame operation: NSCompositeSourceOver fraction: 1.0];
	
	[[self attributedTitle] drawInRect:[self titleRectForBounds:frame]];
}

- (void)drawInteriorWithFrame:(NSRect)rect inView:(NSView *)controlView
{
	if ([self image])
	{
		NSImage *fgImage = [self image];
		if ([self state] == NSOnState)
			fgImage = [self alternateImage];
		
		[fgImage setFlipped: [[self controlView] isFlipped]];
		NSRect centeredRect = NSMakeRect(((rect.size.width / 2) - (fgImage.size.width / 2)), ((rect.size.height / 2) - (fgImage.size.height / 2)), fgImage.size.width, fgImage.size.height);
		[fgImage drawInRect:centeredRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	}
}

@end
