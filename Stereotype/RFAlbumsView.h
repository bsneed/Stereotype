//
//  RFArtistsView.h
//  Stereotype
//
//  Created by brandon on 12/23/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFLibraryView.h"
#import "JUCollectionView.h"

@interface RFAlbumsView : RFLibraryView<JUCollectionViewDelegate, JUCollectionViewDataSource>

@property (weak) IBOutlet JUCollectionView *collectionView;

@end
