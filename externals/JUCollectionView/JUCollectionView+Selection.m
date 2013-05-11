//
//  JUCollectionView+Selection.m
//  JUCollectionView
//
//  Copyright (c) 2011 by Sidney Just
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
//  the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
//  and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
//  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
//  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "JUCollectionView+Selection.h"
#import "JUCollectionView+Dragging.h"

@interface NSIndexSet (JUCollectionView_IndexSet)
- (NSIndexSet *)indexSetByRemovingIndex:(NSUInteger)index;
@end

@implementation NSIndexSet (JUCollectionView_IndexSet)
- (NSIndexSet *)indexSetByRemovingIndex:(NSUInteger)index
{
    return [self indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return index != idx;
    }];
}
@end

@implementation JUCollectionView (JUCollectionView_Selection)

- (BOOL)shiftOrCommandKeyPressed:(NSEvent *)event
{
    return [event modifierFlags] & NSShiftKeyMask || [event modifierFlags] & NSCommandKeyMask;
}

- (NSView *)findClickedViewInCell:(JUCollectionViewCell *)cell atPoint:(NSPoint)point
{
    NSView *result = cell;
    
    NSPoint localPoint = [cell convertPoint:point fromView:nil];
    
    for (NSView *view in cell.subviews)
    {
        NSRect frame = view.frame;
        if (NSPointInRect(localPoint, frame))
        {
            result = view;
            break;
        }
    }
    
    return result;
}

- (void)mouseDown:(NSEvent *)event
{
    [[self window] makeFirstResponder:self];
    
    NSUInteger index;
    NSPoint mousePoint = [self convertPoint:[event locationInWindow] fromView:nil];
    index = [self indexOfCellAtPoint:mousePoint];
    
    // multiple selection
    BOOL shiftOrCommandPressed = [self shiftOrCommandKeyPressed:event];
    BOOL selectionContainsIndex = [self.selection containsIndex:index];

    mouseDownView = [self findClickedViewInCell:[self cellAtIndex:index] atPoint:[event locationInWindow]];
    /*if (mouseDownView && !shiftOrCommandPressed)
    {
        // you'll want to start a drag
        return;
    }
    else
    {
        // they clicked in the cell, but it was empty space
    }*/
    
    if (!mouseDownView)
    {
        [self deselectAllCells];
        return;
    }
    
    if (lastSelectionIndex != index)
        lastSelection = 0;
    
    if (!shiftOrCommandPressed && !selectionContainsIndex)
        [self deselectAllCells];
    
    if (shiftOrCommandPressed && selectionContainsIndex)
        [self deselectCellAtIndex:index];
    else
    {
        if ([event modifierFlags] & NSCommandKeyMask || self.selection.count == 0)
        {
            NSMutableIndexSet *newSelection = [self.selection mutableCopy];
            if (self.selection.count > 0)
            {
                [newSelection addIndex:index];
                [self selectCellsAtIndexes:newSelection];
            }
            else
                [self selectCellAtIndex:index];
        }
        else
        if ([event modifierFlags] & NSShiftKeyMask)
        {
            NSInteger one = [self.selection lastIndex];
            NSInteger two = index;
            
            if (index == NSNotFound)
                return;
            
            if (two > one)
                [self selectCellsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(MIN(one,two), 1+MAX(one,two)-MIN(one,two))]];
            else
                [self selectCellsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(MIN(one,two), MAX(one,two)-MIN(one,two))]];
        }
        else
        //if (!selectionContainsIndex)
            [self selectCellAtIndex:index];
    }
}

- (void)mouseUp:(NSEvent *)event
{
    /*NSUInteger index;
    NSPoint mousePoint = [self convertPoint:[event locationInWindow] fromView:nil];
    index = [self indexOfCellAtPoint:mousePoint];
    
    // multiple selection
    BOOL shiftOrCommandPressed = [self shiftOrCommandKeyPressed:event];
    BOOL selectionContainsIndex = [self.selection containsIndex:index];

    if (mouseDownView && selectionContainsIndex)
    {

    }*/
    
    if(unselectOnMouseUp)
        [self deselectAllCells];
    
    mouseDownView = nil;
    
    lastSelection = [NSDate timeIntervalSinceReferenceDate];
}

- (void)mouseDragged:(NSEvent *)event
{
    //NSPoint mousePoint = [self convertPoint:[event locationInWindow] fromView:nil];
    //NSUInteger index = [self indexOfCellAtPoint:mousePoint];
    //NSView *mouseDownView = [self findClickedViewInCell:[self cellAtIndex:index] atPoint:[event locationInWindow]];

    if (mouseDownView && self.allowsDragging)
    {
        [self initiateDraggingSessionWithEvent:event];   
    }
    else
    {
        NSUInteger index;
        NSPoint mousePoint = [self convertPoint:[event locationInWindow] fromView:nil];
        index = [self indexOfCellAtPoint:mousePoint];
        
        if (index != NSNotFound)
        {
            NSMutableIndexSet *indexes = [self.selection mutableCopy];
            [indexes addIndex:index];
            [self selectCellsAtIndexes:indexes];
            [self autoscroll:event];
        }
    }
}

- (void)mouseMoved:(NSEvent *)event
{
	NSUInteger index;
    NSPoint mousePoint = [self convertPoint:[event locationInWindow] fromView:nil];
    index = [self indexOfCellAtPoint:mousePoint];

	[self hoverOverCellAtIndex:index];
}

- (void)mouseExited:(NSEvent *)theEvent
{
	[self hoverOutOfLastCell];
}

/*- (void)mouseUp:(NSEvent *)event
{
    if(unselectOnMouseUp)
        [self deselectAllCells];
    
    lastSelection = [NSDate timeIntervalSinceReferenceDate];
}*/

- (void)keyDown:(NSEvent *)event
{
    unsigned short keyCode = [event keyCode];
    switch(keyCode)
    {
        case 123: // Left
        case 124: // Right
        case 125: // Down
        case 126: // Up
            [self interpretKeyEvents:[NSArray arrayWithObject:event]];
            break;
            
        default:
            [super keyDown:event];
    }
}

#pragma mark Helper Methods

- (void)simpleSelectItemAtIndex:(NSUInteger)anIndex
{
    if (anIndex != NSNotFound) {
        [self deselectAllCells];
        [self selectCellAtIndex:anIndex];
        [self scrollRectToVisible:[self rectForCellAtIndex:anIndex]];
    }
}

- (void)simpleExtendSelectionRange:(NSRange)range newIndex:(NSUInteger)newIndex
{
    if (newIndex != NSNotFound) {
        if ([self.selection containsIndex:newIndex])
            [self deselectCellsAtIndexes:[[NSIndexSet indexSetWithIndexesInRange:range] indexSetByRemovingIndex:newIndex]];
        else
            [self selectCellsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
        lastSelectionIndex = newIndex;
        [self scrollRectToVisible:[self rectForCellAtIndex:newIndex]];
    }
}

#pragma mark Arrow Keys

- (void)moveLeft:(id)sender
{
    if (lastSelectionIndex > 0)
        [self simpleSelectItemAtIndex:lastSelectionIndex-1];
}

- (void)moveLeftAndModifySelection:(id)sender
{
    if (lastSelectionIndex > 0) {
        NSUInteger newIndex = MAX(0ul, lastSelectionIndex-1);
        [self simpleExtendSelectionRange:NSMakeRange(newIndex, 2) newIndex:newIndex];
    }
}

- (void)moveRight:(id)sender
{
    [self simpleSelectItemAtIndex:MIN(numberOfCells-1, lastSelectionIndex+1)];
}

- (void)moveRightAndModifySelection:(id)sender
{
    NSUInteger newIndex = MIN(numberOfCells-1, lastSelectionIndex+1);
    [self simpleExtendSelectionRange:NSMakeRange(lastSelectionIndex, 2) newIndex:newIndex];
}

- (void)moveUp:(id)sender
{
    NSUInteger index = lastSelectionIndex - numberOfColumns;
    if (index > numberOfCells-1)
        index = numberOfCells-1;
    [self simpleSelectItemAtIndex:index];
}

- (void)moveUpAndModifySelection:(id)sender
{
    NSUInteger newIndex = lastSelectionIndex - numberOfColumns;
    if (newIndex > numberOfCells-1)
        newIndex = 0;
    
    NSRange range = NSMakeRange(newIndex, ([self.selection lastIndex]-newIndex) + 1);
    if ([self.selection containsIndex:newIndex])
        range.location++;
    
    [self simpleExtendSelectionRange:range newIndex:newIndex];
}

- (void)moveDown:(id)sender
{
    NSUInteger index = lastSelectionIndex + numberOfColumns;
    if (index > numberOfCells-1)
        index = 0;
    [self simpleSelectItemAtIndex:index];
}

- (void)moveDownAndModifySelection:(id)sender
{
    NSUInteger newIndex = lastSelectionIndex + numberOfColumns;
    if (newIndex > numberOfCells-1)
        newIndex = numberOfCells-1;
    
    NSRange range = NSMakeRange([self.selection firstIndex], (newIndex-[self.selection firstIndex])+1);
    //if (![self.selection containsIndex:newIndex])
    //    range.length++;
    
    [self simpleExtendSelectionRange:range newIndex:newIndex];
}


/*- (void)modifySelectionForIndex:(NSUInteger)index
{
    NSMutableIndexSet *indexes = [self.selection mutableCopy];

    if ([indexes containsIndex:index])
        [indexes removeIndex:index];
    else
        [indexes addIndex:index];
    
    if (indexes)
        [self selectCellsAtIndexes:indexes];
}

- (void)keyDown:(NSEvent *)event
{
    if([[self selection] count] == 0)
    {
        [super keyDown:event];
        return;
    }

    unsigned short keyCode = [event keyCode];
    NSUInteger index = 0;
    if (keyCode == 125) // down
        index = [[self selection] lastIndex];
    else
    if (keyCode == 126)
        index = [[self selection] first]
        
    NSUInteger index = [[self selection] lastIndex];
    BOOL isSelectionEvent = NO;
    BOOL shiftKeyDown = ([event modifierFlags] & NSShiftKeyMask) != 0;
    
    switch(keyCode)
    {
        case 123: // Left
            if (index > 1)
                index --;
            else
                index = 0;
            isSelectionEvent = YES;
            break;
            
        case 124: // Right
            if (index < numberOfCells-1)
                index ++;
            else
                index = numberOfCells-1;
            isSelectionEvent = YES;
            break;
            
        case 125: // Down
        {
            index += numberOfColumns;
            if (index > numberOfCells-1)
                index = numberOfCells-1;
            isSelectionEvent = NO;
            break;
        }
            
        case 126: // Up
        {
            NSUInteger startIndex = index;
            index -= numberOfColumns;
            if (index > numberOfCells-1)
                index = numberOfCells-1;
            if (shiftKeyDown)
            
            isSelectionEvent = NO;
            break;
        }
            
        default:
        {
            [super keyDown:event];
            return;
        }
            break;
    }
    
    if(isSelectionEvent)
    {
        if (shiftKeyDown)
            [self modifySelectionForIndex:index];
        else
            [self selectCellAtIndex:index];
        
        return;
    }
    
    BOOL delegateImplements = [delegate respondsToSelector:@selector(collectionView:keyEvent:forCellAtIndex:)];
    if(!delegateImplements)
        return;
    
    [[self selection] enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop){
        [delegate collectionView:self keyEvent:event forCellAtIndex:index];
    }];
}*/

@end
