//
//  RFLibraryViewController.m
//  Stereotype
//
//  Created by brandon on 10/26/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFLibraryViewController.h"
#import "NSImage+QuickLook.h"
#import "RFSettingsModel.h"
#import "RFPlaylistEntity.h"
#import "RFPlaylistView.h"
#import "RFSongsView.h"
#import "RFArtistsView.h"
#import "RFAlbumsView.h"
#import "RFAppDelegate.h"

@interface RFLibraryViewController ()

@end

@implementation RFLibraryViewController
{
    VPPCoreData *database;
    NSMutableArray *libraryViews;
    
    RFLibraryView *libraryView;
}

- (void)awakeFromNib
{
    database = [VPPCoreData sharedInstance];
    libraryViews = [[NSMutableArray alloc] init];
    _viewStyle = INT_MAX;
    
    [self.backButton setAlphaValue:0];
    [self.titleLabel setAlphaValue:0];
    
    [self.titlePopup setTarget:self];
    [self.titlePopup setAction:@selector(titlePopupAction:)];
    
    self.dragView.dragWindow = self.window;
}

- (RFLibraryView *)libraryView
{
    return libraryView;
}

- (void)setViewStyle:(RFLibraryViewStyle)viewStyle
{
    if (_viewStyle != viewStyle)
    {
        _viewStyle = viewStyle;
        
        [libraryViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [libraryViews removeAllObjects];
        
        libraryView = nil;
        
        [self.titlePopup setAlphaValue:1.0];
        [self.backButton setAlphaValue:0];
        
        [self.titleLabel setAlphaValue:0];
        [self.titleLabel setStringValue:@""];

        switch (_viewStyle)
        {
            case RFLibraryViewStylePlaylists:
                libraryView = [RFPlaylistView loadFromNib];
                [self.titlePopup setTitle:@"Playlists"];
                break;
                
            case RFLibraryViewStyleAlbums:
                libraryView = [RFAlbumsView loadFromNib];
                [self.titlePopup setTitle:@"Albums"];
                break;
                
            case RFLibraryViewStyleArtists:
                libraryView = [RFArtistsView loadFromNib];
                [(RFArtistsView *)libraryView loadArtists];
                [self.titlePopup setTitle:@"Artists"];
                break;
                
            default:
            case RFLibraryViewStyleSongs:
                libraryView = [RFSongsView loadFromNib];
                [(RFSongsView *)libraryView loadAllSongs];
                [self.titlePopup setTitle:@"Songs"];
                break;
        }
        
        [self pushView:libraryView];
    }
}

- (void)viewControllerDidAppear
{
    
}

- (void)pushView:(RFLibraryView *)aView
{
    aView.alphaValue = 0;
    aView.frame = self.containerView.bounds;
    aView.navigationController = self;
    aView.frame = CGRectOffset(aView.frame, self.containerView.frame.size.width, 0);
    [self.containerView addSubview:aView positioned:NSWindowBelow relativeTo:self.topBarImageView];

    [self.titleLabel setStringValue:aView.title];

    RFLibraryView *lastView = [libraryViews lastObject];
    if (lastView)
    {
        [[self window] makeFirstResponder:aView];
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            [lastView.animator setFrame:CGRectOffset(lastView.frame, -self.containerView.frame.size.width, 0)];
            [aView.animator setFrame:CGRectOffset(aView.frame, -self.containerView.frame.size.width, 0)];
            [lastView.animator setAlphaValue:0];
            [aView.animator setAlphaValue:1.0];
            [self.backButton.animator setAlphaValue:1.0];
            [self.titlePopup.animator setAlphaValue:0];
            [self.titleLabel.animator setAlphaValue:1.0];
        } completionHandler:^{
            libraryView = aView;
            [self.titlePopup setHidden:YES];
        }];
        [libraryViews addObject:aView];
    }
    else
    {
        aView.frame = CGRectOffset(aView.frame, -self.frame.size.width, 0);
        aView.alphaValue = 1.0;
        [libraryViews addObject:aView];
        libraryView = aView;
        //[libraryView.collectionView performSelector:@selector(reloadData) withObject:nil afterDelay:0];
    }
    
    [self.searchField setStringValue:@""];
}

- (void)popView
{
    if ([libraryViews count] <= 1)
        return;
    
    __strong RFLibraryView *currentView = [libraryViews lastObject];
    [libraryViews removeObject:currentView];
    
    RFLibraryView *aView = [libraryViews lastObject];

    [self.titleLabel setStringValue:aView.title];

    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        if ([libraryViews count] <= 1)
        {
            [self.backButton.animator setAlphaValue:0];
            [self.titlePopup setHidden:NO];
            [self.titlePopup.animator setAlphaValue:1.0];
            [self.titleLabel.animator setAlphaValue:0];
        }
        
        [currentView.animator setFrame:CGRectOffset(currentView.frame, self.frame.size.width, 0)];
        [aView.animator setFrame:CGRectOffset(aView.frame, self.frame.size.width, 0)];
        [currentView.animator setAlphaValue:0];
        [aView.animator setAlphaValue:1.0];
    } completionHandler:^{
        [currentView removeFromSuperview];
        libraryView = aView;
        if (libraryView.searchString && libraryView.searchString.length > 0)
            [self.searchField setStringValue:libraryView.searchString];
    }];

    [self.searchField setStringValue:@""];
}

- (IBAction)backAction:(id)sender
{
    [self popView];
}

- (IBAction)titlePopupAction:(NSPopUpButton *)popupButton
{
    NSMenuItem *selectedItem = [popupButton selectedItem];
    [popupButton selectItemAtIndex:selectedItem.tag];
    [popupButton setTitle:selectedItem.title];
    
    self.viewStyle = selectedItem.tag;
    [RFSettingsModel sharedInstance].libraryViewStyle = self.viewStyle;
}

- (IBAction)searchAction:(id)sender
{
    libraryView.searchString = self.searchField.stringValue;
    //NSLog(@"searchString = %@", libraryView.searchString);
}

@end
