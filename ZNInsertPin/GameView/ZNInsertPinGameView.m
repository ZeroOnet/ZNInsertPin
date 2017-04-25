//
//  ZNInsertPinGameView.m
//  ZNInsertPin
//
//  Created by FunctionMaker on 2017/4/15.
//  Copyright © 2017年 FunctionMaker. All rights reserved.
//

#import "ZNInsertPinGameView.h"
#import "CALayer+RotationAngleCalculation.h"

#define kCentralAxisLayerWidth  (self.frame.size.width / 6.0f)
#define kStrokeRoundRadius      (2.0f * kCentralAxisLayerWidth + kTopRoundRadius)
#define kTopRoundRadius         10.0f

@interface ZNInsertPinGameView ()

@property (strong, nonatomic) UIView *showProcessView;
@property (strong, nonatomic) UILabel *oddRoundsLabel;
@property (strong, nonatomic) UIBezierPath *arrowStrokePath;

@property (strong, nonatomic) CAShapeLayer *centralAxisLayer;
@property (strong, nonatomic) CAKeyframeAnimation *rotation;

@end

@implementation ZNInsertPinGameView {
    NSUInteger _oddRounds;
    NSMutableArray<NSValue *> *_strokeRects;
}

#pragma mark - Initializer

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _strokeRects = [NSMutableArray array];
        _oddRounds = 20;
        
        [self.layer addSublayer:self.centralAxisLayer];
        
        [self addSubview:self.showProcessView];
        [self addSubview:self.oddRoundsLabel];
    }
    
    return self;
}

#pragma mark - Layout subviews

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.centralAxisLayer.frame = CGRectMake(0.0f, 0.0f, kCentralAxisLayerWidth, kCentralAxisLayerWidth);
    self.centralAxisLayer.position = self.center;
    
    self.oddRoundsLabel.frame = CGRectMake(0.0f, 0.0f, 2.0f * kTopRoundRadius, 2.0f * kTopRoundRadius);
    self.oddRoundsLabel.center = CGPointMake(self.center.x, self.center.y + kCentralAxisLayerWidth / 2.0f + 3.0f / 2.0f * kCentralAxisLayerWidth + 7.0f * kTopRoundRadius);
    self.oddRoundsLabel.layer.cornerRadius = kTopRoundRadius;
    
    self.showProcessView.frame = CGRectMake(0.0f, 0.0f, 2.0f * kTopRoundRadius, 3.0f / 2.0f * kCentralAxisLayerWidth + 2.0f * kTopRoundRadius);
    self.showProcessView.center = CGPointMake(self.center.x, self.oddRoundsLabel.center.y - 3.0f / 4.0f * kCentralAxisLayerWidth);
}

#pragma mark - Touch view response

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [UIView animateWithDuration:0.1f animations:^{
        self.showProcessView.hidden = NO;
        
        self.showProcessView.center = CGPointMake(self.center.x, self.center.y + kCentralAxisLayerWidth / 2.0f + 3.0f / 4.0f * kCentralAxisLayerWidth + kTopRoundRadius);
    } completion:^(BOOL finished) {
        self.showProcessView.hidden = YES;
        
        self.showProcessView.center = CGPointMake(self.oddRoundsLabel.center.x, self.oddRoundsLabel.center.y - 3.0f / 4.0f * kCentralAxisLayerWidth);
        CGPoint strokeStartPoint = [self.centralAxisLayer convertPointWhenRotatingWithBenchmarkPoint:CGPointMake(kCentralAxisLayerWidth / 2.0f, kCentralAxisLayerWidth)  roundRadius:kCentralAxisLayerWidth / 2.0f];
        CGPoint strokeEndPoint = [self.centralAxisLayer convertPointWhenRotatingWithBenchmarkPoint:CGPointMake(kCentralAxisLayerWidth / 2.0f, kCentralAxisLayerWidth / 2.0f + kStrokeRoundRadius) roundRadius:kStrokeRoundRadius];

        UIBezierPath *strokeBezier = [UIBezierPath bezierPath];
        
        [strokeBezier moveToPoint:strokeStartPoint];
        [strokeBezier addLineToPoint:strokeEndPoint];
        
        [strokeBezier moveToPoint:strokeEndPoint];
        [strokeBezier addArcWithCenter:strokeEndPoint radius:kTopRoundRadius startAngle:0.0f endAngle:2.0f * M_PI clockwise:YES];
        
        [self changedOddRounds];
        
        [self.arrowStrokePath appendPath:strokeBezier];
        self.centralAxisLayer.path = self.arrowStrokePath.CGPath;
        
        CGRect currentStrokeRect = CGRectMake(strokeEndPoint.x, strokeEndPoint.y, 20.0f, 20.0f);
        
        if ([self isIntersectedStrokedRectWithCurrentRect:currentStrokeRect]) {
            [self gameOver];
        };
    }];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self restartGame];
}

#pragma mark - Private Method

- (BOOL)isIntersectedStrokedRectWithCurrentRect:(CGRect)currentRect {
    __block BOOL result = NO;
    
    [_strokeRects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!(*stop)) {
            CGRect preRect = [obj CGRectValue];
    
            result = CGRectIntersectsRect(preRect, currentRect);
            
            if (result) {
                *stop = YES;
            }
        }
    }];
    
    [_strokeRects addObject:[NSValue valueWithCGRect:currentRect]];
    
    return result;
}

- (void)changedOddRounds {
    self.oddRoundsLabel.text = [NSString stringWithFormat:@"%zd", --_oddRounds];
}

- (void)restartGame {
    _oddRounds = 20;
    self.oddRoundsLabel.text = [NSString stringWithFormat:@"%zd", _oddRounds];
    
    self.arrowStrokePath = nil;
    self.centralAxisLayer.path = nil;
    
    [_strokeRects removeAllObjects];
    
    self.centralAxisLayer.path = self.arrowStrokePath.CGPath;
    [self.centralAxisLayer addAnimation:self.rotation forKey:@"rotation"];
}

- (void)gameOver {
    [self.centralAxisLayer removeAnimationForKey:@"rotation"];
}

#pragma mark - getters

- (UIView *)showProcessView {
    if (!_showProcessView) {
        _showProcessView = [[UIView alloc] init];
        _showProcessView.backgroundColor = [UIColor clearColor];
        _showProcessView.hidden = YES;
        
        UIView *roundBottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 2.0f * kTopRoundRadius, 2.0f * kTopRoundRadius)];
        roundBottomView.center = CGPointMake(kTopRoundRadius, 3.0f / 2.0f * kCentralAxisLayerWidth + kTopRoundRadius);
        roundBottomView.backgroundColor = [UIColor blackColor];
        roundBottomView.layer.cornerRadius = kTopRoundRadius;
        roundBottomView.layer.masksToBounds = YES;
        
        [_showProcessView addSubview:roundBottomView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 2.0f, 3.0f / 2.0f * kCentralAxisLayerWidth)];
        lineView.center = CGPointMake(kTopRoundRadius, 3.0f / 4.0f * kCentralAxisLayerWidth);
        lineView.backgroundColor = [UIColor blackColor];
        
        [_showProcessView addSubview:lineView];
    }
    
    return _showProcessView;
}

- (UILabel *)oddRoundsLabel {
    if (!_oddRoundsLabel) {
        _oddRoundsLabel = [[UILabel alloc] init];
        _oddRoundsLabel.layer.cornerRadius = kTopRoundRadius;
        _oddRoundsLabel.layer.masksToBounds = YES;
        _oddRoundsLabel.backgroundColor = [UIColor blackColor];
        _oddRoundsLabel.textColor = [UIColor whiteColor];
        _oddRoundsLabel.textAlignment = NSTextAlignmentCenter;
        _oddRoundsLabel.font = [UIFont systemFontOfSize:13.0f];
        _oddRoundsLabel.text = [NSString stringWithFormat:@"%zd", _oddRounds];
    }
    
    return _oddRoundsLabel;
}

- (UIBezierPath *)arrowStrokePath {
    if (!_arrowStrokePath) {
        _arrowStrokePath = [UIBezierPath bezierPath];

        CGPoint centralAxisStrokeCenter = CGPointMake(kCentralAxisLayerWidth / 2.0f, kCentralAxisLayerWidth);
        [_arrowStrokePath moveToPoint:centralAxisStrokeCenter];
    
        CGPoint strokeEndPoint = CGPointMake(centralAxisStrokeCenter.x, centralAxisStrokeCenter.y + kStrokeRoundRadius - kCentralAxisLayerWidth / 2.0f);
        
        [_arrowStrokePath addLineToPoint:strokeEndPoint];
    
        [_arrowStrokePath moveToPoint:strokeEndPoint];
    
        [_arrowStrokePath addArcWithCenter:CGPointMake(strokeEndPoint.x, strokeEndPoint.y) radius:kTopRoundRadius startAngle:0.0f endAngle:2.0f * M_PI clockwise:YES];
        
        [_strokeRects addObject:[NSValue valueWithCGRect:CGRectMake(strokeEndPoint.x, strokeEndPoint.y, 20.0f, 20.0f)]];
    }
    
    return _arrowStrokePath;
}

- (CAShapeLayer *)centralAxisLayer {
    if (!_centralAxisLayer) {
        _centralAxisLayer = [CAShapeLayer layer];
        _centralAxisLayer.backgroundColor = [UIColor blackColor].CGColor;
        _centralAxisLayer.cornerRadius = self.frame.size.width / 12.0f;
        _centralAxisLayer.path = self.arrowStrokePath.CGPath;
        _centralAxisLayer.lineWidth = 2.0f;
        _centralAxisLayer.strokeColor = [UIColor blackColor].CGColor;
        _centralAxisLayer.fillColor = [UIColor blackColor].CGColor;
        
        [_centralAxisLayer addAnimation:self.rotation forKey:@"rotation"];
    }
    
    return _centralAxisLayer;
}

- (CAKeyframeAnimation *)rotation {
    if (!_rotation) {
        _rotation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
        _rotation.values = @[@0.0f, @(2.0f * M_PI)];
        _rotation.duration = 3.0f;
        _rotation.removedOnCompletion = NO;
        _rotation.repeatCount = INFINITY;
        _rotation.fillMode = kCAFillModeForwards;
    }
    
    return _rotation;
}

@end
