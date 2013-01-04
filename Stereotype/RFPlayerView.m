//
//  RFPlayerView.m
//  Stereotype
//
//  Created by Brandon Sneed on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RFPlayerView.h"
#import "RFCompositionView.h"
#import "RFAppDelegate.h"

@implementation RFPlayerView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (BOOL)becomeFirstResponder {
    BOOL okToChange = [super becomeFirstResponder];
    if (okToChange) [self setKeyboardFocusRingNeedsDisplayInRect: [self bounds]];
    return okToChange;
}

- (BOOL)resignFirstResponder {
    BOOL okToChange = [super resignFirstResponder];
    if (okToChange) [self setKeyboardFocusRingNeedsDisplayInRect: [self bounds]];
    return okToChange;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    RFAppDelegate *appDelegate = [RFAppDelegate sharedInstance];
    [appDelegate.window makeFirstResponder:appDelegate.playerView];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    backgroundImage = [NSImage imageNamed:@"bottomBg"];
    bottomShineImage = [NSImage imageNamed:@"bottomShine"];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    [backgroundImage drawInRect:NSMakeRect(0, 0, 202, 404) fromRect:NSMakeRect(0, 0, 202, 404) operation:NSCompositeSourceOver fraction:1.0];
    
    // draw overlay.
    [bottomShineImage drawInRect:NSMakeRect(0, 0, 202, 404) fromRect:NSMakeRect(0, 0, 202, 404) operation:NSCompositeSourceOver fraction:1.0];
}

@end
