//
//  OGLViewController.m
//  TriangleMan
//
//  Created by binaryinsomnia on 11/28/11.
//  Copyright (c) 2011 binaryinsomnia. All rights reserved.
//

#import "RFCompositionView.h"
#import "NSImage+QuickLook.h"
#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <Accelerate/Accelerate.h>

#import "RFAppDelegate.h"

#define COMPOSITION_UPDATEINTERVAL 0.04//0.0333
#define EXTAUDIOBUFFERSIZE 600

@interface RFCompositionView()
{
    GLuint positionAttribute;
    GLuint colorAttribute;
    QCRenderer *renderer;
    NSTimer *timer;
    NSTimeInterval currentTime;
    GLint currentVirtualScreen;
    
    float ln;
    float no2;
    FFTSetup fftSetup;
    DSPSplitComplex A;
    
	float *buffers[2];
    float *output[2];
	NSInteger numberOfBuffers;
	NSInteger samples;
    size_t bufferSize;
    
    NSMutableDictionary *input;
    NSDictionary *nextTrackInfo;
    
    float lastTrackPosition;
    
    NSArray *binNames;
}
@end

@implementation RFCompositionView

- (id)initWithFrame:(NSRect)frameRect
{
    NSOpenGLPixelFormatAttribute attributes[] =
    {
        NSOpenGLPFAColorSize, 32,
        NSOpenGLPFAAlphaSize, 8,
        NSOpenGLPFADepthSize, 32,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAAccelerated,
        0
        //NSOpenGLPFAAllRenderers,
        //0
    };
    
    NSOpenGLPixelFormat *pixFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
    self = [super initWithFrame:frameRect pixelFormat:pixFormat];
    
    [self setWantsBestResolutionOpenGLSurface:NO];
    currentTime = 0;
    
    // setup stuff for our FFT.
    buffers[0] = (float *)malloc(EXTAUDIOBUFFERSIZE * sizeof(float));
    buffers[1] = (float *)malloc(EXTAUDIOBUFFERSIZE * sizeof(float));
    input = [[NSMutableDictionary alloc] init];
    ln = log2f(EXTAUDIOBUFFERSIZE);
    fftSetup = vDSP_create_fftsetup(ln, FFT_RADIX2);
    no2 = EXTAUDIOBUFFERSIZE / 2;
    
    output[0] = (float *)malloc(no2 * sizeof(float));
    output[1] = (float *)malloc(no2 * sizeof(float));
    A.realp = (float *)malloc(no2 * sizeof(float));
    A.imagp = (float *)malloc(no2 * sizeof(float));
    
    memset(buffers[0], 0, EXTAUDIOBUFFERSIZE * sizeof(float));
    memset(output[0], 0, sizeof(float) * no2);
    memset(buffers[1], 0, EXTAUDIOBUFFERSIZE * sizeof(float));
    memset(output[1], 0, sizeof(float) * no2);
    memset(A.realp, 0, sizeof(float) * no2);
    memset(A.imagp, 0, sizeof(float) * no2);
    
    binNames = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15"];
    for (int i = 0; i < 16; i++)
        [input setObject:[NSNumber numberWithFloat:0] forKey:[binNames objectAtIndex:i]];
    
    return self;
}

- (void)dealloc
{
    _enabled = NO;
    [timer invalidate];
    timer = nil;
    renderer = nil;
    
    vDSP_destroy_fftsetup(fftSetup);
    free(A.realp);
    free(A.imagp);
    
    free(buffers[0]);
    free(buffers[1]);
    free(output[0]);
    free(output[1]);
    
    input = nil;
}

- (void)prepareOpenGL
{
    // Synchronize buffer swaps with vertical refresh rate
    GLint swapInt = 1;
    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
    
    // controls whether its opaque or not
    GLint opaque = 1;
    [[self openGLContext] setValues:&opaque forParameter:NSOpenGLCPSurfaceOpacity];
    
    // can we see through it?
    GLint opacity = 1;
    [[self openGLContext] setValues:&opacity forParameter:NSOpenGLCPSurfaceOpacity];
}

- (void)loadCompositionAtPath:(NSString *)compositionPath
{
    renderer = nil;
    if (compositionPath)
        renderer = [[QCRenderer alloc] initWithOpenGLContext:[self openGLContext] pixelFormat:self.pixelFormat file:compositionPath];
}

- (void)viewDidMoveToWindow
{
    [self prepareOpenGL];
    timer = [NSTimer timerWithTimeInterval:COMPOSITION_UPDATEINTERVAL target:self selector:@selector(updateDisplay) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode];
}

- (void)updateDisplay
{
    if (renderer)
    {
        [self updateInput];
        [self setNeedsDisplay:YES];
    }
    currentTime += COMPOSITION_UPDATEINTERVAL;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (!renderer)
        return;
    
    [self update];
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);

    //@synchronized(self)
    {
        [renderer renderAtTime:currentTime arguments:nil];
    }
    
    [[self openGLContext] flushBuffer];
}

- (void)setTrackInfo:(NSDictionary *)trackInfo
{
    _trackInfo = nil;
    nextTrackInfo = trackInfo;
    [self setNeedsDisplay:YES];
}

- (oneway void)setBuffers:(float **)aBuffer numberOfBuffers:(NSInteger)count samples:(NSInteger)sampleCount
{
    if (!buffers || !aBuffer || !sampleCount || count < 2)
        return;
    
    @synchronized(self)
    {
        if (sampleCount > EXTAUDIOBUFFERSIZE)
            sampleCount = EXTAUDIOBUFFERSIZE;
        A_memcpy(buffers[0], aBuffer[0], sampleCount * sizeof(float));
        A_memcpy(buffers[1], aBuffer[1], sampleCount * sizeof(float));
        numberOfBuffers = count;
        samples = sampleCount;
    }
}

float shiftSample(float sample)
{
    //float result = (0.7 * sample) / 100;
    float result = sample / 100;
    return result;
}

float averageSamples(float sample0, float sample1)
{
    float result = (sample0 + sample1) / 2;
    return result;
}

- (void)updateInput
{
    if (!renderer)
        return;
    
    // don't want the data changed out from under us in another thread.
    @synchronized(self)
    {        
        float trackPosition = [[RFAppDelegate sharedInstance] elapsedTime];
        float peak = 0;
        
        //if (buffers && samples && self.enabled && _trackInfo)
        if (self.enabled && _trackInfo)
        {
            // left channel
            vDSP_ctoz((COMPLEX*)buffers[0], 2, &A, 1, no2);
            vDSP_fft_zrip(fftSetup, &A, 1, ln, FFT_FORWARD);
            
            vDSP_zvabs(&A, 1, output[0], 1, no2);
            
            // right channel
            vDSP_ctoz((COMPLEX*)buffers[1], 2, &A, 1, no2);
            vDSP_fft_zrip(fftSetup, &A, 1, ln, FFT_FORWARD);
            
            vDSP_zvabs(&A, 1, output[1], 1, no2);
            
            for (int i = 0; i < 16; i++)
            {
                float leftSample = output[0][i];
                float rightSample = output[1][i];
                
                float sample = shiftSample(MAX(leftSample, rightSample));
                //if (sample > 0.7)
                //    sample = 0.7;
                if (sample > peak)
                    peak = sample;
                [input setObject:[NSNumber numberWithFloat:sample] forKey:[binNames objectAtIndex:i]];
            }
            
            [renderer setValue:input forInputKey:QCCompositionInputAudioSpectrumKey];
            [renderer setValue:[NSNumber numberWithFloat:peak] forInputKey:QCCompositionInputAudioPeakKey];
            [renderer setValue:[NSNumber numberWithBool:YES] forInputKey:QCCompositionInputTrackSignalKey];
            [renderer setValue:[NSNumber numberWithDouble:trackPosition] forInputKey:QCCompositionInputTrackPositionKey];
            [renderer setValue:_trackInfo forInputKey:QCCompositionInputTrackInfoKey];
        }
        else
        {
            [renderer setValue:input forInputKey:QCCompositionInputAudioSpectrumKey];
            [renderer setValue:[NSNumber numberWithFloat:0.1] forInputKey:QCCompositionInputAudioPeakKey];
            [renderer setValue:[NSNumber numberWithBool:NO] forInputKey:QCCompositionInputTrackSignalKey];
            [renderer setValue:[NSNumber numberWithDouble:trackPosition] forInputKey:QCCompositionInputTrackPositionKey];
            [renderer setValue:nil forInputKey:QCCompositionInputTrackInfoKey];
        }

        lastTrackPosition = trackPosition;
    }
    
    _trackInfo = nextTrackInfo;
}

@end
