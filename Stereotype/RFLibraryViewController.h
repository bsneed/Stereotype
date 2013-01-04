//
//  RFLibraryViewController.h
//  Stereotype
//
//  Created by brandon on 10/26/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RFLibrary.h"
#import "NSObject+RFExtensions.h"
#import "RFTabView.h"
#import "RFLibraryView.h"
#import "RFDragView.h"

@class RFLibraryCollectionView;

typedef enum
{
    RFLibraryViewStyleAlbums = 0,
    RFLibraryViewStyleArtists,
    RFLibraryViewStylePlaylists,
    RFLibraryViewStyleSongs,
} RFLibraryViewStyle;

typedef void(^RFLibrarySelectionBlock)();

@interface RFLibraryViewController : NSView <RFTabViewProtocol>

@property (nonatomic, copy) RFLibrarySelectionBlock selectionBlock;
@property (weak) IBOutlet NSImageView *topBarImageView;
@property (weak) IBOutlet NSTextField *titleLabel;
@property (weak) IBOutlet NSButton *backButton;
@property (weak) IBOutlet NSView *containerView;
@property (weak) IBOutlet NSPopUpButton *titlePopup;
@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet RFDragView *dragView;

@property (nonatomic, readonly) RFLibraryView *libraryView;

@property (nonatomic, assign) RFLibraryViewStyle viewStyle;

- (void)pushView:(RFLibraryView *)aView;
- (void)popView;

@end
