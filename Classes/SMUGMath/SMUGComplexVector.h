#import <Foundation/Foundation.h>
#import "complex.h"

@class SMUGRealVector;
@protocol SMUGFMPlugInComplexVector;

@interface SMUGComplexVector : NSObject

#pragma mark - Initializers

- (id)initWithLength:(unsigned int)N;

#pragma mark - Convenience Constructors

+ (id)complexVectorWithLength:(unsigned int)N;
+ (id)complexVectorWithRealVector:(SMUGRealVector *)v;
+ (id)complexVectorWithAbs:(SMUGRealVector *)mag phase:(SMUGRealVector *)phase;

#pragma mark - Accessors

- (unsigned int)length;
- (complex float *)components;
- (void)setComponent:(complex float)f atIndex:(unsigned int)index;
- (complex float)componentAtIndex:(unsigned int)index;

#pragma mark - Resizing

- (void)setLength:(unsigned int)N;

#pragma mark - Range Operations

- (SMUGComplexVector *)complexVectorInRange:(NSRange)range;
- (void)replaceComponentsInRange:(NSRange)range withComplexFloats:(complex float *)data;
- (void)replaceComponentsInRange:(NSRange)range withComplexVector:(SMUGComplexVector *)v;

#pragma mark - Phase

- (SMUGRealVector *)phaseInRadians;
- (SMUGRealVector *)phaseInDegrees;

#pragma mark - Complex -> Real Operations

- (SMUGRealVector *)real;
- (SMUGRealVector *)imag;
- (SMUGRealVector *)abs;

#pragma mark - Basic Math

- (void)add:(SMUGRealVector *)x;
- (void)complexAdd:(SMUGComplexVector *)x;
- (void)scaleBy:(float)scalar;
- (void)complexScaleBy:(complex float)scalar;
- (void)multiplyBy:(SMUGRealVector *)x;
- (void)complexMultiplyBy:(SMUGComplexVector *)x;
- (void)divideBy:(SMUGRealVector *)x;
- (void)complexDivideBy:(SMUGComplexVector *)x;

#pragma mark - Intermediate Math

- (void)square;
- (void)sqrt;
- (void)invert;
- (void)exp;
- (void)conjugate;

#pragma mark - Combinations of Vectors

+ (SMUGComplexVector *)average:(NSArray *)vectors;
+ (SMUGComplexVector *)RMSAverageOfVectors:(NSArray *)vectors;

@end
