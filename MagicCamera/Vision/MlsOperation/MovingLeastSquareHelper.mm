
#ifndef MovingLeastSquareHelper_h
#define MovingLeastSquareHelper_h

#import "MovingLeastSquareHelper.h"
#import "MovingLeastSquare.h"

@implementation MLSMesh

-(instancetype)initWithWidth: (NSInteger)width andHeight: (NSInteger)height {
    if (self = [super init]) {
        _width = width;
        _height = height;
    }
    
    return self;
}

-(void)setupWithRows: (NSUInteger)rows andCols: (NSUInteger)cols {
    if (![self isEmpty]) {
        _originPoints = [MovingLeastSquareHelper createMeshPointsForSize:CGSizeMake(_width, _height) withRows:rows andCols:cols];
        _trianglesIndices = [MovingLeastSquareHelper meshTrianglesIndicesWithRows:rows andCols:cols];
    }
}

-(void)setupWithRect: (CGRect)rect andRows: (NSUInteger)rows andCols: (NSUInteger)cols {
    if (![self isEmpty]) {
        _originPoints = [MovingLeastSquareHelper createMeshPointsForRect:rect withRows:rows andCols:cols];
        _trianglesIndices = [MovingLeastSquareHelper meshTrianglesIndicesWithRows:rows andCols:cols];
    }
}

-(BOOL)doMovingLeastSquareDefromFrom: (NSArray *)controlPoints to: (NSArray *)targetPoints {
    if (![self isEmpty] && controlPoints.count == targetPoints.count) {
        _deformedPoints = [MovingLeastSquareHelper doMovingLeastSquareDeformForGridPoints:_originPoints withControlPoints:controlPoints toTargetPoints:targetPoints];
        return YES;
    }
    return NO;
}

-(BOOL)doMovingLeastSquareDefromTo: (NSArray *)targetPoints {
    if (![self isEmpty] && _baseControlPoints != nil && _baseControlPoints.count == targetPoints.count) {
        _deformedPoints = [MovingLeastSquareHelper doMovingLeastSquareDeformForGridPoints:_originPoints withControlPoints:_baseControlPoints toTargetPoints:targetPoints];
        return YES;
    }
    return NO;
}

-(BOOL)isEmpty {
    return _width == 0 || _height == 0;
}

@end

@implementation MovingLeastSquareHelper

+(float *)convertCGPointArray: (NSArray *)array {
    float *result = (float *)malloc(array.count * 2 * sizeof(float));
    [array enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint curPoint = [obj CGPointValue];
        result[idx * 2] = (float)curPoint.x;
        result[idx * 2 + 1] = (float)curPoint.y;
    }];
    return result;
}

+(NSArray *)doMovingLeastSquareDeformForGridPoints: (NSArray *)gridPoints withControlPoints: (NSArray *)controlPoints toTargetPoints: (NSArray *)targetPoints {
    float *controlPointsData = [MovingLeastSquareHelper convertCGPointArray: controlPoints];
    Mat controlPointsMatCache = createPointMat(controlPointsData, (int)controlPoints.count);
    free(controlPointsData);
    float *gridPointsData = [MovingLeastSquareHelper convertCGPointArray: gridPoints];
    Mat gridPointsMatCache = createPointMat(gridPointsData, (int)gridPoints.count);
    free(gridPointsData);
    float *targetPointsData = [MovingLeastSquareHelper convertCGPointArray: targetPoints];
    Mat targetPointsMatCache = createPointMat(targetPointsData, (int)targetPoints.count);
    free(targetPointsData);
    
    Mat w = precomputeWeights(controlPointsMatCache, gridPointsMatCache, 1.0);
    vector<_typeA> tA = precomputeSimilar(controlPointsMatCache, gridPointsMatCache, w);
    Mat fv = PointsTransformSimilar(w, tA, targetPointsMatCache);
    
    int count = (int)gridPoints.count;
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity: count];
    const Float32 *xData = fv.ptr<Float32>(0);
    const Float32 *yData = fv.ptr<Float32>(1);
    for (int i = 0; i < count; i++) {
        [result addObject: [NSValue valueWithCGPoint:CGPointMake(xData[i], yData[i])]];
    }
    
    return result;
}

+(NSArray *)createMeshPointsForSize: (CGSize)size withRows: (NSUInteger)rows andCols: (NSUInteger)cols {
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity: (rows + 1) * (cols + 1)];
    NSUInteger xStep = size.width / rows;
    NSUInteger yStep = size.height / cols;
    for (int row = 0; row <= rows; row++) {
        for (int col = 0; col <= cols; col++) {
            CGPoint point = CGPointZero;
            if (row == rows) {
                point.y = size.height - 1;
            } else {
                point.y = row * yStep;
            }
            if (col == cols) {
                point.x = size.width - 1;
            } else {
                point.x = col * xStep;
            }
            [result addObject: [NSValue valueWithCGPoint:point]];
        }
    }
    return result;
}

+(NSArray *)createMeshPointsForRect: (CGRect)rect withRows: (NSUInteger)rows andCols: (NSUInteger)cols {
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity: (rows + 1) * (cols + 1)];
    NSUInteger xStep = rect.size.width / rows;
    NSUInteger yStep = rect.size.height / cols;
    NSUInteger x = rect.origin.x;
    NSUInteger y = rect.origin.y;
    for (int row = 0; row <= rows; row++) {
        for (int col = 0; col <= cols; col++) {
            CGPoint point = CGPointZero;
            if (row == rows) {
                point.y = rect.size.height - 1 + y;
            } else {
                point.y = row * yStep + y;
            }
            if (col == cols) {
                point.x = rect.size.width - 1 + x;
            } else {
                point.x = col * xStep + x;
            }
            [result addObject: [NSValue valueWithCGPoint:point]];
        }
    }
    return result;
}

+(NSArray *)meshTrianglesIndicesWithRows: (NSUInteger)rows andCols: (NSUInteger)cols {
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity: rows * cols * 6];
    NSUInteger pointCountPerRow = cols + 1;
    for (NSUInteger row = 0; row < rows; row++) {
        for (NSUInteger col = 0; col < cols; col++) {
            NSUInteger leftTopIndex = row * pointCountPerRow + col;
            NSUInteger rightTopIndex = leftTopIndex + 1;
            NSUInteger leftBottomIndex = leftTopIndex + pointCountPerRow;
            NSUInteger rightBottomIndex = leftBottomIndex + 1;
            
            [result addObject: [NSNumber numberWithUnsignedInteger:leftTopIndex]];
            [result addObject: [NSNumber numberWithUnsignedInteger:rightTopIndex]];
            [result addObject: [NSNumber numberWithUnsignedInteger:leftBottomIndex]];
            [result addObject: [NSNumber numberWithUnsignedInteger:rightTopIndex]];
            [result addObject: [NSNumber numberWithUnsignedInteger:leftBottomIndex]];
            [result addObject: [NSNumber numberWithUnsignedInteger:rightBottomIndex]];
        }
    }
    return result;
}

@end


#endif /* MovingLeastSquareHelper_h */
