//
//  RFLibraryView.h
//  Stereotype
//
//  Created by brandon on 12/18/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JUCollectionView.h"
#import "NSImage+QuickLook.h"

@class RFLibraryViewController;

@interface RFLibraryView : NSView<JUCollectionViewDelegate, JUCollectionViewDataSource>
{
    VPPCoreData *database;
    id observer;
    NSString *_searchString;
}

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *items;

@property (weak) IBOutlet NSScrollView *scrollView;

@property (weak) IBOutlet JUCollectionView *collectionView;
@property (nonatomic, weak) RFLibraryViewController *navigationController;

@property (nonatomic, strong) NSString *searchString;

@end
