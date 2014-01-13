//
//  OGLViewController.m
//  TriangleMan
//
//  Created by binaryinsomnia on 11/28/11.
//  Copyright (c) 2011 binaryinsomnia. All rights reserved.
//

#import "RFCompositionView.h"
#import "NSImage+QuickLook.h"
#import "RFSpectrumAnalyzer.h"
#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

#import "RFAppDelegate.h"

#define COMPOSITION_UPDATEINTERVAL 0.04//0.0333
#define EXTAUDIOBUFFERSIZE 512

@interface RFCompositionView()
{
    GLuint positionAttribute;
    GLuint colorAttribute;
    QCRenderer *renderer;
    NSTimer *timer;
    NSTimeInterval currentTime;
    GLint currentVirtualScreen;
    
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
    
    input = [NSMutableDictionary dictionary];
    binNames = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15"];
    
    for (int i = 0; i < 16; i++)
        [input setObject:[NSNumber numberWithFloat:0] forKey:[binNames objectAtIndex:i]];
    
    self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [[self superview] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    return self;
}

- (void)dealloc
{
    _enabled = NO;
    [timer invalidate];
    timer = nil;
    renderer = nil;
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
        //self.bounds = self.superview.bounds;
        //self.frame = self.superview.frame;
        [self updateInput];
        [self setNeedsDisplay:YES];
    }
    currentTime += COMPOSITION_UPDATEINTERVAL;
}

/*- (void)reshape
{
    [super setNeedsDisplay:YES];
    [[self openGLContext] update];
    NSLog(@"reshap function called");
}*/

- (void)drawRect:(NSRect)dirtyRect
{
    if (!renderer)
        return;
    
    [self update];
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);

    [renderer renderAtTime:currentTime arguments:nil];
    
    [[self openGLContext] flushBuffer];
}

- (void)setTrackInfo:(NSDictionary *)trackInfo
{
    _trackInfo = nil;
    nextTrackInfo = trackInfo;
    [self setNeedsDisplay:YES];
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
        
        if (self.enabled && _trackInfo)
        {
            RFSpectrumAnalyzer *analyzer = [RFSpectrumAnalyzer sharedInstance];
            const float *bandLevels = analyzer.bandLevels;

            for (int i = 0; i < 16; i++)
            {
                float sample = bandLevels[i];

                if (sample > peak)
                    peak = sample;
                [input setObject:[NSNumber numberWithFloat:sample] forKey:[binNames objectAtIndex:i]];
            }
            
            [renderer setValue:input forInputKey:QCCompositionInputAudioSpectrumKey];
            [renderer setValue:[NSNumber numberWithFloat:peak] forInputKey:QCCompositionInputAudioPeakKey];
            [renderer setValue:[NSNumber numberWithBool:YES] forInputKey:QCCompositionInputTrackSignalKey];
            [renderer setValue:[NSNumber numberWithDouble:trackPosition] forInputKey:QCCompositionInputTrackPositionKey];
            [renderer setValue:_trackInfo forInputKey:QCCompositionInputTrackInfoKey];
            
            //free(bandLevels);
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
