
#import <UIKit/UIKit.h>

@interface MLSMesh: NSObject

@property(nonatomic, readonly, assign) NSInteger width;
@property(nonatomic, readonly, assign) NSInteger height;
@property(nonatomic, strong) NSArray *baseControlPoints;
@property(nonatomic, readonly, strong) NSArray *originPoints;
@property(nonatomic, readonly, strong) NSArray *deformedPoints;
@property(nonatomic, readonly, strong) NSArray *trianglesIndices;

-(instancetype)initWithWidth: (NSInteger)width andHeight: (NSInteger)height;

-(void)setupWithRows: (NSUInteger)rows andCols: (NSUInteger)cols;

-(void)setupWithRect: (CGRect)rect andRows: (NSUInteger)rows andCols: (NSUInteger)cols;


-(BOOL)doMovingLeastSquareDefromFrom: (NSArray *)controlPoints to: (NSArray *)targetPoints;
-(BOOL)doMovingLeastSquareDefromTo: (NSArray *)targetPoints;

-(BOOL)isEmpty;

@end

@interface MovingLeastSquareHelper : NSObject

/// 对网格点进行移动最小二乘变形
///
/// GridPoints 网格点数组 CGPoint数组
/// ControlPoints 原始控制点 CGPoint数组
/// TargetPoints 控制点目的位置 CGPoint数组
+(NSArray *)doMovingLeastSquareDeformForGridPoints: (NSArray *)gridPoints withControlPoints: (NSArray *)controlPoints toTargetPoints: (NSArray *)targetPoints;

/// 计算出指定大小矩形的M行N列网格点阵
+(NSArray *)createMeshPointsForSize: (CGSize)size withRows: (NSUInteger)rows andCols: (NSUInteger)cols;

/// 计算出指定大小矩形的M行N列网格点阵
+(NSArray *)createMeshPointsForRect: (CGRect)rect withRows: (NSUInteger)rows andCols: (NSUInteger)cols;

/// 获得M行N列网格三角形点阵序列
+(NSArray *)meshTrianglesIndicesWithRows: (NSUInteger)rows andCols: (NSUInteger)cols;

@end

