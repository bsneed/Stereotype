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
#import "RFPlayerView.h"

@interface RFVisualizer : QCRenderer
{
    FFTSetup fftSetup;
	COMPLEX_SPLIT A;
	int log2n, n, nOver2;
    size_t index;

	float *buffers;
    float *output;
    float *window;
    size_t bufferCapacity;
    int maxBin;
    
	int numberOfBuffers;
	int samples;
	NSTimeInterval currentTime;
	NSTimeInterval lastRenderTime;
    NSTimer *updateTimer;
    
    //SimpleSpectrumProcessor processor;
    
    NSMutableDictionary *input;
}

- (void)setBuffers:(float **)aBuffer numberOfBuffers:(int)count samples:(int)sampleCount;

@property (nonatomic, strong) RFPlayerView *viewToUpdate;
@property (nonatomic, assign) BOOL enabled;
@end
