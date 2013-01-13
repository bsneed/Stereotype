//
//  RFPlaylistEditor.h
//  Stereotype
//
//  Created by brandon on 1/6/13.
//  Copyright (c) 2013 redf.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JUCollectionView.h"

@interface RFPlaylistEditor : NSView<JUCollectionViewDelegate, JUCollectionViewDataSource>

@property (weak) IBOutlet JUCollectionView *collectionView;
@property (weak) IBOutlet NSTextField *textField;
@property (weak) IBOutlet NSButton *doneButton;

@end
