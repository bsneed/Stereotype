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
}

@end
