/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A DSPKernel subclass implementing the realtime signal processing portion of the AUv3FilterDemo audio unit.
*/
#ifndef FilterDSPKernel_hpp
#define FilterDSPKernel_hpp

#import "DSPKernel.hpp"
#import <vector>

static inline float convertBadValuesToZero(float x) {
    /*
     Eliminate denormals, not-a-numbers, and infinities.
     Denormals will fail the first test (absx > 1e-15), infinities will fail
     the second test (absx < 1e15), and NaNs will fail both tests. Zero will
     also fail both tests, but since it will get set to zero that is OK.
     */

    float absx = fabs(x);

    if (absx > 1e-15 && absx < 1e15) {
        return x;
    }

    return 0.0;
}


enum {
    FilterParamCutoff = 0,
    FilterParamResonance = 1
};

static inline double squared(double x) {
    return x * x;
}

/*
 FilterDSPKernel
 Performs our filter signal processing.
 As a non-ObjC class, this is safe to use from render thread.
 */
class FilterDSPKernel : public DSPKernel {
public:

    void init(int channelCount, double inSampleRate) {

        sampleRate = float(inSampleRate);
        nyquist = 0.5 * sampleRate;
    }

    void setBuffers(AudioBufferList* inBufferList, AudioBufferList* outBufferList) {
        inBufferListPtr = inBufferList;
        outBufferListPtr = outBufferList;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        return;
    }

    // MARK: Member Variables

private:
    float sampleRate = 44100.0;
    float nyquist = 0.5 * sampleRate;

    AudioBufferList* inBufferListPtr = nullptr;
    AudioBufferList* outBufferListPtr = nullptr;

    bool bypassed = false;
};

#endif /* FilterDSPKernel_hpp */
