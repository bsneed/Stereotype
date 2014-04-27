//
//  RFBlurWindow.h
//  Stereotype
//
//  Created by Brandon Sneed on 2/8/14.
//  Copyright (c) 2014 redf.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RFBlurWindow : NSWindow

@property (nonatomic, assign) BOOL showArtworkInBackground;
@property (nonatomic, strong) NSImage *artworkImage;

- (void)enableBlur:(double)radius;
- (void)disableBlur;

@end
