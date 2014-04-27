//
//  RFTableRowView.m
//  Stereotype
//
//  Created by Brandon Sneed on 3/16/13.
//  Copyright (c) 2013 redf.net. All rights reserved.
//

#import "RFTableRowView.h"

@implementation RFTableRowView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected)
    {
        self.layer.shadowOpacity = 1.0;
    }
    else
    {
        self.layer.shadowOpacity = 0;
    }
}

- (void)drawSelectionInRect:(NSRect)dirtyRect
{
    NSImage *image = [NSImage imageNamed:@"selectionImageLong"];
    [image drawInRect:dirtyRect fromRect:NSMakeRect(0, 0, image.size.width, image.size.height) operation:NSCompositeCopy fraction:1.0 respectFlipped:YES hints:nil];
}

@end
