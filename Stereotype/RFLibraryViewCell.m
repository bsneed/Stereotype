//
//  RFLibraryViewCell.m
//  Stereotype
//
//  Created by brandon on 12/25/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFLibraryViewCell.h"

@implementation RFLibraryViewCell

- (void)awakeFromNib
{
    //self.imageView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    self.drawSelection = NO;
    //self.selectionColor = [NSColor whiteColor];
}

- (void)setSelected:(BOOL)value
{
    [super setSelected:value];
    [self.selectionImageView setHidden:!value];
}

- (void)prepareForReuse
{
    self.imageView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    [self.selectionImageView setHidden:YES];
}

- (NSImage *)image
{
    return self.imageView.image;
}

@end
