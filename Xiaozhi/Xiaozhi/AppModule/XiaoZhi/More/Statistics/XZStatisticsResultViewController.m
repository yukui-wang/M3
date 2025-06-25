//
//  XZStatisticsResultViewController.m
//  M3
//
//  Created by wujiansheng on 2018/2/28.
//

#import "XZStatisticsResultViewController.h"
#import "XZStatisticsResultViewCell.h"
#import "XZOpenM3AppHelper.h"
@interface XZStatisticsResultViewController ()<UITableViewDelegate, UITableViewDataSource> {
    UITableView *_tableView;
}

@end

@implementation XZStatisticsResultViewController

- (void)dealloc{
    self.dataList = nil;
    _tableView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self setTitle:@"表单统计"];
    
    UIButton *aBackButton = [UIButton defualtButtonWithFrame:CGRectMake(0, 0, 60, 38) title:[self backBarButtonTitle]];
        [aBackButton setTitleColor:UIColorFromRGB(0x3aadfb) forState:UIControlStateNormal];
    [aBackButton setImage:[UIImage imageNamed:@"ic_banner_return"] forState:UIControlStateNormal];
    aBackButton.titleLabel.font = FONTSYS(16);
    [aBackButton addTarget:self action:@selector(backBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bannerNavigationBar setLeftBarButtonItems:[NSArray arrayWithObject:aBackButton]];

    self.view.backgroundColor = UIColorFromRGB(0xf1f1f1);
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.mainFrame.origin.y+10, self.mainFrame.size.width, self.mainFrame.size.height-10) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = UIColorFromRGB(0xffffff);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"XZStatisticsResultViewCell";
    XZStatisticsResultViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[XZStatisticsResultViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (indexPath.row <self.dataList.count) {
        cell.model = self.dataList[indexPath.row];
    }
    [cell addLineWithRow:indexPath.row RowCount:self.dataList.count separatorLeftMargin:20];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row <self.dataList.count) {
        NSDictionary *mode = self.dataList[indexPath.row];
        NSString *url = [NSString stringWithFormat:@"http://formqueryreport.v5.cmp/v/html/index.html#dostatistics/2/%@?from=from", mode[@"id"]];
        [XZOpenM3AppHelper pushWebviewWithUrl:url nav:self.navigationController];
    }
}
@end
