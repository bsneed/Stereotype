//
//  RFTabView.h
//  Stereotype
//
//  Created by brandon on 10/26/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RFTabView : NSView

@property (nonatomic, strong) NSArray *viewControllers;

- (NSUInteger)activeViewControllerIndex;
- (NSView *)activeViewController;
- (NSView *)viewControllerAtIndex:(NSUInteger)index;
- (NSUInteger)indexForController:(NSView *)controller;
- (void)setActiveController:(NSView *)controller;
- (void)setActiveControllerAtIndex:(NSUInteger)index;

@end

@protocol RFTabViewProtocol <NSObject>
@optional
- (void)viewControllerWillAppear;
- (void)viewControllerDidAppear;
- (void)viewControllerWillDisappear;
- (void)viewControllerDidDisappear;
@end