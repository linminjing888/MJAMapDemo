//
//  MJPoiResultViewController.m
//  MJAMapDemo
//
//  Created by YXCZ on 2018/1/25.
//  Copyright © 2018年 JingJing_Lin. All rights reserved.
//

#import "MJPoiResultViewController.h"
#import "MJPoiTableViewCell.h"
#import "MJMapHeader.h"

@interface MJPoiResultViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) int selectedIndex;

@end

@implementation MJPoiResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedIndex = -1;
    
    [self setMyTableView];
}
- (void)setResultListArray:(NSArray *)resultListArray{
    if (resultListArray != nil) {
        _resultListArray = nil;
        _resultListArray = resultListArray;
        [self.tableView reloadData];
        
        if (_resultListArray.count!=0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:(UITableViewScrollPositionTop) animated:NO];
        }
    }
}
- (void)setMyTableView{
    
    CGFloat H = SCREEN_HEIGHT-(MJStatusAndNavHeight+MapH+titleViH)-MJTabbarSafeBottomMargin;
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, H) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellID"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MJPoiTableViewCell" bundle:nil] forCellReuseIdentifier:POITableViewCellIdentifier];
    [self.view addSubview:self.tableView];
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:view];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (self.resultListArray.count != 0)?(self.resultListArray.count):(0);// http://freevpnss.cc
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 62.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MJPoiTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:POITableViewCellIdentifier forIndexPath:indexPath];
    AMapPOI *POI = self.resultListArray[indexPath.row];
    cell.nameLabel.text = POI.name;
    cell.infoLabel.text = POI.address;
    cell.selectedImageView.hidden = indexPath.row == self.selectedIndex ? NO : YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedIndex = (int)indexPath.row;
    [self.tableView reloadData];
    
    AMapPOI *POI = self.resultListArray[indexPath.row];
    self.poiListBlock(POI);
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
