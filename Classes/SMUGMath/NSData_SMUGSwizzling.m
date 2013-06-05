//
//  NSData_SMUGSwizzling.m
//  MLSMeasurement
//
//  Created by Chris Liscio on 28/02/06.
//  Copyright 2006 SuperMegaUltraGroovy. All rights reserved.
//

#import "NSData_SMUGSwizzling.h"

@implementation NSMutableData (SMUGNSDataSwizzlingAdditions)

- (void)smug_swapFloatsHostToBigIfRequired {
    if (CFByteOrderGetCurrent() == CFByteOrderLittleEndian) {
        unsigned int *swizBuf = [self mutableBytes];
        unsigned int i, length = ([self length] / sizeof(float) );
        for (i = 0; i < length; i++) {
            swizBuf[i] = CFSwapInt32HostToBig(swizBuf[i]);
        }
    }
}

- (void)smug_swapFloatsBigToHostIfRequired {
    if (CFByteOrderGetCurrent() == CFByteOrderLittleEndian) {
        unsigned int *swizBuf = [self mutableBytes];
        unsigned int i, length = ([self length] / sizeof(float) );
        for (i = 0; i < length; i++) {
            swizBuf[i] = CFSwapInt32BigToHost(swizBuf[i]);
        }
    }
}

- (NSData *)smug_swappedFloat32HostToBig {
    NSMutableData *ret = [NSMutableData dataWithLength:[self length]];
    unsigned int *c = [ret mutableBytes], *my_c = [self mutableBytes];

    int i, len = [self length] / sizeof(float);
    for (i = 0; i < len; i++) {
        c[i] = CFSwapInt32HostToBig(my_c[i]);
    }

    return ret;
}
@end
