//
//  RFSettingsModel.h
//  Stereotype
//
//  Created by brandon on 10/27/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RFDrawerClosedIndex -1

@interface RFSettingsModel : NSObject

@property (nonatomic, strong) NSString *preferredDevice;
@property (nonatomic, assign) float preferredSampleRate;
@property (nonatomic, assign) BOOL useVisualizer;
@property (nonatomic, assign) BOOL exclusiveMode;
@property (nonatomic, assign) BOOL upsampling;
@property (nonatomic, strong) NSArray *equalizerValues;
@property (nonatomic, strong) NSArray *urlQueue;
@property (nonatomic, assign) NSInteger urlQueueIndex;
@property (nonatomic, assign) float volume;
@property (nonatomic, assign) NSInteger activeDrawer;
@property (nonatomic, strong) NSArray *filterNames;
@property (nonatomic, assign) int libraryViewStyle;
@property (nonatomic, assign) BOOL shuffle;
@property (nonatomic, assign) int repeatMode;

+ (RFSettingsModel *)sharedInstance;
+ (void)save;
- (void)save;

@end
