//
//  RFTabView.m
//  Stereotype
//
//  Created by brandon on 10/26/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFTabView.h"

@implementation RFTabView
{
    NSUInteger activeIndex;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSUInteger)activeViewControllerIndex
{
    return [self indexForController:[self activeViewController]];
}

- (NSViewController *)activeViewController
{
    if ([self.viewControllers count] == 0)
        return nil;
    
    return [self.viewControllers objectAtIndex:activeIndex];
}

- (NSViewController *)viewControllerAtIndex:(NSUInteger)index
{
    NSUInteger count = [self.viewControllers count];
    if (count == 0 || index >= count)
        return nil;
    
    return [self.viewControllers objectAtIndex:index];
}

- (NSUInteger)indexForController:(NSViewController *)controller
{
    return [self.viewControllers indexOfObject:controller];
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    _viewControllers = viewControllers;
    [self setActiveControllerAtIndex:0];
}

- (void)setActiveController:(NSView *)controller
{
    [self setActiveControllerAtIndex:[self indexForController:controller]];
}

- (void)setActiveControllerAtIndex:(NSUInteger)index
{
    if (index >= [self.viewControllers count])
        return;
    
    NSView<RFTabViewProtocol> *activeController = (NSView<RFTabViewProtocol> *)[self activeViewController];
    if ([activeController respondsToSelector:@selector(viewControllerWillDisappear)])
        [activeController viewControllerWillDisappear];
    [activeController removeFromSuperview];
    if ([activeController respondsToSelector:@selector(viewControllerDidDisappear)])
        [activeController viewControllerDidDisappear];
    
    activeIndex = index;
    activeController = [self.viewControllers objectAtIndex:activeIndex];
    if ([activeController respondsToSelector:@selector(viewControllerWillAppear)])
        [activeController viewControllerWillAppear];
    
    //NSRect frame = activeController.view.frame;
    //frame.origin.x = -2;
    activeController.frame = self.bounds;
    
    if (activeController.superview != self)
        [self addSubview:activeController];
    if ([activeController respondsToSelector:@selector(viewControllerDidAppear)])
        [activeController viewControllerDidAppear];
}



@end
