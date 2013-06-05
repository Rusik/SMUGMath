//
//  SMUGComplexVector_FFT.m
//  SMUGMath
//
//  Created by Christopher Liscio on 4/19/10.
//  Copyright 2010 SuperMegaUltraGroovy. All rights reserved.
//

#import "SMUGComplexVector_FFT.h"
#import "SMUGRealFFTPlan.h"
#import "kiss_fftr.h"

@implementation SMUGComplexVector (FFT)

- (SMUGRealVector *)ifft {
    unsigned int N = ([self length] - 1) * 2;
    float scale = 1.0f / (float)N;
    SMUGRealVector *ret = [SMUGRealVector realVectorWithLength:N];
    kiss_fftr_cfg fftConfig = kiss_fftr_alloc(N, 1, NULL, NULL);
    kiss_fftri(fftConfig, (kiss_fft_cpx *)[self components], [ret components]);
    kiss_fftr_free(fftConfig);
    [ret scaleBy:scale];
    return ret;
}

- (SMUGRealVector *)ifftWithPlan:(SMUGRealFFTPlan *)inPlan {
    unsigned int N = ([self length] - 1) * 2;
    SMUGRealVector *ret = [SMUGRealVector realVectorWithLength:N];
    [self ifftIntoRealVector:ret withPlan:inPlan];
    return ret;
}

- (void)ifftIntoRealVector:(SMUGRealVector *)inRealVector withPlan:(SMUGRealFFTPlan *)inPlan {
    unsigned int N = ([self length] - 1) * 2;
    if ([self length] == 0) {
        [NSException raise:@"FFTZeroLength" format:@"Tried to perform 0-length FFT"];
    }
    if (N != inPlan.fftSize) {
        [NSException raise:@"FFTSizeMismatch" format:@"Plan does not match fft length"];
    }
    if (N != [inRealVector length]) {
        [NSException raise:@"FFTOutputVectorSizeMismatch" format:@"Supplied input vector not proper length"];
    }
    kiss_fftri(inPlan.inversePlan, (kiss_fft_cpx *)[self components], [inRealVector components]);
    [inRealVector scaleBy:1.0f / (float)N];
}

@end
