//
//  RFSettingsViewController.h
//  Stereotype
//
//  Created by brandon on 10/26/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RFSettingsViewController : NSView

@property (weak) IBOutlet NSPopUpButton *outputDevicePopup;
@property (weak) IBOutlet NSPopUpButton *sampleRatePopup;
@property (weak) IBOutlet NSPopUpButton *formatPopup;
@property (weak) IBOutlet NSButton *preferredDeviceCheckbox;
@property (weak) IBOutlet NSButton *exclusiveModeCheckbox;
@property (weak) IBOutlet NSButton *upsamplingCheckbox;

@property (weak) IBOutlet NSPopUpButton *audioFilter1Popup;
@property (weak) IBOutlet NSPopUpButton *audioFilter2Popup;
@property (weak) IBOutlet NSPopUpButton *audioFilter3Popup;
@property (weak) IBOutlet NSButton *filter1WindowButton;
@property (weak) IBOutlet NSButton *filter2WindowButton;
@property (weak) IBOutlet NSButton *filter3WindowButton;

@property (weak) IBOutlet NSButton *visualizerCheckbox;

- (void)updateState;
- (void)refreshDisplay;

@end
