//
//  RFVisualizerView.m
//  frequence
//
//  Created by Brandon Sneed on 12/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RFVisualizerView.h"
#import <AudioLibrary/AFLibrary.h>
#import "SimpleSpectrumProcessor.h"

@implementation RFVisualizer
{
    SimpleSpectrumProcessor* spectrumProcessor;
}

- (id)initOffScreenWithSize:(NSSize)size colorSpace:(CGColorSpaceRef)colorSpace composition:(QCComposition *)composition
{
	self = [super initOffScreenWithSize:size colorSpace:colorSpace composition:composition];
	
    unsigned long bufferSize = (EXTAUDIOBUFFERSIZE * sizeof(float));
    buffers = (float *)malloc(bufferSize);
    memset(buffers, 0, bufferSize);
    
    window = (float *)malloc(EXTAUDIOBUFFERSIZE * sizeof(float));
    
	output = (float*)malloc(EXTAUDIOBUFFERSIZE *sizeof(float));
	log2n = log2f(EXTAUDIOBUFFERSIZE);
	n = 1 << log2n;
	assert(n == EXTAUDIOBUFFERSIZE);
	nOver2 = EXTAUDIOBUFFERSIZE/2;
	bufferCapacity = EXTAUDIOBUFFERSIZE;
	index = 0;
	A.realp = (float *)malloc(nOver2 * sizeof(float));
	A.imagp = (float *)malloc(nOver2 * sizeof(float));
	fftSetup = vDSP_create_fftsetup(log2n, FFT_RADIX2);

    //updateTimer = [NSTimer timerWithTimeInterval:0.02 target:self selector:@selector(updateVisualizer) userInfo:nil repeats:YES];
    //[[NSRunLoop currentRunLoop] addTimer:updateTimer forMode:NSRunLoopCommonModes];

    input = [[NSMutableDictionary alloc] init];
    
    spectrumProcessor = new SimpleSpectrumProcessor::SimpleSpectrumProcessor();
    spectrumProcessor->Allocate(2, EXTAUDIOBUFFERSIZE * sizeof(float));
    
    
	return self;
}

- (void)dealloc
{
    [updateTimer invalidate];
    updateTimer = nil;
 
    vDSP_destroy_fftsetup(fftSetup);
    free(A.realp);
    free(A.imagp);

    free(buffers);
    free(output);
    free(window);
    
    input = nil;
}

- (void)updateVisualizer
{
    if (!self.enabled)
        return;
    
    [self renderAtTime:currentTime arguments:nil];
	currentTime += 0.02;
}

- (oneway void)setBuffers:(float **)aBuffer numberOfBuffers:(int)count samples:(int)sampleCount
{
    if (!buffers || !aBuffer || !sampleCount)
        return;
    
    AudioBufferList *bufferList = (AudioBufferList *)malloc((sizeof(AudioBufferList) * count) + ((sizeof(float) * sampleCount) * count));
    bufferList->mNumberBuffers = count;
    bufferList->mBuffers[0].mData = aBuffer[0];
    bufferList->mBuffers[0].mDataByteSize = sizeof(float) * sampleCount;
    bufferList->mBuffers[0].mNumberChannels = 1;
    bufferList->mBuffers[1].mData = aBuffer[1];
    bufferList->mBuffers[1].mDataByteSize = sizeof(float) * sampleCount;
    bufferList->mBuffers[1].mNumberChannels = 1;
    
    spectrumProcessor->CopyInputToRingBuffer(sampleCount, bufferList);
    
    free(bufferList);
    
    //memcpy(buffers, aBuffer[0], sampleCount * sizeof(float));
    //numberOfBuffers = count;
    //samples = sampleCount;
}

float averagedSamples(float *samples, int width)
{
    float avg = 0;
    for (int i = 0; i < width; i++)
        avg += samples[i];
    return avg / width;
}

- (BOOL) renderAtTime:(NSTimeInterval)time arguments:(NSDictionary*)arguments
{
    static OSStatus	AudioUnitRenderCallback (void *inRefCon,
											 AudioUnitRenderActionFlags *ioActionFlags,
											 const AudioTimeStamp *inTimeStamp,
											 UInt32 inBusNumber,
											 UInt32 inNumberFrames,
											 AudioBufferList *ioData) {
        
		OSStatus err = AudioUnitRender(audioUnitWrapper->audioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
        
		if(err != 0) NSLog(@"AudioUnitRender status is %d", err);
		// These values should be in a more conventional location for a bunch of preprocessor defines in your real code
#define DBOFFSET -74.0
		// DBOFFSET is An offset that will be used to normalize the decibels to a maximum of zero.
		// This is an estimate, you can do your own or construct an experiment to find the right value
#define LOWPASSFILTERTIMESLICE .001
		// LOWPASSFILTERTIMESLICE is part of the low pass filter and should be a small positive value
        
		SInt16* samples = (SInt16*)(ioData->mBuffers[0].mData); // Step 1: get an array of your samples that you can loop through. Each sample contains the amplitude.
        
		Float32 decibels = DBOFFSET; // When we have no signal we'll leave this on the lowest setting
		Float32 currentFilteredValueOfSampleAmplitude, previousFilteredValueOfSampleAmplitude; // We'll need these in the low-pass filter
		Float32 peakValue = DBOFFSET; // We'll end up storing the peak value here
        
		for (int i=0; i < inNumberFrames; i++) {
            
			Float32 absoluteValueOfSampleAmplitude = abs(samples[i]); //Step 2: for each sample, get its amplitude's absolute value.
            
			// Step 3: for each sample's absolute value, run it through a simple low-pass filter
			// Begin low-pass filter
			currentFilteredValueOfSampleAmplitude = LOWPASSFILTERTIMESLICE * absoluteValueOfSampleAmplitude + (1.0 - LOWPASSFILTERTIMESLICE) * previousFilteredValueOfSampleAmplitude;
			previousFilteredValueOfSampleAmplitude = currentFilteredValueOfSampleAmplitude;
			Float32 amplitudeToConvertToDB = currentFilteredValueOfSampleAmplitude;
			// End low-pass filter
            
			Float32 sampleDB = 20.0*log10(amplitudeToConvertToDB) + DBOFFSET;
			// Step 4: for each sample's filtered absolute value, convert it into decibels
			// Step 5: for each sample's filtered absolute value in decibels, add an offset value that normalizes the clipping point of the device to zero.
            
			if((sampleDB == sampleDB) && (sampleDB = -DBL_MAX)) { // if it's a rational number and isn't infinite
                
				if(sampleDB > peakValue) peakValue = sampleDB; // Step 6: keep the highest value you find.
				decibels = peakValue; // final value
			}
		}
        
		NSLog(@"decibel level is %f", decibels);
        
		for (UInt32 i=0; i < ioData->mNumberBuffers; i++) { // This is only if you need to silence the output of the audio unit
			memset(ioData->mBuffers[i].mData, 0, ioData->mBuffers[i].mDataByteSize); // Delete if you need audio output as well as input
		}
        
		return err;
	}
}
    /*BOOL success = NO;
    if (!buffers || samples == 0 || time == 0)
        return YES;//[super renderAtTime:time arguments:arguments];
    
    vDSP_hann_window(window, n, vDSP_HANN_NORM);
    vDSP_vmul(buffers, 1, window, 1, buffers, 1, n);
    
    vDSP_ctoz((COMPLEX*)buffers, 2, &A, 1, nOver2);
    vDSP_fft_zrip(fftSetup, &A, 1, log2n, FFT_FORWARD);
    vDSP_ztoc(&A, 1, (COMPLEX*)output, 2, nOver2);
    
    //vDSP_zvabs(&A, 1, output, 1, nOver2);
    //float scale = 0.001;//0.002f;
    //vDSP_vsmul(output, 1, &scale, output, 1, nOver2);
    
    //float dominantFrequency = 0;
    //int bin = -1;
    int width = samples / 16;
    int inputIndex = 0;
    for (int i=0; i<n; i += width)
    {
        float output1 = averagedSamples(&output[i], width);
        //output1 = 1.0;
        //float output2 = averagedSamples(&output[i + width], width);
        float curFreq = output1 * output1;//MagnitudeSquared(output1, output2);
        
        [input setObject:[NSNumber numberWithFloat:curFreq] forKey:[NSString stringWithFormat:@"%u", inputIndex]];
        inputIndex++;
        /*if (curFreq > dominantFrequency) {
            dominantFrequency = curFreq;
            bin = (i+1)/2;
            //if (bin > maxBin)
            //    maxBin = bin;
            maxBin = i % 16;
            NSLog(@"maxBin = %i", maxBin);
        }
    }
    
    /*float peak = 0;
    
    for (int i = 0; i < n; i+=width)
    {
        if (i < n)
        {
            float sample = output[i];
            if (sample > 1.0)
                sample = 1.0;
            if (sample > peak)
                peak = sample;
            [input setObject:[NSNumber numberWithFloat:sample] forKey:[NSString stringWithFormat:@"%u", i]];
        }
    }
    
    memset(output, 0, n*sizeof(SInt16));*/
    
    BOOL success = YES;
    
    uint32_t fftsize = (EXTAUDIOBUFFERSIZE * sizeof(float));
    if (spectrumProcessor->TryFFT(fftsize))
    {
        float *result = (float *)malloc(fftsize);
        memset(result, 0, fftsize);
        spectrumProcessor->GetMagnitudes(result, SimpleSpectrumProcessor::Rectangular);
    
        int width = samples / 16;
        int inputIndex = 0;
        for (int i=0; i<n; i += width)
        {
            float output1 = averagedSamples(&result[i], width);
            [input setObject:[NSNumber numberWithFloat:output1] forKey:[NSString stringWithFormat:@"%u", inputIndex]];
            inputIndex++;
        }

        free(result);

        uint32_t binCount =  fftsize >> 1;
        NSLog(@"bin count = %u", binCount);
        
        [self setValue:input forInputKey:@"_protocolInput_AudioSpectrum"];
        //[self setValue:[NSNumber numberWithFloat:peak] forInputKey:@"_protocolInput_AudioPeak"];
        success = [super renderAtTime:time arguments:arguments];
        input = nil;
        
        [self performSelectorOnMainThread:@selector(performUpdate) withObject:nil waitUntilDone:NO];
    }
    
	return success;
}

- (void)setViewToUpdate:(RFPlayerView *)value
{
    _viewToUpdate = value;
    if (_viewToUpdate)
    {
        updateTimer = [NSTimer timerWithTimeInterval:0.02 target:self selector:@selector(updateVisualizer) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:updateTimer forMode:NSRunLoopCommonModes];
    }
    else
    {
        [updateTimer invalidate];
        updateTimer = nil;
    }
}

- (void)performUpdate
{
	if (currentTime >= lastRenderTime + 0.02)
	{
        lastRenderTime = currentTime;
        NSImage *snapshot = [self snapshotImage];
        self.viewToUpdate.albumArtImage = snapshot;
        snapshot = nil;
	}
}

@end
