//
//  RFSongViewCell.h
//  Stereotype
//
//  Created by brandon on 12/18/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RFLibraryViewCell.h"

@interface RFSongViewCell : RFLibraryViewCell

@property (weak) IBOutlet NSTextField *indexLabel;
@property (weak) IBOutlet NSTextField *titleLabel;
@property (weak) IBOutlet NSTextField *detailLabel;
@property (weak) IBOutlet NSTextField *detail2Label;
@property (weak) IBOutlet NSTextField *timeLabel;
@property (weak) IBOutlet NSView *contentView;

@property (nonatomic, strong) RFTrackEntity *trackObject;

- (void)hideIndexLabel;
- (void)configureCellWithItemEntity:(RFItemEntity *)item;
- (void)configureCellWithTrackEntity:(RFTrackEntity *)track;
- (void)configureCellWithTrackEntity:(RFTrackEntity *)track displayIndex:(NSUInteger)displayIndex;

@end
