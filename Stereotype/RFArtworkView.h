//
//  RFArtworkView.h
//  Stereotype
//
//  Created by brandon on 11/10/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RFDragView.h"

@class RFCompositionView;

@interface RFArtworkView : RFDragView

@property (nonatomic, strong) NSImage *albumArtImage;

- (void)setCompositionView:(RFCompositionView *)value;
- (RFCompositionView *)compositionView;
- (void)adjustChildWindow:(BOOL)hidden;
- (void)setFullscreen:(BOOL)fullscreen;

@end
