//
//  CMPOcrUploadManageViewController.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/5.
//

#import "CMPOcrUploadManageViewController.h"
#import "CMPOcrUploadManageView.h"
#import "CMPOcrFileModel.h"
#import <CMPLib/NSObject+CMPHUDView.h>
#import "CMPOcrPackageViewModel.h"
#import "CMPOcrPickPackageViewController.h"
#import "CMPOcrInvoiceCheckViewController.h"
#import "CMPOcrMainViewDataProvider.h"
@interface CMPOcrUploadManageViewController ()

@property (nonatomic, strong) CMPOcrUploadManageView *manageView;
@property (nonatomic, strong) NSArray<CMPOcrFileModel *> *fileArray;

@property (nonatomic, strong) CMPOcrPackageViewModel *packageViewModel;

@property (nonatomic, strong) NSMutableArray *packageArray;
@property (nonatomic, strong) CMPOcrPackageModel *selectedPackageModel;
@property (nonatomic, strong) CMPOcrPackageModel *defaultPackageModel;

@property (nonatomic, assign) BOOL forbidCreatePackage;//禁止点击选择报销包
@property (nonatomic, assign) BOOL isFromForm;//来自表单
@property (nonatomic, strong) id ext;
@property (nonatomic, strong) CMPOcrMainViewDataProvider *dataProvider;
@end

@implementation CMPOcrUploadManageViewController

- (void)dealloc{
    NSLog(@"%@-delloc",self.class);
}

- (UIColor *)bannerNavigationBarBackgroundColor{
    return UIColor.whiteColor;
}

- (instancetype)initWithFileArray:(NSArray *)fileArray package:(CMPOcrPackageModel *)package ext:(id)ext{
    if (self = [super init]) {
        self.ext = ext;
        self.fileArray = fileArray;
        self.selectedPackageModel = package;
        self.forbidCreatePackage = [ext integerValue]==2 || [ext integerValue]==3;//ext==2 包详情页面添加上传进入，不允许更换包
        self.isFromForm = [ext integerValue]==3;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.title = @"上传整理";
    self.view.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
    [self setupStatusBarViewBackground:UIColor.whiteColor];
    [self.bannerNavigationBar hideBottomLine:YES];
    [self configView];
    
    if (!_forbidCreatePackage) {
        [self loadPackage];
    }
    if (self.isFromForm) {
        [self fetchDefaultPackage];
    }
}

//获取默认详情
- (void)fetchDefaultPackage{
    __weak typeof(self) weakSelf = self;
    [self.dataProvider fetchDefaultPackageIdWithParams:nil completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (!error) {
            weakSelf.defaultPackageModel = [CMPOcrPackageModel yy_modelWithJSON:respData];
            if (weakSelf.defaultPackageModel.pid) {
                //保存一个全局的默认票夹ID
                [[NSUserDefaults standardUserDefaults] setValue:weakSelf.defaultPackageModel.pid forKey:@"cmp_ocr_defaultPackageId"];
            }
        }
    }];
}

- (void)configView{
    //main view
    _manageView = (CMPOcrUploadManageView *)self.mainView;
    [_manageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.baseSafeView.mas_top).offset(0);
        make.left.right.bottom.mas_equalTo(0);
    }];
    
    //传入数据
    __weak typeof(self) weakSelf = self;
    [_manageView reloadDataWithFileArray:_fileArray forbidCreatePackage:_forbidCreatePackage completion:^(NSArray *pickedFileArray) {
        if (pickedFileArray) {
            weakSelf.fileArray = pickedFileArray;
        }
    }];
    //点击选择包
    _manageView.PickPackageSectionBlock = ^{
        [weakSelf pickPackageAction];
    };
    
    //底部上传按钮
//    UIView *botView = [[UIView alloc]init];
//    botView.backgroundColor = UIColor.whiteColor;
//    [self.view addSubview:botView];
//    [botView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.bottom.mas_equalTo(0);
//        make.height.mas_equalTo(IS_IPHONE_X_LATER?84:50);
//    }];
//    UIButton *uploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [botView addSubview:uploadBtn];
//    [uploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(botView);
//        make.top.mas_equalTo(7);
//        make.width.mas_equalTo(120);
//        make.height.mas_equalTo(36);
//    }];
//    uploadBtn.layer.cornerRadius = 18.f;
//    uploadBtn.backgroundColor = [UIColor cmp_specColorWithName:@"theme-bgc"];
//    [uploadBtn setTitle:@"上传" forState:(UIControlStateNormal)];
//    uploadBtn.titleLabel.font = [UIFont systemFontOfSize:18];
//    [uploadBtn addTarget:self action:@selector(uploadBtnAction) forControlEvents:(UIControlEventTouchUpInside)];
}

//加载所有报销包数据
- (void)loadPackage{
    _manageView.canClickCreatePackage = NO;//不能点击选择报销包
    __weak typeof(self) weakSelf = self;
    [self.packageViewModel getNonUsedPackageListSuccessBlock:^(NSArray<CMPOcrPackageModel *> *packages) {
        weakSelf.manageView.canClickCreatePackage = YES;
        if (packages.count) {
            [weakSelf.packageArray addObjectsFromArray:packages];
            CMPOcrPackageModel *tmp;
            for (CMPOcrPackageModel *p in packages) {
                if (p.lastUsedTag == 1) {
                    tmp = p;
                    break;
                }
            }
            if (!tmp) {//找默认票夹
                NSString *defaultPid = [[NSUserDefaults standardUserDefaults] stringForKey:@"cmp_ocr_defaultPackageId"];
                for (CMPOcrPackageModel *p in packages) {
                    if ([p.pid isEqualToString:defaultPid]) {
                        tmp = p;
                        break;
                    }
                }
                if (!tmp) {
                    tmp = packages.firstObject;
                }
            }
            weakSelf.selectedPackageModel = tmp;
            [weakSelf.manageView refreshWithPackage:tmp];
        }
    } errorBlock:^(NSError *error) {
        [weakSelf cmp_showHUDError:error];
    }];
}
#pragma mark - 点击选择报销包
- (void)pickPackageAction{
    __weak typeof(self) weakSelf = self;
    CMPOcrPickPackageViewController *vc = [[CMPOcrPickPackageViewController alloc]initWithPackageArr:self.packageArray select:self.selectedPackageModel pickBackBlock:^(CMPOcrPackageModel *packageModel) {
        //返回的报销包
        weakSelf.selectedPackageModel = packageModel;
        [weakSelf.manageView refreshWithPackage:packageModel];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 点击上传
#pragma mark - custom right button
//票据识别跳转btn
- (void)setupBannerButtons{
    self.bannerNavigationBar.rightMargin = 4;
    self.backBarButtonItemHidden = NO;
    UIButton *uploadButton = [UIButton buttonWithTitle:@"确定" textColor:UIColor.blackColor textSize:16];
    self.bannerNavigationBar.rightBarButtonItems = [NSArray arrayWithObject:uploadButton];
    [uploadButton addTarget:self action:@selector(uploadBtnAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)uploadBtnAction{
    if (self.isFromForm) {
        self.selectedPackageModel = self.defaultPackageModel;
        if (self.selectedPackageModel.pid.length<=0) {
            [self cmp_showHUDWithText:@"未获取到默认票夹"];
            return;
        }
    }
    if (self.selectedPackageModel.pid.length<=0) {
        [self cmp_showHUDWithText:@"请选择报销包"];
        return;
    }
    
    CMPOcrInvoiceCheckViewController *check = [[CMPOcrInvoiceCheckViewController alloc]initWithFileArray:self.fileArray package:self.selectedPackageModel ext:self.ext];
    check.formData = self.formData;
    [self.navigationController pushViewController:check animated:YES];
    
    //删除本VC
    __weak typeof(self) weakSelf = self;
    NSMutableArray *vcs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [vcs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:self.class]) {
            [vcs removeObject:obj];
            [weakSelf.navigationController setViewControllers:vcs];
            *stop = YES;
        }
    }];
    
}

- (CMPOcrPackageViewModel *)packageViewModel{
    if (!_packageViewModel) {
        _packageViewModel = [[CMPOcrPackageViewModel alloc]init];
    }
    return _packageViewModel;
}

- (NSMutableArray *)packageArray{
    if (!_packageArray) {
        _packageArray = [NSMutableArray new];
    }
    return _packageArray;
}
-(CMPOcrMainViewDataProvider *)dataProvider
{
    if (!_dataProvider) {
        _dataProvider = [[CMPOcrMainViewDataProvider alloc] init];
    }
    return _dataProvider;
}

@end
