//
//  SMUGRealVector_FFT.h
//  SMUGMath
//
//  Created by Christopher Liscio on 4/19/10.
//  Copyright 2010 SuperMegaUltraGroovy. All rights reserved.
//

#import "SMUGRealVector.h"

@class SMUGRealFFTPlan;

@interface SMUGRealVector (FFT)

// Performs a real-valued FFT. N/2+1 values are returned, since the FFT results
// for a real-valued input array are symmetric about the nyquist frequency. The
// First element in the array is the DC component.
- (SMUGComplexVector *)fft;

// Same as above, but you can use a pre-allocated plan to save a bit of time
- (SMUGComplexVector *)fftWithPlan:(SMUGRealFFTPlan *)inPlan;

// Same as above, but you can also use a pre-allocated output vector.
- (void)fftIntoComplexVector:(SMUGComplexVector *)inComplexVector withPlan:(SMUGRealFFTPlan *)inPlan;

@end