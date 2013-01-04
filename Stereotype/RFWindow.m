//
//  RFWindow.m
//  frequence
//
//  Created by Brandon Sneed on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RFWindow.h"
#import "RFAppDelegate.h"

@implementation RFWindow

- (BOOL)canBecomeKeyWindow
{
	return YES;
}

- (RFDragView *)dragView
{
    return (RFDragView *)self.contentView;
}

/*- (void)setFrame:(NSRect)frameRect display:(BOOL)flag
{
    [super setFrame:frameRect display:flag];
    [[RFAppDelegate sharedInstance].artworkView adjustChildWindowWithFrame:frameRect];
}*/

@end
