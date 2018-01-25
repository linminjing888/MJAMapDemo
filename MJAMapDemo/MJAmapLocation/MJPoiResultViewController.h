//
//  MJPoiResultViewController.h
//  MJAMapDemo
//
//  Created by YXCZ on 2018/1/25.
//  Copyright © 2018年 JingJing_Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

static const CGFloat MapH =  300.0f;
static const CGFloat titleViH =  44.0f;

@interface MJPoiResultViewController : UIViewController

@property (nonatomic,strong)NSArray *resultListArray;

@property (nonatomic,copy) void(^poiListBlock)(AMapPOI * poi);

@end
