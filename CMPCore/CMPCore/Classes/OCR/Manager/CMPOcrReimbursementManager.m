//
//  CMPOcrReimbursementManager.m
//  M3
//
//  Created by Shoujian Rao on 2022/1/14.
//

#import "CMPOcrReimbursementManager.h"
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import "CMPOcrMainViewDataProvider.h"
#import "CMPOcrNotificationKey.h"
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPAlertView.h>

@interface CMPOcrReimbursementManager()
@property (nonatomic, strong) CMPOcrMainViewDataProvider *dataProvider;
@end

@implementation CMPOcrReimbursementManager

- (CMPOcrMainViewDataProvider *)dataProvider{
    if (!_dataProvider) {
        _dataProvider = [CMPOcrMainViewDataProvider new];
    }
    return _dataProvider;
}

//处理PC唤醒一键报销结果
- (void)pcReimbursementWithData:(NSDictionary *)respData templateId:(NSString *)templateId formId:(NSString *)formId packageId:(NSString *)packageId summaryId:(NSString *)summaryId fromVC:(UIViewController *)fromVC wakeUpBlock:(void(^)(void))wakeUpBlock {
    NSString *code = [NSString stringWithFormat:@"%@",respData[@"code"]];
    if ([code isEqualToString:@"0"]) {
        if (wakeUpBlock) {
            wakeUpBlock();
        }
    }else{
        NSString *msg = respData[@"message"]?:@"";//html文本
        NSString *title = [respData[@"title"] isKindOfClass:NSString.class]?respData[@"title"]:@"一键报销";
        UIAlertAction *act;
        if ([code isEqualToString:@"1"]) {
            act = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //需要删除重复发票后再进入报销流程
//                [self.dataProvider deleteRepeatTicketsForPackageBeforeSubmitWithParams:@{@"packageId":packageId?:@""} completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
//                    if (!error) {
//                        //删除后通知刷新
//                        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationOneReimbursementRemovedInvoice object:nil];
//                    }else{
//                        [fromVC.view cmp_showHUDError:error];
//                    }
//                }];
            }];
        }else{
            act = [UIAlertAction actionWithTitle:SY_STRING(@"common_confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
        }
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:SY_STRING(@"common_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        CMPAlertViewController *alert = [CMPAlertViewController alertControllerWithTitle:title html:msg preferredStyle:UIAlertControllerStyleAlert actions:@[cancel,act]];
        [fromVC presentViewController:alert animated:YES completion:nil];
    }
}

- (void)reimbursementWithData:(NSDictionary *)respData
                invoiceIdList:(NSArray *)invoiceIdList
                   templateId:(NSString *)templateId
                       formId:(NSString *)formId
                       fromVC:(UIViewController *)fromVC
              callCreateBlock:(void (^)(NSInteger))callCreateBlock{
    
}

/**
 ks add
 //处理check结果
 */
- (void)ks_reimbursementWithData:(NSDictionary *)respData templateId:(NSString *)templateId formId:(NSString *)formId packageId:(NSString *)packageId summaryId:(NSString *)summaryId fromVC:(UIViewController *)fromVC cancelBlock:(void(^)(void))cancelBlock actBlock:(void(^)(NSArray *invoiceIds,NSError *err,id ext, NSInteger from))actBlock ext:(id)ext{
    NSString *code = [NSString stringWithFormat:@"%@",respData[@"code"]];
    if ([code isEqualToString:@"0"]||[code isEqualToString:@"7"]) {
        
        NSDictionary *extraInfoDict;
        if ([respData[@"extraInfo"] isKindOfClass:NSDictionary.class]) {
            extraInfoDict = respData[@"extraInfo"];
        }
        NSArray *invoiceIds = extraInfoDict[@"invoiceIds"];
        
        NSString *msg = respData[@"message"]?:@"";//html内容
        NSString *title = [respData[@"title"] isKindOfClass:NSString.class]?respData[@"title"]:@"一键报销";

        UIAlertAction *act = [UIAlertAction actionWithTitle:SY_STRING(@"common_confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([ext integerValue]==3) {
                NSDictionary *backParam = @{
    //                @"id":packageId?:@"",
                    @"formId":formId?:@"",
                    @"templateId":templateId?:@"",
                    @"invoiceIdList":invoiceIds.count>0?[invoiceIds componentsJoinedByString:@","]:@"",
                };
                
                [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationFormReimburseCompleted object:backParam];
                [fromVC.navigationController popViewControllerAnimated:YES];
                return;
            }
            if (actBlock) {
                actBlock(invoiceIds,nil,extraInfoDict,1);
            }
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:SY_STRING(@"common_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (cancelBlock) {
                cancelBlock();
            }
        }];
        CMPAlertViewController *alert = [CMPAlertViewController alertControllerWithTitle:title html:msg preferredStyle:UIAlertControllerStyleAlert actions:@[cancel,act]];
        [fromVC presentViewController:alert animated:YES completion:nil];
    } else{
        NSString *msg = respData[@"message"]?:@"";//html文本
        NSString *title = [respData[@"title"] isKindOfClass:NSString.class]?respData[@"title"]:@"一键报销";
        
        NSDictionary *extraInfoDict;
        if ([respData[@"extraInfo"] isKindOfClass:NSDictionary.class]) {
            extraInfoDict = respData[@"extraInfo"];
        }
        NSArray *invoiceIds = extraInfoDict[@"invoiceIds"];
        UIAlertAction *act;
        if ([code isEqualToString:@"1"]) {
            act = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //需要删除重复发票后再进入报销流程
                [self.dataProvider deleteRepeatWithInvoiceIdList:invoiceIds completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
                    if (!error) {
                        //删除后通知刷新
                        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationOneReimbursementRemovedInvoice object:respData];
                        if (actBlock) {
                            actBlock(respData,error,ext,2);
                        }
                    }else{
                        [fromVC.view cmp_showHUDError:error];
                    }
                }];
            }];
        }else{
            act = [UIAlertAction actionWithTitle:SY_STRING(@"common_confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            title = nil;
        }
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:SY_STRING(@"common_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (cancelBlock) {
                cancelBlock();
            }
        }];
        CMPAlertViewController *alert = [CMPAlertViewController alertControllerWithTitle:title html:msg preferredStyle:UIAlertControllerStyleAlert actions:@[cancel,act]];
        [fromVC presentViewController:alert animated:YES completion:nil];
    }
}

//处理一键报销结果
- (void)reimbursementWithData:(NSDictionary *)respData templateId:(NSString *)templateId formId:(NSString *)formId packageId:(NSString *)packageId summaryId:(NSString *)summaryId fromVC:(UIViewController *)fromVC cancelBlock:(void(^)(void))cancelBlock deleteBlock:(void(^)(void))deleteBlock ext:(id)ext{
    NSString *code = [NSString stringWithFormat:@"%@",respData[@"code"]];
    if ([code isEqualToString:@"0"]||[code isEqualToString:@"7"]) {
        
        NSDictionary *extraInfoDict;
        if ([respData[@"extraInfo"] isKindOfClass:NSDictionary.class]) {
            extraInfoDict = respData[@"extraInfo"];
        }
        NSArray *invoiceIds = extraInfoDict[@"invoiceIds"];
        
        NSString *msg = respData[@"message"]?:@"";//html内容
        NSString *title = [respData[@"title"] isKindOfClass:NSString.class]?respData[@"title"]:@"一键报销";

        UIAlertAction *act = [UIAlertAction actionWithTitle:SY_STRING(@"common_confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([ext integerValue]==3) {
                NSDictionary *backParam = @{
    //                @"id":packageId?:@"",
                    @"formId":formId?:@"",
                    @"templateId":templateId?:@"",
                    @"invoiceIdList":invoiceIds.count>0?[invoiceIds componentsJoinedByString:@","]:@"",
                };
                
                [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationFormReimburseCompleted object:backParam];
                [fromVC.navigationController popViewControllerAnimated:YES];
                return;
            }
            [self jumpToFormFromVC:fromVC invoiceIdList:invoiceIds templateId:templateId packageId:packageId formId:formId];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:SY_STRING(@"common_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (cancelBlock) {
                cancelBlock();
            }
        }];
        CMPAlertViewController *alert = [CMPAlertViewController alertControllerWithTitle:title html:msg preferredStyle:UIAlertControllerStyleAlert actions:@[cancel,act]];
        [fromVC presentViewController:alert animated:YES completion:nil];
    } else{
        NSString *msg = respData[@"message"]?:@"";//html文本
        NSString *title = [respData[@"title"] isKindOfClass:NSString.class]?respData[@"title"]:@"一键报销";
        
        NSDictionary *extraInfoDict;
        if ([respData[@"extraInfo"] isKindOfClass:NSDictionary.class]) {
            extraInfoDict = respData[@"extraInfo"];
        }
        NSArray *invoiceIds = extraInfoDict[@"invoiceIds"];
        UIAlertAction *act;
        if ([code isEqualToString:@"1"]) {
            act = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //需要删除重复发票后再进入报销流程
                [self.dataProvider deleteRepeatWithInvoiceIdList:invoiceIds completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
                    if (!error) {
                        //删除后通知刷新
                        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationOneReimbursementRemovedInvoice object:respData];
                        if (deleteBlock) {
                            deleteBlock();
                        }
                    }else{
                        [fromVC.view cmp_showHUDError:error];
                    }
                }];
            }];
        }else{
            act = [UIAlertAction actionWithTitle:SY_STRING(@"common_confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            title = nil;
        }
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:SY_STRING(@"common_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (cancelBlock) {
                cancelBlock();
            }
        }];
        CMPAlertViewController *alert = [CMPAlertViewController alertControllerWithTitle:title html:msg preferredStyle:UIAlertControllerStyleAlert actions:@[cancel,act]];
        [fromVC presentViewController:alert animated:YES completion:nil];
    }
}

//跳转到表单
- (void)jumpToFormFromVC:(UIViewController *)fromVC
           invoiceIdList:(NSArray *)invoiceIdList
              templateId:(NSString *)templateId
               packageId:(NSString *)packageId
                  formId:(NSString *)formId{
    CMPBannerWebViewController *webCtrl = [[CMPBannerWebViewController alloc] init];
    NSString *href = @"http://ocr.v5.cmp/v1.0.0/html/ocrTransfer.html";
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:href]];
    if ([NSString isNotNull:localHref]) {
        href = localHref;
    }
//    NSString *pp = [invoiceIdList?:@[] yy_modelToJSONString];
    NSString *pp = [invoiceIdList componentsJoinedByString:@","];
    href = [NSString stringWithFormat:@"%@?templateId=%@&formId=%@&invoiceIdList=%@&packageId=%@",href,templateId,formId,pp,packageId];
    href = [href urlCFEncoded];
    NSLog(@"跳转表单href=%@",href);
    webCtrl.hideBannerNavBar = NO;
    webCtrl.startPage = href;

    webCtrl.viewWillClose = ^{};
    [fromVC.navigationController pushViewController:webCtrl animated:YES];
}

//默认票夹页面-check结果处理
- (void)reimbursementCheckWithData:(NSDictionary *)respData templateId:(NSString *)templateId formId:(NSString *)formId packageId:(NSString *)packageId fromVC:(UIViewController *)fromVC callCreateBlock:(void(^)(NSInteger))callCreateBlock{
    NSString *code = [NSString stringWithFormat:@"%@",respData[@"code"]];
    if ([code isEqualToString:@"7"]) {
        NSString *msg = respData[@"message"]?:@"";//html内容
        NSString *title = [respData[@"title"] isKindOfClass:NSString.class]?respData[@"title"]:@"一键报销";
        //确认
        UIAlertAction *act = [UIAlertAction actionWithTitle:SY_STRING(@"common_confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (callCreateBlock) {
                callCreateBlock(7);
            }
        }];
        //取消
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:SY_STRING(@"common_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        CMPAlertViewController *alert = [CMPAlertViewController alertControllerWithTitle:title html:msg preferredStyle:UIAlertControllerStyleAlert actions:@[cancel,act]];
        [fromVC presentViewController:alert animated:YES completion:nil];
    } else if ([code isEqualToString:@"1"]) {
        //需要删除
        NSString *msg = respData[@"message"]?:@"";//html内容
        NSString *title = respData[@"title"]?:@"";
        //确认
        UIAlertAction *act = [UIAlertAction actionWithTitle:@"确认删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (callCreateBlock) {
                callCreateBlock(1);
            }
        }];
        //取消
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:SY_STRING(@"common_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        CMPAlertViewController *alert = [CMPAlertViewController alertControllerWithTitle:title html:msg preferredStyle:UIAlertControllerStyleAlert actions:@[cancel,act]];
        [fromVC presentViewController:alert animated:YES completion:nil];
    } else{
        //只需提示
        NSString *msg = respData[@"message"]?:@"";//html内容
        NSString *title = respData[@"title"]?:@"";
        //确认
        UIAlertAction *act = [UIAlertAction actionWithTitle:SY_STRING(@"common_confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        //取消
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:SY_STRING(@"common_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        CMPAlertViewController *alert = [CMPAlertViewController alertControllerWithTitle:title html:msg preferredStyle:UIAlertControllerStyleAlert actions:@[cancel,act]];
        [fromVC presentViewController:alert animated:YES completion:nil];
    }
}
@end
