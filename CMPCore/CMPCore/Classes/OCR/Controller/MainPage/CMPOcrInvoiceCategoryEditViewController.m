//
//  CMPOcrInvoiceCategoryEditViewController.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/8.
//

#import "CMPOcrInvoiceCategoryEditViewController.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPThemeManager.h>
#import "CMPOcrInvoiceCategoryEditView.h"
#import "CMPOcrInvoiceCategoryEditViewModel.h"

@interface CMPOcrInvoiceCategoryEditViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic,strong) CMPOcrInvoiceCategoryEditViewModel *viewModel;
@end

@implementation CMPOcrInvoiceCategoryEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    CMPOcrInvoiceCategoryEditView *aMainView = (CMPOcrInvoiceCategoryEditView *)self.mainView;
    [aMainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.bottom.equalTo(self.view.mas_bottom);
        make.top.equalTo(self.view.mas_top).offset(UIScreen.mainScreen.bounds.size.height * 0.34);
    }];
    
    __weak typeof(CMPOcrInvoiceCategoryEditView *) wMainView = aMainView;
    [self.viewModel fetchAllModulesWithParams:@{@"history":@(_history)} completion:^(NSArray * _Nonnull modules, NSError * _Nonnull error, id  _Nonnull ext) {
        if (!error) {
            if (ext){
                [wMainView.collectionView setItems:ext];
            }
        }else{
            
        }
    }];
    
    __weak typeof(self) wSelf = self;
    aMainView.collectionView.actBlk = ^(NSInteger act, id ext, UIViewController *controller) {
        switch (act) {
            case 0://cell点击
            {
                NSIndexPath *path = ext;
                if (path.section == 0) {
                    [wSelf dispatchAsyncToMain:^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationName_ocrModulesDidSelect" object:@(path.row)];
                        [wSelf dismissViewControllerAnimated:NO completion:^{
                            
                        }];
                    }];
                }
            }
                break;
            case 1://编辑保存
            {
                [wSelf.viewModel updateModulesListWithParams:@{@"history":@(self->_history),@"data":ext?:@[]} completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
                    if (!error) {
                        [wSelf dispatchAsyncToMain:^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationName_ocrModulesUpdateSuccess" object:nil];
                            
                            [wSelf dismissViewControllerAnimated:NO completion:^{
                                
                            }];
                        }];
                    }else{
                        
                    }
                }];
            }
                break;
                
            default:
                break;
        }
    };

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
}

-(void)setHistory:(BOOL)history
{
    _history = history;
    self.viewModel.history = history;
}

- (void)dismiss:(UIGestureRecognizer *)tap{
    [self dismissViewControllerAnimated:NO completion:^{
            
    }];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self.mainView]) {
        return NO;
    }
    return YES;
}


-(CMPOcrInvoiceCategoryEditViewModel *)viewModel
{
    if (!_viewModel) {
        _viewModel = [[CMPOcrInvoiceCategoryEditViewModel alloc] init];
    }
    return _viewModel;
}

@end
