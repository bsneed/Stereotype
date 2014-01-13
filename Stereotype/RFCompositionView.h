//
//  OGLViewController.h
//  TriangleMan
//
//  Created by binaryinsomnia on 11/28/11.
//  Copyright (c) 2011 binaryinsomnia. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RFAudioPlayer.h"

@interface RFCompositionView : NSOpenGLView

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong) NSDictionary *trackInfo;

- (void)loadCompositionAtPath:(NSString *)compositionPath;

@end
