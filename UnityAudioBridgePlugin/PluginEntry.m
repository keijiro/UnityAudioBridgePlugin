// Unity Audio Bridge Plug-in / the entry point
// By Keijiro Takahashi, 2013

#import "AudioInputBuffer.h"
#import "SpectrumAnalyzer.h"

// Managed-native shared object definition.
struct SharedObject
{
    int32_t fftPointNumber;
    int32_t bandType;
    float bandLevels[32];
};

static bool initialized;

int UnityAudioBridge_Update(struct SharedObject *shared)
{
    AudioInputBuffer *input = [AudioInputBuffer sharedInstance];
    SpectrumAnalyzer *analyzer = [SpectrumAnalyzer sharedInstance];
    
    // Initialize on the first invocation.
    if (!initialized) {
        [input start];
        initialized = true;
    }
    
    // If the parameters were changed, apply it.
    if (analyzer.pointNumber != shared->fftPointNumber) {
        analyzer.pointNumber = shared->fftPointNumber;
    }

    if (analyzer.bandType != shared->bandType) {
        analyzer.bandType = shared->bandType;
    }
    
    // Do FFT.
    [analyzer calculateWithAudioInputBuffer:input];
    
    // Copy the result to the shared object.
    const float *bandLevels = analyzer.bandLevels;
    NSUInteger bandCount = [analyzer countBands];
    NSUInteger i;
    for (i = 0; i <bandCount; i++) {
        shared->bandLevels[i] = bandLevels[i];
    }
    for (; i < 32; i++) {
        shared->bandLevels[i] = -1.0f;
    }
    
    return 0;
}
