//
//  CMPSelectItemView.m
//  M3
//
//  Created by MacBook on 2019/11/4.
//

#import "CMPSelectItemView.h"
#import "CMPSelectItemCell.h"
#import "CMPShareCellModel.h"
#import "CMPFileManagementManager.h"
#import "CMPShareManager.h"

#import <CMPLib/CMPFileManagementRecord.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/YBIBUtilities.h>
#import <CMPLib/CMPBannerWebViewController.h>

static CGFloat const kIphoneXMargin = 15.f;

@interface CMPSelectItemView()<UITableViewDelegate,UITableViewDataSource>

/* tableView */
@property (strong, nonatomic) UITableView *tableView;
/* dataArray */
@property (copy, nonatomic) NSArray *dataArray;

@end

@implementation CMPSelectItemView

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = UIColor.clearColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.scrollEnabled = NO;
        [_tableView registerNib:[UINib nibWithNibName:@"CMPSelectItemCell" bundle:nil] forCellReuseIdentifier:CMPSelectItemCellId];
    }
    return _tableView;
}

- (void)loadDataArray {
    NSMutableArray *dataArray = [NSMutableArray array];
    NSArray *dataArr = @[@{@"title" : SY_STRING(@"common_read"), @"index" : @"0"},
    @{@"title" : SY_STRING(@"print_action"), @"index" : @"1"},
    @{@"title" : SY_STRING(@"Share"), @"index" : @"2"},
    @{@"title" : SY_STRING(@"common_cancel"), @"index" : @"3"}];
    
    for (NSDictionary *dic in dataArr) {
        CMPShareCellModel *check = [[CMPShareCellModel alloc] init];
        check.title = dic[@"title"];
        check.index = dic[@"index"];
        [dataArray addObject:check];
    }
    self.dataArray = dataArray.copy;
    [self.tableView reloadData];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (YBIBUtilities.isIphoneX) {
            self.cmp_height += kIphoneXMargin;
        }
        [self addSubview:self.tableView];
        [self loadDataArray];
    }
    return self;
}

- (void)dealloc {
    DDLogDebug(@"---%s----",__func__);
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    _tableView.frame = self.bounds;
    if (YBIBUtilities.isIphoneX) {
        _tableView.cmp_height -= kIphoneXMargin;
    }
    _tableView.rowHeight = _tableView.height/_dataArray.count;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMPSelectItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CMPSelectItemCellId forIndexPath:indexPath];
    CMPShareCellModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CMPShareCellModel *model = self.dataArray[indexPath.row];
    
    switch (model.index.intValue) {
        case 0:
        {
            //查看文件
//            [self showFilePreview:self.mfr];
        }
            break;
        case 1:
        {
            //打印
            
        }
            break;
        case 2:
        {
            //分享
            [self shareClicked];
        }
            break;
            
        default:
            break;
    }
    
    //取消
    [self.viewController touchesBegan:nil withEvent:nil];
}

#pragma mark - tableViewCell点击响应


- (void)shareClicked {
    [CMPShareManager.manager showShareViewWithList:nil mfr:_mfr];
//    NSDictionary *options = @{@"animated" : @"0",@"clearDetailPad" : @"1",@"inStack" : @"1",@"openWebview" : @"1",@"pushInDetailPad" : @"0", @"replaceTop" : @"0", @"useNativebanner" : @"0"};
//    NSDictionary *param = @{@"appId" : @"1",@"from" : @"internalShare", @"shareType" : @"file",@"param" : @{@"fileList" : @[@{@"path" : self.mfr.filePath}]}};
//    CMPBannerWebViewController *webViewVC = (CMPBannerWebViewController *)self.pushParentVC;
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    params[@"url"] = @"http://cmp/v1.0.0/page/cmp-app-share.html";
//    params[@"param"] = param;
//    params[@"options"] = options;
//    [webViewVC pushPage:params];
    
}

@end
