//
//  CMPImpAlertManager.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/8/29.
//

#import "CMPImpAlertManager.h"
#import "CMPImpAlertViewModel.h"
#import "CMPImpAlertViewController.h"
#import "CMPHomeAlertManager.h"
#import <CMPLib/CMPServerVersionUtils.h>

@interface CMPImpAlertManager()
{
    CMPImpAlertViewModel *_viewModel;
}
@end

@implementation CMPImpAlertManager

static CMPImpAlertManager *impAlertManager ;
static dispatch_once_t onceTokenImpAlert;

+(instancetype)shareInstance
{
    dispatch_once(&onceTokenImpAlert, ^{
        impAlertManager = [[[self class] alloc] init];
    });
    return impAlertManager;
}

-(void)begin
{
    if (![CMPServerVersionUtils serverIsLaterV8_2_810]) return;
    if (!_viewModel) {
        _viewModel = [[CMPImpAlertViewModel alloc] init];
    }
    [_viewModel fetchImpMsgs:^(NSArray * _Nonnull datas, NSError * _Nonnull err) {
        if (!err && datas && [datas isKindOfClass:NSArray.class] && datas.count){
            [[CMPHomeAlertManager sharedInstance] pushTaskWithShowBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    CMPImpAlertViewController *vc = [[CMPImpAlertViewController alloc] initWithDatas:datas];
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                    UIViewController *curVc = [[UIApplication sharedApplication] keyWindow].rootViewController;
                    [curVc presentViewController:nav animated:YES completion:^{
                                            
                    }];
                });
            } priority:CMPHomeAlertPriorityImportMsg];
        }else{
            
        }
    }];
}

+(void)showMsgWithDatas:(NSArray *)datas
{
//    if (![CMPServerVersionUtils serverIsLaterV8_2_810]) return;
    if (datas && [datas isKindOfClass:NSArray.class] && datas.count){
        [[CMPHomeAlertManager sharedInstance] pushTaskWithShowBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                CMPImpAlertViewController *vc = [[CMPImpAlertViewController alloc] initWithDatas:datas];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                UIViewController *curVc = [[UIApplication sharedApplication] keyWindow].rootViewController;
                nav.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                [curVc presentViewController:nav animated:NO completion:^{
                                        
                }];
            });
        } priority:CMPHomeAlertPriorityImportMsg];
        [[CMPHomeAlertManager sharedInstance] ready];
    }
}

@end
