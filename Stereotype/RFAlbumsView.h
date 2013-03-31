//
//  RFArtistsView.h
//  Stereotype
//
//  Created by brandon on 12/23/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFLibraryView.h"
#import "RFCollectionView.h"

@interface RFAlbumsView : RFLibraryView<RFCollectionViewDelegate, NSCollectionViewDelegate>

@property (weak) IBOutlet NSCollectionView *collectionView;

@end
