//
//  RFDragView.m
//  frequence
//
//  Created by Brandon Sneed on 11/23/11.
//  Copyright (c) 2011 redf.net. All rights reserved.
//

#import "RFDragView.h"

@implementation RFDragView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _dragWindow = self.window;
    }
    
    return self;
}

- (void)awakeFromNib
{
    _dragWindow = self.window;
}

/*- (BOOL)movableByWindowBackground
{
	return YES;
}*/

- (BOOL)isFlipped
{
	return NO;
}

//- (void)mouseMoved:(NSEvent *)theEvent{
//}

- (void)mouseDown:(NSEvent *)theEvent
{
    if (!_dragWindow)
        _dragWindow = self.window;
    currentLocation = [_dragWindow convertBaseToScreen:[_dragWindow mouseLocationOutsideOfEventStream]];
    offsetX = currentLocation.x - [_dragWindow frame].origin.x;
    offsetY = currentLocation.y - [_dragWindow frame].origin.y;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    currentLocation = [_dragWindow convertBaseToScreen:[_dragWindow mouseLocationOutsideOfEventStream]];
    newOrigin.x = currentLocation.x - offsetX;
    newOrigin.y = currentLocation.y - offsetY;
    
    [_dragWindow setFrameOrigin:newOrigin];
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    if (_overlayImage)
        [_overlayImage drawInRect:NSMakeRect(0, 0, 202, 202) fromRect:NSMakeRect(0, 0, 202, 202) operation:NSCompositeSourceOver fraction:1.0];
}

@end
