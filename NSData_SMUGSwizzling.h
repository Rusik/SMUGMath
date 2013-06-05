//
//  NSData_SMUGSwizzling.h
//  MLSMeasurement
//
//  Created by Chris Liscio on 28/02/06.
//  Copyright 2006 SuperMegaUltraGroovy. All rights reserved.
//

@interface NSMutableData (SMUGSwizzling)

- (void)smug_swapFloatsHostToBigIfRequired;
- (void)smug_swapFloatsBigToHostIfRequired;
- (NSData *)smug_swappedFloat32HostToBig;

@end
