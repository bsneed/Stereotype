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

@interface RFGlossWindow : NSWindow
- (void)configureDropTarget;
@end

@implementation RFGlossWindow

- (BOOL)canBecomeKeyWindow
{
	return NO;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    [[RFAppDelegate sharedInstance].playerView becomeFirstResponder];
}

- (void)configureDropTarget
{
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];
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

@end

@implementation RFArtworkView
{
    NSImage *_topBgImage;
    NSImage *_shineImage;
    RFCompositionView *_compositionView;
    __strong RFGlossWindow *overlayWindow;
}

- (void)setAlbumArtImage:(NSImage *)image
{
    _albumArtImage = image;
    [self setNeedsDisplay:YES];
}

- (void)setFullscreen:(BOOL)fullscreen
{
    if (fullscreen)
    {
        [overlayWindow orderOut:nil];
    }
    else
    {
        [overlayWindow orderFront:nil];
    }
}

- (void)awakeFromNib
{
    _albumArtImage = [NSImage imageNamed:@"topBg"];
    _topBgImage = [NSImage imageNamed:@"topBg"];
    
    _shineImage = [NSImage imageNamed:@"topShine"];
    
    // setup the shine overlay.  gotta do it this way to get it over the GL renderer.
    CGRect wRect = self.window.frame;
    
    CGRect rect = CGRectMake(wRect.origin.x, wRect.origin.y + 202, 202, 202);
    overlayWindow = [[RFGlossWindow alloc] initWithContentRect:rect
                                                     styleMask:NSBorderlessWindowMask
                                                       backing:NSBackingStoreBuffered
                                                         defer:NO];
    overlayWindow.backgroundColor = [NSColor clearColor];
    [overlayWindow setOpaque:NO];
    [overlayWindow setHasShadow:NO];
    overlayWindow.alphaValue = 1.0f;
    [overlayWindow setReleasedWhenClosed:NO];
    [overlayWindow configureDropTarget];

    NSView *contentView = self.window.contentView;

    RFDragView *dragView = [[RFDragView alloc] initWithFrame:contentView.bounds];
    dragView.dragWindow = self.window;
    dragView.overlayImage = _shineImage;
    [overlayWindow.contentView addSubview:dragView];
    
    [self.window addChildWindow:overlayWindow ordered:NSWindowAbove];
    [overlayWindow setParentWindow:self.window];
    
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

- (void)adjustChildWindow:(BOOL)hidden
{
    // setup the shine overlay.  gotta do it this way to get it over the GL renderer.
    CGRect wRect = self.window.frame;
    CGRect rect = CGRectMake(wRect.origin.x, wRect.origin.y + 202, 202, 202);
    [overlayWindow setFrame:rect display:!hidden];
    if (hidden)
        [overlayWindow orderOut:nil];
    else
        [overlayWindow orderFront:nil];

    if (!hidden)
        [self.window addChildWindow:overlayWindow ordered:NSWindowAbove];
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
    [_topBgImage drawInRect:outRect fromRect:artRect operation:NSCompositeSourceOver fraction:1.0];
    [_albumArtImage drawInRect:outRect fromRect:artRect operation:NSCompositeSourceOver fraction:1.0];
    //[_shineImage drawInRect:NSMakeRect(0, 0, 202, 202) fromRect:artRect operation:NSCompositeSourceOver fraction:1.0];
}


@end
