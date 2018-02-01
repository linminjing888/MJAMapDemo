//
//  MJPulsingHaloLayer.m
//  MJWaveAnimation
//
//  Created by YXCZ on 2018/2/1.
//  Copyright © 2018年 JingJing_Lin. All rights reserved.
//

#import "MJPulsingHaloLayer.h"

@interface MJPulsingHaloLayer()

@property (nonatomic, strong) CAAnimationGroup *animationGroup;
/// 雷达扩散效果持续时间, 默认:2s
@property (nonatomic, assign) NSTimeInterval animationDuration;

@end
@implementation MJPulsingHaloLayer

//初始化方法
- (id)init {
    self = [super init];
    if (self) {
        // 配置默认参数
        self.cornerRadius = 10;
        self.backgroundColor = [[UIColor greenColor] CGColor];
        self.animationDuration = 2;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self setupAnimationGroup];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self addAnimation:self.animationGroup forKey:@"pulse"];
            });
        });
    }
    return self;
}

- (void)setupAnimationGroup {
    
    CAMediaTimingFunction * defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    
    CAAnimationGroup * animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = self.animationDuration;
    animationGroup.repeatCount = 1;//重复无限次  INFINITY
    animationGroup.removedOnCompletion = NO;
    // 速度控制函数
    animationGroup.timingFunction = defaultCurve;
    //尺寸比例动画
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    scaleAnimation.fromValue = @0.5;//开始的大小
    scaleAnimation.toValue = @10.0;//最后的大小
    scaleAnimation.duration = 2;//动画持续时间
    //    scaleAnimation.removedOnCompletion = NO;
    //透明度动画
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.duration = self.animationDuration;
    opacityAnimation.values = @[@0.4, @0.45,@0];//透明度值的设置
    opacityAnimation.keyTimes = @[@0, @0.2,@1];//关键帧
    //    opacityAnimation.removedOnCompletion = NO;
    self.animationGroup.animations = @[scaleAnimation, opacityAnimation];//添加到动画组
    
}

@end
