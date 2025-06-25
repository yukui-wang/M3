//
//  CMPBackgroundRequestsManager.m
//  CMPCore
//
//  Created by youlin on 2017/1/14.
//
//

#import "CMPBackgroundRequestsManager.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataResponse.h>
#import <CMPLib/SvUDIDTools.h>
#import "CMPCommonManager.h"
#import <CMPLib/JSONKit.h>
#import "CMPConstant_Ext.h"
#import "AppDelegate.h"
#import <CMPLib/CMPFileManager.h>
#import "M3LoginManager.h"
#import <CMPVpn/CMPVpn.h>

@interface CMPBackgroundRequestsManager ()<CMPDataProviderDelegate> {
    
}

@property (nonatomic, copy)NSString *registerRemoteNotiID;
@property (nonatomic, copy)NSString *requestCustomStartPageID;
@property (nonatomic, copy)NSString *downloadStartPageBGID; // 下载启动页背景图片ID
@property (nonatomic, copy)NSString *downloadStartPageLogoID; // 下载启动页logo图片ID
@property (nonatomic, copy)NSString *downloadStartPageLandscapeBGID;// 下载启动页横屏背景图片ID
@property (nonatomic, copy)NSString *downloadPadEmptyImageID; // 下载空白页图片ID
@property (nonatomic, copy)CMPRequestBgImageUtil *requestBgImageUtil;

@end

@implementation CMPBackgroundRequestsManager

- (void)dealloc
{
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
    [_registerRemoteNotiID release];
    _registerRemoteNotiID = nil;
    
    [_requestCustomStartPageID release];
    _requestCustomStartPageID = nil;
    
    [_downloadStartPageBGID release];
    _downloadStartPageBGID = nil;
    
    [_downloadStartPageLogoID release];
    _downloadStartPageLogoID = nil;
    
    [_requestBgImageUtil release];
    _requestBgImageUtil = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

+ (CMPBackgroundRequestsManager *)sharedManager
{
    static CMPBackgroundRequestsManager *_instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        // kNotificationName_DidRegisterNotifiDeviceToken
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerRemoteNotificationAction) name:kNotificationName_DidRegisterNotifiDeviceToken object:nil];
        // 监听切换后台、前台事件
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidResignActive:)
                                                     name:UIApplicationWillResignActiveNotification object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

- (void)onAppWillEnterForeground:(NSNotification*)notification
{

}

// This method is called to let your application know that it moved from the inactive to active state.
- (void)onAppDidBecomeActive:(NSNotification*)notification
{
    if ([CMPCore isLoginState]) {
        [self requestAppWakeup];
    }
}

- (void)onAppDidResignActive:(NSNotification*)notification
{
    if ([CMPCore isLoginState]) {
        [self requestAppHide];
    }
}

- (void)onAppDidEnterBackground:(NSNotification*)notification
{
    // NSLog(@"%@",@"applicationDidEnterBackground");
    // pause
//    if ([CMPCore isLoginState]) {
//        [self requestAppHide];
//    }
}

// App 进入后台
- (void)requestAppHide
{
    NSString *aUserId = [CMPCore sharedInstance].userID;
    if (!aUserId) {
        aUserId = @"";
    }
    NSDictionary *aParam = [NSDictionary dictionaryWithObjectsAndKeys:aUserId, @"statisticId",([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? @(2) : @(1)),@"clientType", nil];
    NSString *aUrl = [CMPCore fullUrlForPath:kM3AppStatisticsHideUrl];
    // 构建请求参数 结束
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = aUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"POST";
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestParam = [aParam JSONRepresentation];
    aDataRequest.requestType = kDataRequestType_Url;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [aDataRequest release];
}

// App 进入前台
- (void)requestAppWakeup
{
    NSString *serverID = [CMPCore sharedInstance].serverID;
    CMPServerVpnModel *vpnModel = [CMPVpnManager getVpnModelByServerID:serverID];
    if (vpnModel.vpnUrl && ![CMPVpnManager isVpnConnected]) {
        __weak typeof(self) wSelf = self;
        
        [[CMPVpnManager sharedInstance] loginVpnWithConfig:vpnModel process:^(id obj, id ext) {
                        
                    } success:^(id obj, id ext) {
                        [wSelf requestWakeUpApi];
                    } fail:^(id obj, id ext) {
                        //退出到登录页面
                        NSString *errStr = @"VPN错误";
                       if ([obj isKindOfClass:NSString.class]) {
                           errStr = obj;
                       }
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [[M3LoginManager sharedInstance] logout];
                           [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:errStr];
                       });
                    }];
    }else{
        //435版本这个接口漏调了
        [self requestWakeUpApi];
    }
}

- (void)requestWakeUpApi{
    NSString *aUserId = [CMPCore sharedInstance].userID;
    if (!aUserId) {
        aUserId = @"";
    }
    NSDictionary *aParam = [NSDictionary dictionaryWithObjectsAndKeys:aUserId, @"statisticId", @"iphone", @"client", ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? @(2) : @(1)),@"clientType", nil];
    NSString *aUrl = [CMPCore fullUrlForPath:kM3AppStatisticsWakeUpUrl];
    // 构建请求参数 结束
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = aUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"POST";
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestParam = [aParam JSONRepresentation];
    aDataRequest.requestType = kDataRequestType_Url;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [aDataRequest release];
}

- (void)registerRemoteNotificationAction
{
    if (![NSString isNull:[CMPCore sharedInstance].jsessionId]) {
        // 1、开始注册离线消息推送
        [[CMPBackgroundRequestsManager sharedManager] registerRemoteNotification];
    }
}

// 注册远程消息推送
- (void)registerRemoteNotification {
    NSString *userId = [CMPCore sharedInstance].userID;
    NSDictionary *registInfo = [CMPCore sharedInstance].baiduRemoteNotifiInfo;
    NSString *aTokenId = [registInfo objectForKey:@"channel_id"];
    NSString *token = [CMPCore sharedInstance].remoteNotifiToken;
    if ([NSString isNull:aTokenId] ||
        [NSString isNull:userId] ||
        [NSString isNull:token]) {
        return;
    }
    
    NSString *aUrl = [CMPCore fullUrlPathMapForPath:@"/api/pns/device/register"];
    // 构建请求参数 开始
    NSMutableDictionary *aParam = [[[NSMutableDictionary alloc] init] autorelease];
    // set registerPlatform
    NSArray *platforms = [NSArray arrayWithObjects:@"baidu", @"apple", nil];
    [aParam setObject:platforms forKey:@"registerPlatform"];
    NSDictionary *value = [NSDictionary dictionaryWithObjectsAndKeys:aTokenId, @"baidu", token, @"apple", nil];
    [aParam setObject:value forKey:@"registerNumber"];
    [aParam setObject:[SvUDIDTools UDID] forKey:@"deviceId"];
    // set userId
    [aParam setObject:userId forKey:@"userId"];
    // deviceType
    NSString *clientProtocolType = [CMPCommonManager pushMsgClientProtocolType];
    [aParam setObject:clientProtocolType forKey:@"deviceType"];
    [aParam setObject:clientProtocolType forKey:@"deviceFirm"];
    [aParam setObject:([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? @(2) : @(1)) forKey:@"clientType"];

    // 构建请求参数 结束
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = aUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"POST";
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestParam = [aParam JSONRepresentation];
    aDataRequest.requestType = kDataRequestType_Url;
    self.registerRemoteNotiID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [aDataRequest release];
}

// 请求启动页
- (void)requestCustomStartPage
{
    NSString *aUrl = [CMPCore fullUrlForPath:kM3CustomStartPageUrl];
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

// 检查启动页信息
- (void)checkStartPageInfo:(NSDictionary *)aStartPageDict
{
    if (!aStartPageDict || (aStartPageDict && [[aStartPageDict objectForKey:@"deft"] boolValue])){
        return;
    }
    id cus = [[CMPCore sharedInstance].customStartPageSetting objectFromJSONString];
    //创建启动页文件夹
    [CMPCommonManager createStartPageDirPath];
    
    NSDictionary * moreBackgroundImage = aStartPageDict[@"moreBackgroundImage"];
    if (moreBackgroundImage && [moreBackgroundImage isKindOfClass:[NSDictionary class]]) {
        NSDictionary * oldMoreBackgroundImage = cus[@"moreBackgroundImage"];
        NSArray *newbgImages = [self imageUrlsWithmoreBackgroundImageDic:moreBackgroundImage];
        NSArray *oldbgImages = [self imageUrlsWithmoreBackgroundImageDic:oldMoreBackgroundImage];
        if (![newbgImages count]) {
            return;
        }
        
        NSString *oldPortraitUrl = [oldbgImages count] ? [NSString stringWithFormat:@"%@%@",[CMPCore sharedInstance].serverurl,oldbgImages[0]] : @"";
        NSString *oldLandscapeUrl = [oldbgImages count] ? [NSString stringWithFormat:@"%@%@",[CMPCore sharedInstance].serverurl,oldbgImages[1]] :@"";
        
        NSString *newPortraitUrl = [NSString stringWithFormat:@"%@%@",[CMPCore sharedInstance].serverurl,newbgImages[0]?:@""];
        NSString *newLandscapeUrl = [NSString stringWithFormat:@"%@%@",[CMPCore sharedInstance].serverurl,newbgImages[1]?:@""];
        
        NSString *portraiImagePath = [CMPCommonManager getStartPageBackgroundPath];
        NSString *landscapeImagePath = [CMPCommonManager getStartPageLandBackgroundPath];
        //是否下载了
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isPortraiImageExists =  [fileManager fileExistsAtPath:portraiImagePath];
        BOOL isLandscapeImageExists =  [fileManager fileExistsAtPath:landscapeImagePath];
        
        if (!isPortraiImageExists || ![oldPortraitUrl isEqualToString:newPortraitUrl]) {
            [self downloadStartPageBGImageWithUrl:newPortraitUrl];
        }
        
        if (!isLandscapeImageExists || ![oldLandscapeUrl isEqualToString:newLandscapeUrl]) {
            [self downloadStartPageLandscapeBGImageWithUrl:newLandscapeUrl];
        }
        
    } else {
        
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
            NSString *path = [CMPCommonManager getStartPageBackgroundPath];
            //是否下载了
            NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL exists =  [fileManager fileExistsAtPath:path];
            
            if (![oldUrl isEqualToString:newUrl] || !exists) {
                [self downloadStartPageBGImageWithUrl:newUrl];
            }
        }
    }
}

- (NSArray *)imageUrlsWithmoreBackgroundImageDic:(NSDictionary *)moreBackgroundImage {
    NSMutableArray *result = [NSMutableArray array];
    if (!moreBackgroundImage) {
        return result;
    }
    
    NSDictionary *bgImageDic = nil;
    if (INTERFACE_IS_PAD) {
        bgImageDic = moreBackgroundImage[@"pad"];
    } else if (INTERFACE_IS_PHONE) {
        bgImageDic = moreBackgroundImage[@"phone"];
    }
    
    if ([bgImageDic count]) {
        NSMutableDictionary *portraitCompareResultDic = [NSMutableDictionary dictionary];
        NSMutableDictionary *landscapeCompareResultDic = [NSMutableDictionary dictionary];
        CGFloat screenWidth = [UIScreen mainScreen].nativeBounds.size.width;
        CGFloat screenheight = [UIScreen mainScreen].nativeBounds.size.height;
        CGFloat portraitScale = screenWidth/screenheight;
        CGFloat landscapeScale = screenheight/screenWidth;
        
        [bgImageDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([key isKindOfClass:NSString.class] && [key containsString:@"*"]) {
                NSArray *sizeArr = [key componentsSeparatedByString:@"*"];
                CGFloat width = [sizeArr[0] doubleValue];
                CGFloat heght = [sizeArr[1] doubleValue];
                CGFloat scale = width/heght;
                CGFloat portraitCompare = fabs(scale - portraitScale);
                CGFloat landscapeCompare = fabs(scale - landscapeScale);
                [portraitCompareResultDic setObject:obj forKey:[NSNumber numberWithDouble:portraitCompare]];
                [landscapeCompareResultDic setObject:obj forKey:[NSNumber numberWithDouble:landscapeCompare]];
            }
        }];
        
        NSArray *portraitCompareResultArr = [portraitCompareResultDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        
        NSArray *landscapeCompareResultArr = [landscapeCompareResultDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        
        NSString *portraitUrl = portraitCompareResultDic[portraitCompareResultArr.firstObject];
        NSString *landscapeUrl = landscapeCompareResultDic[landscapeCompareResultArr.firstObject];
        [result addObject:portraitUrl];
        [result addObject:landscapeUrl];
    }
    return [[result copy] autorelease];
}


// 下载启动页背景图片
- (void)downloadStartPageBGImageWithUrl:(NSString *)url
{
    NSString *path = [CMPCommonManager getStartPageBackgroundPath];
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

// 下载启动页横屏背景图片
- (void)downloadStartPageLandscapeBGImageWithUrl:(NSString *)url
{
    NSString *path = [CMPCommonManager getStartPageLandBackgroundPath];
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
    self.downloadStartPageLandscapeBGID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [aDataRequest release];
    
}

// 下载启动页logo图片
- (void)downloadStartPageLogoImageWithUrl:(NSString *)url
{
    NSString *path = [CMPCommonManager getStartPageLogoPath];
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
    self.downloadStartPageLogoID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [aDataRequest release];
}

- (NSString *)padEmptyImagePath {
    NSString *accountID = [CMPCore sharedInstance].currentUser.accountID;
    NSString *documentPath = [NSString stringWithFormat:@"Documents/padEmptyImage/%@",accountID];
    documentPath = [CMPFileManager createFullPath:documentPath];
    //默认是2倍图片
    NSString *path = [documentPath stringByAppendingPathComponent:@"pad_empty_img@2x.png"];
    return path;
}

//检查iPad空白页图片
- (void)checkPadEmptyImageInfo:(NSDictionary *)aStartPageDict {
    if (INTERFACE_IS_PHONE || !aStartPageDict) {
        return;
    }
    id cus = [[CMPCore sharedInstance].customStartPageSetting objectFromJSONString];
    NSString *emptyImageUrl = aStartPageDict[@"padEmptyImage"];
    NSString *emptyImagePath = [self padEmptyImagePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([NSString isNull:emptyImageUrl]) {
        //路径为空，不下载,使用默认的图片
        if ([fileManager fileExistsAtPath:emptyImagePath]) {
            [fileManager removeItemAtPath:emptyImagePath error:nil];
        }
        return;
    }
    NSString *oldEmptyImageUrl = cus[@"padEmptyImage"];
    if ([emptyImageUrl isEqualToString:oldEmptyImageUrl] &&
        [fileManager fileExistsAtPath:emptyImagePath]) {
        //路径和之前的一样，并且已经下载了
        return;
    }
    //要重新下载，把之前的删除掉
    if ([fileManager fileExistsAtPath:emptyImagePath]) {
        [fileManager removeItemAtPath:emptyImagePath error:nil];
    }
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",[CMPCore sharedInstance].serverurl,emptyImageUrl];
    //下载空白页图片
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"Get";
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_FileDownload;
    aDataRequest.downloadDestinationPath = emptyImagePath;
    self.downloadPadEmptyImageID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [aDataRequest release];
}

- (CMPRequestBgImageUtil *)requestBgImageUtil
{
    if (!_requestBgImageUtil) {
         _requestBgImageUtil = [[CMPRequestBgImageUtil alloc] init];
     }
    return _requestBgImageUtil;
}

#pragma -mark CMPDataProviderDelegate
- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse
{
    if ([aRequest.requestID isEqualToString:self.registerRemoteNotiID]) {
        // todo
        self.registerRemoteNotiID = nil;
    }
    else if ([aRequest.requestID isEqualToString:self.requestCustomStartPageID]) {
        NSDictionary *aStartPageDict = [aResponse.responseStr JSONValue];
        [self checkStartPageInfo:aStartPageDict];
        [self checkPadEmptyImageInfo:aStartPageDict];
        [CMPCore sharedInstance].customStartPageSetting = aResponse.responseStr;
        self.requestCustomStartPageID = nil;
    }
    else if ([aRequest.requestID isEqualToString:self.downloadStartPageBGID]) {
        // 缓存背景图片路径
        self.downloadStartPageBGID = nil;
    }
    else if ([aRequest.requestID isEqualToString:self.downloadStartPageLandscapeBGID]) {
        // 缓存横屏背景图片路径
        self.downloadStartPageLandscapeBGID = nil;
    }
    else if ([aRequest.requestID isEqualToString:self.downloadStartPageLogoID]) {
        // 缓存logo图片路径
        self.downloadStartPageLogoID = nil;
    }
    else if ([aRequest.requestID isEqualToString:self.downloadPadEmptyImageID]) {
        //空白页图片下载
        self.downloadPadEmptyImageID = nil;
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
    if ([aRequest.requestID isEqualToString:self.registerRemoteNotiID]) {
        AppDelegate *delegate = [AppDelegate shareAppDelegate];
        [delegate handleError:error];
    }
    else if ([aRequest.requestID isEqualToString:self.requestCustomStartPageID]) {
    }
    else if ([aRequest.requestID isEqualToString:self.downloadStartPageBGID]) {
        // 缓存背景图片路径
        self.downloadStartPageBGID = nil;
        NSString *path = [CMPCommonManager getStartPageBackgroundPath];
        //删除掉
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path]) {
            [fileManager removeItemAtPath:path error:nil];
        }
    }
    else if ([aRequest.requestID isEqualToString:self.downloadStartPageLandscapeBGID]) {
        // 缓存背景图片路径
        self.downloadStartPageLandscapeBGID = nil;
        NSString *path = [CMPCommonManager getStartPageLandBackgroundPath];
        //删除掉
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path]) {
            [fileManager removeItemAtPath:path error:nil];
        }
    }
    else if ([aRequest.requestID isEqualToString:self.downloadStartPageLogoID]) {
        // 缓存logo图片路径
        self.downloadStartPageLogoID = nil;
    }
    else if ([aRequest.requestID isEqualToString:self.downloadPadEmptyImageID]) {
        //空白页图片下载
        self.downloadPadEmptyImageID = nil;
        NSString *path = [self padEmptyImagePath];
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
