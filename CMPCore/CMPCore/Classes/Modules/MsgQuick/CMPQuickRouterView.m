//
//  CMPQuickRouterView.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/3/10.
//

#import "CMPQuickRouterView.h"
#import "CMPQuickRouterViewModel.h"
#import "CMPQuickRouterItemView.h"
#import <CMPLib/CMPServerVersionUtils.h>
#import "CMPScanWebViewController.h"
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPNavigationController.h>
#import <CMPLib/CMPCachedResManager.h>
#import "CMPMessageManager.h"
#import <CMPLib/MSWeakTimer.h>
#import "CMPCheckUpdateManager.h"
#import <CMPLib/NSObject+CMPHUDView.h>
#import "CMPTabBarProvider.h"
@interface CMPQuickRouterView()<CMPAppViewItemDelegate>
{
    UIView *_botLine;
    MSWeakTimer *_timer;
    NSInteger _height;
}
@property (nonatomic,strong) CMPQuickRouterViewModel *viewModel;
@property (nonatomic,strong) UITableView *msgTableView;

@end
@implementation CMPQuickRouterView

- (instancetype)initWithBundleTableView:(UITableView *)tableView frame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _msgTableView = tableView;
        _height = 46;
    }
    return self;
}
- (void)dealloc
{
    [_timer invalidate];
    _timer = nil;
    _viewModel = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(CMPQuickRouterViewModel *)viewModel
{
    if(!_viewModel) {
        _viewModel = [[CMPQuickRouterViewModel alloc] init];
    }
    return _viewModel;
}

-(void)setup
{
    [super setup];
    self.backgroundColor = [UIColor clearColor];
    
    UIView *contentV = [[UIView alloc] init];
    contentV.tag = 11;
    contentV.backgroundColor = [UIColor clearColor];
    [self addSubview:contentV];
    contentV.frame = CGRectMake(0, 0, self.width, self.height-0.5);
    
    _botLine = [[UIView alloc] init];
    _botLine.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];//UIColorFromRGB(0xE4E4E4);
    [self addSubview:_botLine];
    _botLine.frame = CGRectMake(14, self.height-0.5, self.width-28, 0.5);
    
    _timer = [MSWeakTimer scheduledTimerWithTimeInterval:30
                                                                      target:self
                                                                    selector:@selector(refreshData)
                                                                    userInfo:nil
                                                                     repeats:YES
                                                               dispatchQueue:dispatch_get_main_queue()];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(free) name:kNotificationName_UserLogout object:nil];
}

-(void)free
{
    [_timer invalidate];
    _timer = nil;
}

-(void)refreshData
{
    if (![CMPServerVersionUtils serverIsLaterV8_2]) {
        [_timer invalidate];
        _timer = nil;
        _msgTableView.tableHeaderView = nil;
        return;
    }

    __weak typeof(self) wSelf = self;
    [self.viewModel fetchQuickItemsWithResult:^(NSArray<CMPAppModel *> * _Nonnull appList, NSError * _Nonnull error, id  _Nonnull ext) {
        if (!error) {
            [wSelf refreshViews];
        }
    }];
}

-(void)refreshViews
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *_tempArr = [self.viewModel needToShowItemsArr];
        UIView *contentV = [self viewWithTag:11];
        [contentV removeAllSubviews];
        if (!_tempArr || _tempArr.count == 0) {
            self.msgTableView.tableHeaderView = nil;
            return;
        }

        self.msgTableView.tableHeaderView = self;
        
        CGFloat w = contentV.width/_tempArr.count;
        for (int i=0; i<=_tempArr.count-1; i++) {
            CMPAppModel *appModel = _tempArr[i];
            CMPQuickRouterItemView *appView = [[CMPQuickRouterItemView alloc] init];
            appView.delegate = self;
            [appView setModel:appModel];
            [contentV addSubview:appView];
            appView.frame = CGRectMake(i*w, 0, w, self->_height);

            if (i != _tempArr.count-1) {
                UIView *aLine = [[UIView alloc] init];
                aLine.backgroundColor = UIColorFromRGB(0xE4E4E4);
                [appView addSubview:aLine];
                aLine.frame = CGRectMake(w, 17, 0.5, self->_height-34);
            }
        }

    });
}


-(void)cmpAppViewItem:(CMPAppViewItem *)appView didAction:(NSInteger)action model:(CMPAppModel *)model ext:(id)ext
{
    if (!model || !_viewController) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (![[CMPCheckUpdateManager sharedManager] canShowApp]) {
            [self cmp_showHUDWithText:SY_STRING(@"UpdatePackage_updating")];
            return;
        }
        
        if ([model isScanCodeApp]) {
            //ks fix -- V5-48341【UE应用检查-M3-扫码办事】扫描部门群二维码没有任何作用，一直停留在当前页面
            [[CMPMessageManager sharedManager] showScanViewWithUrl:nil viewController:self.viewController];
            return;
        }

        NSString *url = [NSString stringWithFormat:@"http://application.m3.cmp/v1.0.0/layout/m3-transit-page.html?id=%@&from=m3quick", model.appId];;
        NSDictionary *params = @{@"appId":model.appId?:@"",
                                 @"gotoParams":model.gotoParam?:@""};
        
        //文档协作、待开会议
        CMPTabBarProvider *tabBarProvider = [[CMPTabBarProvider alloc] init];
        [tabBarProvider appClick:model.appId appName:model.appName uniqueId:@""];//无uniqueId字段数据，model数据由接口m3/entry/fast返回
        
        [[CMPMessageManager sharedManager] showWebviewWithUrl:url viewController:self.viewController params:params actionBlk:^(id params, NSError *error, NSInteger act) {
                    
        }];
    });
}

@end
