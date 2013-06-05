//
//  SMUGRealMatrix.m
//  Capo
//
//  Created by Christopher Liscio on 11/19/09.
//  Copyright 2009 SuperMegaUltraGroovy. All rights reserved.
//

#import "SMUGRealMatrix.h"
#import <Accelerate/Accelerate.h>

@implementation SMUGRealMatrix  {
    SMUGRealVector *mVector;
    uint64_t mRows;
    uint64_t mColumns;
}

- (id)initWithRows:(uint64_t)rows columns:(uint64_t)cols {
    if (!(self = [super init]) ) {
        return nil;
    }

    mVector = [(SMUGRealVector *)[SMUGRealVector alloc] initWithLength : rows * cols];
    mRows = rows;
    mColumns = cols;

    return self;
}

- (id)initWithRealVector:(SMUGRealVector *)realVector rows:(uint64_t)rows columns:(uint64_t)cols {
    NSParameterAssert([realVector length] == (rows * cols) );

    if (!(self = [super init]) ) {
        return nil;
    }

    mVector = [realVector copy];
    mRows = rows;
    mColumns = cols;

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[SMUGRealMatrix alloc] initWithRealVector:mVector rows:mRows columns:mColumns];
}

#pragma mark - Operations

- (SMUGRealMatrix *)transposedCopy {
    SMUGRealMatrix *ret = [[SMUGRealMatrix alloc] initWithRows:mColumns columns:mRows];
    float *my_c = [self components];
    float *ret_c = [ret components];
    for (uint64_t i = 0; i < mRows; i++) {
        for (uint64_t j = 0; j < mColumns; j++) {
            ret_c[j * mRows + i] = my_c[i * mColumns + j];
        }
    }
    return ret;
}

- (SMUGRealVector *)solutionWith_b:(SMUGRealVector *)b {
    NSParameterAssert(mRows == mColumns);
    NSParameterAssert([b length] == mRows);

    SMUGRealMatrix *m = [self transposedCopy];

    SMUGRealVector *resultVector = [b copy];
    float *ac = [m components];
    float *bc = [resultVector components];

    __CLPK_integer n = mRows;
    __CLPK_integer numB = 1;
    __CLPK_integer lda = n;
    __CLPK_integer ldb = n;
    __CLPK_integer result = 0;
    __CLPK_integer *dummy = malloc(n * sizeof(float) );
    sgesv_(&n, &numB, ac, &lda, dummy, bc, &ldb, &result);
    free(dummy);

    if (result != 0) {
        NSLog(@"Nonzero result from sgesv_: %ld", result);
        return nil;
    }

    return resultVector;
}

- (NSString *)description {
    NSMutableString *returnString = [NSMutableString string];
    [returnString appendFormat:@"\n\n"];
    for (uint64_t i = 0; i < mRows; i++) {
        for (uint64_t j = 0; j < mColumns; j++) {
            [returnString appendFormat:@"%15f ", [self componentAtRow:i column:j]];
        }
        [returnString appendFormat:@"\n"];
    }
    [returnString appendFormat:@"\n"];
    return returnString;
}

#pragma mark - Public Accessors

@synthesize rows = mRows;
@synthesize columns = mColumns;

- (float *)components {
    return [mVector components];
}

- (void)setComponent:(float)c atRow:(uint64_t)row column:(uint64_t)col {
    NSParameterAssert(row < mRows && col < mColumns);
    [mVector setComponent:c atIndex:(row * mColumns) + col];
}

- (float)componentAtRow:(uint64_t)row column:(uint64_t)col {
    NSParameterAssert(row < mRows && col < mColumns);
    return [mVector componentAtIndex:(row * mColumns) + col];
}

@end
