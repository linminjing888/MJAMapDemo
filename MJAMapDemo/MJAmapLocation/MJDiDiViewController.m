//
//  MJDiDiViewController.m
//  MJAMapDemo
//
//  Created by YXCZ on 2018/1/26.
//  Copyright © 2018年 JingJing_Lin. All rights reserved.
//

#import "MJDiDiViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "MJPoiResultViewController.h"
#import "MBProgressHUD+JDragon.h"
#import "MJMapHeader.h"

@interface MJDiDiViewController ()<MAMapViewDelegate,AMapSearchDelegate,CAAnimationDelegate>

/// 地图视图
@property (nonatomic, strong) MAMapView *mapView;
/// 搜索API
@property (nonatomic, strong) AMapSearchAPI *search;
/// 中心视图
@property (nonatomic, strong) UIImageView *centerAnnotationView;
/// 定位Btn
@property (nonatomic, strong) UIButton *locationBtn;
/// 当前地址
@property (nonatomic, copy) NSString *currentAddress;
/// 上锁，防止一直重复定位
@property (nonatomic, assign) BOOL isLocated;
@property (nonatomic, strong) UILabel * textLabel;

@property (nonatomic, strong) CALayer * animationLayer;

@end

@implementation MJDiDiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, MJStatusAndNavHeight, SCREEN_WIDTH, SCREEN_HEIGHT/2)];
    self.mapView.delegate = self;
    self.mapView.zoomLevel = 15;
    //显示用户位置
    self.mapView.showsUserLocation = YES;
    [self.view addSubview:self.mapView];
    
    self.isLocated = NO;
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    [self setupViews];
}
-(void)setupViews{
    self.centerAnnotationView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wateRedBlank"]];
    self.centerAnnotationView.center = CGPointMake(self.mapView.center.x, self.mapView.center.y - MJStatusAndNavHeight - CGRectGetHeight(self.centerAnnotationView.bounds) / 2);
    [self.mapView addSubview:self.centerAnnotationView];
    
    self.locationBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.mapView.bounds) - 40, CGRectGetMaxY(self.mapView.frame) - 50, 32, 32)];
    self.locationBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.locationBtn.backgroundColor = [UIColor whiteColor];
    self.locationBtn.layer.cornerRadius = 3;
    [self.locationBtn addTarget:self action:@selector(actionLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.locationBtn setImage:[UIImage imageNamed:@"gpsnormal"] forState:UIControlStateNormal];
    [self.view addSubview:self.locationBtn];
    
    UILabel * textLabel = [[UILabel alloc]init];
    textLabel.text =  @"";
    textLabel.numberOfLines = 0;
    textLabel.frame = CGRectMake(30, CGRectGetMaxY(self.mapView.frame) + 60, SCREEN_WIDTH-60, 100);
    textLabel.textColor = [UIColor darkGrayColor];
    self.textLabel = textLabel;
    [self.view addSubview:textLabel];
}
-(void)actionLocation{
    
    if (self.mapView.userTrackingMode == MAUserTrackingModeFollow){
        
        [self.mapView setUserTrackingMode:MAUserTrackingModeNone animated:YES];
    }else{
        
        [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            // 因为下面这句的动画有bug，所以要延迟0.5s执行，动画由上一句产生
            [self.mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
        });
    }
}

#pragma mark - MapViewDelegate

//地图区域改变完成后会调用此接口
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {

    
    if (self.mapView.userTrackingMode == MAUserTrackingModeNone) {
        [self SearchAroundAt:self.mapView.centerCoordinate];
    }
}

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"error = %@",error);
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    if(!updatingLocation){
        return ;
        
    }
    if (userLocation.location.horizontalAccuracy < 0){
        return ;
    }
    
    if (!self.isLocated) {
        self.isLocated = YES;
        
        self.mapView.userTrackingMode = MAUserTrackingModeFollow;
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude)];
        [self SearchAroundAt:userLocation.location.coordinate];
    }
}

#pragma mark --- AMapSearchDelegate

-(void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    if (response.regeocode != nil){
        
        self.currentAddress = response.regeocode.formattedAddress;
        MJLog(@"%@ %f %f",response.regeocode.formattedAddress,request.location.latitude,request.location.longitude);
        self.textLabel.text = [NSString stringWithFormat:@"%@\n%f\n%f",response.regeocode.formattedAddress,request.location.latitude,request.location.longitude];
        
    }
}
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    MJLog(@"%@",error);
}

#pragma mark --- 方法
/// 根据中心点去搜索
- (void)SearchAroundAt:(CLLocationCoordinate2D)coordinate
{
    [self searchReGeocodeWithCoordinate:coordinate];
    [self centerAnnotationAnimimate];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
        [self addGroupAnimation];
    });
}
/* 移动窗口水滴弹一下的动画 */
- (void)centerAnnotationAnimimate
{
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGPoint center = self.centerAnnotationView.center;
                         center.y -= 20;
                         [self.centerAnnotationView setCenter:center];}
                     completion:nil];
    
    [UIView animateWithDuration:0.45
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         CGPoint center = self.centerAnnotationView.center;
                         center.y += 20;
                         [self.centerAnnotationView setCenter:center];}
                     completion:nil];
}
-(void)addGroupAnimation{
    
    if (self.animationLayer) {
        [self.animationLayer removeFromSuperlayer];
    }
    
    CGFloat PX = self.centerAnnotationView.frame.size.width/2;
    CGFloat PY = self.centerAnnotationView.frame.size.height;
    
    CALayer * spreadLayer;
    spreadLayer = [CALayer layer];
    CGFloat diameter = 8;  //扩散的基底
    spreadLayer.bounds = CGRectMake(0,0, diameter, diameter);
    spreadLayer.cornerRadius = diameter/2; //设置圆角变为圆形
    spreadLayer.position = CGPointMake(PX, PY);
    spreadLayer.backgroundColor = [[UIColor greenColor] CGColor];
    
    CAMediaTimingFunction * defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    CAAnimationGroup * animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 2;
    animationGroup.repeatCount = 1;//重复无限次  INFINITY
    animationGroup.removedOnCompletion = NO;
    animationGroup.delegate  = self;
    // 速度控制函数
    animationGroup.timingFunction = defaultCurve;
    //尺寸比例动画
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    scaleAnimation.fromValue = @0.5;//开始的大小
    scaleAnimation.toValue = @8.0;//最后的大小
    scaleAnimation.duration = 2;//动画持续时间
    //    scaleAnimation.removedOnCompletion = NO;
    //透明度动画
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.duration = 2;
    opacityAnimation.values = @[@0.4, @0.45,@0];//透明度值的设置
    opacityAnimation.keyTimes = @[@0, @0.2,@1];//关键帧
    //    opacityAnimation.removedOnCompletion = NO;
    animationGroup.animations = @[scaleAnimation, opacityAnimation];//添加到动画组
    [spreadLayer addAnimation:animationGroup forKey:@"pulse"];
    
    CALayer * animationLayer = [[CALayer alloc]init];
    [animationLayer addSublayer:spreadLayer];
    self.animationLayer = animationLayer;
    
    [self.centerAnnotationView.layer insertSublayer:self.animationLayer below:self.centerAnnotationView.layer];//把扩散层放到头像按钮下面
}

/* 根据中心点坐标来搜周边的POI. */
//- (void)searchPoiWithCenterCoordinate:(CLLocationCoordinate2D )coord
//{
//    AMapPOIAroundSearchRequest*request = [[AMapPOIAroundSearchRequest alloc] init];
//
//    request.location = [AMapGeoPoint locationWithLatitude:coord.latitude  longitude:coord.longitude];
//
//    /// 查询半径
//    request.radius   = 1000;
//    request.types = @"住宅|楼宇|商场";
//    /// 距离排序
//    request.sortrule = 0;
//    [self.search AMapPOIAroundSearch:request];
//}

/* 根据中心点坐标来请求逆地理编码 */
- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension = YES;
    
    [self.search AMapReGoecodeSearch:regeo];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
    
//    if (self.animationLayer) {
//        [self.animationLayer removeFromSuperlayer];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
