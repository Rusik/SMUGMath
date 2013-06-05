#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
#import "SMUGRealVector.h"
#import "NSData_SMUGSwizzling.h"

@implementation SMUGRealVector  {
    float *mBytes;
    uint64_t mByteLength;
    BOOL mFreeWhenDone;
}

#pragma mark - Initializers

- (id)initWithLength:(unsigned int)N {
    if (!(self = [super init]) ) {
        return nil;
    }

    mFreeWhenDone = YES;
    mByteLength = N * sizeof(float);
    mBytes = calloc(mByteLength, 1);
    if (!mBytes) {
        return nil;
    }

    return self;
}

- (id)initWithData:(NSData *)data {
    if (!(self = [super init]) ) {
        return nil;
    }

    mFreeWhenDone = YES;
    mByteLength = [data length];
    mBytes = malloc(mByteLength);
    if (!mBytes) {
        return nil;
    }
    memcpy(mBytes, [data bytes], [data length]);

    return self;
}

- (id)initWithBytesNoCopy:(float *)inBytes length:(NSUInteger)inLength {
    if (!(self = [super init]) ) {
        return nil;
    }

    mFreeWhenDone = NO;
    mBytes = inBytes;
    mByteLength = inLength * sizeof(float);

    return self;
}

#pragma mark - NSObject

- (void)dealloc {
    if (mFreeWhenDone) {
        free(mBytes); mBytes = nil;
    }
    mByteLength = 0;
}

- (NSString *)description {
    NSMutableString *returnString = [NSMutableString string];
    unsigned int i;
    [returnString appendFormat:@"\n\n"];
    for (i = 0; i < [self length]; i++) {
        [returnString appendFormat:@"%4f ", [self componentAtIndex:i]];
    }
    [returnString appendFormat:@"\n"];
    return returnString;
}

#pragma mark - Convenience Constructors

+ (id)realVectorWithLength:(unsigned int)N {
    return [(SMUGRealVector *)[SMUGRealVector alloc] initWithLength:N];
}

+ (id)realVectorWithComponents:(unsigned int)N, ... {
    va_list ap;
    int i;
    SMUGRealVector *ret = [SMUGRealVector realVectorWithLength:N];

    va_start(ap, N);
    for (i = 0; i < N; i++) {
        double val = va_arg(ap, double);
        [ret setComponent:(float)val atIndex:i];
    }
    va_end(ap);

    return ret;
}

+ (id)realVectorWithData:(NSData *)data {
    return [[SMUGRealVector alloc] initWithData:data];
}

+ (id)realVectorWithBytesNoCopy:(float *)inBytes length:(NSUInteger)inLength {
    return [[SMUGRealVector alloc] initWithBytesNoCopy:inBytes length:inLength];
}

+ (id)realVectorWithContentsOfMappedFile:(NSString *)path {
    return [[SMUGRealVector alloc] initWithData:[NSData dataWithContentsOfMappedFile:path]];
}

#pragma mark - Specialized Convenience Constructors

+ (id)onesWithLength:(unsigned int)N {
    SMUGRealVector *ones = [SMUGRealVector realVectorWithLength:N];
    float *c = [ones components];
    unsigned int i, length = [ones length];
    for (i = 0; i < length; i++) {
        c[i] = 1.0f;
    }
    return ones;
}

+ (id)realVectorWithIntegersRangingFrom:(int)begin to:(int)end {
    unsigned int i;
    unsigned int rangeLength = abs(end - begin);
    int op;
    SMUGRealVector *range = [SMUGRealVector realVectorWithLength:rangeLength];
    float *rangeComponents = [range components];

    if (end > begin) {
        // Incrementing range
        for (i = 0; i < rangeLength; i++) {
            op = (begin + i);
            rangeComponents[i] = (float)(op);
        }
    } else if (begin > end) {
        // Decrementing range
        for (i = 0; i < rangeLength; i++) {
            op = (begin - i);
            rangeComponents[i] = (float)(op);
        }
    } else {
        [NSException raise:@"ParametersEqual" format:@"Parameters equal when trying to create range vector"];
    }

    return range;
}

#pragma mark - Serialization

- (void)writeToFile:(NSString *)path {
    [[NSData dataWithBytesNoCopy:mBytes length:mByteLength] writeToFile:path atomically:NO];
}

#pragma mark - Accessors

- (unsigned int)length {
    return mByteLength / sizeof(float);
}
- (float *)components {
    return mBytes;
}
- (void)setComponent:(float)val atIndex:(unsigned int)index {
    if (index >= [self length]) {
        [NSException raise:NSRangeException format:@"Trying to set component outside"];
    }
    [self components][index] = val;
}
- (float)componentAtIndex:(unsigned int)index {
    if (index >= [self length]) {
        [NSException raise:NSRangeException
                    format:@"Trying to retrieve component outside range"];
    }
    return [self components][index];
}


#pragma mark - Range Operations

- (SMUGRealVector *)realVectorInRange:(NSRange)range {
    if (range.location + range.length > [self length]) {
        [NSException raise:NSRangeException
                    format:@"Trying to retrieve vector outside bounds"];
    }
    SMUGRealVector *returnVector = [SMUGRealVector realVectorWithLength:range.length];
    [returnVector replaceComponentsInRange:NSMakeRange(0, range.length)
                                withFloats:&([self components][range.location])];

    return returnVector;
}

- (SMUGRealVector *)realVectorInRangeNoCopy:(NSRange)inRange {
    if (inRange.location + inRange.length > [self length]) {
        [NSException raise:NSRangeException
                    format:@"Trying to retrieve vector outside bounds"];
    }
    return [SMUGRealVector realVectorWithBytesNoCopy:([self components] + inRange.location) length:inRange.length];
}

- (void)replaceComponentsInRange:(NSRange)range withFloats:(float *)data {
    if (range.location + range.length > [self length]) {
        [NSException raise:NSRangeException
                    format:@"Trying to replace floats outside range"];
    }
    memcpy( (mBytes + range.location), data, range.length * sizeof(float) );
}

- (void)replaceComponentsInRange:(NSRange)range withRealVector:(SMUGRealVector *)v {
    if (range.length > [v length]) {
        [NSException raise:NSRangeException
                    format:@"Range length exceeds length of replacement vector"];
    }
    [self replaceComponentsInRange:range withFloats:[v components]];
}

#pragma mark - Resizing

- (void)setLength:(unsigned int)N {
    unsigned int myLength = [self length];
    if (N != myLength) {
        mBytes = realloc(mBytes, N * sizeof(float) );
        mByteLength = N * sizeof(float);
    }
}

- (void)increaseLengthBy:(unsigned int)N {
    if (N != 0) {
        mBytes = realloc(mBytes, mByteLength + (N * sizeof(float) ) );
        mByteLength += N * sizeof(float);
    }
}

- (void)appendVector:(SMUGRealVector *)v {
    uint64_t origLength = [self length];
    [self increaseLengthBy:[v length]];
    [self replaceComponentsInRange:NSMakeRange(origLength, [v length]) withRealVector:v];
}

- (void)appendComponent:(float)c {
    [self increaseLengthBy:1];
    [self setComponent:c atIndex:([self length] - 1)];
}

#pragma mark - Manipulation Routines

- (void)reverse {
    float *components = [self components];
    float temp;
    unsigned int length = [self length];
    unsigned int halfLength = length;
    unsigned int i;

    if ( (halfLength % 2) == 1) {
        halfLength -= 1;
    }
    halfLength /= 2;

    for (i = 0; i < halfLength; i++) {
        temp = components[i];
        components[i] = components[length - i - 1];
        components[length - i - 1] = temp;
    }
}

- (void)circularShiftBy:(int)amount {
    unsigned int length = [self length];
    int index = (length - amount) % length;
    SMUGRealVector *a = [self realVectorInRange:NSMakeRange(0, index)];
    SMUGRealVector *b = [self realVectorInRange:NSMakeRange(index, length - index)];

    [self replaceComponentsInRange:NSMakeRange(0, [b length]) withRealVector:b];
    [self replaceComponentsInRange:NSMakeRange([b length], [a length]) withRealVector:a];
}

- (void)overlapAddRealVector:(SMUGRealVector *)inVector atComponent:(unsigned int)inStartIndex {
    if (inStartIndex >= [self length]) {
        [NSException raise:@"OutOfBounds" format:@"Trying to overlap-add past vector length"];
    }

    unsigned int newLength = MAX(inStartIndex + [inVector length], [self length]);

    // Resize if necessary, for convenience
    if (newLength > [self length]) {
        [self setLength:newLength];
    }

    vDSP_vadd( ([self components] + inStartIndex), 1, [inVector components], 1, ([self components] + inStartIndex), 1, [inVector length]);
}

#pragma mark - Minimum/Maximum

- (void)getMinimum:(float *)oMin location:(unsigned int *)oLoc {
    if ( (!oMin) || (!oLoc) ) {
        [NSException raise:@"NullArguments" format:@"NULL argument given when getting maximum value"];
        return;
    }

    vDSP_Length loc;
    vDSP_minvi([self components], 1, oMin, &loc, [self length]);
    *oLoc = loc;
}

- (void)getMaximum:(float *)oMax location:(unsigned int *)oLoc {
    if ( (!oMax) || (!oLoc) ) {
        [NSException raise:@"NullArguments" format:@"NULL argument given when getting maximum value"];
        return;
    }

    vDSP_Length loc;
    vDSP_maxvi([self components], 1, oMax, &loc, [self length]);
    *oLoc = loc;
}

- (void)getMaximumMagnitude:(float *)oMax location:(unsigned int *)oLoc {
    if ( (!oMax) || (!oLoc) ) {
        [NSException raise:@"NullArguments" format:@"NULL argument given when getting maximum value"];
        return;
    }

    vDSP_Length loc;
    vDSP_maxmgvi([self components], 1, oMax, &loc, [self length]);
    *oLoc = loc;
}

- (void)getRMSMaximum:(float *)max location:(unsigned int *)loc {
    if ( (!max) || (!loc) ) {
        [NSException raise:@"NullArguments" format:@"NULL argument given when getting maximum value"];
        return;
    }

    unsigned int length = [self length];
    unsigned int i;
    float *components = [self components];
    float rms;

    *max = -FLT_MAX;
    *loc = 0xFFFFFFFF;

    for (i = 0; i < length; i++) {
        rms = sqrtf(components[i] * components[i]);
        if (*max < rms) {
            *max = rms;
            *loc = i;
        }
    }
}

#pragma mark - Basic Math

- (void)add:(SMUGRealVector *)x {
    float *xComponents = [x components];
    unsigned int xNumComponents = [x length];
    float *myComponents = [self components];
    unsigned int myNumComponents = [self length];

    if (xNumComponents != myNumComponents) {
        [NSException raise:@"LengthMismatchException" format:@"Operand lengths do not match"];
    }

    vDSP_vadd(myComponents, 1, xComponents, 1, myComponents, 1, myNumComponents);
}

- (void)subtract:(SMUGRealVector *)x {
    float *xComponents = [x components];
    unsigned int xNumComponents = [x length];
    float *myComponents = [self components];
    unsigned int myNumComponents = [self length];

    if (xNumComponents != myNumComponents) {
        [NSException raise:@"LengthMismatchException" format:@"Operand lengths do not match"];
    }

    vDSP_vsub(xComponents, 1, myComponents, 1, myComponents, 1, myNumComponents);
}

- (void)scaleBy:(float)scalar {
    float *myComponents = [self components];
    unsigned int numComponents = [self length];

    vDSP_vsmul(myComponents, 1, &scalar, myComponents, 1, numComponents);
}

- (void)multiplyBy:(SMUGRealVector *)x {
    float *xComponents = [x components];
    unsigned int xNumComponents = [x length];
    float *myComponents = [self components];
    unsigned int myNumComponents = [self length];

    if (xNumComponents != myNumComponents) {
        [NSException raise:@"LengthMismatchException" format:@"Operand lengths do not match"];
    }

    vDSP_vmul(myComponents, 1, xComponents, 1, myComponents, 1, myNumComponents);
}

- (void)divideBy:(SMUGRealVector *)x {
    float *xComponents = [x components];
    unsigned int xNumComponents = [x length];
    float *myComponents = [self components];
    unsigned int myNumComponents = [self length];
    unsigned int i = 0;

    if (xNumComponents != myNumComponents) {
        [NSException raise:@"LengthMismatchException" format:@"Operand lengths do not match"];
    }

    for (i = 0; i < myNumComponents; i++) {
        if (xComponents[i] == 0.0f) {
            [NSException raise:@"DivideByZero" format:@"Divide by zero"];
        }
        myComponents[i] = myComponents[i] / xComponents[i];
    }
}

#pragma mark - Intermediate Math

- (void)square {
    vDSP_vsq([self components], 1, [self components], 1, [self length]);
}

- (void)sqrt {
    float *c = [self components];
    unsigned int i, length = [self length];
    for (i = 0; i < length; i++) {
        c[i] = sqrtf(c[i]);
    }
}

- (void)invert {
    float *myComponents = [self components];
    unsigned int numComponents = [self length];
    unsigned int i = 0;

    for (i = 0; i < numComponents; i++) {
        myComponents[i] = 1.0f / myComponents[i];
    }
}

- (void)normalize {
    float max = -FLT_MAX;
    unsigned int idx;

    [self getMaximumMagnitude:&max location:&idx];
    [self scaleBy:1.0f / max];
}

#pragma mark - Summation/Averaging

- (float)cumsum {
    float *c = [self components];
    float accum = 0.0f;
    unsigned int i, length = [self length];
    for (i = 0; i < length; i++) {
        accum += c[i];
    }
    return accum;
}

- (void)integrate {
    float accum = 0.0f;
    float *myComponents = [self components];
    unsigned int numComponents = [self length];
    unsigned int i = 0;

    for (i = 0; i < numComponents; i++) {
        accum += myComponents[i];
        myComponents[i] = accum;
    }
}

- (float)RMSAverage {
    float *c = [self components];
    unsigned int i, length = [self length];
    float bin = 0;

    for (i = 0; i < length; i++) {
        bin += c[i] * c[i];
    }

    bin /= (float)length;

    return sqrtf(bin);
}

#pragma mark - Combinations of Vectors

+ (SMUGRealVector *)sumOfVectors:(NSArray *)vectors {
    unsigned int count = [vectors count];
    if (count == 0) {
        [NSException raise:@"ZeroLengthList" format:@"No vectors to add"];
    }

    unsigned int length = [(SMUGRealVector *)[vectors objectAtIndex:0] length];
    unsigned int i, j;

    // Ensure all the vectors share the same length
    for (i = 1; i < count; i++) {
        if ([(SMUGRealVector *)[vectors objectAtIndex:i] length] != length) {
            [NSException raise:@"LengthMismatch" format:@"Lengths of vectors to add don't match"];
        }
    }

    SMUGRealVector *ret = [SMUGRealVector realVectorWithLength:length];
    float *c = [ret components];
    float *x = NULL;

    for (j = 0; j < count; j++) {
        x = [(SMUGRealVector *)[vectors objectAtIndex:j] components];
        for (i = 0; i < length; i++) {
            c[i] += x[i];
        }
    }

    return ret;
}

+ (SMUGRealVector *)differenceOfVectors:(NSArray *)vectors {
    unsigned int count = [vectors count];
    if (count == 0) {
        [NSException raise:@"ZeroLengthList" format:@"No vectors to subtract"];
    }

    unsigned int length = [(SMUGRealVector *)[vectors objectAtIndex:0] length];
    unsigned int i, j;

    // Ensure all the vectors share the same length
    for (i = 1; i < count; i++) {
        if ([(SMUGRealVector *)[vectors objectAtIndex:i] length] != length) {
            [NSException raise:@"LengthMismatch" format:@"Lengths of vectors to subtract don't match"];
        }
    }

    SMUGRealVector *ret = [SMUGRealVector realVectorWithLength:length];
    float *c = [ret components];
    float *x = NULL;

    for (j = 0; j < count; j++) {
        x = [(SMUGRealVector *)[vectors objectAtIndex:j] components];
        for (i = 0; i < length; i++) {
            if (j == 0) {
                c[i] = x[i];
            } else {
                c[i] -= x[i];
            }
        }
    }

    return ret;
}

+ (SMUGRealVector *)averageOfVectors:(NSArray *)vectors {
    unsigned int count = [vectors count];
    if (count == 0) {
        [NSException raise:@"ZeroLengthList" format:@"No vectors to average"];
    }

    unsigned int length = [(SMUGRealVector *)[vectors objectAtIndex:0] length];
    unsigned int i;

    // Ensure all the vectors share the same length
    for (i = 1; i < count; i++) {
        if ([(SMUGRealVector *)[vectors objectAtIndex:i] length] != length) {
            [NSException raise:@"LengthMismatch" format:@"Lengths of vectors to average don't match"];
        }
    }

    SMUGRealVector *ret = [SMUGRealVector sumOfVectors:vectors];
    [ret scaleBy:(1.0f / (float)count)];

    return ret;
}

+ (SMUGRealVector *)RMSAverageOfVectors:(NSArray *)vectors {
    unsigned int count = [vectors count];
    if (count == 0) {
        [NSException raise:@"ZeroLengthList" format:@"No vectors to average"];
    }

    unsigned int length = [(SMUGRealVector *)[vectors objectAtIndex:0] length];
    unsigned int i, j;

    // Ensure all the vectors share the same length
    for (i = 1; i < count; i++) {
        if ([(SMUGRealVector *)[vectors objectAtIndex:i] length] != length) {
            [NSException raise:@"LengthMismatch" format:@"Lengths of vectors to average don't match"];
        }
    }

    SMUGRealVector *ret = [SMUGRealVector realVectorWithLength:length];
    float *c = [ret components];
    float *x = NULL;

    // Add up the squares of each vector
    for (j = 0; j < count; j++) {
        x = [(SMUGRealVector *)[vectors objectAtIndex:j] components];
        for (i = 0; i < length; i++) {
            c[i] += x[i] * x[i];
        }
    }

    // Divide by the number of vectors
    for (i = 0; i < length; i++) {
        c[i] = sqrtf(c[i] / (float)count);
    }

    return ret;
}

#pragma mark - Downsample/Upsample

- (void)downsampleBy:(unsigned int)n withOffset:(unsigned int)offset {
    float *c = [self components];
    unsigned int downsampledLength = floorf(([self length] - offset) / n);
    unsigned int i;

    if (downsampledLength == 0) {
        [NSException raise:@"ZeroLengthResult" format:@"Downsampling reduces sequence to 0 length"];
    }

    for (i = 0; i < downsampledLength; i++) {
        c[i] = c[ i * n + offset ];
    }

    [self setLength:downsampledLength];
}

- (void)upsampleBy:(unsigned int)n {
    unsigned int upsampledLength = [self length] * n;
    int i, length = [self length];
    [self setLength:upsampledLength];
    float *c = [self components];

    for (i = length - 1; i > 0; i--) {
        c[ i * n ] = c[ i ];
    }
    for (i = 0; i < upsampledLength; i++) {
        if ( (i % n) != 0) {
            c[ i ] = 0.0f;
        }
    }
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder {
    NSMutableData *aData = [[coder decodeObjectForKey:@"VectorData"] mutableCopy];
    [aData smug_swapFloatsBigToHostIfRequired];

    return [self initWithData:aData];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    NSMutableData *aData = [[NSData dataWithBytesNoCopy:mBytes length:mByteLength] mutableCopy];
    if (CFByteOrderGetCurrent() == CFByteOrderLittleEndian) {
        [coder encodeObject:[aData smug_swappedFloat32HostToBig] forKey:@"VectorData"];
    } else {
        [coder encodeObject:aData forKey:@"VectorData"];
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    SMUGRealVector *newObj = [(SMUGRealVector *)[[self class] allocWithZone:zone] initWithLength :[self length]];
    [newObj replaceComponentsInRange:NSMakeRange(0, [self length])
                      withRealVector:self];
    return newObj;
}

@end
