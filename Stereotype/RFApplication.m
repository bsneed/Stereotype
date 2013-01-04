//
//  RFApplication.m
//  Stereotype
//
//  Created by brandon on 12/21/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFApplication.h"
#import "RFAppDelegate.h"

#define SPSystemDefinedEventMediaKeys 8

@implementation RFApplication

- (id)init
{
    return [super init];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [super initWithCoder:aDecoder];
}

- (void)sendEvent:(NSEvent *)theEvent
{
    RFAppDelegate *appDelegate = (RFAppDelegate *)self.delegate;
    //NSResponder *responder = appDelegate.window.firstResponder;
    //NSLog(@"responder = %@", responder);
    //NSLog(@"theEvent = %@", theEvent);
    
    /*if (theEvent.type == NSKeyUp && theEvent.keyCode == 49) // 49 = space
    {
        if (![responder isKindOfClass:[NSTextView class]])
            [appDelegate playPauseTrackAction:nil];
        else
            NSLog(@"skipping playPause since firstResponder is an NSTextView");
    }
    else*/
    if (theEvent.type == NSSystemDefined && theEvent.subtype == SPSystemDefinedEventMediaKeys)
    {
        [appDelegate mediaKeyTap:nil receivedMediaKeyEvent:theEvent];
    }
    else
        [super sendEvent:theEvent];
}


@end
