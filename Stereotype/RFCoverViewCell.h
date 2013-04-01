//
//  RFCoverViewCell.h
//  Stereotype
//
//  Created by brandon on 12/18/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RFCollectionView.h"

@interface RFCoverViewCell : RFCollectionViewItem

@property (nonatomic, strong) NSImage *image;
@property (nonatomic, strong) NSString *albumTitle;
@property (nonatomic, strong) NSString *artistName;
@property (nonatomic, strong) NSString *playlistName;

@end
