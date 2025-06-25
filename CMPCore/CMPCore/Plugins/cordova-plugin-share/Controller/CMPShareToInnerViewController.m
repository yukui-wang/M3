//
//  CMPShareToInnerViewController.m
//  M3
//
//  Created by MacBook on 2019/10/28.
//

#import "CMPShareToInnerViewController.h"
#import "CMPShareCellModel.h"
#import "CMPShareToInnerCell.h"
#import "CMPShareImageView.h"
#import "CMPShareFileView.h"
#import "CMPMessageForwardView.h"
#import "CMPRCChatViewController.h"
#import "CMPMessageManager.h"
#import "CMPShareToUcManager.h"
#import "CMPVideoMessage.h"
#import "CMPTabBarViewController.h"
#import "AppDelegate.h"
#import "CMPChatManager.h"

#import <RongIMKit/RongIMKit.h>
#import <CMPLib/FCFileManager.h>
#import <CMPLib/AFNetworking.h>
#import <CMPLib/YYModel.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/CMPFileTypeHandler.h>
#import <CMPLib/CMPFileManager.h>
#import <RongIMKit/RongIMKit.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPBannerWebViewController+Create.h>
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPPopOverManager.h>
#import <CMPLib/CMPSplitViewController.h>
#import <CMPLib/CMPUploadFileTool.h>
#import <CMPLib/YBImageBrowserTipView.h>
#import "CMPSelectContactViewController.h"
#import "CMPPrivilegeManager.h"

static NSString * const CMPShareToInnerCellListPlist = @"CMPShareToInnerCellList.plist";
static NSString * const CMPShareToInnerCellListPlist1 = @"CMPShareToInnerCellList1.plist";

@interface CMPShareToInnerViewController ()<UITableViewDelegate,UITableViewDataSource,CMPDataProviderDelegate>

/* tableView */
@property (strong, nonatomic) UITableView *tableView;
/* dataArray */
@property (copy, nonatomic) NSArray *dataArray;
/* forwardView */
@property (weak, nonatomic) CMPMessageForwardView *forwardView;

@end

@implementation CMPShareToInnerViewController

#pragma mark - 初始化、销毁 相关
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 50.f;
        _tableView.backgroundColor = UIColor.clearColor;
//        [_tableView registerNib:[UINib nibWithNibName:@"CMPShareToInnerCell" bundle:nil] forCellReuseIdentifier:CMPShareToInnerCellId];
        [_tableView registerClass:NSClassFromString(@"CMPShareToInnerCell") forCellReuseIdentifier:CMPShareToInnerCellId];
    }
    return _tableView;
}

- (void)dealloc {
    DDLogDebug(@"%s",__func__);
    
    if (_vcDissmissed) {
        _vcDissmissed();
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hideBannerNavBar = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor cmp_colorWithName:@"p-bg"];
    
    self.bannerNavigationBar.bannerTitleView.text = SY_STRING(@"share_share_to_innner_title");
    self.tableView.cmp_y = CGRectGetMaxY(self.bannerNavigationBar.frame);
    [self.view addSubview:self.tableView];
    [self configureHeaderView];
    [self loadPlist];
}

- (void)setupBannerButtons
{
    self.bannerNavigationBar.leftViewsMargin = 0.0f;
    self.bannerNavigationBar.rightViewsMargin = 10.0f;
    self.bannerNavigationBar.leftMargin = 14.0f;
    self.bannerNavigationBar.rightMargin = 0.0f;
    [self.bannerNavigationBar setBannerBackgroundColor:[UIColor cmp_colorWithName:@"white-bg"]];
    self.statusBarView.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
    self.backBarButtonItemHidden = YES;
    [self.bannerNavigationBar hideBottomLine:YES];
    UIButton *closeItem = [[UIButton alloc] initWithFrame:CGRectMake(12.f, 0, 20.f, 20.f)];
    closeItem.contentMode = UIViewContentModeCenter;
    
    UIImage *closeImg = [[UIImage imageNamed:@"ic_banner_close"] cmp_imageWithTintColor:[CMPThemeManager sharedManager].iconColor];
    [closeItem setImage:closeImg forState:UIControlStateNormal];
    [closeItem addTarget:self action:@selector(closeClicked) forControlEvents:UIControlEventTouchUpInside];
    self.bannerNavigationBar.leftBarButtonItems = @[closeItem];
}

- (void)loadPlist {
    NSString *path = [NSBundle.mainBundle pathForResource:CMPShareToInnerCellListPlist ofType:nil];
    if (!CMPCore.sharedInstance.serverIsLaterV8_0) {
        path = [NSBundle.mainBundle pathForResource:CMPShareToInnerCellListPlist1 ofType:nil];
    }
    if (path) {
        NSMutableArray *tmpArr = [NSMutableArray array];
        NSArray *arr = [NSArray arrayWithContentsOfFile:path];
        NSInteger count = arr.count;
        for (NSInteger i = 0; i < count; i++) {
            id data = arr[i];
            if ([data isKindOfClass: [NSArray class]]) {
                NSArray *tmpData = (NSArray *)data;
                NSMutableArray *tmpArr1 = [NSMutableArray array];
                NSInteger count1 = tmpData.count;
                for (NSInteger j = 0; j < count1; j++) {
                    NSDictionary *dic = tmpData[j];
                    CMPShareCellModel *model = [CMPShareCellModel yy_modelWithDictionary:dic];
                    if (model.shareType == CMPShareTypeChat && CMPMessageManager.sharedManager.hasZhiXinPermissionAndServerAvailable == NO) {
                        continue;
                    } else if (model.shareType == CMPShareTypeFileAssistant && CMPMessageManager.sharedManager.hasZhiXinPermissionAndServerAvailable == NO) {
                        continue;
                    } else if (model.shareType == CMPShareTypeDocCenter && [CMPFeatureSupportControl isSupportCollect] == NO) {
                        continue;
                    } else if (model.shareType == CMPShareTypeNewCoaop && [CMPPrivilegeManager getCurrentUserPrivilege].hasColNew == NO) {
                        continue;
                    }
                    [tmpArr1 addObject:model];
                }
                [tmpArr addObject:tmpArr1.copy];
            }else {
                CMPShareCellModel *model = [CMPShareCellModel yy_modelWithDictionary:data];
                [tmpArr addObject:model];
            }
            
        }
        self.dataArray = tmpArr.copy;
        [self.tableView reloadData];
    }
}

- (void)configureHeaderView {
    NSString *firstFilepath = self.filePaths.firstObject;
    NSString *mineType = [CMPFileTypeHandler getFileMineTypeWithFilePath:firstFilepath];
    NSString *judgeType = mineType.pathComponents.firstObject;
    if ([judgeType isEqualToString:@"image"] || [judgeType isEqualToString:@"video"]) {
        CMPShareImageView *imageView = [CMPShareImageView imageViewWithFrame:CGRectMake(0, 0, self.view.width, 230.f) image:firstFilepath shareFileCount:self.filePaths.count];
        imageView.isVideo = [judgeType isEqualToString:@"video"];
        self.tableView.tableHeaderView = imageView;
    }else {
        CMPShareFileView *fileView = [CMPShareFileView fileViewWithFrame:CGRectMake(0, 0, self.view.width, 170.f) filePath:firstFilepath shareFileCount:self.filePaths.count];
        self.tableView.tableHeaderView = fileView;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if ([CMPThemeManager.sharedManager.currentThemeInterfaceStyle isEqualToString:CMPThemeInterfaceStyleDark]) {
        return UIStatusBarStyleLightContent;
    }
    
    return UIStatusBarStyleDefault;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = self.dataArray[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMPShareToInnerCell *cell = [tableView dequeueReusableCellWithIdentifier:CMPShareToInnerCellId forIndexPath:indexPath];
    NSArray *tmpArr = self.dataArray[indexPath.section];
    CMPShareCellModel *model = tmpArr[indexPath.row];
    cell.model = model;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *arr = self.dataArray[indexPath.section];
    CMPShareCellModel *model = arr[indexPath.row];
    
    switch (model.shareType) {
        case CMPShareTypeChat:
        {
            //发起聊天
            [self showSelectContactView];
        }
            break;
        case CMPShareTypeFileAssistant:
        {
            //文件助手
            [self sendMsgToFileAssistant];
        }
            break;
        case CMPShareTypeMyFiles:
        {
            //保存到我的文件
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self saveToMyfiles];
            });
        }
            break;
        case CMPShareTypeNewCoaop:
        {
                //新建协同
            [self uploadfileWithType:@"newCollaboration" appId:@"1"];
        }
                
            break;
        
        case CMPShareTypeDocCenter:
        {
            //其他文档夹
            [self uploadfileWithType:@"otherDoc" appId:@"3"];
            
        }
            break;
        
        default:
            break;
    }
    
    
}

#pragma mark header和footer设置
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 14.f;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return UIView.new;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return UIView.new;
}

#pragma mark - IM分享

/// 显示 选择联系人 view
- (void)showSelectContactView {
    __weak typeof(self) weakSelf = self;
    [CMPShareToUcManager.manager showSelectContactViewWithFilePaths:self.filePaths inVC:self willForwardMsg:^{
        [MBProgressHUD cmp_showProgressHUDInView:weakSelf.fromWindow];
    } forwardSucess:nil forwardSucessWithMsgObj:^(CMPMessageObject * _Nonnull msgObj, NSArray * _Nonnull fileList) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD cmp_hideProgressHUD];
            UIViewController *vc =  weakSelf.navigationController.topViewController;
            if ([vc isKindOfClass:[CMPSelectContactViewController class]]) {
                [weakSelf.navigationController dismissViewControllerAnimated:NO completion:^{
                    [CMPMessageManager.sharedManager showChatView:msgObj viewController:weakSelf.fromVC filePaths:weakSelf.filePaths];
                }];
            } else {
                [weakSelf.presentingViewController dismissViewControllerAnimated:NO completion:^{
                    [CMPMessageManager.sharedManager showChatView:msgObj viewController:nil filePaths:weakSelf.filePaths];
                }];
            }
    
        });
    } forwardFailed:nil];
}


/// 保存到我的文件
- (void)saveToMyfiles {
    
    for (NSString *filePath in self.filePaths) {
        CMPFile *aFile = [[CMPFile alloc] init];
        aFile.filePath = filePath;
        aFile.fileID = [NSString uuid];
        aFile.fileName = filePath.lastPathComponent;
        aFile.from = @"外部APP";
        aFile.fromType = CMPFileFromTypeComeFromThird;
        aFile.origin = nil;
        [CMPFileManager.defaultManager saveFile:aFile];
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:SY_STRING(@"file_management_save_ro_file_success_from_other_tips") message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAc = [UIAlertAction actionWithTitle:SY_STRING(@"common_ok") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertVc addAction:confirmAc];
        [self.navigationController presentViewController:alertVc animated:YES completion:nil];
    });
}

#pragma mark - 按钮点击

/// 关闭按钮点击
- (void)closeClicked {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 文件助手文件发送相关

- (void)sendMsgToFileAssistant {
    NSString *cId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    //调用不影响ui发送，因为发生的对象不是当前ui不要关心
    CMPMessageObject *tagMsg = [[CMPMessageObject alloc] initFileAssistantMessageWithAppID:cId];
    [CMPMessageManager.sharedManager showChatView:tagMsg viewController:self.fromVC filePaths:self.filePaths];

    [self closeClicked];
   
}

#pragma mark - 分享到 文档中心
/**
第三方APP分享到M3内部
分享到其他文件夹，走老逻辑你加载我们之前的中间页面
中间页面地址：http://cmp/v1.0.0/page/cmp-share.html
pushPage的参数：{
      appId: '文档的应用ID',
      params: {paths:[.........],
      type:"MyDoc"   、 "otherDoc"
 }
}
*/

/// 上传文件至服务器
/// @param type 保存到的类型
- (void)uploadfileWithType:(NSString *)type appId:(NSString *)appId {
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    
    NSMutableDictionary *pParams = NSMutableDictionary.dictionary;
    pParams[@"paths"] = self.filePaths;
    pParams[@"type"] = type;
    
    NSMutableDictionary *param = NSMutableDictionary.dictionary;
    param[@"appId"] = appId;
    param[@"params"] = pParams;
    
    CMPTabBarViewController *tabBarViewController = [AppDelegate shareAppDelegate].tabBarViewController;
    UIViewController *selectedViewController = tabBarViewController.selectedViewController;
    UINavigationController *nav = nil;
    if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
        nav = (UINavigationController *)selectedViewController;
    } else {
        nav = (UINavigationController *)((CMPSplitViewController *)selectedViewController).detailNavigation;
    }
    UIViewController *vc = nav.viewControllers.lastObject;
    CMPBannerWebViewController *webVC = [CMPBannerWebViewController bannerWebView1WithUrl:CMPShareFromAppsToMyDoUrl params:param];
    [CMPCommonTool pushInDetailWithViewController:webVC in:vc];
    
}

@end
