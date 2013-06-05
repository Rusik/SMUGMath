#import <Foundation/Foundation.h>

@class SMUGComplexVector;
@class SMUGDoubleVector;
@class SMUGWindow;
@protocol SMUGFMPlugInRealVector;

@interface SMUGRealVector : NSObject <NSCopying, NSCoding>

#pragma mark - Initializers

- (id)initWithLength:(unsigned int)N;
- (id)initWithData:(NSData *)data;
- (id)initWithBytesNoCopy:(float *)inBytes length:(NSUInteger)inLength;

#pragma mark - Convenience Constructors

+ (id)realVectorWithLength:(unsigned int)N;
+ (id)realVectorWithComponents:(unsigned int)N, ...;
+ (id)realVectorWithData:(NSData *)data;
+ (id)realVectorWithBytesNoCopy:(float *)inBytes length:(NSUInteger)inLength;
+ (id)realVectorWithContentsOfMappedFile:(NSString *)path;

#pragma mark - Specialized Convenience Constructors

+ (id)onesWithLength:(unsigned int)N;
+ (id)realVectorWithIntegersRangingFrom:(int)begin
                                     to:(int)end;

#pragma mark - Serialization

- (void)writeToFile:(NSString *)path;

#pragma mark - Accessors

- (unsigned int)length;
- (float *)components;
- (void)setComponent:(float)val atIndex:(unsigned int)index;
- (float)componentAtIndex:(unsigned int)index;

#pragma mark - Range Operations

- (SMUGRealVector *)realVectorInRange:(NSRange)range;
- (SMUGRealVector *)realVectorInRangeNoCopy:(NSRange)inRange;
- (void)replaceComponentsInRange:(NSRange)range withFloats:(float *)data;
- (void)replaceComponentsInRange:(NSRange)range withRealVector:(SMUGRealVector *)floatData;

#pragma mark - Resizing

- (void)setLength:(unsigned int)N;
- (void)increaseLengthBy:(unsigned int)N;
- (void)appendVector:(SMUGRealVector *)v;
- (void)appendComponent:(float)c;

#pragma mark - Manipulation Routines

- (void)reverse;
- (void)circularShiftBy:(int)amount;
- (void)overlapAddRealVector:(SMUGRealVector *)inVector atComponent:(unsigned int)inStartIndex;

#pragma mark - Minimum/Maximum

- (void)getMinimum:(float *)min location:(unsigned int *)loc;
- (void)getMaximum:(float *)max location:(unsigned int *)loc;
- (void)getMaximumMagnitude:(float *)max location:(unsigned int *)loc;
- (void)getRMSMaximum:(float *)max location:(unsigned int *)loc;

#pragma mark - Basic Math

- (void)add:(SMUGRealVector *)x;
- (void)subtract:(SMUGRealVector *)x;
- (void)scaleBy:(float)scalar;
- (void)multiplyBy:(SMUGRealVector *)x;
- (void)divideBy:(SMUGRealVector *)x;

#pragma mark - Intermediate Math

- (void)square;
- (void)sqrt;
- (void)invert;
- (void)normalize;

#pragma mark - Summation/Averaging

- (float)cumsum;
- (void)integrate;
- (float)RMSAverage;

#pragma mark - Combinations of Vectors

+ (SMUGRealVector *)sumOfVectors:(NSArray *)vectors;
+ (SMUGRealVector *)differenceOfVectors:(NSArray *)vectors;
+ (SMUGRealVector *)RMSAverageOfVectors:(NSArray *)vectors;
+ (SMUGRealVector *)averageOfVectors:(NSArray *)vectors;

#pragma mark - Downsample/Upsample

- (void)downsampleBy:(unsigned int)n withOffset:(unsigned int)offset;
- (void)upsampleBy:(unsigned int)n;

@end
