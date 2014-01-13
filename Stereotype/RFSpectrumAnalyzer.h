// Realtime FFT spectrum and octave-band analysis.
// by Keijiro Takahashi, 2013
// https://github.com/keijiro/AudioSpectrum

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
#import <CoreAudio/CoreAudio.h>

@interface RFSpectrumAnalyzer : NSObject
{
@private
    // FFT data point number.
    NSUInteger _pointNumber;
    NSUInteger _logPointNumber;
    
    // Octave band type.
    NSUInteger _bandType;
    
    // FFT objects.
    FFTSetup _fftSetup;
    DSPSplitComplex _fftBuffer;
    Float32 *_inputBuffer;
    Float32 *_window;
    
    // Spectrum data.
    Float32 *_spectrum;
    Float32 *_bandLevels;
}

// Configuration.
@property (nonatomic, assign) NSUInteger pointNumber;
@property (nonatomic, assign) NSUInteger bandType;

// Spectrum data accessors.
@property (nonatomic, readonly) const Float32 *spectrum;
@property (nonatomic, readonly) const Float32 *bandLevels;

- (void)resetBuffers;

// Returns the number of the octave bands.
- (NSUInteger)countBands;

// Process the audio input.
- (void)processAudioInput:(AudioBufferList *)bufferList sampleRate:(Float32)sampleRate;

// Retrieve the shared instance.
+ (RFSpectrumAnalyzer *)sharedInstance;

@end
