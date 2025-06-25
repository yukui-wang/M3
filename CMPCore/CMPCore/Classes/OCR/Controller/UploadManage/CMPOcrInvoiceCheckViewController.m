//
//  CMPOcrInvoiceCheckViewController.m
//  M3
//
//  Created by Shoujian Rao on 2022/1/12.
//

#import "CMPOcrInvoiceCheckViewController.h"
#import "CustomDefine.h"
#import "UIView+Layer.h"
#import <CMPLib/CMPFileManager.h>
#import "CMPOcrItemDBManager.h"
#import <CMPLib/CMPUploadFileTool.h>
#import <CMPLib/YBIBWebImageManager.h>

#import "CMPOcrItemViewModel.h"
#import "CMPOcrInvoiceCheckListCell.h"
#import <CMPLib/CMPAlertView.h>
#import "CMPOcrTipTool.h"

#import "CMPOcrItemManager.h"
#import "CMPOcrDefaultInvoiceViewController.h"
#import "CMPOcrPackageDetailViewController.h"
#import "CMPOcrPackageModel.h"

#import "CMPCustomLeftSwipeTableView.h"
#import <CMPLib/CMPNavigationController.h>

#import <CMPLib/YBImageBrowser.h>
#import <CMPLib/CMPQuickLookPreviewController.h>

@interface CMPOcrInvoiceCheckViewController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic ,strong) CMPCustomLeftSwipeTableView *myTableView;
@property (nonatomic, strong) CMPOcrItemViewModel *itemViewModel;
@property (nonatomic, strong) dispatch_source_t sourceTimer;
@property (nonatomic, strong) NSArray *originalFileArray;
@property (nonatomic, copy) NSString *packageId;
@property (nonatomic, copy) NSString *packageName;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSArray *leftBtnInfoArr;

@property (nonatomic, strong) id ext;

@end

@implementation CMPOcrInvoiceCheckViewController

- (void)dealloc{
    NSLog(@"%@-delloc",self.class);
}

- (instancetype)initWithFileArray:(NSArray *)fileArray package:(CMPOcrPackageModel *)package ext:(id)ext{
    if (self = [super init]) {
        self.ext = ext;
        self.originalFileArray = fileArray;
        self.packageId = package.pid;
        self.packageName = package.name;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self startIntervalCheck];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([self.ext integerValue] == 3) {//表单入口需要强制关闭侧滑返回
        if ([self.navigationController isKindOfClass:CMPNavigationController.class]) {
            CMPNavigationController *navi = (CMPNavigationController *)self.navigationController;
            navi.forceDisablePanGestureBack = YES;
        }
    }
    [self checkInvoice];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    dispatch_source_cancel(_sourceTimer);
    if ([self.ext integerValue] == 3) {//表单入口需要强制关闭侧滑返回
        if ([self.navigationController isKindOfClass:CMPNavigationController.class]) {
            CMPNavigationController *navi = (CMPNavigationController *)self.navigationController;
            navi.forceDisablePanGestureBack = NO;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.title = @"发票识别";
    self.view.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
    
    //左滑删除按钮，适配iOS10及以下
    _leftBtnInfoArr = @[
//        @{@"iconName":@"ocr_card_main_edit",@"title":@""},
        @{@"iconName":@"ocr_card_main_del",@"title":@""},
    ];
    
    //tableView
    [self.view addSubview:self.myTableView];
    [self.myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat top = CGRectGetMaxY(self.bannerNavigationBar.frame);
        make.top.mas_equalTo(top);
        make.left.right.bottom.mas_equalTo(0);
    }];
    
    //同步存入数据库
    for (id obj in _originalFileArray) {
        if ([obj isKindOfClass:CMPOcrFileModel.class]) {
            CMPOcrFileModel *originalFile = obj;
            [[CMPOcrItemManager sharedInstance] saveFileToLocalAndDb:originalFile withPackageId:_packageId];
        }
    }
    NSArray<CMPOcrItemModel *> *arr = [[CMPOcrItemManager sharedInstance] getAllLocalItemByPackageId:self.packageId];
    [self.dataSource addObjectsFromArray:arr];
    
    [self reloadTable];
    __weak typeof(self) weakSelf = self;
    for (CMPOcrItemModel *ocrItem in arr) {
        [[CMPOcrItemManager sharedInstance] beginTaskWithItem:ocrItem callBack:^(CMPOcrItemModel *item, NSError *err) {
            [weakSelf reloadTable];
        }];
    }
}
#pragma mark - 返回按钮
- (void)setupBannerButtons{
    self.bannerNavigationBar.leftMargin = 0;
    self.backBarButtonItemHidden = YES;
    UIButton *backButton = [UIButton buttonWithImageName:@"navBackButton" frame:kBannerImageButtonFrame buttonImageAlignment:kButtonImageAlignment_Center modifyImage:NO];
    self.bannerNavigationBar.leftBarButtonItems = [NSArray arrayWithObject:backButton];
    [backButton addTarget:self action:@selector(backBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *clearBtn = [UIButton buttonWithTitle:@"清空异常" textColor:UIColor.blackColor textSize:16];//[UIColor cmp_specColorWithName:@"theme-bgc"]
    self.bannerNavigationBar.rightBarButtonItems = [NSArray arrayWithObject:clearBtn];
    [clearBtn addTarget:self action:@selector(clearBtn:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)clearBtn:(id)sender{
    if (self.dataSource.count) {
        [self delAction];
    }else{
        [self.view cmp_showHUDWithText:@"无异常票据～"];
    }
}

//返回btn事件
- (void)backBarButtonAction:(id)sender{
    //来自表单
    if ([self.ext integerValue] == 3) {
        NSMutableArray *vcs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        if (vcs.count>=1) {
            NSInteger idx = vcs.count - 1;
            NSString *cmp_ocr_defaultPackageId = [[NSUserDefaults standardUserDefaults] stringForKey:@"cmp_ocr_defaultPackageId"];
            if ([_packageId isEqualToString:cmp_ocr_defaultPackageId]) {
                //默认票夹
                CMPOcrPackageModel *package = [CMPOcrPackageModel new];
                package.pid = _packageId;
                CMPOcrDefaultInvoiceViewController *defaultVC = [[CMPOcrDefaultInvoiceViewController alloc] initWithPackage:package ext:@3];
                defaultVC.formData = self.formData;
                UIViewController *vc = [vcs objectAtIndex:idx];
                if ([vc isKindOfClass:CMPOcrDefaultInvoiceViewController.class]) {
                    [vcs replaceObjectAtIndex:idx withObject:defaultVC];
                }else{
                    [vcs insertObject:defaultVC atIndex:idx];
                }
                [self.navigationController setViewControllers:vcs];
            }else{
                //包详情
                CMPOcrPackageModel *pack = [CMPOcrPackageModel new];//name&pid
                pack.name = _packageName;
                pack.pid = _packageId;
                CMPOcrPackageDetailViewController *detailVC = [[CMPOcrPackageDetailViewController alloc] initWithPackageModel:pack ext:@3];
                detailVC.formData = self.formData;
                UIViewController *vc = [vcs objectAtIndex:idx];
                if ([vc isKindOfClass:CMPOcrDefaultInvoiceViewController.class]) {
                    [vcs replaceObjectAtIndex:idx withObject:detailVC];
                }else{
                    [vcs insertObject:detailVC atIndex:idx];
                }
                [self.navigationController setViewControllers:vcs];
            }
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - timer轮询
- (void)startIntervalCheck{
    //全局队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _sourceTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    NSTimeInterval delayTime = 0.5f;//延迟时间
    if (self.dataSource.count <= 0) {
        delayTime = 0;//如果么有本地数据，则
    }
    NSTimeInterval timeInterval = 1.0f;//间隔时间
    //设置开始时间
    dispatch_time_t startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC));
    //设置计时器
    dispatch_source_set_timer(_sourceTimer,startDelayTime,timeInterval*NSEC_PER_SEC,0.1*NSEC_PER_SEC);
    //执行事件
    dispatch_source_set_event_handler(_sourceTimer,^{
        //销毁定时器
        //dispatch_source_cancel(_myTimer);
        [self checkInvoice];
    });
    dispatch_resume(_sourceTimer);//启动计时器
}
//获取识别数据
- (void)checkInvoice1{
    __weak typeof(self) weakSelf = self;
    [self.itemViewModel checkInvoiceWithPackageId:_packageId successBlock:^(NSArray<CMPOcrItemModel *> *serverItemArray) {
        //服务端只返回非成功的数据（!=3）
        for (CMPOcrItemModel *serverItem in serverItemArray) {
            BOOL isInLocal = NO;
            for (CMPOcrItemModel *localItem in weakSelf.dataSource) {
                if (localItem.taskStatus != CMPOcrItemStateCheckSuccess) {
                    //只有上传成功、提交成功或失败的状态fileId才能和服务端返回数据比较
                    if ([localItem.fileId isEqual:serverItem.fileId]) {
                        NSInteger idx = [weakSelf.dataSource indexOfObject:localItem];
                        serverItem.filename = localItem.filename;//保留本地图片名字
                        [weakSelf.dataSource replaceObjectAtIndex:idx withObject:serverItem];
                        isInLocal = YES;
                        break;
                    }
                }else if (serverItem.taskStatus == CMPOcrItemStateCheckSuccess){
                    if(localItem.taskStatus == CMPOcrItemStateUploadSuccess){
                        [[CMPOcrItemManager sharedInstance]deleteOcrItem:localItem callBack:^(NSError *error) {
                            
                        }];
                    }
                }
            }
            //如果没有替换&未识别成功的添加到列表
            if (!isInLocal && serverItem.taskStatus != CMPOcrItemStateCheckSuccess) {
                [weakSelf.dataSource addObject:serverItem];
            }
        }
        //删除识别成功的
        NSMutableArray *removes = [NSMutableArray new];
        for (CMPOcrItemModel *item in weakSelf.dataSource) {
            if (item.taskStatus == CMPOcrItemStateCheckSuccess) {
                [removes addObject:item];
            }
        }
        [weakSelf.dataSource removeObjectsInArray:removes];
        
        [weakSelf reloadTable];
    } errorBlock:^(NSError *error) {
        
    }];
}
- (void)checkInvoice{
    __weak typeof(self) weakSelf = self;
    [self.itemViewModel checkInvoiceWithPackageId:_packageId successBlock:^(NSArray<CMPOcrItemModel *> *serverItemArray) {
        NSMutableArray *localItemArray = [NSMutableArray new];
        [localItemArray addObjectsFromArray:weakSelf.dataSource];
        //CMPOcrItemStateSubmitSuccess,CMPOcrItemStateCheckProcessing
        NSMutableArray *notInLocalArr = [NSMutableArray new];
        for (CMPOcrItemModel *serverItem in serverItemArray) {
            BOOL inLocal = NO;
            for (CMPOcrItemModel *localItem in localItemArray) {
                if ([localItem.fileId isEqual:serverItem.fileId]) {
                    NSInteger idx = [localItemArray indexOfObject:localItem];
                    serverItem.filename = localItem.filename;//保留本地图片名字
                    [weakSelf.dataSource replaceObjectAtIndex:idx withObject:serverItem];
                    inLocal = YES;
                }
            }
            if (!inLocal) {
                [notInLocalArr addObject:serverItem];
            }
        }
        
        NSMutableArray *serverFileIds = [NSMutableArray new];
        [serverItemArray enumerateObjectsUsingBlock:^(CMPOcrItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.fileId.length) {
                [serverFileIds addObject:obj.fileId];
            }
        }];
        
        NSMutableArray *removes = [NSMutableArray new];
        for (CMPOcrItemModel *localItem in weakSelf.dataSource) {
            if (localItem.taskStatus == CMPOcrItemStateCheckSuccess) {
                [removes addObject:localItem];
            }else if (localItem.taskStatus == CMPOcrItemStateSubmitSuccess && ![serverFileIds containsObject:localItem.fileId]){
                [removes addObject:localItem];
            }else if (localItem.taskStatus == CMPOcrItemStateCheckProcessing && ![serverFileIds containsObject:localItem.fileId]){
                [removes addObject:localItem];
            }
        }
        [weakSelf.dataSource removeObjectsInArray:removes];
        [weakSelf.dataSource addObjectsFromArray:notInLocalArr];
        [weakSelf reloadTable];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf checkInvoice];
        });
        
    } errorBlock:^(NSError *error) {
        [weakSelf cmp_showHUDError:error];
    }];
}

- (void)reloadTable{
    if (!self.myTableView.editing) {//正处于编辑状态或者删除状态，不允许刷新列表
        [self.myTableView reloadData];
        [CMPOcrTipTool.new showNoCheckDataView:self.dataSource.count<=0 toView:self.view];
    }
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

static NSString *kCMPOcrInvoiceCheckListCell = @"CMPOcrInvoiceCheckListCell";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMPOcrInvoiceCheckListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCMPOcrInvoiceCheckListCell forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    __weak typeof(self) weakSelf = self;
    cell.ActionBtnBlock = ^(CMPOcrItemModel *itemModel) {
        [weakSelf cellActionBtnClick:itemModel];
    };
    CMPOcrItemModel *item = self.dataSource[indexPath.row];
    cell.itemModel = item;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CMPOcrItemModel *itemModel = self.dataSource[indexPath.row];
    
    if ([itemModel.fileType containsString:@"pdf"]) {//pdf
        if (itemModel.filePath.length>0) {
            AttachmentReaderParam *aParam = [[AttachmentReaderParam alloc] init];
            aParam.origin = [CMPCore sharedInstance].serverurlForSeeyon;
            aParam.fileName = itemModel.filename;
            aParam.fileType = itemModel.fileType;
            CMPQuickLookPreviewController *aViewController = [[CMPQuickLookPreviewController alloc] init];
            aViewController.attReaderParam = aParam;
            aParam.url = itemModel.filePath;
            [self.navigationController pushViewController:aViewController animated:YES];
        }else if(itemModel.fileId.length>0){
            AttachmentReaderParam *aParam = [[AttachmentReaderParam alloc] init];
            aParam.fileId = itemModel.fileId;
            CMPQuickLookPreviewController *aViewController = [[CMPQuickLookPreviewController alloc] init];
            aParam.url = [CMPCore fullUrlForPathFormat:@"/rest/attachment/file/%@", itemModel.fileId];
            aParam.origin = [CMPCore sharedInstance].serverurlForSeeyon;
            aParam.fileName = itemModel.filename;
            aParam.fileType = itemModel.fileType;
            aViewController.attReaderParam = aParam;
            [self.navigationController pushViewController:aViewController animated:YES];
        }
    }else{
        NSURL *URL;
        if (itemModel.filePath.length>0) {//本地图片
            URL = [NSURL URLWithString:itemModel.filePath];
            itemModel.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:itemModel.filePath]];
        }else if(itemModel.fileId.length>0){//在线图片
            NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/commonImage/showImage?size=source&id=%@", itemModel.fileId];
            URL = [NSURL URLWithString:url];
        }
        YBImageBrowseCellData *cellData;
        if(itemModel.image){
            cellData = [[YBImageBrowseCellData alloc]init];
            cellData.imageBlock = ^__kindof UIImage * _Nullable{
                YBImage *ybImage = [YBImage imageWithData:UIImageJPEGRepresentation(itemModel.image,1)];
                return ybImage;
            };
        }else if (URL) {
            cellData = [[YBImageBrowseCellData alloc]init];
            cellData.url = URL;
            cellData.extraData = @{
                @"originImageURL":URL
            };
        }
        if (cellData) {
            YBImageBrowser *browser = [YBImageBrowser new];
            browser.toolBars = @[];
            browser.dataSourceArray = @[cellData];
            browser.allDataSourceArray = @[cellData];
            browser.currentIndex = 0;
            browser.showCheckAllPicsBtn = NO;
            [browser show];
        }
    }
    
//    if (itemModel.image) {
//        _invoiceImageView.image = itemModel.image;
//    }else if ([itemModel.fileType containsString:@"pdf"]) {
//        _invoiceImageView.image = [UIImage imageNamed:@"ocr_card_pdf_placeholder"];
//    }else if (itemModel.filePath.length>0){//优先显示本地copy后的图片
//        _invoiceImageView.image = [UIImage imageWithContentsOfFile:itemModel.filePath];
//    }else if (itemModel.fileId.length>0){//显示网络图片
//        NSString *url = [CMPCore fullUrlForPathFormat:@"/commonimage.do?method=showImage&id=%@&createDate=&size=custom&w=60&h=60&igonregif=1&option.n_a_s=1",itemModel.fileId];
//        [_invoiceImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"ocr_card_image_placeholder"]];
//    }else{
//        _invoiceImageView.image = [UIImage imageNamed:@"ocr_card_image_placeholder"];
//    }
    
//    if ([itemModel.fileType containsString:@"pdf"]) {
//        AttachmentReaderParam *aParam = [[AttachmentReaderParam alloc] init];
//        aParam.fileId = itemModel.fileId;
//        CMPQuickLookPreviewController *aViewController = [[CMPQuickLookPreviewController alloc] init];
//        NSString *aFileUrl = [CMPCore fullUrlForPathFormat:@"/rest/attachment/file/%@", itemModel.fileId];
//        aParam.url = aFileUrl;
//        aParam.origin = [CMPCore sharedInstance].serverurlForSeeyon;
//        aParam.fileName = itemModel.filename;
//        aParam.fileType = itemModel.fileType;
//        aViewController.attReaderParam = aParam;
//        [self.navigationController pushViewController:aViewController animated:YES];
//    }else{
//        NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/commonImage/showImage?size=source&id=%@", itemModel.fileId];
//        NSURL *URL = [NSURL URLWithString:url];
//        if (URL) {
//            YBImageBrowseCellData *cellData = [[YBImageBrowseCellData alloc]init];
//            cellData.url = URL;
//            cellData.extraData = @{
//                @"originImageURL":URL
//            };
//            YBImageBrowser *browser = [YBImageBrowser new];
//            browser.dataSourceArray = @[cellData];
//            browser.allDataSourceArray = @[cellData];
//            browser.currentIndex = 0;
//            browser.showCheckAllPicsBtn = NO;
//            [browser show];
//        }
//    }
}
//MARK: 左滑操作
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)){
    //删除
    weakify(self);
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        strongify(self);
        [self deleteIndexPath:indexPath];
        completionHandler (YES);
    }];
    deleteRowAction.image = [UIImage imageNamed:@"ocr_card_main_del"];
    deleteRowAction.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
    
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction]];
    config.performsFirstActionWithFullSwipe = NO;
    return config;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)setupSlideBtnWithEditingIndexPath:(NSIndexPath *)editingIndexPath {
    // 判断系统是否是 iOS13 及以上版本
    if (@available(iOS 13.0, *)) {
        for (UIView *subView in self.myTableView.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"_UITableViewCellSwipeContainerView")] && [subView.subviews count] >= 1) {
                // 修改图片
                UIView *remarkContentView = subView.subviews.firstObject;
                [self setupRowActionView:remarkContentView];
            }
        }
        return;
    }
    
    // 判断系统是否是 iOS11 及以上版本
    if (@available(iOS 11.0, *)) {
        for (UIView *subView in self.myTableView.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"UISwipeActionPullView")] && [subView.subviews count] >= 1) {
                // 修改图片
                UIView *remarkContentView = subView;
                [self setupRowActionView:remarkContentView];
            }
        }
        return;
    }
    
    // iOS11 以下的版本
    UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:editingIndexPath];
    for (UIView *subView in cell.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")] && [subView.subviews count] >= 1) {
            // 修改图片
            UIView *remarkContentView = subView;
            [self setupRowActionView:remarkContentView];
        }
    }
}

- (void)setupRowActionView:(UIView *)rowActionView {
    // 切割圆角
//    [rowActionView cl_setCornerAllRadiusWithRadiu:20];
    // 改变父 View 的frame，这句话是因为我在 contentView 里加了另一个 View，为了使划出的按钮能与其达到同一高度
    CGRect frame = rowActionView.frame;
    frame.origin.y += (7);
    frame.size.height -= (13);
    rowActionView.frame = frame;
    // 拿到按钮,设置
    for (int i=0; i<_leftBtnInfoArr.count; i++) {
        NSDictionary *btnDict = _leftBtnInfoArr[i];
        NSString *iconName = btnDict[@"iconName"];
        UIButton *button = rowActionView.subviews[i];
        UIView *bgView = button.subviews.firstObject;
        bgView.backgroundColor = UIColor.clearColor;
        [button setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
        [button setTitle:@"" forState:UIControlStateNormal];
    }
}
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    if (@available(iOS 11.0, *)) {
        
    }else{
        //iOS10以下采用这个方式
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupSlideBtnWithEditingIndexPath:indexPath];
        });
    }
}

- (NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    NSMutableArray *actionArr = [NSMutableArray new];
    __weak typeof(self) weakSelf = self;
    for (int i=0; i<_leftBtnInfoArr.count; i++) {
        UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"        " handler:^(UITableViewRowAction *action, NSIndexPath *indexPath1){
            NSLog(@"i=%ld",i);
            [weakSelf deleteIndexPath:indexPath];
            [tableView setEditing:NO animated:YES];  // 这句很重要，退出编辑模式，隐藏左滑菜单
        }];
        [actionArr insertObject:rowAction atIndex:0];
    }
    return actionArr;
}
#pragma mark - 操作按钮
- (void)cellActionBtnClick:(CMPOcrItemModel *)itemModel{
    switch (itemModel.taskStatus) {
        case CMPOcrItemStateUploadPause:
        case CMPOcrItemStateUploadError:{
            //上传
            NSLog(@"ocr-item重新上传-%@",itemModel.filename);
            itemModel.taskStatus = CMPOcrItemStateNotUpload;
            [self reloadTable];
            __weak typeof(self) weakSelf = self;
            [[CMPOcrItemManager sharedInstance] reUpload:itemModel callBack:^(NSError *err) {
                [weakSelf reloadTable];
            }];
            break;
        }
        case CMPOcrItemStateNotUpload:{
            //暂停上传
            NSLog(@"ocr-item暂停上传-%@",itemModel.filename);
            __weak typeof(self) weakSelf = self;
            [[CMPOcrItemManager sharedInstance] cancelUpload:itemModel callBack:^{
                [weakSelf reloadTable];
            }];
            break;
        }
        case CMPOcrItemStateSubmitFail:{
            //提交识别
            NSLog(@"ocr-item重新提交-%@",itemModel.filename);
            itemModel.taskStatus = CMPOcrItemStateUploadSuccess;
            [self reloadTable];
            __weak typeof(self) weakSelf = self;
            [[CMPOcrItemManager sharedInstance] reSubmitTask:itemModel completion:^(NSError *error) {
                if (!error) {
                    [weakSelf.dataSource removeObject:itemModel];
                }
                [weakSelf reloadTable];
            }];
            break;
        }
        case CMPOcrItemStateCheckFailed:
        case CMPOcrItemStateCheckSuspend:
        case CMPOcrItemStateCheckBlurring:
        case CMPOcrItemStateCheckRepeat:
        case CMPOcrItemStateOcrServerFail:
        {
            //重新识别
            NSLog(@"ocr-item重新识别-%@",itemModel.filename);
            itemModel.taskStatus = CMPOcrItemStateCheckProcessing;
            [self reloadTable];
            __weak typeof(self) weakSelf = self;
            [[CMPOcrItemManager sharedInstance] reCheckTask:itemModel completion:^(NSError *error) {
                if (error) {
                    [weakSelf cmp_showHUDError:error];
                }
                [weakSelf reloadTable];
            }];
        }
            break;
        case CMPOcrItemStateOcrNoAuthCount://单独调用一个接口
        {
            itemModel.taskStatus = CMPOcrItemStateCheckProcessing;
            [self reloadTable];
            __weak typeof(self) weakSelf = self;
            [[CMPOcrItemManager sharedInstance] retryTask:itemModel completion:^(NSError *error) {
                if (error) {
                    [weakSelf cmp_showHUDError:error];
                }
                [weakSelf reloadTable];
            }];
        }
            break;
        default:
        {
            NSInteger taskStatus = itemModel.taskStatus;
            if (taskStatus >= 12 && taskStatus < 40) {//可以重新识别
                NSLog(@"ocr-item重新识别-%@",itemModel.filename);
                itemModel.taskStatus = CMPOcrItemStateCheckProcessing;
                [self reloadTable];
                __weak typeof(self) weakSelf = self;
                [[CMPOcrItemManager sharedInstance] reCheckTask:itemModel completion:^(NSError *error) {
                    if (error) {
                        [weakSelf cmp_showHUDError:error];
                    }
                    [weakSelf reloadTable];
                }];
            }
        }
            break;
    }
}
//删除
- (void)deleteIndexPath:(NSIndexPath*)indexPath{
    //弹框确认
    CMPAlertView *alertView = [[CMPAlertView alloc]initWithTitle:nil message:@"确定删除该票据？" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] callback:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            CMPOcrItemModel *delItem = [self.dataSource objectAtIndex:indexPath.row];
            __weak typeof(self) weakSelf = self;
            [[CMPOcrItemManager sharedInstance] deleteOcrItem:delItem callBack:^(NSError *error) {
                if (error) {
                    [weakSelf cmp_showHUDError:error];
                }else{
                    [weakSelf.dataSource removeObject:delItem];
                    [weakSelf.myTableView reloadData];
                    [CMPOcrTipTool.new showNoCheckDataView:weakSelf.dataSource.count<=0 toView:weakSelf.view];
                }
            }];
        }else{
            [self.myTableView endEditing:YES];
        }
    }];
    [alertView show];
}

- (void)delAction{
    //弹框确认
    CMPAlertView *alertView = [[CMPAlertView alloc]initWithTitle:nil message:@"确定清空所有异常票据？" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] callback:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            NSMutableArray *remoteArray = [NSMutableArray new];
            NSMutableArray *localArray = [NSMutableArray new];
//            CMPOcrItemStateCheckFailed = 4,//服务器返回，云平台识别失败
//            CMPOcrItemStateCheckSuspend = 5,//服务器返回，发票识别暂停
//            CMPOcrItemStateCheckWaiting = 6,//服务器返回，发票等待识别
//            CMPOcrItemStateCheckBlurring = 7,//服务器返回，发票未识别出来
//            CMPOcrItemStateCheckRepeat = 8,//服务器返回，发票识别重复
//            CMPOcrItemStateMixResult = 9,//成功{0}张，失败{1}张。建议重新上传失败发票
            
            //此处清空的为识别异常的票据，上传中、正在处理中的都不能被删除
            for (CMPOcrItemModel *item in self.dataSource) {
                if (item.taskStatus == CMPOcrItemStateCheckFailed
                    ||item.taskStatus == CMPOcrItemStateCheckBlurring
                    ||item.taskStatus == CMPOcrItemStateMixResult
                    ||item.taskStatus == CMPOcrItemStateOcrServerFail
                    ||item.taskStatus == CMPOcrItemStateOcrNoAuthCount
                    ||item.taskStatus == CMPOcrItemStateCheckRepeat
                    ||(item.taskStatus >= 12 && item.taskStatus < 100)) {
                    if (item.invoiceId) {
                        [remoteArray addObject:item];
                    }else{
                        [localArray addObject:item];
                    }
                }
            }
            //删除远程
            if (remoteArray.count) {
                __weak typeof(self) weakSelf = self;
                [[CMPOcrItemManager sharedInstance] deleteRemoteOcrItemArr:remoteArray callBack:^(NSError *error) {
                    if (error) {
                        [weakSelf cmp_showHUDError:error];
                    }else{
                        [weakSelf.dataSource removeObjectsInArray:remoteArray];
                        [weakSelf.myTableView reloadData];
                        [CMPOcrTipTool.new showNoCheckDataView:weakSelf.dataSource.count<=0 toView:weakSelf.view];
                    }
                }];
            }
            //删除本地
            if (localArray.count) {
                [[CMPOcrItemManager sharedInstance]deleteLocalOcrItemArr:localArray callBack:^(NSError *error) {}];
            }
        }else{
            [self.myTableView endEditing:YES];
        }
    }];
    [alertView show];
}
#pragma mark - getter
- (CMPCustomLeftSwipeTableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[CMPCustomLeftSwipeTableView alloc]init];
        _myTableView.dataSource = self;
        _myTableView.delegate = self;
        _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _myTableView.showsHorizontalScrollIndicator = NO;
        _myTableView.showsVerticalScrollIndicator = NO;
        _myTableView.separatorInset = UIEdgeInsetsZero;
        [_myTableView registerClass:CMPOcrInvoiceCheckListCell.class forCellReuseIdentifier:kCMPOcrInvoiceCheckListCell];
        _myTableView.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
    }
    return _myTableView;
}

- (CMPOcrItemViewModel *)itemViewModel{
    if (!_itemViewModel) {
        _itemViewModel = [[CMPOcrItemViewModel alloc]init];
    }
    return _itemViewModel;
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}

@end
