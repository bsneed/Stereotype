//
//  RFSettingsViewController.m
//  Stereotype
//
//  Created by brandon on 10/26/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFSettingsViewController.h"
#import "RFSettingsModel.h"
#import "RFAppDelegate.h"
#import "RFAudioDevices.h"
#import "RFAudioPlayer.h"

@interface RFSettingsViewController ()

@end

@implementation RFSettingsViewController
{
    NSString *preferredDevice;
    BOOL preferredDeviceSelected;
    RFSettingsModel *settings;
}

- (void)awakeFromNib
{
    settings = [RFSettingsModel sharedInstance];
    
    self.audioFilter1Popup.menu = [self menuForAudioFilters];
    self.audioFilter2Popup.menu = [self menuForAudioFilters];
    self.audioFilter3Popup.menu = [self menuForAudioFilters];

    [self updateState];
}

- (void)filterChanged:(id)sender
{
    NSString *filter1Value = self.audioFilter1Popup.selectedItem.representedObject;
    NSString *filter2Value = self.audioFilter2Popup.selectedItem.representedObject;
    NSString *filter3Value = self.audioFilter3Popup.selectedItem.representedObject;
    
    settings.filterNames = @[filter1Value, filter2Value, filter3Value];
    
    [[RFAudioPlayer sharedInstance] setEffects:settings.filterNames];
    [self refreshDisplay];
}

- (NSMenu *)menuForAudioFilters
{
    NSArray *filters = [[RFAudioPlayer sharedInstance] availableEffectsFilters];
    
    NSMenu *menu = [[NSMenu alloc] init];
    
    NSMenuItem *noneItem = [[NSMenuItem alloc] initWithTitle:@"None" action:nil keyEquivalent:@""];
    noneItem.representedObject = @"None";
    noneItem.target = self;
    noneItem.action = @selector(filterChanged:);
    
    NSMenuItem *separatorItem = [NSMenuItem separatorItem];

    [menu addItem:noneItem];
    [menu addItem:separatorItem];
    
    for (int i = 0; i < [filters count]; i++)
    {
        NSString *title = [filters objectAtIndex:i];
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
        item.representedObject = title;
        item.target = self;
        item.action = @selector(filterChanged:);
        [menu addItem:item];
    }
    
    return menu;
}

- (void)updateState
{
    self.visualizerCheckbox.state = settings.useVisualizer;
    self.exclusiveModeCheckbox.state = settings.exclusiveMode;
    self.upsamplingCheckbox.state = !settings.upsampling;
    
    [self.audioFilter1Popup selectItemWithTitle:[settings.filterNames objectAtIndex:0]];
    [self.audioFilter2Popup selectItemWithTitle:[settings.filterNames objectAtIndex:1]];
    [self.audioFilter3Popup selectItemWithTitle:[settings.filterNames objectAtIndex:2]];
    
    [self refreshDisplay];
}

- (void)refreshDisplay
{
    if (settings.preferredDevice)
    {
        NSString *name = [RFAudioPlayer sharedInstance].outputDevice.deviceName;
        if ([name isEqualToString:settings.preferredDevice])
            self.preferredDeviceCheckbox.state = NSOnState;
        else
            self.preferredDeviceCheckbox.state = NSOffState;
    }
    
    BOOL upsampling = [RFAudioPlayer sharedInstance].upsampling;
    self.upsamplingCheckbox.state = !upsampling;
    
    if ([self.audioFilter1Popup.selectedItem.title isEqualToString:@"None"])
        [self.filter1WindowButton setHidden:YES];
    else
        [self.filter1WindowButton setHidden:NO];
    
    if ([self.audioFilter2Popup.selectedItem.title isEqualToString:@"None"])
        [self.filter2WindowButton setHidden:YES];
    else
        [self.filter2WindowButton setHidden:NO];
    
    if ([self.audioFilter3Popup.selectedItem.title isEqualToString:@"None"])
        [self.filter3WindowButton setHidden:YES];
    else
        [self.filter3WindowButton setHidden:NO];
}

#pragma mark - Actions

- (IBAction)preferredDeviceAction:(id)sender
{
    NSInteger state = self.preferredDeviceCheckbox.state;
    if (state == NSOffState)
        settings.preferredDevice = nil;
    else
        settings.preferredDevice = [RFAudioPlayer sharedInstance].outputDevice.deviceName;
}

- (IBAction)visualizerAction:(id)sender
{
    settings.useVisualizer = self.visualizerCheckbox.state;
}

- (IBAction)exclusiveModeAction:(id)sender
{
    settings.exclusiveMode = self.exclusiveModeCheckbox.state;
    [RFAudioPlayer sharedInstance].exclusiveMode = settings.exclusiveMode;
}

- (IBAction)upsamplingAction:(id)sender
{
    settings.upsampling = !self.upsamplingCheckbox.state;
    [RFAudioPlayer sharedInstance].upsampling = settings.upsampling;
    [[RFAudioPlayer sharedInstance] setManagedOutputSampleRatePopup:self.sampleRatePopup];
}

- (IBAction)showEffectWindowAction:(id)sender
{
    NSButton *button = (NSButton *)sender;
    NSPopUpButton *popupButton = nil;
    switch (button.tag) {
        case 1:
            popupButton = self.audioFilter1Popup;
            break;
            
        case 2:
            popupButton = self.audioFilter2Popup;
            break;
            
        default:
        case 3:
            popupButton = self.audioFilter3Popup;
            break;
    }
    
    NSWindow *unitWindow = [[RFAudioPlayer sharedInstance] windowForEffectFilter:popupButton.selectedItem.title];
    [unitWindow makeKeyAndOrderFront:nil];
}

@end
