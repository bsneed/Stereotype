//
//  RFArtworkView.m
//  Stereotype
//
//  Created by brandon on 11/10/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFArtworkView.h"
#import "RFCompositionView.h"
#import "RFDragView.h"
#import "RFAppDelegate.h"

@implementation RFArtworkView
{
    RFCompositionView *_compositionView;
}

- (void)setAlbumArtImage:(NSImage *)image
{
    _albumArtImage = image;
    [self setNeedsDisplay:YES];
}

- (void)awakeFromNib
{
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];
    
    //self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType])
    {
        if (sourceDragMask & NSDragOperationCopy)
            return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType])
    {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        [[RFAppDelegate sharedInstance] application:nil openFiles:files];
    }
    return YES;
}


- (void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    RFAppDelegate *appDelegate = [RFAppDelegate sharedInstance];
    [appDelegate.window makeFirstResponder:appDelegate.playerView];
}

- (void)setCompositionView:(RFCompositionView *)value
{
    if (!value)
    {
        [_compositionView loadCompositionAtPath:nil];
        [_compositionView removeFromSuperview];
        [self setNeedsDisplay:YES];

        // keep the shine on top.
        //[self addSubview:_shineImageView];
        return;
    }
    
    if (_compositionView)
        [_compositionView removeFromSuperview];
    _compositionView = value;
    //_compositionView.frame = NSMakeRect(0, 0, 202, 202);
    [self addSubview:_compositionView];
    
    // keep the shine on top.
    //[self addSubview:_shineImageView];
}

- (RFCompositionView *)compositionView
{
    return _compositionView;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // draw album art.
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    
    NSRect outRect = self.bounds; // NSMakeRect(0, 0, 202, 202)

    NSRect artRect = NSMakeRect(0, 0, _albumArtImage.size.width, _albumArtImage.size.height);
    [_albumArtImage drawInRect:outRect fromRect:artRect operation:NSCompositeSourceOver fraction:1.0];
}


@end
