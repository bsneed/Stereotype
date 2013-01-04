//
//  RFWindow.h
//  frequence
//
//  Created by Brandon Sneed on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "RFDragView.h"

@interface RFWindow : NSWindow

@property (nonatomic, readonly) RFDragView *dragView;

@end
