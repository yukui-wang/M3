//
//  CMPFaceManager.m
//  CMPCore
//
//  Created by Shoujian Rao on 2023/9/20.
//

#import "CMPFaceManager.h"
#import "CMPCommonManager.h"
#import <CMPLib/NSObject+CMPHUDView.h>

#import "CMPFaceConstant.h"
#import "CMPFaceDataProvider.h"

#import "FaceEEAlert.h"
#import "FaceEENetwork.h"
#import <CMPLib/CMPCustomAlertView.h>
#import "CMPFaceTool.h"

#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPThemeManager.h>

#import <CMPLib/CMPCommonWebViewController.h>
#import <CMPLib/CMPBannerWebViewController.h>
@interface CMPFaceManager()

#if TARGET_OS_SIMULATOR
    // 在模拟器环境下
#else
@property (nonatomic, strong) MegFaceEEManager *faceeeManager;
#endif



@property (nonatomic, strong) CMPFaceDataProvider *dataProvider;

@property (nonatomic, copy) NSString *domain;
@property (nonatomic, copy) NSString *endpoint;
@property (nonatomic, copy) NSString *clientId;
@property (nonatomic, copy) NSString *clientSecret;
@property (nonatomic, copy) NSString *username;

@property (nonatomic, assign) BOOL hasFaceIdAuth;//OA授权
@property (nonatomic, assign) BOOL faceIdEnable;//人脸识别关闭
@property (nonatomic, assign) BOOL exist;//用户是否存在
@property (nonatomic, assign) BOOL forbid;//禁用
@property (nonatomic, assign) BOOL hasImage;//已录入人脸

@end

@implementation CMPFaceManager


static CMPFaceManager *manager = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CMPFaceManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dataProvider = [[CMPFaceDataProvider alloc]init];
//        _domain = @"seeyoncloudv5test";
//        _endpoint = @"https://faceid.seeyoncloud.com";
//        _clientId = @"BM9rifoCWbM6_bEUlpuAoqpwpbWL4cx5";
//        _clientSecret = @"L_4PJU6Qf6dA4401rgOYdHmJEZ3rWVJh";
//        _username = @"raosj";
    }
    return self;
}

#if TARGET_OS_SIMULATOR
#else
//获取配置信息
- (void)getConfigCompletion:(ResultCompletion)resultCompletion{
    [self clearConfig];
    if (!resultCompletion) {
        return;
    }
    //如果只获取一次信息
//    if (self.clientId.length) {
//        if (resultCompletion) {
//            resultCompletion(YES,nil);
//        }
//        return;
//    }
    [self.dataProvider faceIdConfigCompletion:^(NSDictionary * _Nullable respData, NSError * _Nullable error) {
        if (error) {
            resultCompletion(NO,[CMPFaceErrorModel errFromNSError:error]);
        }else{
            self.hasFaceIdAuth = [CMPFaceTool boolValue:respData forKey:@"hasFaceIdAuth"];
            self.faceIdEnable = [CMPFaceTool boolValue:respData forKey:@"faceIdEnable"];
            self.clientId = [CMPFaceTool stringValue:respData forKey:@"clientId"];
            self.clientSecret = [CMPFaceTool stringValue:respData forKey:@"clientSecret"];
            self.domain = [CMPFaceTool stringValue:respData forKey:@"domain"];
            self.endpoint = [CMPFaceTool stringValue:respData forKey:@"endpoint"];

            NSDictionary *userInfo = [CMPFaceTool dicValue:respData forKey:@"checkUserName"];
            self.username = [CMPFaceTool stringValue:userInfo forKey:@"userName"];
            self.exist = [CMPFaceTool boolValue:userInfo forKey:@"exist"];
            self.forbid = [CMPFaceTool boolValue:userInfo forKey:@"forbid"];
            self.hasImage = [CMPFaceTool boolValue:userInfo forKey:@"hasImage"];
            
            resultCompletion(YES,nil);
        }
    }];
}

//签到插件
- (void)faceEECheckWithDict:(NSDictionary *)dict inVC:(UIViewController *)vc detectCompletion:(DetectCompletion)detectCompletion{
    if (!detectCompletion) {
        return;
    }
    @WeakObj(self);
    [self createManagerInVC:vc completion:^(BOOL success, CMPFaceErrorModel *errModel) {
        @StrongObj(self);
        if (success) {
            if (!self.hasImage) {//录入流程
                detectCompletion(200,LocalString(@"face_local_register_success"),nil,2);//人脸录入成功
                [self cmp_showSuccessHUDWithText:LocalString(@"face_local_register_success")];
            }else{
                [self verifyBizInVC:vc completion:detectCompletion];
            }
        }else{
            if (detectCompletion) {
                detectCompletion(errModel.errCode,errModel.errMsg,nil,0);
            }
        }
    }];
}

//验证人脸
- (void)verifyBizInVC:(UIViewController *)vc completion:(DetectCompletion)detectCompletion{
    if(!detectCompletion){
        return;
    }
    NSString *biz_no = [@"biz_no123456_ios_" stringByAppendingFormat:@"%f",[[NSDate date]timeIntervalSince1970]];
    @WeakObj(self);
    [self.dataProvider bizAndQrCodeByUserName:self.username biz_no:biz_no completion:^(NSDictionary * _Nullable respData, NSError * _Nullable error) {
        @StrongObj(self);
        if (error) {
            detectCompletion(400, error.description,nil,0);
        }else{
            NSString *remote_biz_no = [CMPFaceTool stringValue:respData forKey:@"bizNo"];
            if (![biz_no isEqualToString:remote_biz_no]) {
                //如果业务号和返回的对不上，则怀疑被篡改拦截
                detectCompletion(400, LocalString(@"face_local_bizNoChanged"),nil,0);//业务号已变更，验证失败
            }else{
                NSString *qrCode = [CMPFaceTool stringValue:respData forKey:@"qrCodeHref"];
                MegFaceEEOptions *options = [[MegFaceEEOptions alloc]init];
                options.needConfirmPage = NO;
                options.needSuccessPage = NO;
                options.needFailedPage = NO;
                options.credentialType = MegFaceEECredentialTypeFace;
                
                NSString *biz_info_token = [CMPFaceTool stringValue:respData forKey:@"bit"];
                @WeakObj(self);
                [self.faceeeManager qrCodeVerificationWithCurrentViewController:vc qrCode:qrCode options:options toExit:nil success:^(MegFaceEEVerifyResult * _Nullable verifyResult) {
                    @StrongObj(self);
                    NSString *qrCodeId = [self getQRCodeId:qrCode];
                    //biz_no
                    //扫码识别不需要传这个
                    [self.dataProvider getResultWith:biz_no bizInfoToken:biz_info_token completion:^(NSDictionary * _Nullable respData, NSError * _Nullable error) {
                        if (error) {
                            detectCompletion(error.code,error.description,nil,0);
                        }else{
                            NSString *remote_bizNo = [CMPFaceTool stringValue:respData forKey:@"bizNo"];
                            if (![biz_no isEqualToString:remote_bizNo]) {
                                detectCompletion(400, LocalString(@"face_local_bizNoChanged"),nil,0);//业务号已变更，验证失败。如果业务号和返回的对不上，则怀疑被篡改拦截
                            }else{
                                NSString *result = [CMPFaceTool stringValue:respData forKey:@"status"];
                                BOOL success = [result isEqualToString:@"success"];
                                if (success) {
                                    detectCompletion(200,LocalString(@"face_local_verify_success"),qrCodeId,1);//验证成功
                                }else{
                                    detectCompletion(400,LocalString(@"face_local_verify_fail"),qrCodeId,0);//验证失败
                                }
                            }
                        }
                    }];
                } failed:^(MegFaceEEError * _Nonnull error) {
                    detectCompletion(error.errorCode, error.errorDescription,nil,0);
                    NSLog(@"qrCodeVerification failed: %zd - %@ - %@", error.errorCode, error.errorMessage, error.errorDescription);
                }];
            }
        }
    }];
}

//二维码
- (void)verifyQrCode:(NSString *)qrCode inVC:(UIViewController *)vc completion:(ResultCompletion)resultCompletion{
    if (!resultCompletion) {
        return;
    }
    @WeakObj(self);
    [self createManagerInVC:vc completion:^(BOOL success, CMPFaceErrorModel *errModel) {
        @StrongObj(self);
        if (success) {
            if (!self.hasImage) {//未录入过人脸
                resultCompletion(NO,[CMPFaceErrorModel errCode:400 errMsg:LocalString(@"face_local_register_success") errEnum:@""]);//人脸录入成功
            }else{
                if ([self.faceeeManager isFaceEEQrCode:qrCode]) {
                    MegFaceEEOptions *options = [[MegFaceEEOptions alloc]init];
                    options.needConfirmPage = NO;
                    options.needSuccessPage = NO;
                    options.needFailedPage = NO;
                    options.credentialType = MegFaceEECredentialTypeFace;
                    @WeakObj(self);
                    [self.faceeeManager qrCodeVerificationWithCurrentViewController:vc qrCode:qrCode options:options toExit:nil success:^(MegFaceEEVerifyResult * _Nonnull verifyResult) {
                        @StrongObj(self);
                        [self cmp_showSuccessHUDWithText:LocalString(@"face_local_verify_success")];//扫码提示要保留(验证成功)
                        resultCompletion(YES,nil);
//                        [self alertInVC:vc message:@"验证成功" confirmBlock:^{
//                            resultCompletion(YES,nil);
//                        }];
                    } failed:^(MegFaceEEError * _Nonnull error) {
                        @StrongObj(self);
                        [self alertInVC:vc message:error.errorDescription confirmBlock:^{
                            resultCompletion(NO,[CMPFaceErrorModel errCode:error.errorCode errMsg:error.errorDescription errEnum:error.errorMessage]);
                        }];
                        NSLog(@"qrCodeVerification failed: %zd - %@ - %@", error.errorCode, error.errorMessage, error.errorDescription);
                    }];
                }else{
                    [self alertInVC:vc message:LocalString(@"face_local_notFaceQrCode") confirmBlock:^{//非人脸识别二维码
                        resultCompletion(NO,[CMPFaceErrorModel errCode:400 errMsg:LocalString(@"face_local_notFaceQrCode") errEnum:@""]);
                    }];
                }
            }
        }else{
            [self alertInVC:vc message:errModel.errMsg confirmBlock:^{
                resultCompletion(NO,errModel);
            }];
        }
    }];
}

- (void)loginSDKWithUsername:(NSString *)username isSilent:(BOOL)isSilent inVC:(UIViewController *)vc completion:(ResultCompletion)resultCompletion{
    
    //隐私协议 app第一次录入人脸弹出
    [self setAgreementConfig];
    
    @WeakObj(self);
    [self.dataProvider credentialBy:username isSkip:isSilent completion:^(NSDictionary * _Nullable respData, NSError * _Nullable error) {
        @StrongObj(self);
        if (error) {
            if (resultCompletion) {
                resultCompletion(NO,[CMPFaceErrorModel errFromNSError:error]);
            }
        }else{
            NSString *credential = [CMPFaceTool stringValue:respData forKey:@"cred"];
            @WeakObj(self);
            [MegFaceEEManager createManagerWithBundlePath:[self getBundlePath] domain:self.domain endpoint:self.endpoint options:[self getOptions] success:^(MegFaceEEManager * _Nonnull manager) {
                @StrongObj(self);
                self.faceeeManager = manager;
                [self updateLanguage];
                MegFaceEEUserInfo *userInfo = [MegFaceEEManager getUserInfoWithDomain:self.domain error:nil];
                if (!userInfo.isPassed) {
                    [self loginManageWithCredential:credential inVC:vc completion:resultCompletion];
                } else {
                    @WeakObj(self);
                    [self logout:^{
                        [MegFaceEEManager createManagerWithBundlePath:[self getBundlePath] domain:self.domain endpoint:self.endpoint options:[self getOptions] success:^(MegFaceEEManager * _Nonnull manager) {
                            @StrongObj(self);
                            self.faceeeManager = manager;
                            [self updateLanguage];
                            [self loginManageWithCredential:credential inVC:vc completion:resultCompletion];
                        } failed:^(MegFaceEEError * _Nonnull error) {
                            if (resultCompletion) {
                                resultCompletion(NO,[CMPFaceErrorModel errCode:error.errorCode errMsg:error.errorDescription errEnum:error.errorMessage]);
                            }
                        }];
                    }];
                }
            } failed:^(MegFaceEEError * _Nonnull error) {
                if (resultCompletion) {
                    resultCompletion(NO,[CMPFaceErrorModel errCode:error.errorCode errMsg:error.errorDescription errEnum:error.errorMessage]);
                }
                NSLog(@"createManager: %zd-%@-%@", error.errorCode, error.errorMessage, error.errorDescription);
            }];
        }
    }];
}

//切换语言
- (void)updateLanguage{
    NSString *lang = [CMPCore languageCode];
    if ([lang isEqualToString:kLanguageCode_En]) {//英语
        [self.faceeeManager setLanguage:(MegFaceEELanguageTypeEn)];
    }else{
        [self.faceeeManager setLanguage:(MegFaceEELanguageTypeCh)];
    }
}

//使用credential登录SDK
- (void)loginManageWithCredential:(NSString *)credential inVC:(UIViewController *)vc completion:(ResultCompletion)resultCompletion{
    MegFaceEEOptions *options = [[MegFaceEEOptions alloc]init];
    options.needConfirmPage = NO;
    options.credentialType = MegFaceEECredentialTypeFace;
    options.needSuccessPage = NO;
    options.needFailedPage = NO;
    [self.faceeeManager loginWithCurrentViewController:vc credential:credential options:options success:^{
        if(resultCompletion){
            resultCompletion(YES, nil);
        }
    } failed:^(MegFaceEEError * _Nonnull error) {
        if(resultCompletion){
            resultCompletion(NO, [CMPFaceErrorModel errCode:error.errorCode errMsg:error.errorDescription errEnum:error.errorMessage]);
        }
        NSLog(@"login failed: %zd-%@-%@", error.errorCode, error.errorMessage, error.errorDescription);
    }];
}

//退出
- (void)logout:(void(^)(void))completion {
    [self.faceeeManager logout:^{
        if (completion) {
            completion();
        }
    } failed:^(MegFaceEEError * _Nonnull error) {
        if (completion) {
            completion();
        }
    }];
}

//隐私弹框/页面
- (void)setAgreementConfig{
    MegFaceEEGlobalConfig *globalConfig = [[MegFaceEEGlobalConfig alloc] init];
    MegFaceEEError *agreeError;
    
//    NSString *face_url = @"https://bj-faceid-test-asset.oss-cn-beijing.aliyuncs.com/faceid-enterprise-doc/faceid-agreement.html";
//    NSString *language = [CMPCore languageCode];//[NSLocale preferredLanguages][0];
//    NSString *urlStr = [NSString stringWithFormat:@"http://m3.seeyon.com/privacy/index.html?language=%@", language];
    
    //《隐私政策》
//    MegFaceEEAgreementConfig *agreementConfig = [[MegFaceEEAgreementConfig alloc] initWithAgreementTitle:LocalString(@"face_local_privacyPolicy") agreementUrl:urlStr error:&agreeError];
    
        MegFaceEEAgreementConfig *agreementConfig = [[MegFaceEEAgreementConfig alloc] initWithStartFaceDetectBlock:^(UIViewController * _Nonnull vc, MegFaceEEManager * _Nonnull manager, MegFaceEEContinueBlock continueBlock, MegFaceEEExitBlock exitBlock) {
            
//            TestViewController *testvc = [[TestViewController alloc] init];
//            if (vc.navigationController) {
//                [vc.navigationController pushViewController:testvc animated:YES];
//            } else {
//                [vc presentViewController:testvc animated:YES completion:^{
//    
//                }];
//            }
//            testvc.continueBlock = continueBlock;
//            testvc.exitBlock = ^{
//                if (vc.navigationController) {
//                    [vc.navigationController popToViewController:vc animated:YES];
//                } else {
//                    [vc dismissViewControllerAnimated:YES completion:nil];
//                }
//                exitBlock();
//            };
//            continueBlock(vc);
            
            //自定义查看隐私协议弹框
            [self alertAgreeFromVC:vc okAction:^(id vc1) {
                UIViewController *vcc = vc1;
                if (continueBlock) {
                    continueBlock(vcc);
                }
            } cancelAction:^{
                if (exitBlock) {
                    exitBlock();
                }
            }];
        } error:&agreeError];

    [globalConfig setAgreementConfig:agreementConfig];
    [MegFaceEEManager setGlobalConfig:globalConfig error:&agreeError];
}

- (void)alertAgreeFromVC:(UIViewController *)vc okAction:(void(^)(id))okAction cancelAction:(void(^)(void))cancelAction{
    NSString *title = LocalString(@"face_local_authorize_biological_title");
    NSString *content = LocalString(@"face_local_authorize_biological_content");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];

    //同意
    UIAlertAction *okAction1 = [UIAlertAction actionWithTitle:LocalString(@"face_local_agree") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (okAction) {
            okAction(vc);
        }
    }];
    //不同意
    UIAlertAction *cancelAction1 = [UIAlertAction actionWithTitle:LocalString(@"face_local_not_agree_exit") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (cancelAction) {
            cancelAction();
        }
    }];
    //查看隐私政策
    UIAlertAction *privateAction = [UIAlertAction actionWithTitle:LocalString(@"face_local_view_privacyPolicy") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//        CMPCommonWebViewController *ctrl = [[CMPCommonWebViewController alloc] initWithURL:[NSURL URLWithString:urlStr]];
//        ctrl.closeBlock = ^{
//            [self alertAgreeFromVC:vc okAction:^(id vc1) {
//                if (okAction) {
//                    okAction(vc1);
//                }
//            } cancelAction:^{
//                if (cancelAction) {
//                    cancelAction();
//                }
//            }];
//        };
//        [vc presentViewController:ctrl animated:YES completion:nil];
        
        CMPBannerWebViewController *viewController = [[CMPBannerWebViewController alloc] init];
        viewController.startPage = [CMPCommonManager privacyAgreementUrl];
        viewController.closeButtonHidden = YES;
        viewController.hideBannerNavBar = NO;
        viewController.isShowBannerProgress = YES;
        
        __weak typeof(self) weakSelf = self;
        viewController.dismissCompletionBlock = ^{
            [weakSelf alertAgreeFromVC:vc okAction:^(id vc1) {
                if (okAction) {
                    okAction(vc1);
                }
            } cancelAction:^{
                if (cancelAction) {
                    cancelAction();
                }
            }];
        };
        [vc presentViewController:viewController animated:YES completion:nil];
    }];
    [alertController addAction:privateAction];
    [alertController addAction:okAction1];
    [alertController addAction:cancelAction1];
    // 显示 UIAlertController
    [vc presentViewController:alertController animated:YES completion:nil];
}

- (void)createManagerInVC:(UIViewController *)vc completion:(ResultCompletion)resultCompletion {
    if (!resultCompletion) {
        return;
    }
    @WeakObj(self);
    [self getConfigCompletion:^(BOOL success, CMPFaceErrorModel *errModel) {
        @StrongObj(self);
        if (success) {
            if (self.faceIdEnable) {
                if(self.hasFaceIdAuth){
                    if (self.username.length) {
                        if (!self.forbid) {
                            if (![NSString isNull:self.clientId] && ![NSString isNull:self.clientSecret] && ![NSString isNull:self.domain] && ![NSString isNull:self.endpoint]) {
                                if (self.hasImage) {
                                    //有人脸
                                    [self loginSDKWithUsername:self.username isSilent:YES inVC:vc completion:resultCompletion];
                                }else{
                                    //未录入人脸
                                    @WeakObj(self);
                                    [self confirmRegisterFaceInVC:vc confirmBlock:^{
                                        @StrongObj(self);
                                        [self loginSDKWithUsername:self.username isSilent:NO inVC:vc completion:resultCompletion];
                                    } cancelBlock:^{
                                        //取消人脸录入
                                        resultCompletion(NO,[CMPFaceErrorModel errCode:501 errMsg:@"" errEnum:@""]);//
                                    }];
                                }
                            }else{
                                //配置信息为空
                                resultCompletion(NO,[CMPFaceErrorModel errCode:501 errMsg:LocalString(@"face_local_noConfig") errEnum:@""]);
                            }
                        }else{
                            //被禁用
                            resultCompletion(NO,[CMPFaceErrorModel errCode:501 errMsg:LocalString(@"face_local_accountForbid") errEnum:@""]);
                        }
                    }else{
                        //旷视关联账号不存在
                        resultCompletion(NO,[CMPFaceErrorModel errCode:501 errMsg:LocalString(@"face_local_noAccount") errEnum:@""]);
                    }
                }else{
                    //人脸服务未授权
                    resultCompletion(NO,[CMPFaceErrorModel errCode:501 errMsg:LocalString(@"face_local_noAuth") errEnum:@""]);
                }
            }else{
                //人脸服务不可用
                resultCompletion(NO,[CMPFaceErrorModel errCode:501 errMsg:LocalString(@"face_local_disabled") errEnum:@""]);
            }
        }else{
            resultCompletion(success,errModel);
        }
    }];
}

//确认开始录入
- (void)confirmRegisterFaceInVC:(UIViewController *)vc confirmBlock:(void(^)(void))confirmBlock cancelBlock:(void(^)(void))cancelBlock{
//    [FaceEEAlert alertWithViewController:vc title:@"" message:@"管理员已开启人脸识别打卡，请先录入人脸再打卡" cancelText:@"取消" confirmText:@"开始录入" needCancle:YES cancelHandler:^(UIAlertAction * _Nonnull action) {
//        if (cancelBlock) {
//            cancelBlock();
//        }
//    } confirmHandler:^(UIAlertAction * _Nonnull action) {
//        if (confirmBlock) {
//            confirmBlock();
//        }
//    }];
    
    id<CMPCustomAlertViewProtocol> alert = [CMPCustomAlertView alertViewWithTitle:nil message:LocalString(@"face_local_confirmRegister") preferredStyle:CMPCustomAlertViewStyleAlert footStyle:CMPAlertPublicFootStyleDefalut bodyStyle:CMPAlertPublicBodyStyleDefalut cancelButtonTitle:SY_STRING(@"common_cancel") otherButtonTitles:@[LocalString(@"face_local_beginRegister")] handler:^(NSInteger buttonIndex, id  _Nullable value) {
        if (buttonIndex == 1) {
            if (confirmBlock) {
                confirmBlock();
            }
        } else {
            if (cancelBlock) {
                cancelBlock();
            }
        }
    }];
    [alert setTheme:CMPTheme.new];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert show];
    });
}

//确认弹框
- (void)alertInVC:(UIViewController *)vc message:(NSString *)message confirmBlock:(void(^)(void))confirmBlock{
    id<CMPCustomAlertViewProtocol> alert = [CMPCustomAlertView alertViewWithTitle:nil message:message preferredStyle:CMPCustomAlertViewStyleAlert footStyle:CMPAlertPublicFootStyleDefalut bodyStyle:CMPAlertPublicBodyStyleDefalut cancelButtonTitle:nil otherButtonTitles:@[SY_STRING(@"common_ok")] handler:^(NSInteger buttonIndex, id  _Nullable value) {
        if (buttonIndex == 1) {//确定
            if (confirmBlock) {
                confirmBlock();
            }
        }
    }];
    [alert setTheme:CMPTheme.new];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert show];
    });
}

//获取UI配置
- (MegFaceEEGlobalOptions *)getOptions{
    MegFaceEEGlobalOptions *options = [[MegFaceEEGlobalOptions alloc] init];
    //主题色
    options.themeColor = [UIColor cmp_colorWithName:@"theme-bgc"];
    MegLiveV5DetectUIConfigItem *uiConfig = [[MegLiveV5DetectUIConfigItem alloc]init];
    uiConfig.livenessHomeBackgroundColor1 = [UIColor whiteColor];
    uiConfig.livenessHomeBackgroundColor2 = [UIColor whiteColor];
    
    //退出识别后的弹框按钮颜色
    uiConfig.livenessHomeConfirmButtonColor = UIColorFromRGB(0x007AFF);//#007AFF
    uiConfig.livenessHomeCancelButtonColor = UIColorFromRGB(0x007AFF);//#007AFF
    
    //蛇形线条
    uiConfig.livenessHomeLoadingLineColor = [UIColor cmp_colorWithName:@"theme-bgc"];
    //检测中人形线条
    uiConfig.livenessHomeFlashContourLineColor = UIColorFromRGB(0xffffff);
    //活体进度条颜色(动作和静默活体)
    uiConfig.livenessHomeProcessBarColor = [UIColor cmp_colorWithName:@"theme-bgc"];
    //正常状态提示文字颜色
    uiConfig.livenessHomeNormalRemindTextColor = UIColorFromRGB(0x333333);
    
    uiConfig.livenessHomeRemindTextSize = 16;
    //错误提示文字颜色
    uiConfig.livenessHomeFailedRemindTextColor = UIColor.redColor;
    //loading文字颜色
    uiConfig.livenessHomeLoadingTextColor = UIColorFromRGB(0xffffff);//UIColor.redColor;
    //检测成功中间人形线条色
    uiConfig.livenessHomeContourLineColor = [UIColor cmp_colorWithName:@"theme-bgc"];
    
    options.v5UIConfig = uiConfig;
    return options;
}

- (NSString *)getBundlePath{
    return [[NSBundle mainBundle] pathForResource:@"MegFaceEE" ofType:@"bundle"];
}

//退出登录或者切换账号使用
- (void)clearConfig{
    self.domain = nil;
    self.endpoint = nil;
    self.clientId = nil;
    self.clientSecret = nil;
    self.username = nil;
    self.exist = NO;
    self.forbid = YES;
    self.hasImage = NO;
    [self.faceeeManager logout:^{
    } failed:^(MegFaceEEError * _Nonnull error) {
    }];
//    self.faceeeManager = nil;
}

//本地判断是否为人脸二维码
- (BOOL)isFaceEEQrCode:(NSString *)qrCode {
    if (![qrCode hasPrefix:@"https://api.megvii.com/faceid_enterprise/faceee/pages/open-app?"] && ![qrCode hasPrefix:@"https://eeqr.faceid.com"]) {
        return NO;
    }
    NSURL *url = [NSURL URLWithString:qrCode];
    NSString *query = url.query;
    NSURLComponents *components = [NSURLComponents componentsWithString:qrCode];
    NSArray *queryItems = components.queryItems;
    if ([query containsString:@"qr_code_id"] && [query containsString:@"domain"]) {
        NSString *domain = @"";
        NSString *qrCodeId = @"";
        NSString *site = @"";
        if (![query containsString:@"site"]) {
            site = @"main";
        }
        for (NSURLQueryItem *item in queryItems) {
            if ([item.name isEqualToString:@"domain"]) {
                domain = item.value;
            } else if ([item.name isEqualToString:@"qr_code_id"]) {
                qrCodeId = item.value;
            } else if ([item.name isEqualToString:@"site"]) {
                site = item.value;
            }
        }
        if (domain.length > 0 && qrCodeId.length > 0 && site.length > 0) {
            return YES;
        }
    }
    if ([query containsString:@"otp_data"] && [query containsString:@"domain"]) {
        return YES;
    }
    return NO;
}

//根据qrcode字符串获取qr_code_id
- (NSString *)getQRCodeId:(NSString *)qrCode {
    NSURLComponents *components = [NSURLComponents componentsWithString:qrCode];
    NSArray *queryItems = components.queryItems;
    NSString *qrCodeId = @"";
    for (NSURLQueryItem *item in queryItems) {
        if ([item.name isEqualToString:@"qr_code_id"]) {
            qrCodeId = item.value;
            break;
        }
    }
    return qrCodeId;
}
#endif
@end
