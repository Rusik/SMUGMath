#import "SMUGComplexVector.h"
#import "SMUGRealVector.h"
#import "complex.h"

@implementation SMUGComplexVector {
    NSMutableData *mData;
}

#pragma mark - Initializers

- (id)initWithLength:(unsigned int)N {
    if (![super init]) {
        return nil;
    }

    mData = [(NSMutableData *)[NSMutableData alloc] initWithLength : (N * sizeof(complex float))];
    if (!mData) {
        return nil;
    }

    return self;
}

#pragma mark - Convenience Constructors

+ (id)complexVectorWithLength:(unsigned int)N {
    return [(SMUGComplexVector *)[SMUGComplexVector alloc] initWithLength : N];
}

+ (id)complexVectorWithRealVector:(SMUGRealVector *)v {
    SMUGComplexVector *t = [SMUGComplexVector complexVectorWithLength:[v length]];
    complex float *c = [t components];
    const float *d = [v components];
    unsigned int i, length = [t length];
    for (i = 0; i < length; i++) {
        c[i] = d[i];
    }
    return t;
}

+ (id)complexVectorWithAbs:(SMUGRealVector *)mag phase:(SMUGRealVector *)phase {
    if ([mag length] != [phase length]) {
        [NSException raise:@"LengthMismatch" format:@"Length mismatch between magnitude and phase"];
    }
    SMUGComplexVector *cvec = [SMUGComplexVector complexVectorWithLength:[mag length]];
    complex float *components = [cvec components];
    float *magComponents = [mag components];
    float *phaseComponents = [phase components];
    unsigned int i, length = [mag length];

    for (i = 0; i < length; i++) {
        components[i] = magComponents[i] * (cosf(phaseComponents[i]) + (I * sinf(phaseComponents[i]) ) );
    }

    return cvec;
}

#pragma mark - Accessors

- (unsigned int)length {
    return [mData length] / sizeof(complex float);
}

- (complex float *)components {
    return (complex float *)[mData mutableBytes];
}

- (void)setComponent:(complex float)f atIndex:(unsigned int)index {
    if (index >= [self length]) {
        [NSException raise:@"OutOfBounds" format:@"Trying to set float outside range"];
    }
    [mData replaceBytesInRange:NSMakeRange(index * sizeof(complex float), sizeof(complex float) )
                     withBytes:&f];
}

- (complex float)componentAtIndex:(unsigned int)index {
    if (index >= [self length]) {
        [NSException raise:@"OutOfBounds" format:@"Trying to set float outside range"];
    }
    return [self components][index];
}

#pragma mark - Resizing

- (void)setLength:(unsigned int)N {
    unsigned int myLength = [self length];
    if (N != myLength) {
        [mData setLength:((myLength + (N - myLength) ) * sizeof(complex float))];
    }
}

#pragma mark - Range Operations

- (SMUGComplexVector *)complexVectorInRange:(NSRange)range {
    if (range.location + range.length > [self length]) {
        [NSException raise:NSRangeException
                    format:@"Trying to retrieve vector outside bounds"];
    }
    SMUGComplexVector *returnVector = [SMUGComplexVector complexVectorWithLength:range.length];
    [returnVector replaceComponentsInRange:NSMakeRange(0, range.length)
                         withComplexFloats:&([self components][range.location])];

    return returnVector;
}

- (void)replaceComponentsInRange:(NSRange)range withComplexFloats:(complex float *)data {
    if (range.location + range.length > [self length]) {
        [NSException raise:NSRangeException
                    format:@"Trying to replace complex floats outside range"];
    }
    [mData replaceBytesInRange:NSMakeRange(range.location * sizeof(complex float), range.length * sizeof(complex float) )
                     withBytes:data];
}

- (void)replaceComponentsInRange:(NSRange)range withComplexVector:(SMUGComplexVector *)v {
    if (range.length > [v length]) {
        [NSException raise:NSRangeException
                    format:@"Range length exceeds length of replacement complex vector"];
    }
    [self replaceComponentsInRange:range withComplexFloats:[v components]];
}

#pragma mark - Phase

- (SMUGRealVector *)phaseInRadians {
    int length = [self length];
    SMUGRealVector *resultVector = [SMUGRealVector realVectorWithLength:length];
    float *resultComponents = [resultVector components];
    complex float *myComponents = [self components];
    int i;

    for (i = 0; i < length; i++) {
        resultComponents[i] = cargf(myComponents[i]);
    }

    return resultVector;
}

- (SMUGRealVector *)phaseInDegrees {
    SMUGRealVector *resultVector = [self phaseInRadians];

    [resultVector scaleBy:(180.0f / (float)M_PI)];

    return resultVector;
}

#pragma mark - Complex -> Real Operations

- (SMUGRealVector *)real {
    complex float *myComponents = [self components];
    unsigned int length = [self length];
    SMUGRealVector *ret = [SMUGRealVector realVectorWithLength:length];
    float *retComponents = [ret components];
    unsigned int i;

    for (i = 0; i < length; i++) {
        retComponents[i] = crealf(myComponents[i]);
    }

    return ret;
}

- (SMUGRealVector *)imag {
    complex float *myComponents = [self components];
    unsigned int length = [self length];
    SMUGRealVector *ret = [SMUGRealVector realVectorWithLength:length];
    float *retComponents = [ret components];
    unsigned int i;

    for (i = 0; i < length; i++) {
        retComponents[i] = cimagf(myComponents[i]);
    }

    return ret;
}

- (SMUGRealVector *)abs {
    int length = [self length];
    SMUGRealVector *resultVector = [SMUGRealVector realVectorWithLength:length];
    float *resultComponents = [resultVector components];
    complex float *myComponents = [self components];
    int i;

    for (i = 0; i < length; i++) {
        resultComponents[i] = cabsf(myComponents[i]);
    }

    return resultVector;
}

#pragma mark - Basic Math

- (void)add:(SMUGRealVector *)x {
    float *xComponents = [x components];
    unsigned int xLength = [x length];
    complex float *myComponents = [self components];
    unsigned int myLength = [self length];
    unsigned int i = 0;

    if (xLength != myLength) {
        [NSException raise:@"LengthMismatchException" format:@"Operand lengths do not match"];
    }

    for (i = 0; i < myLength; i++) {
        myComponents[i] = myComponents[i] + xComponents[i];
    }
}

- (void)complexAdd:(SMUGComplexVector *)x {
    complex float *xComponents = [x components];
    unsigned int xLength = [x length];
    complex float *myComponents = [self components];
    unsigned int myLength = [self length];
    unsigned int i = 0;

    if (xLength != myLength) {
        [NSException raise:@"LengthMismatchException" format:@"Operand lengths do not match"];
    }

    for (i = 0; i < myLength; i++) {
        myComponents[i] = myComponents[i] + xComponents[i];
    }
}

- (void)scaleBy:(float)scalar {
    complex float *myComponents = [self components];
    unsigned int numComponents = [self length];
    unsigned int i = 0;

    for (i = 0; i < numComponents; i++) {
        myComponents[i] = myComponents[i] * scalar;
    }
}

- (void)complexScaleBy:(complex float)scalar {
    complex float *myComponents = [self components];
    unsigned int numComponents = [self length];
    unsigned int i = 0;

    for (i = 0; i < numComponents; i++) {
        myComponents[i] = myComponents[i] * scalar;
    }
}

- (void)multiplyBy:(SMUGRealVector *)x {
    float *xComponents = [x components];
    unsigned int xLength = [x length];
    complex float *myComponents = [self components];
    unsigned int myLength = [self length];
    unsigned int i = 0;

    if (xLength != myLength) {
        [NSException raise:@"LengthMismatchException" format:@"Operand lengths do not match"];
    }

    for (i = 0; i < myLength; i++) {
        myComponents[i] = myComponents[i] * xComponents[i];
    }
}

- (void)complexMultiplyBy:(SMUGComplexVector *)x {
    complex float *xComponents = [x components];
    unsigned int xLength = [x length];
    complex float *myComponents = [self components];
    unsigned int myLength = [self length];
    unsigned int i = 0;

    if (xLength != myLength) {
        [NSException raise:@"LengthMismatchException" format:@"Operand lengths do not match"];
    }

    for (i = 0; i < myLength; i++) {
        myComponents[i] = myComponents[i] * xComponents[i];
    }
}

- (void)divideBy:(SMUGRealVector *)x {
    float *xComponents = [x components];
    unsigned int xLength = [x length];
    complex float *myComponents = [self components];
    unsigned int myLength = [self length];
    unsigned int i = 0;

    if (xLength != myLength) {
        [NSException raise:@"LengthMismatchException" format:@"Operand lengths do not match"];
    }

    for (i = 0; i < myLength; i++) {
        if (xComponents[i] == 0.0f) {
            [NSException raise:@"DivideByZero" format:@"Divide by zero"];
        }
        myComponents[i] = myComponents[i] / xComponents[i];
    }
}

- (void)complexDivideBy:(SMUGComplexVector *)x {
    complex float *xComponents = [x components];
    unsigned int xLength = [x length];
    complex float *myComponents = [self components];
    unsigned int myLength = [self length];
    unsigned int i = 0;

    if (xLength != myLength) {
        [NSException raise:@"LengthMismatchException" format:@"Operand lengths do not match"];
    }

    for (i = 0; i < myLength; i++) {
        if (xComponents[i] == 0.0f) {
            myComponents[i] = 0.0;
        }
        myComponents[i] = myComponents[i] / xComponents[i];
    }
}

#pragma mark - Intermediate Math

- (void)square {
    unsigned int i, length = [self length];
    complex float *x = [self components];
    for (i = 0; i < length; i++) {
        x[i] = x[i] * x[i];
    }
}

- (void)sqrt {
    unsigned int i, length = [self length];
    complex float *x = [self components];
    for (i = 0; i < length; i++) {
        x[i] = csqrtf(x[i]);
    }
}

- (void)invert {
    complex float *myComponents = [self components];
    unsigned int length = [self length];
    unsigned int i = 0;

    for (i = 0; i < length; i++) {
        myComponents[i] = 1.0f / myComponents[i];
    }
}

- (void)exp {
    unsigned int i, length = [self length];
    complex float *c = [self components];
    for (i = 0; i < length; i++) {
        c[i] = cexpf(c[i]);
    }
}

- (void)conjugate {
    complex float *c = [self components];
    unsigned int i, length = [self length];
    for (i = 0; i < length; i++) {
        c[i] = conjf(c[i]);
    }
}

#pragma mark - Combinations of Vectors

+ (SMUGComplexVector *)RMSAverageOfVectors:(NSArray *)vectors {
    int itemCount = [vectors count];

    if (itemCount <= 0) {
        [NSException raise:@"ZeroLengthOperation" format:@"Trying to average 0 vectors"];
        return nil;
    }

    NSEnumerator *e = [vectors objectEnumerator];
    SMUGComplexVector *v = nil;
    unsigned int avgLength = 0;
    while (v = [e nextObject])
        avgLength = MAX([v length], avgLength);

    if (avgLength == 0) {
        [NSException raise:@"ZeroLengthOperation" format:@"Trying to average with a 0-length vectors"];
        return nil;
    }

    SMUGComplexVector *result = [SMUGComplexVector complexVectorWithLength:avgLength];

    e = [vectors objectEnumerator];
    while (v = [e nextObject]) {
        [v setLength:avgLength];
        [v square];
        [result complexAdd:v];
    }

    [result scaleBy:1.0f / (float)itemCount];
    [result sqrt];

    return result;
}

+ (SMUGComplexVector *)average:(NSArray *)vectors {
    int itemCount = [vectors count];

    if (itemCount <= 0) {
        [NSException raise:@"ZeroLengthOperation" format:@"Trying to average 0 vectors"];
        return nil;
    }

    NSEnumerator *e = [vectors objectEnumerator];
    SMUGComplexVector *v = nil;
    unsigned int avgLength = 0;
    while (v = [e nextObject])
        avgLength = MAX([v length], avgLength);

    if (avgLength == 0) {
        [NSException raise:@"ZeroLengthOperation" format:@"Trying to average with a 0-length vectors"];
        return nil;
    }

    SMUGComplexVector *result = [SMUGComplexVector complexVectorWithLength:avgLength];

    e = [vectors objectEnumerator];
    while (v = [e nextObject]) {
        [v setLength:avgLength];
        [result complexAdd:v];
    }

    [result scaleBy:1.0f / (float)itemCount];

    return result;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    SMUGComplexVector *newObj = [(SMUGComplexVector *)[[self class] allocWithZone:zone] initWithLength :[self length]];
    [newObj replaceComponentsInRange:NSMakeRange(0, [self length])
                   withComplexVector:self];
    return newObj;
}

@end
