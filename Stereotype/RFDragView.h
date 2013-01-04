//
//  RFDragView.h
//  frequence
//
//  Created by Brandon Sneed on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RFDragView : NSView
{
    NSPoint currentLocation;
    NSPoint newOrigin;
    int offsetX;
    int offsetY;
}

@property (nonatomic, weak) NSWindow *dragWindow;
@property (nonatomic, strong) NSImage *overlayImage;

@end
