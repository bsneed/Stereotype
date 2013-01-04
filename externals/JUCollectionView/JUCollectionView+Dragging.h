//
//  JUCollectionView+Dragging.h
//  Stereotype
//
//  Created by brandon on 12/30/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "JUCollectionView.h"

@interface JUCollectionView (Dragging)

- (void)initiateDraggingSessionWithEvent:(NSEvent *)anEvent;

- (void)showPoofAnimation;
- (void)showPoofCursor;
- (void)showNormalCursor;

@end
