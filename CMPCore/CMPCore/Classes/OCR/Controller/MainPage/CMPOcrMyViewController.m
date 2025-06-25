//
//  CMPOcrMyViewController.m
//  M3
//
//  Created by Shoujian Rao on 2021/11/30.
//

#import "CMPOcrMyViewController.h"
#import "CMPOcrMyView.h"
#import "CMPOcrMyViewModel.h"
#import <CMPLib/NSObject+CMPHUDView.h>
#import "CMPOcrTipTool.h"
#import "CMPOcrTabbarViewController.h"

@interface CMPOcrMyViewController ()
@property (nonatomic,strong) CMPOcrMyViewModel *viewModel;
@end

@implementation CMPOcrMyViewController

-(CMPOcrMyViewModel *)viewModel
{
    if (!_viewModel) {
        _viewModel = [[CMPOcrMyViewModel alloc] init];
        _viewModel.statusArr = @[@2,@3];
    }
    return _viewModel;
}
- (void)dealloc{
    NSLog(@"%@-dealloc",self.class);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
    
    self.title = @"我的";
    self.bannerNavigationBar.backgroundColor = [UIColor whiteColor];
    
    CMPOcrMyView *mainView = (CMPOcrMyView *)self.mainView;
    mainView.cardCategoryView.viewModel = self.viewModel;
    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.baseSafeView).offset(0);
        make.bottom.equalTo(self.baseSafeView).offset(-50);
        make.top.offset(self.mainFrame.origin.y);
    }];
    
    __weak typeof(self) wSelf = self;
    __weak typeof(CMPOcrMyView *) wMainView = mainView;
    self.viewModel.commonModulesCompletionBlk = ^(NSArray<CMPOcrModuleItemModel *> * _Nonnull modules, NSError * _Nonnull error) {
        if (!error) {
            if (modules.count>0) {
                wMainView.hidden = NO;
                [CMPOcrTipTool.new showNoMoudleDataView:NO toView:wSelf.view];
                [wMainView.cardCategoryView updateCommonModules];
                [wSelf.viewModel setSelectedModuleIndex:wSelf.viewModel.selectedModuleIndex];
                [wSelf.viewModel refreshCurrentPackageList];
                
                [wSelf _dealWithActionAfterFormReimburse];
                
            }else{
                wMainView.hidden = YES;
                [CMPOcrTipTool.new showNoMoudleDataView:YES toView:wSelf.view];
            }
        }else{
            [wSelf cmp_showHUDError:error];
        }
    };
    
    self.viewModel.packagesCompletionBlk = ^(NSArray<CMPOcrPackageModel *> * _Nonnull packages, NSError * _Nonnull error) {
        if (!error) {
            [wMainView.cardCategoryView updatePackageList];
        }else{
            [wSelf cmp_showHUDError:error];
        }
    };
    
    [self.viewModel refreshCommonModules];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_commonModulesUpdate) name:@"kNotificationName_ocrModulesUpdateSuccess" object:nil];

}

-(void)_commonModulesUpdate
{
    [self.viewModel refreshCommonModules];
}

-(void)_refreshCurrentModules
{
    if (_mainView) {
        [self.viewModel refreshCurrentPackageList];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self _commonModulesUpdate];
    [self _refreshCurrentModules];
}

/**
 处理表单报销后 自动滚动到对应的tab下
 */
-(void)_dealWithActionAfterFormReimburse
{
    CMPOcrTabbarViewController *tabCtrl = self.rdv_tabBarController;
    if (tabCtrl) {
        id obj = tabCtrl.viewModel.paramFromFormAfterReimburse;
        if (obj) {
            if ([obj isKindOfClass:NSDictionary.class]) {
                BOOL saveDraft = [obj[@"saveDraft"] boolValue];
                if (!saveDraft) {
                    NSString *tempId = obj[@"templateId"];
                    if (tempId) {
                        CMPOcrModuleItemModel *curModule = self.viewModel.selectedModule;
                        if (curModule && [curModule.templateId isEqualToString:tempId]) {
                            
                        }else{
                            __block NSInteger desIndex = -1;
                            [self.viewModel.modulesArr enumerateObjectsUsingBlock:^(CMPOcrModuleItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                if ([obj.templateId isEqualToString:tempId]) {
                                    desIndex = idx;
                                    *stop = YES;
                                }
                            }];
                            if (desIndex >= 0) {
                                [((CMPOcrMyView *)self.mainView).cardCategoryView selectModulesIndex:desIndex];
                            }
                        }
                    }
                }
            }
            tabCtrl.viewModel.paramFromFormAfterReimburse = nil;
        }
    }
}

//自定义返回btn
- (void)setupBannerButtons{
    self.bannerNavigationBar.leftMargin = 0;
    self.backBarButtonItemHidden = YES;
    UIButton *backButton = [UIButton buttonWithImageName:@"navBackButton" frame:kBannerImageButtonFrame buttonImageAlignment:kButtonImageAlignment_Center modifyImage:NO];
    self.bannerNavigationBar.leftBarButtonItems = [NSArray arrayWithObject:backButton];
    [backButton addTarget:self action:@selector(backBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}
//返回btn事件
- (void)backBarButtonAction:(id)sender{
    if (self.rdv_tabBarController.navigationController) {
        [self.rdv_tabBarController.navigationController popViewControllerAnimated:YES];
    }else{
        [self.rdv_tabBarController dismissViewControllerAnimated:YES completion:nil];
    }
}


@end
