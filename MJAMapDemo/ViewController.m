//
//  ViewController.m
//  MJAMapDemo
//
//  Created by YXCZ on 2018/1/25.
//  Copyright © 2018年 JingJing_Lin. All rights reserved.
//

#import "ViewController.h"
#import "MJMapHeader.h"
#import "MJMapViewController.h"

@interface ViewController ()
@property (nonatomic,strong) UILabel * textLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton * locationBtn =[[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-100)/2, 260, 100, 50)];
    [locationBtn setTitle:@"获取定位" forState:UIControlStateNormal];
    [locationBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [locationBtn  addTarget:self action:@selector(locationAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locationBtn];
    
    
    UILabel * textLabel = [[UILabel alloc]init];
    textLabel.text =  @"";
    textLabel.numberOfLines = 0;
    textLabel.frame = CGRectMake(30, 320, SCREEN_WIDTH-60, 100);
    textLabel.textColor = [UIColor darkGrayColor];
    self.textLabel = textLabel;
    [self.view addSubview:textLabel];
}
-(void)locationAction{
    
    MJMapViewController * VC =[[MJMapViewController alloc]init];
    VC.selectPoiBlock = ^(NSString *address, CGFloat latitude, CGFloat longitude) {
        self.textLabel.text = [NSString stringWithFormat:@"地址：\n%@\n纬度：%f\n经度：%f",address,latitude,longitude];
    };
    [self.navigationController pushViewController:VC animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
