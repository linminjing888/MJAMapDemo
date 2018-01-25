//
//  MJMapViewController.h
//  MJAMapDemo
//
//  Created by YXCZ on 2018/1/25.
//  Copyright © 2018年 JingJing_Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MJMapViewController : UIViewController

///纬度（垂直方向）、经度（水平方向）
@property (nonatomic,copy) void(^selectPoiBlock)(NSString * address, CGFloat latitude,CGFloat longitude);

@end
