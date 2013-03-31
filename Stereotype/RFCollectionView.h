//
//  RFCollectionView.h
//  image-browser
//
//  Created by Brandon Sneed on 3/27/13.
//
//

#import <Quartz/Quartz.h>

@class RFCollectionViewCell;
@class RFCollectionView;

@protocol RFCollectionViewDelegate <NSObject>
@required
- (RFCollectionViewCell *)collectionView:(RFCollectionView *)collectionView cellForItem:(id)item;

@optional
- (CALayer *)collectionView:(RFCollectionView *)collectionView selectionLayerToModify:(CALayer *)layer;
- (CALayer *)collectionView:(RFCollectionView *)collectionView foregroundLayerToModify:(CALayer *)layer;
- (CALayer *)collectionView:(RFCollectionView *)collectionView backgroundLayerToModify:(CALayer *)layer;
- (CALayer *)collectionView:(RFCollectionView *)collectionView placeholderLayerToModify:(CALayer *)layer;

@end


@interface RFCollectionView : IKImageBrowserView

@property (nonatomic, assign) NSColor *containerBackgroundColor;
@property (nonatomic, assign) NSColor *imageOutlineColor;

@end
