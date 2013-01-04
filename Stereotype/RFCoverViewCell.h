//
//  RFCoverViewCell.h
//  Stereotype
//
//  Created by brandon on 12/18/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RFLibraryViewCell.h"

@interface RFCoverViewCell : RFLibraryViewCell

@property (weak) IBOutlet NSTextField *textLabel;
@property (weak) IBOutlet NSTextField *detailTextLabel;
@property (weak) IBOutlet NSTextField *playlistLabel;

@end
