//
//  RFPlaylistView.h
//  Stereotype
//
//  Created by brandon on 12/18/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "RFLibraryView.h"
#import "RFCollectionView.h"

@interface RFPlaylistView : RFLibraryView<RFCollectionViewDelegate>

@property (weak) IBOutlet RFCollectionView *collectionView;

@end
