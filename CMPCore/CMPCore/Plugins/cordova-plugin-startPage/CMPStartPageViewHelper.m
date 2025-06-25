//
//  CMPStartPageHelper.m
//  M3
//
//  Created by youlin on 2017/11/21.
//

#import "CMPStartPageViewHelper.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/JSONKit.h>
#import "AppDelegate.h"
#import "CMPStartPageView.h"

#define kRequestStartPageUrl @"/rest/m3/startPage/getCustom/iphone"

@interface CMPStartPageViewHelper()<CMPDataProviderDelegate>
{
}

@property (nonatomic, assign)CMPStartPageView *startPageView;
@property (nonatomic, copy)NSString *requestCustomStartPageID;
@property (nonatomic, copy)NSString *downloadStartPageBGID; // 下载启动页背景图片ID

@end

@implementation CMPStartPageViewHelper

- (void)dealloc
{
    [_startPageView removeFromSuperview];
    SY_RELEASE_SAFELY(_startPageView);
    
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
    
    [_requestCustomStartPageID release];
    _requestCustomStartPageID = nil;
    
    [_downloadStartPageBGID release];
    _downloadStartPageBGID = nil;
    
    [super dealloc];
}

+ (BOOL)needShowStartPageView
{
    return YES;
}

// 是否是默认启动页,只有当设置了服务器地址后
- (BOOL)isDefaultStartPage
{
    return YES;
}

// 显示启动页
- (void)showStartPageView
{
    AppDelegate *aAppDelegate = [AppDelegate shareAppDelegate];
//    [aAppDelegate.startPageView removeFromSuperview];
    [_startPageView release];
    _startPageView = [[CMPStartPageView alloc] init];
    _startPageView.hidden = NO;
    [aAppDelegate.window makeKeyAndVisible];
    [aAppDelegate.window.rootViewController.view addSubview:_startPageView];
    [aAppDelegate.window.rootViewController.view bringSubviewToFront:_startPageView];
}

- (void)bringToFront
{
    if (_startPageView) {
        AppDelegate *aAppDelegate = [AppDelegate shareAppDelegate];
        [aAppDelegate.window.rootViewController.view bringSubviewToFront:self.startPageView];
    }
}

// 隐藏启动页
- (void)hideStartPageView
{
    [UIView animateWithDuration:0.3 animations:^{
        _startPageView.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [_startPageView removeFromSuperview];
            SY_RELEASE_SAFELY(_startPageView);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationName_startViewDidClosed" object:nil];
    }];
}

// 请求启动页
- (void)requestCustomStartPage
{
    NSString *aUrl = [CMPCore fullUrlForPath:kRequestStartPageUrl];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = aUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"GET";
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    self.requestCustomStartPageID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [aDataRequest release];
}

- (NSString *)currentAccountStartPagePath
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *startPageDirPath = [documentPath stringByAppendingPathComponent:@"StartPageFile"];
    NSString *accountStartPageDirPath = [startPageDirPath stringByAppendingPathComponent:[CMPCore sharedInstance].currentUser.accountID];
    NSString *path = [accountStartPageDirPath stringByAppendingPathComponent:@"startPage.png"];
    return path;
}

// 创建启动页目录
- (void)createStartPageDirPath
{
    NSString *path = [self currentAccountStartPagePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

// 解析启动页信息
- (void)handleStartPageInfo:(NSDictionary *)aStartPageDict
{
    if (!aStartPageDict || (aStartPageDict && [[aStartPageDict objectForKey:@"deft"] boolValue])){
        return;
    }
    id cus = [[CMPCore sharedInstance].customStartPageSetting objectFromJSONString];
    //创建启动页文件夹
    [self createStartPageDirPath];
    
    // 1、背景图片：判断本地存在的backgroundImage地址是否与cus里面的一致，如果不一致就需要下载
    NSDictionary *oldBackground = [[cus objectForKey:@"backgroundImage"] JSONValue];
    NSDictionary *newBackground = [[aStartPageDict objectForKey:@"backgroundImage"] JSONValue];
    
    NSString *oldfileId = [oldBackground objectForKey:@"fileId"];
    NSString *oldcreateDate = [oldBackground objectForKey:@"createDate"];
    NSString *newfileId = [newBackground objectForKey:@"fileId"];
    NSString *newcreateDate = [newBackground objectForKey:@"createDate"];
    
    if (![NSString isNull:newfileId]) {
        if ([NSString isNull:oldcreateDate]) {
            oldcreateDate = @"";
        }
        if ([NSString isNull:newcreateDate]) {
            newcreateDate = @"";
        }
        if ([NSString isNull:oldfileId]) {
            oldfileId = @"";
        }
        NSString *oldUrl = [CMPCore fullUrlPathMapForPath:@"/seeyon/fileUpload.do"];
        oldUrl = [oldUrl appendHtmlUrlParam:@"method" value:@"showRTE"];
        oldUrl = [oldUrl appendHtmlUrlParam:@"fileId" value:oldfileId];
        oldUrl = [oldUrl appendHtmlUrlParam:@"createDate" value:oldcreateDate];
        oldUrl = [oldUrl appendHtmlUrlParam:@"type" value:@"image"];
        NSString *newUrl = [CMPCore fullUrlPathMapForPath:@"/seeyon/fileUpload.do"];
        newUrl = [newUrl appendHtmlUrlParam:@"method" value:@"showRTE"];
        newUrl = [newUrl appendHtmlUrlParam:@"fileId" value:newfileId];
        newUrl = [newUrl appendHtmlUrlParam:@"createDate" value:newcreateDate];
        newUrl = [newUrl appendHtmlUrlParam:@"type" value:@"image"];
        NSString *path = [self currentAccountStartPagePath];
        //是否下载了
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL exists =  [fileManager fileExistsAtPath:path];
        
        if (![oldUrl isEqualToString:newUrl] || !exists) {
            [self downloadStartPageBGImageWithUrl:newUrl];
        }
    }
}

// 下载启动页背景图片
- (void)downloadStartPageBGImageWithUrl:(NSString *)url
{
    NSString *path = [self currentAccountStartPagePath];
    //要重新下载，把之前的删除掉
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:nil];
    }
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"Get";
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_FileDownload;
    aDataRequest.downloadDestinationPath = path;
    self.downloadStartPageBGID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [aDataRequest release];
    
}

#pragma -mark CMPDataProviderDelegate
- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse
{
    if ([aRequest.requestID isEqualToString:self.requestCustomStartPageID]) {
        NSDictionary *aStartPageDict = [aResponse.responseStr JSONValue];
        [self handleStartPageInfo:aStartPageDict];
        [CMPCore sharedInstance].customStartPageSetting = aResponse.responseStr;
        self.requestCustomStartPageID = nil;
    }
    else if ([aRequest.requestID isEqualToString:self.downloadStartPageBGID]) {
        // 缓存背景图片路径
        self.downloadStartPageBGID = nil;
    }
    [[CMPDataProvider sharedInstance] cancelWithRequestId:aRequest.requestID];
}

/**
 * 2. 当请求数据出现错误时调用
 *
 * aProvider: 数据访问类
 * anError: 错误信息
 * aRequest: 请求对象
 */
- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error
{
    if ([aRequest.requestID isEqualToString:self.requestCustomStartPageID]) {
    }
    else if ([aRequest.requestID isEqualToString:self.downloadStartPageBGID]) {
        // 缓存背景图片路径
        self.downloadStartPageBGID = nil;
        NSString *path = [self currentAccountStartPagePath];
        //删除掉
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path]) {
            [fileManager removeItemAtPath:path error:nil];
        }
    }
    [[CMPDataProvider sharedInstance] cancelWithRequestId:aRequest.requestID];
}

/**
 * 3. 开始请求时调用
 *
 * aProvider: 数据访问类
 * aRequest: 请求对象
 */
- (void)providerDidStartLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest
{
    
}

@end
