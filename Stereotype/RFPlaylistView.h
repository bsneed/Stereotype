//
//  RFPlaylistView.h
//  Stereotype
//
//  Created by brandon on 12/18/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFLibraryView.h"
#import "RFCollectionView.h"

@interface RFPlaylistView : RFLibraryView<NSCollectionViewDelegate, RFCollectionViewDelegate>

@property (weak) IBOutlet RFCollectionView *collectionView;

@end
