//
//  RFLibraryView.h
//  Stereotype
//
//  Created by brandon on 12/18/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSImage+QuickLook.h"

@class RFLibraryViewController;

@interface RFLibraryView : NSView
{
    VPPCoreData *database;
    id observer;
    NSString *_searchString;
    NSOperationQueue *_imageQueue;
}

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *items;

@property (weak) IBOutlet NSScrollView *scrollView;

@property (nonatomic, weak) RFLibraryViewController *navigationController;

@property (nonatomic, strong) NSString *searchString;

- (NSArray *)selectedPaths;

@end
