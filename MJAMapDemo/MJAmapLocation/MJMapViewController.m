//
//  MJMapViewController.m
//  MJAMapDemo
//
//  Created by YXCZ on 2018/1/25.
//  Copyright © 2018年 JingJing_Lin. All rights reserved.
//

#import "MJMapViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "MJPoiResultViewController.h"
#import "MBProgressHUD+JDragon.h"
#import "MJMapHeader.h"

@interface MJMapViewController ()<MAMapViewDelegate,AMapLocationManagerDelegate,AMapSearchDelegate>

@property (nonatomic, strong) AMapLocationManager *locationManager;
/// 地图视图
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIView *contentView;
/// 搜索API
@property (nonatomic, strong) AMapSearchAPI *search;
/// 定位数据
@property (nonatomic, assign) CLLocationCoordinate2D currentGPSCoordinate;
@property (nonatomic, copy) NSArray<AMapPOI *> *POIDataArray;
@property (nonatomic,strong)MJPoiResultViewController *poiResultVC;
@end

@implementation MJMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setNavBarItem];
    
    //定位
    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager.delegate = self;
    //高德提供了 kCLLocationAccuracyBest 参数，设置该参数可以获取到精度在10m左右的定位结果，但是相应的需要付出比较长的时间（10s左右）
    //kCLLocationAccuracyHundredMeters，一次还不错的定位，偏差在百米左右，超时时间设置在2s-3s左右即可。
    // 带逆地理信息的一次定位（返回坐标和地址信息）
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    //   定位超时时间，默认为10s。最小值是2s
    self.locationManager.locationTimeout = 5;
    //   逆地理请求超时时间，默认为5s。最小值是2s
    self.locationManager.reGeocodeTimeout  =5;
    
    //地图
    self.mapView = [[MAMapView alloc]initWithFrame:CGRectMake(0, MJStatusAndNavHeight, SCREEN_WIDTH, MapH)];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = NO;
    self.mapView.rotateCameraEnabled = NO;
    self.mapView.rotateEnabled = NO;
    [self.view addSubview:self.mapView];
    
    UILabel * titleLab = [[UILabel alloc]init];
    titleLab.text =  @"我的位置";
    titleLab.frame = CGRectMake(23, (titleViH-20)/2, 100, 20);
    titleLab.textColor = [UIColor blueColor];
    [self.titleView addSubview:titleLab];
    
    MJPoiResultViewController *poiResultVC = [[MJPoiResultViewController alloc]init];
    [self addChildViewController:poiResultVC];
    __weak typeof(self) weakSelf = self;
    [poiResultVC setPoiListBlock:^(AMapPOI * POI) {
        //        [weakSelf.mapView setCenterCoordinate:CLLocationCoordinate2DMake(POI.location.latitude, POI.location.longitude) animated:YES];
        //        [weakSelf.mapView setZoomLevel:19 animated:YES];
        MJLog(@"%@",POI.name);
        weakSelf.selectPoiBlock(POI.address,POI.location.latitude, POI.location.longitude);
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    //搜索
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    [self startLocation];
}

-(void)setNavBarItem{
    self.title = @"地图定位";
    
    UIButton *locationBtn=[UIButton buttonWithType:(UIButtonTypeCustom)];
    [locationBtn setTitle:@"重新定位" forState:UIControlStateNormal];
    [locationBtn addTarget:self action:@selector(startLocation) forControlEvents:UIControlEventTouchUpInside];
    [locationBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    locationBtn.frame = CGRectMake(0, 0, 60, 25);
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithCustomView:locationBtn];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
}

//开始定位
- (void)startLocation {
    
    self.currentGPSCoordinate = kCLLocationCoordinate2DInvalid;  //一开始要设置为非法值，等定位成功才设置有效值
    [MBProgressHUD showActivityMessageInView:@"定位中..."];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    __weak typeof(self) weakSelf = self;
    // 是否带有逆地理信息 YES/NO
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        
        [MBProgressHUD hideHUD];
        if (error) {
            [MBProgressHUD showTipMessageInView:@"定位失败,请重新定位"];
            MJLog(@"定位错误:{%ld - %@};", (long)error.code, error.localizedDescription);
            return;
        }
        
        MJLog(@"坐标:%@",location);
        if (regeocode) {
            MJLog(@"信息地址:%@",regeocode);
        }
        
        weakSelf.currentGPSCoordinate = location.coordinate;
        
        //添加定位点的大头针
        MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
        annotation.coordinate = location.coordinate;
        [weakSelf.mapView addAnnotation:annotation];
        annotation.lockedToScreen = YES;
        annotation.lockedScreenPoint = CGPointMake(weakSelf.mapView.bounds.size.width / 2, weakSelf.mapView.bounds.size.height / 2) ;
        
        //设置地图
        [weakSelf.mapView setZoomLevel:15.5 animated:YES];
        [weakSelf.mapView selectAnnotation:annotation animated:YES];
        [weakSelf.mapView setCenterCoordinate:location.coordinate animated:NO];
        
        //        //搜索POI
        [weakSelf searchAllPOIAround:location.coordinate];
    }];
}

//搜索周边POI
- (void)searchAllPOIAround:(CLLocationCoordinate2D)coordinate {
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.sortrule = 0;
    request.offset = 30;
    request.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    request.radius = 500;
    [self.search AMapPOIAroundSearch:request];
}

#pragma mark --- MAMapViewDelegate

//地图区域改变完成后会调用此接口
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    if (!CLLocationCoordinate2DIsValid(self.currentGPSCoordinate)) {  //非法的时候需返回
        return;
    }
    
    MJPoiResultViewController *poiResultVC = (MJPoiResultViewController *)self.childViewControllers[0];
    self.poiResultVC = poiResultVC;
    [self.contentView addSubview:poiResultVC.view];
    
    //搜索POI
    [self searchAllPOIAround:mapView.centerCoordinate];
    
}
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        
        MAPinAnnotationView *annotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil) {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        
        annotationView.canShowCallout = NO;
        annotationView.animatesDrop = YES;
        annotationView.draggable = NO;
        
        return annotationView;
    }
    
    return nil;
}

#pragma mark --- AMapSearchDelegate

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    self.POIDataArray = response.pois;
    self.poiResultVC.resultListArray = response.pois;
    
}

#pragma mark --- 视图

- (UIView *)titleView{
    if (_titleView == nil) {
        _titleView = [[UIView alloc]init];
        _titleView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:NO] ;
        _titleView.frame = CGRectMake(0, MJStatusAndNavHeight+MapH, SCREEN_WIDTH, titleViH);
        [self.view addSubview:_titleView];
    }
    return _titleView;
}
- (UIView *)contentView{
    if (_contentView == nil) {
        CGFloat Y = MJStatusAndNavHeight+MapH+titleViH;
        CGFloat H = SCREEN_HEIGHT-(Y)-MJTabbarSafeBottomMargin;
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.frame = CGRectMake(0, Y, [UIScreen mainScreen].bounds.size.width, H);
        [self.view addSubview:_contentView];
    }
    return _contentView;
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
