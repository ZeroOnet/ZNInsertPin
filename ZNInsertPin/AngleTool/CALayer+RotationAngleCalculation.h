//
//  CALayer+RotationAngleCalculation.h
//  ZNInsertPin
//
//  Created by FunctionMaker on 2017/4/22.
//  Copyright © 2017年 FunctionMaker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CALayer (ZNRotationAngleCalculation)

- (CGFloat)transformAngleWithRotationDirection:(BOOL)clockwise;

- (CGPoint)convertPointWhenRotatingWithBenchmarkPoint:(CGPoint)point roundRadius:(CGFloat)radius;

@end
