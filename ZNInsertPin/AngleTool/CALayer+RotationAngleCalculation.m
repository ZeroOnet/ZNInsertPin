//
//  CALayer+RotationAngleCalculation.m
//  ZNInsertPin
//
//  Created by FunctionMaker on 2017/4/22.
//  Copyright © 2017年 FunctionMaker. All rights reserved.
//

#import "CALayer+RotationAngleCalculation.h"

@implementation CALayer (ZNRotationAngleCalculation)

//#warning  these methods can work effective just with round layer.

- (CGFloat)transformAngleWithRotationDirection:(BOOL)clockwise {
    return clockwise ? [self transformRotationAngle] : 2.0f * M_PI - [self transformRotationAngle];
}

- (CGFloat)transformRotationAngle {
    CGFloat degreeAngle = - atan2f(self.presentationLayer.transform.m21, self.presentationLayer.transform.m22);
    
    if (degreeAngle < 0.0f) {
        degreeAngle += (2.0f * M_PI);
    }
    
    return degreeAngle;
}

- (CGPoint)convertPointWhenRotatingWithBenchmarkPoint:(CGPoint)point roundRadius:(CGFloat)radius {
    CGFloat rotationAngle = [self.presentationLayer transformRotationAngle];

    return CGPointMake(point.x + sinf(rotationAngle) * radius, point.y - radius + cosf(rotationAngle) * radius);
}

@end
