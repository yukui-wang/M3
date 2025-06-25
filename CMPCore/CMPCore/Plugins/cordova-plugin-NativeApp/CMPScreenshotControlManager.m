//
//  CMPScreenshotControlManager.m
//  M3
//
//  Created by MacBook on 2019/11/26.
//

#import "CMPScreenshotControlManager.h"
#import "CMPShareManager.h"

#import <CMPLib/CMPCore.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPDataProvider.h>
#import <CordovaLib/CDVViewController.h>
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPStringConst.h>
#import <CMPLib/CMPCommonTool.h>
#import "CMPLoginViewController.h"
#import "CMPNewLoginViewController.h"

static CMPScreenshotControlManager *instance_ = nil;

@interface CMPScreenshotControlManager()<NSCopying,CMPDataProviderDelegate>

@end

@implementation CMPScreenshotControlManager

#pragma mark - 单例实现

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = [[self alloc] init];
    });
    return instance_;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = [super allocWithZone:zone];
    });
    return instance_;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - 截屏消息拦截及其处理

#pragma mark 外部方法

- (void)initializeScreenshotConfig {
    [self addNoti];
}

#pragma mark 通知相关
- (void)addNoti {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(userDidTakeScreenshot:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(ybImageBrowserForwardNoti:) name:CMPYBImageBrowserForwardNoti object:nil];
}

/// 处理截屏事件
- (void)userDidTakeScreenshot:(NSNotification *)noti {
    if (CMPCore.sharedInstance.screenshotType == -1) {
        //版本不支持，则返回
        return;
    }
    //这里通知传过来的也就是一个UIApplication的对象而已，在这里实际用处不大
//    NSLog(@"did take screenshot");
    //如果后台开启了截屏控制的话，就进行截屏提示
    
    BOOL isLoginVC = NO;
    UIViewController *frontVc = [CMPCommonTool getCurrentShowViewController];
    if ([frontVc isKindOfClass:CMPLoginViewController.class]
        || [frontVc isKindOfClass:CMPNewLoginViewController.class]) {
        isLoginVC = YES;
    }
    
    //截屏提示：登录页面必须提示；其他截图提示根据后端配置
    BOOL alert = NO;
    if (isLoginVC) {
        alert = YES;
    }else if (CMPCore.isLoginState && CMPCore.sharedInstance.screenshotType==0){
        //登录后页面&&不允许截屏
        alert = YES;
    }
    
    if (alert) {
        [self showScreenShotAlert];
        if (CMPCore.isLoginState) {
            [self uploadLog];//上传日志
        }
    }
}

- (void)showScreenShotAlert{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:SY_STRING(@"screenshot_control_tips") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:SY_STRING(@"screeenshot_control_iknow_btn") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [ac addAction:sure];
    
    UIViewController *frontVc = [CMPCommonTool getCurrentShowViewController];
    [frontVc presentViewController:ac animated:YES completion:^{}];
}

///处理图片组件转发事件
- (void)ybImageBrowserForwardNoti:(NSNotification *)noti {
    
}

/// 上传日志
- (void)uploadLog {
    NSString *title = [CMPCommonTool getCurrentShowingVCTitle];
    NSString *log = title;
    
    [self requestToUploadScreenshotLog:log];
}


#pragma mark - 网络请求

/// 上传日志请求
- (void)requestToUploadScreenshotLog:(NSString *)log {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPath:CMPUploadScreenshotLog];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"POST";
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.httpShouldHandleCookies = NO;
    
    NSMutableDictionary *param = NSMutableDictionary.dictionary;
    param[@"actionId"] =  @"5501";
    param[@"message"] = log;
    aDataRequest.requestParam = param.JSONRepresentation;
    
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

/// 请求成功回调
- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider
                      request:(CMPDataRequest *)aRequest
                     response:(CMPDataResponse *)aResponse {
    NSDictionary *strDic = [aResponse.responseStr JSONValue];
    if ([strDic[@"code"] intValue] == 0) {
        NSLog(@"上传截屏日志成功");
    }else {
        NSLog(@"上传截屏日志失败---error: %@",strDic[@"message"]);
    }
}

/// 请求失败回调
- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    NSLog(@"上传截屏日志失败");
    
}

@end
