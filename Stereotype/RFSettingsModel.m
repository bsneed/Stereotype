//
//  RFSettingsModel.m
//  Stereotype
//
//  Created by brandon on 10/27/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFSettingsModel.h"

@implementation RFSettingsModel

/*@property (nonatomic, assign) RFInputType inputType;
@property (nonatomic, strong) NSString *preferredDevice;
@property (nonatomic, assign) BOOL useVisualizer;
@property (nonatomic, strong) NSArray *equalizerValues;
@property (nonatomic, strong) NSArray *activePlaylist;
@property (nonatomic, assign) NSUInteger activePlaylistIndex;
@property (nonatomic, assign) float volume;*/

static RFSettingsModel *_settingsModel = nil;

+ (void)initialize
{
    NSDictionary *appDefaults = @{ @"volumeLevel": @1,
                                   @"activeDrawerIndex": @0 };
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
}

+ (RFSettingsModel *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _settingsModel = [[RFSettingsModel alloc] init];
    });
    return _settingsModel;
}

+ (void)save
{
    // save shit.
    [_settingsModel save];
}

- (id)init
{
    self = [super init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.useVisualizer = [defaults boolForKey:@"useVisualizer"];
    self.preferredSampleRate = [defaults floatForKey:@"preferredSampleRate"];
    self.exclusiveMode = [defaults boolForKey:@"exclusiveMode"];
    self.upsampling = [defaults boolForKey:@"upsampling"];
    self.preferredDevice = [defaults stringForKey:@"preferredDevice"];
    self.equalizerValues = [defaults arrayForKey:@"equalizerValues"];
    self.urlQueue = [defaults arrayForKey:@"urlQueue"];
    self.urlQueueIndex = [defaults integerForKey:@"urlQueueIndex"];
    self.volume = [defaults floatForKey:@"volumeLevel"];
    self.activeDrawer = [defaults integerForKey:@"activeDrawerIndex"];
    self.filterNames = [defaults arrayForKey:@"filterNames"];
    self.libraryViewStyle = [defaults integerForKey:@"libraryViewStyle"];
    self.shuffleMode = [defaults integerForKey:@"shuffleMode"];
    self.repeatMode = [defaults integerForKey:@"repeatMode"];
    
    if (!self.filterNames)
        self.filterNames = @[@"None", @"None", @"None"];
    
    if ([self.filterNames count] < 3)
    {
        NSMutableArray *newFilterNames = [self.filterNames mutableCopy];
        while ([newFilterNames count] < 3)
            [newFilterNames addObject:@"None"];
        self.filterNames = newFilterNames;
    }
    
    return self;
}

- (void)save
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setBool:self.useVisualizer forKey:@"useVisualizer"];
    [defaults setBool:self.exclusiveMode forKey:@"exclusiveMode"];
    [defaults setBool:self.upsampling forKey:@"upsampling"];
    [defaults setObject:self.preferredDevice forKey:@"preferredDevice"];
    [defaults setObject:self.equalizerValues forKey:@"equalizerValues"];
    [defaults setObject:self.urlQueue forKey:@"urlQueue"];
    [defaults setInteger:self.urlQueueIndex forKey:@"urlQueueIndex"];
    [defaults setFloat:self.volume forKey:@"volumeLevel"];
    [defaults setFloat:self.preferredSampleRate forKey:@"preferredSampleRate"];
    [defaults setInteger:self.activeDrawer forKey:@"activeDrawerIndex"];
    [defaults setObject:self.filterNames forKey:@"filterNames"];
    [defaults setInteger:self.libraryViewStyle forKey:@"libraryViewStyle"];
    [defaults setInteger:self.shuffleMode forKey:@"shuffleMode"];
    [defaults setInteger:self.repeatMode forKey:@"repeatMode"];
    
    [defaults synchronize];
}

@end
