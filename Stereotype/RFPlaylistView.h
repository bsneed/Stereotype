//
//  RFPlaylistView.h
//  Stereotype
//
//  Created by brandon on 12/18/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFLibraryView.h"
#import "JUCollectionView.h"

@interface RFPlaylistView : RFLibraryView<JUCollectionViewDelegate, JUCollectionViewDataSource>

@property (weak) IBOutlet JUCollectionView *collectionView;

@end
