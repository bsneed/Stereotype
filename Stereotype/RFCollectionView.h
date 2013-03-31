//
//  RFCollectionView.h
//  Stereotype
//
//  Created by Brandon Sneed on 3/27/13.
//  Copyright (c) 2013 redf.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RFCollectionView;

@protocol RFCollectionViewDelegate<NSObject>
@optional
- (NSCollectionViewItem *)collectionView:(RFCollectionView *)collectionView cellForObject:(id)object;
- (void)collectionView:(RFCollectionView *)collectionView doubleClickOnObject:(id)object;
@end

@interface RFCollectionViewCellView : NSView
@property (weak) RFCollectionView *collectionView;
@property (weak) id representedObject;
@end

@interface RFCollectionView : NSCollectionView

@end
