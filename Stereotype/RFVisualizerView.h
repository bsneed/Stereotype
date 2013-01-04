//
//  RFVisualizerView.h
//  frequence
//
//  Created by Brandon Sneed on 12/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Accelerate/Accelerate.h>
//#import "RFPlayerView.h"

@interface RFVisualizerRenderer : QCRenderer
{
    float ln;
    float no2;
    FFTSetup fftSetup;
    DSPSplitComplex A;
    
	float *buffers;
	int numberOfBuffers;
	int samples;
    size_t bufferSize;
    
    NSMutableDictionary *input;
    
    float lastTrackPosition;
}

- (void)setBuffers:(float **)aBuffer numberOfBuffers:(int)count samples:(int)sampleCount;

@end


@interface RFVisualizerView : NSView
{
    RFVisualizerRenderer *renderer;
    NSOpenGLContext *mainGLContext;
    NSOpenGLPixelFormat *mainPixelFormat;
}

- (void)setBuffers:(float **)aBuffer numberOfBuffers:(int)count samples:(int)sampleCount;
- (void)setCompositionFile:(NSString *)filePath;

@end
