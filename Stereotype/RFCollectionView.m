//
//  RFCollectionView.m
//  image-browser
//
//  Created by Brandon Sneed on 3/27/13.
//
//

#import "RFCollectionView.h"
#import "RFCollectionViewCell.h"

@implementation RFCollectionView
{
    NSRect lastVisibleRect;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    [self _initialize];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self _initialize];
    return self;
}

- (void)_initialize
{
    //allow reordering, animations et set draggind destination delegate
    [self setAllowsReordering:YES];
    [self setAnimates:YES];
    [self setDraggingDestinationDelegate:self];
    [self setAllowsMultipleSelection:YES];
    
    self.cellSize = NSMakeSize(124, 124);
    //[_imageBrowser setIntercellSpacing:NSMakeSize(10, 80)];
    
    [self setCellsStyleMask:IKCellsStyleOutlined | IKCellsStyleTitled | IKCellsStyleSubtitled | IKCellsStyleShadowed];
    
    //-- change default font
    // create a centered paragraph style
    //NSMutableParagraphStyle *paraphStyle = [[NSMutableParagraphStyle alloc] init];
    //[paraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    //[paraphStyle setAlignment:NSCenterTextAlignment];

    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:[NSFont systemFontOfSize:12] forKey:NSFontAttributeName];
    //[attributes setObject:paraphStyle forKey:NSParagraphStyleAttributeName];
    [attributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
    [self setValue:attributes forKey:IKImageBrowserCellsTitleAttributesKey];

    attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:[NSFont systemFontOfSize:12] forKey:NSFontAttributeName];
    //[attributes setObject:paraphStyle forKey:NSParagraphStyleAttributeName];
    [attributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
    [self setValue:attributes forKey:IKImageBrowserCellsHighlightedTitleAttributesKey];
    
    attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:[NSFont systemFontOfSize:12] forKey:NSFontAttributeName];
    //[attributes setObject:paraphStyle forKey:NSParagraphStyleAttributeName];
    [attributes setObject:[NSColor lightGrayColor] forKey:NSForegroundColorAttributeName];
    [self setValue:attributes forKey:IKImageBrowserCellsSubtitleAttributesKey];
    
    [self setIntercellSpacing:NSMakeSize(46, 20)];
    
    [self setValue:[NSColor clearColor] forKey:IKImageBrowserBackgroundColorKey];
    [self setValue:[NSColor blackColor] forKey:IKImageBrowserCellsOutlineColorKey];
    
    //change selection color
    [self setValue:[NSColor colorWithCalibratedRed:1 green:0 blue:0.5 alpha:1.0] forKey:IKImageBrowserSelectionColorKey];
    
    //[self setZoomValue:0.60];
    
    self.mouseOverView.alphaValue = 0;
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
    [super viewWillMoveToWindow:newWindow];
    
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingMouseMoved | NSTrackingActiveAlways owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];    
}

/*- (NSView *)hitTest:(NSPoint)aPoint
{
    NSView *view = [super hitTest:aPoint];
    if (view == self)
    {
        NSInteger index = [self indexOfItemAtPoint:aPoint];
        NSRect itemFrame = [self itemFrameAtIndex:index];
        
        if (itemFrame.origin.x != self.mouseOverView.frame.origin.x && itemFrame.origin.y != self.mouseOverView.frame.origin.y)
        {
            [self hideMouseOverView];
            [self showMouseOverViewInRect:itemFrame];
        }
    }
    
    return view;
}*/

- (IKImageBrowserCell *)newCellForRepresentedItem:(id)anItem
{
    RFCollectionViewCell *cell = [[RFCollectionViewCell alloc] init];
    return cell;
}

// override draw rect and force the background layer to redraw if the view did resize or did scroll
- (void)drawRect:(NSRect) rect
{
	//retrieve the visible area
	NSRect visibleRect = [self visibleRect];
	
	//compare with the visible rect at the previous frame
	if(!NSEqualRects(visibleRect, lastVisibleRect)){
		//we did scroll or resize, redraw the background
		[[self backgroundLayer] setNeedsDisplay];
		
		//update last visible rect
		lastVisibleRect = visibleRect;
	}
	
	[super drawRect:rect];
}

- (void)hideMouseOverView
{
    self.mouseOverView.alphaValue = 0;
    [self.mouseOverView removeFromSuperview];
}

- (void)showMouseOverViewInRect:(NSRect)rect
{
    if (self.mouseOverView.frame.origin.x != rect.origin.x || self.mouseOverView.frame.origin.y != rect.origin.y)
        [self hideMouseOverView];
    
    self.mouseOverView.frame = rect;
    [self addSubview:self.mouseOverView];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [[NSAnimationContext currentContext] setDuration:0.2];
        [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        self.mouseOverView.alphaValue = 1.0;
    } completionHandler:^{
    }];

}

- (void)mouseMoved:(NSEvent *)theEvent
{
    [super mouseMoved:theEvent];
    
    NSPoint eventLocation = [theEvent locationInWindow];
    NSPoint localPoint = [self convertPoint:eventLocation fromView:nil];
    
    NSInteger index = [self indexOfItemAtPoint:localPoint];
    if (index == NSNotFound)
    {
        [self hideMouseOverView];
        return;
    }
    
    NSRect itemFrame = [self itemFrameAtIndex:index];
    
    NSIndexSet *selection = [self selectionIndexes];
    if ([selection containsIndex:index])
        [self showMouseOverViewInRect:itemFrame];
    else
        [self hideMouseOverView];
}

@end
