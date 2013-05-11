//
//  RFCoverViewCell.h
//  Stereotype
//
//  Created by brandon on 12/18/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JUCollectionViewCell.h"

@interface RFCoverViewCell : JUCollectionViewCell

@property (nonatomic, copy) NSString *albumTitle;
@property (nonatomic, copy) NSString *artistName;
@property (nonatomic, copy) NSString *playlistName;
@property (nonatomic, copy) NSString *url;

@end
