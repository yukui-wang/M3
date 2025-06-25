//
//  CMPOcrMainView.m
//  M3
//
//  Created by Kaku Songu on 11/23/21.
//

#import "CMPOcrMainView.h"
#import "CMPOcrCardMainHeaderView.h"
#import "CMPOcrDefaultInvoiceViewController.h"
#import "CMPOcrAddPhotoOrCameraOrFileTool.h"
#import "CMPOcrUploadManageViewController.h"
#import "CMPOcrPickFileTool.h"
@interface CMPOcrMainView()
@property (nonatomic, strong) CMPOcrPickFileTool *pickFileTool;
@property (nonatomic,strong) CMPOcrCardMainHeaderView *headerView;

@end

@implementation CMPOcrMainView
- (void)layoutSubviews{
    [super layoutSubviews];
    _cardCategoryView.viewController = self.viewController;
    CGFloat offset = CGRectGetMaxY([UIApplication sharedApplication].statusBarFrame) + self.viewController.navigationController.navigationBar.frame.size.height;
    [_cardCategoryView setHeaderOffset:offset];
    
    _headerView.viewController = self.viewController;
    RDVTabBarController *vc = self.viewController.rdv_tabBarController;
    [_cardCategoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-vc.tabBar.height);
    }];
}
- (void)setup{
    self.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
    CGFloat width = self.frame.size.width;
    
    //headerView
    CGFloat h = 268*width/375 + 104/2 + 14 + 55;
    _headerView = [[CMPOcrCardMainHeaderView alloc]initWithFrame:CGRectMake(0, 0, width, h)];
    _headerView.defaultPackage = self.viewModel.defaultPackageModel;
    __weak typeof(self) weakSelf = self;
    _headerView.actBlk = ^(NSInteger act, id ext, UIViewController *controller) {
        switch (act) {
            case 0:
            {
                //默认票夹入口
                CMPOcrDefaultInvoiceViewController *vc = [[CMPOcrDefaultInvoiceViewController alloc] initWithPackage:weakSelf.viewModel.defaultPackageModel ext:nil];
                [controller.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 1:
            {
                [CMPOcrAddPhotoOrCameraOrFileTool openCustomAlbumFromVC:weakSelf.viewController.navigationController choosedPhotos:^(NSArray<CMPOcrFileModel *> * imageArray) {
                    CMPOcrUploadManageViewController *vc = [[CMPOcrUploadManageViewController alloc]initWithFileArray:imageArray package:nil ext:nil];
                    [controller.navigationController pushViewController:vc animated:YES];
                } cancel:^{
                    
                }];
            }
                break;
            case 2:{
                [CMPOcrAddPhotoOrCameraOrFileTool openCameraFromVC:weakSelf.viewController.navigationController cameraPhotos:^(NSArray<CMPOcrFileModel *> * imageArray) {
                    CMPOcrUploadManageViewController *vc = [[CMPOcrUploadManageViewController alloc]initWithFileArray:imageArray package:nil ext:nil];
                    [controller.navigationController pushViewController:vc animated:YES];
                } cancel:^{
                    
                }];
            }
                break;
            case 3:{
                [weakSelf.pickFileTool pushPickToVC:weakSelf.viewController Completion:^(NSArray<CMPOcrFileModel *> *fileArray) {
                    CMPOcrUploadManageViewController *vc = [[CMPOcrUploadManageViewController alloc]initWithFileArray:fileArray package:nil ext:nil];
                    dispatch_after(0.2, dispatch_get_main_queue(), ^{
                        //等收藏页面pop返回后再跳转
                        [controller.navigationController pushViewController:vc animated:YES];
                    });
                }];
            }
                break;
            default:
                break;
        }
    };
    
    _cardCategoryView = [[CMPOcrCardCategoryView alloc] initWithHeaderView:_headerView];
    [self addSubview:_cardCategoryView];    
}
-(void)setViewModel:(CMPOcrMainViewModel *)viewModel
{
    _viewModel = viewModel;
    if (_cardCategoryView) {
        _cardCategoryView.viewModel = viewModel;
    }
}

- (CMPOcrPickFileTool *)pickFileTool{
    if (!_pickFileTool) {
        _pickFileTool = [CMPOcrPickFileTool new];
    }
    return _pickFileTool;
}

@end
