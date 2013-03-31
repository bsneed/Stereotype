//
//  RFCoverViewCell.m
//  Stereotype
//
//  Created by brandon on 12/18/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFCoverViewCell.h"

@implementation RFCoverViewCell

- (void)setSelected:(BOOL)flag
{
    [super setSelected:flag];
    
    if (flag)
    {
        [self.selectionImageView setHidden:NO];
    }
    else
    {
        [self.selectionImageView setHidden:YES];
    }
}

@end
