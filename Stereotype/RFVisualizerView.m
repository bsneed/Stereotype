//
//  RFVisualizerView.m
//  frequence
//
//  Created by Brandon Sneed on 12/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RFVisualizerView.h"
#import "RFAppDelegate.h"
#import <AudioLibrary/AFLibrary.h>

@implementation RFVisualizerRenderer

//- (id)initWithCGLContext:(CGLContextObj)context pixelFormat:(CGLPixelFormatObj)format colorSpace:(CGColorSpaceRef)colorSpace composition:(QCComposition *)composition
- (id)initWithOpenGLContext:(NSOpenGLContext *)context pixelFormat:(NSOpenGLPixelFormat *)format file:(NSString *)path
{
    //self = [super initWithCGLContext:context pixelFormat:format colorSpace:colorSpace composition:composition];
    self = [super initWithOpenGLContext:context pixelFormat:format file:path];
    
    buffers = (float *)malloc(EXTAUDIOBUFFERSIZE * sizeof(float));
    
    input = [[NSMutableDictionary alloc] init];
    
    ln = log2f(EXTAUDIOBUFFERSIZE);
    fftSetup = vDSP_create_fftsetup(ln, FFT_RADIX2);
    
    no2 = EXTAUDIOBUFFERSIZE / 2;
    
    A.realp = (float *)malloc(no2 * sizeof(float));
    A.imagp = (float *)malloc(no2 * sizeof(float));
    
    return self;
}

- (void)dealloc
{
    vDSP_destroy_fftsetup(fftSetup);
    free(A.realp);
    free(A.imagp);
    
    free(buffers);
    
    input = nil;
}

- (oneway void)setBuffers:(float **)aBuffer numberOfBuffers:(int)count samples:(int)sampleCount
{
    if (!buffers || !aBuffer || !sampleCount)
        return;
    
    memcpy(buffers, aBuffer[0], EXTAUDIOBUFFERSIZE * sizeof(float));
    numberOfBuffers = count;
    samples = sampleCount;
    
    //[self performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:NO];
}

float shiftSample(float sample)
{
    float result = (0.7 * sample) / 100;
    return result;
}

- (BOOL) renderAtTime:(NSTimeInterval)time arguments:(NSDictionary*)arguments
//- (void)update
{
    //BOOL success = NO;
    //if (!buffers || samples == 0 || time == 0)
    //    return YES;//[super renderAtTime:time arguments:arguments];
    
    float trackPosition = [[RFAppDelegate sharedInstance] elapsedTime];
    float peak = 0;
    
    if (buffers && samples && (trackPosition != lastTrackPosition))
    {
        vDSP_ctoz((COMPLEX*)buffers, 2, &A, 1, no2);
        vDSP_fft_zrip(fftSetup, &A, 1, ln, FFT_FORWARD);
        
        float *output = (float *)malloc(no2 * sizeof(float));
        vDSP_zvabs(&A, 1, output, 1, no2);
        
        //float scale = 0.006f;
        //vDSP_vsmul(output, 1, &scale, output, 1, no2);
        
        for (int i = 0; i < 16; i++)
        {
            float sample = shiftSample(output[i]);//averagedSamples(&output[i], width);
            if (sample > 0.7)
                sample = 0.7;
            if (sample > peak)
                peak = sample;
            [input setObject:[NSNumber numberWithFloat:sample] forKey:[NSString stringWithFormat:@"%u", i]];
        }
        
        free(output);
        
        [self setValue:input forInputKey:@"_protocolInput_AudioSpectrum"];
        [self setValue:[NSNumber numberWithFloat:peak] forInputKey:@"_protocolInput_AudioPeak"];
        [self setValue:[NSNumber numberWithBool:YES] forInputKey:@"_protocolInput_TrackSignal"];
        [self setValue:[NSNumber numberWithDouble:trackPosition] forInputKey:@"_protocolInput_TrackPosition"];
    }
    else
    {
        [input removeAllObjects];
        [self setValue:input forInputKey:@"_protocolInput_AudioSpectrum"];
        [self setValue:[NSNumber numberWithFloat:0] forInputKey:@"_protocolInput_AudioPeak"];
        [self setValue:[NSNumber numberWithBool:NO] forInputKey:@"_protocolInput_TrackSignal"];
        [self setValue:[NSNumber numberWithDouble:trackPosition] forInputKey:@"_protocolInput_TrackPosition"];
    }
    
    lastTrackPosition = trackPosition;
        
    return [super renderAtTime:time arguments:arguments];
}

@end

@implementation RFVisualizerView
{
    NSTimer *updateTimer;
    NSTimeInterval currentTime;
}

- (id)initWithFrame:(NSRect)frameRect
{
    //NSOpenGLPixelFormatAttribute	attributes[] = {NSOpenGLPFAAccelerated, NSOpenGLPFANoRecovery, NSOpenGLPFADoubleBuffer, NSOpenGLPFADepthSize, 24, 0};

    self = [super initWithFrame:frameRect];// pixelFormat:[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes]];
    
    //[self setWantsLayer:YES];
    return self;
}

- (void)viewDidMoveToWindow
{
    [self performBlock:^{
        NSOpenGLPixelFormatAttribute attributes[] =
        {
            //NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
            NSOpenGLPFAColorSize    , 24                           ,
            //NSOpenGLPFAAlphaSize    , 8                            ,
            NSOpenGLPFADoubleBuffer ,
            NSOpenGLPFAAccelerated  ,
            NSOpenGLPFANoRecovery   ,
            0
        };
        GLint							swapInterval = 1;
        
        //Create the OpenGL context used to render the animation and attach it to the rendering view
        mainPixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
        mainGLContext = [[NSOpenGLContext alloc] initWithFormat:mainPixelFormat shareContext:nil];
        [mainGLContext setValues:&swapInterval forParameter:NSOpenGLCPSwapInterval];
        [mainGLContext setView:self];
        //mainGLContext setView:self];
        
        updateTimer = [NSTimer timerWithTimeInterval:0.0333 target:self selector:@selector(updateForTimer) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:updateTimer forMode:NSRunLoopCommonModes];
        
        [mainGLContext makeCurrentContext];
        [mainGLContext update];
        
        NSString *vizPath = [[NSBundle mainBundle] pathForResource:@"wowlab_Snow" ofType:@"qtz"];
        renderer = [[RFVisualizerRenderer alloc] initWithOpenGLContext:mainGLContext pixelFormat:mainPixelFormat file:vizPath];
    } afterDelay:1.0];
}

/*- (id)initWithFrame:(NSRect)frame
{
    if (self = [super initWithFrame:frame]) {
        NSOpenGLPixelFormatAttribute pixelFormatAttributes[] = {
            NSOpenGLPFADepthSize, 32,
            0
        };
        NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:pixelFormatAttributes];
        
        [self setOpenGLContext:[[NSOpenGLContext alloc] initWithFormat:format shareContext:nil]];
        [self setPixelFormat:format];
        
        mainGLContext = self.openGLContext;

        updateTimer = [NSTimer timerWithTimeInterval:0.0333 target:self selector:@selector(updateForTimer) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:updateTimer forMode:NSRunLoopCommonModes];
    }
    
    //if (self = [super initWithFrame:frame pixelFormat:pixelFormat])
    {
        //[self prepareOpenGL];
        
        //mainGLContext = self.openGLContext;
        //mainPixelFormat = self.pixelFormat;

    }
    
    //[pixelFormat release];
    return self;
}*/

- (void)dealloc
{
    [updateTimer invalidate];
    updateTimer = nil;
}

- (void)updateForTimer
{
    if (renderer)
    {
        //if (mainGLContext.view != self)
        //    [mainGLContext setView:self];
     
        //[mainGLContext update];

        //if (mainGLContext.view == self)
        {
            //[mainGLContext makeCurrentContext];
            //glClearColor(1.0, 1.0, 0.0, 0.0);
            //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            
            //glViewport(0, 0, self.frame.size.width, self.frame.size.height);
            //Clear background
            glClearColor(0.25, 0.25, 0.25, 0.25);
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

            [renderer renderAtTime:currentTime arguments:nil];
            
            //glFlushRenderAPPLE();
            
            [mainGLContext flushBuffer];
            currentTime += 0.0333;
            
            //[NSOpenGLContext clearCurrentContext];
            
            //[self setNeedsDisplay:YES];
            //[self update];
        }
    }
}

/*- (void)drawRect: (NSRect) bounds
{
    //[mainGLContext makeCurrentContext];
    //glClearColor(1.0, 1.0, 0.0, 0.0);
    //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [renderer renderAtTime:currentTime arguments:nil];
    [mainGLContext flushBuffer];
    currentTime += 0.0333;
    
    //[NSOpenGLContext clearCurrentContext];
}*/

- (void)setBuffers:(float **)aBuffer numberOfBuffers:(int)count samples:(int)sampleCount
{
    if (renderer)
        [renderer setBuffers:aBuffer numberOfBuffers:count samples:sampleCount];
}

- (void)setCompositionFile:(NSString *)filePath
{
    if (!filePath)
        renderer = nil;
    //[self prepareOpenGL];
    //[mainGLContext setView:self];

    //renderer = [[RFVisualizerRenderer alloc] initWithOpenGLContext:mainGLContext pixelFormat:mainPixelFormat file:filePath];
    
    //[self loadCompositionFromFile:filePath];
    //[self startRendering];
    
    /*[self stopRendering];
    [self loadCompositionFromFile:filePath];
    self.maxRenderingFrameRate = 30.0;
    [self startRendering];*/
    
    /*[compositionLayer removeFromSuperlayer];
     compositionLayer = [QCCompositionLayer compositionLayerWithFile:filePath];
     
     CGRect frame = self.layer.bounds;
     //frame.size.width = frame.size.width * 2;
     //frame.size.height = frame.size.height * 2;
     compositionLayer.frame = frame;
     //compositionLayer.contentsScale = 4;
     compositionLayer.masksToBounds = YES;
     //[self.layer addSublayer:compositionLayer];
     [self setLayer:compositionLayer];
     [self setWantsLayer:YES];*/
}

@end
