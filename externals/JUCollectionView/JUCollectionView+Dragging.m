//
//  JUCollectionView+Dragging.m
//  Stereotype
//
//  Created by brandon on 12/30/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "JUCollectionView+Dragging.h"

@implementation JUCollectionView (Dragging)

- (void)initiateDraggingSessionWithEvent:(NSEvent *)anEvent
{
    NSPoint mousePoint = [self convertPoint:[anEvent locationInWindow] fromView:nil];
    
    NSIndexSet *currentSelection = [self.selection copy];
    NSIndexSet *visibleSelection = [selection indexesInRange:self.visibleRange options:0 passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return [currentSelection containsIndex:idx];
    }];

    // add offset
    mousePoint.x += 29;
    mousePoint.y += 19;

    NSMutableArray *draggingItems = [[NSMutableArray alloc] init];
    [visibleSelection enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        JUCollectionViewCell *cell = [self cellAtIndex:idx];
        NSDraggingItem *item = [[NSDraggingItem alloc] initWithPasteboardWriter:cell];
        
        NSRect dragRect = cell.frame;
        dragRect.origin.x += (dragRect.size.width / 2) - 32;
        dragRect.origin.y += (dragRect.size.height / 2) - 32;
        dragRect.size = NSMakeSize(64, 64);
        
        [item setDraggingFrame:dragRect contents:cell.image];
        [draggingItems addObject:item];
    }];

    draggingSession = [self beginDraggingSessionWithItems:draggingItems event:anEvent source:self];
    draggingSession.draggingFormation = NSDraggingFormationPile;
}

#pragma mark - Dragging Source protocol

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    if ([self.delegate respondsToSelector:@selector(collectionView:draggingSession:sourceOperationMaskForDraggingContext:)])
        return [self.delegate collectionView:self draggingSession:session sourceOperationMaskForDraggingContext:context];
    
    return NSDragOperationNone;
}

- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation
{
    if ([self.delegate respondsToSelector:@selector(collectionView:draggingSession:endedAtPoint:operation:)])
        [self.delegate collectionView:self draggingSession:session endedAtPoint:screenPoint operation:operation];
    draggingSession = nil;
}

- (void)draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint
{
    if ([self.delegate respondsToSelector:@selector(collectionView:draggingSession:willBeginAtPoint:)])
        [self.delegate collectionView:self draggingSession:session willBeginAtPoint:screenPoint];
}

- (void)draggingSession:(NSDraggingSession *)session movedToPoint:(NSPoint)screenPoint
{
    if ([self.delegate respondsToSelector:@selector(collectionView:draggingSession:movedToPoint:)])
        [self.delegate collectionView:self draggingSession:session movedToPoint:screenPoint];
}

#pragma mark - Dragging destination protocol

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
    if ([self.delegate respondsToSelector:@selector(collectionView:draggingEntered:)])
        return [self.delegate collectionView:self draggingEntered:sender];
    return NSDragOperationNone;
}

- (void)draggingEnded:(id < NSDraggingInfo >)sender
{
    if ([self.delegate respondsToSelector:@selector(collectionView:draggingEnded:)])
        [self.delegate collectionView:self draggingEnded:sender];
}

- (void)draggingExited:(id < NSDraggingInfo >)sender
{
    if ([self.delegate respondsToSelector:@selector(collectionView:draggingExited:)])
        [self.delegate collectionView:self draggingExited:sender];
}

- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender
{
    if ([self.delegate respondsToSelector:@selector(collectionView:prepareForDragOperation:)])
        return [self.delegate collectionView:self prepareForDragOperation:sender];
    return NO;
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender
{
    if ([self.delegate respondsToSelector:@selector(collectionView:performDragOperation:)])
        return [self.delegate collectionView:self performDragOperation:sender];
    return NO;
}

- (void)concludeDragOperation:(id < NSDraggingInfo >)sender
{
    if ([self.delegate respondsToSelector:@selector(collectionView:concludeDragOperation:)])
        [self.delegate collectionView:self concludeDragOperation:sender];
}

#pragma mark - Utility methods

- (void)showPoofAnimation
{
    NSShowAnimationEffect(NSAnimationEffectPoof, [NSEvent mouseLocation], NSZeroSize, NULL, NULL, NULL);
    [NSCursor setHiddenUntilMouseMoves:YES];
}

- (void)showPoofCursor
{
    [[NSCursor disappearingItemCursor] set];
}

- (void)showNormalCursor
{
    [[NSCursor arrowCursor] set];
}

@end
