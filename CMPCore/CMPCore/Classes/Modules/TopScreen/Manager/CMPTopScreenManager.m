//
//  CMPTopScreenManager.m
//  M3
//
//  Created by Shoujian Rao on 2023/12/26.
//

#import "CMPTopScreenManager.h"
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/NSObject+MJKeyValue.h>
#import "CMPAppManagerPlugin.h"
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import "CMPTopScreenDataProvider.h"
@interface CMPTopScreenManager()

@property (nonatomic, strong)CMPTopScreenDB *db;
@property (nonatomic, strong)CMPTopScreenDataProvider *dataProvider;

@end

@implementation CMPTopScreenManager

#pragma mark - 我的二楼【远程数据】

- (CMPAppList_2 *)getAppInfoByPushPageParam:(NSDictionary *)param{
    CMPAppList_2 *appInfo = nil;
    if ([param[@"param"] isKindOfClass:NSDictionary.class]) {
        NSDictionary *p = param[@"param"];
        NSString *bizId = (p[@"portalId"]?:p[@"id"])?:p[@"menuId"];
        appInfo = [self getAppInfoByUniqueId:bizId];//业务id
        if (!appInfo) {
            NSString *url = param[@"url"];
            NSURL *URL = [NSURL URLWithString:url];
            NSString *bundleName = [URL.host componentsSeparatedByString:@"."].firstObject;
            appInfo = [self getAppInfoByType:@"default" bundleName:bundleName];
            if (!appInfo && [bundleName isEqualToString:@"search"]) {//通讯录
                appInfo = [self getAppInfoByType:@"default" bundleName:@"addressbook"];
            }
        }
    }else{//param不是字典的情况
        NSString *url = param[@"url"];
        NSURLComponents *components = [NSURLComponents componentsWithString:url];
        NSString *menuId = @"";//url中取menuId
        for (NSURLQueryItem *item in components.queryItems) {
            if ([item.name.lowercaseString containsString:@"menuid"]) {
                menuId = item.value;
                break;
            }
        }
        if (menuId.length) {
            appInfo = [self getAppInfoByUniqueId:menuId];
        }
    }
    return appInfo;
}

- (void)checkById:(NSString *)iid completion:(void(^)(BOOL exist,NSError *err))completion{
    [self.dataProvider topScreenCheckById:iid completion:^(id respData, NSError * _Nullable error) {
        if ([respData respondsToSelector:@selector(boolValue)]) {
            completion([respData boolValue],error);
        }else{
            completion(NO,error);
        }
    }];
}

- (void)topScreenSaveByParam:(NSDictionary *)param completion:(CompletionBlock)completionBlock{
    [self.dataProvider topScreenSaveByParam:param completion:^(id  _Nonnull respData, NSError * _Nonnull error) {
        if (completionBlock) {
            completionBlock(respData,error);
        }
    }];
}

- (void)topScreenDelById:(NSString *)iid completion:(CompletionBlock)completionBlock{
    [self.dataProvider topScreenDelById:iid completion:^(id  _Nonnull respData, NSError * _Nonnull error) {
        if (completionBlock) {
            completionBlock(respData,error);
        }
    }];
}

- (void)topScreenGetAllCompletion:(CompletionBlock)completionBlock{
    [self.dataProvider topScreenGetAllCompletion:^(id  _Nonnull respData, NSError * _Nonnull error) {
        if (completionBlock) {
            NSMutableArray *tmpArr = [NSMutableArray new];
            if ([respData isKindOfClass:NSArray.class]) {
                for (NSDictionary *dict in respData) {
                    CMPTopScreenModel *model = [CMPTopScreenModel new];
                    model.uniqueId = dict[@"id"];
                    model.appId = dict[@"appId"];
                    model.appName = [dict[@"title"] isKindOfClass:NSString.class]?dict[@"title"]:@"";
                    model.iconUrl = dict[@"icon"];
                    model.goToParam = dict[@"params"];
                    model.isSecondFloor = YES;
                    
                    if ([model.iconUrl isKindOfClass:NSString.class] && !model.iconUrl.length) {
                        CMPAppList_2 *appInfo = [self getAppInfoByPushPageParam:dict[@"params"]];
                        model.iconUrl = appInfo.iconUrl;
                    }
                    
                    model.openType = CMPTopScreenOpenTypePushPage;
                    [tmpArr addObject:model];
                }
            }
            completionBlock(tmpArr,error);
        }
    }];
}


#pragma mark - 常用入口【本地数据】
//loadApp
- (void)loadAppClickByParam:(NSDictionary *)param{
    NSString *from = [param objectForKey:@"from"];
    if ([from isEqualToString:@"navbar"]) {//来自底导航的数据过滤掉
        return;
    }
    
    NSString *appId = [param objectForKey:@"appId"];
    if ([appId isEqualToString:@"59"]) {//全文检索不记录
        return;
    }
    NSString *appType = [param objectForKey:@"appType"];
    NSString *bundle_name = [param objectForKey:@"bundle_name"];
    if ([NSString isNull:bundle_name]) {
        bundle_name = [param objectForKey:@"bundleName"];
    }
    //来自扩展导航
    BOOL fromExpandTab = [[param objectForKey:@"fromExpandTab"] boolValue];
    if (fromExpandTab) {
        if ([appType isEqualToString:@"biz"]) {//业务应用
            NSString *bizMenuId = [param objectForKey:@"bizMenuId"];
            [self saveBizApp:bizMenuId appType:appType param:param openType:(CMPTopScreenOpenTypeLoadApp)];
            return;
        }else if ([appType isEqualToString:@"default"]) {//标准应用
            [self saveDefaultApp:appId appType:appType bundleName:bundle_name param:param openType:(CMPTopScreenOpenTypeLoadApp)];
            return;
        }
    }
    
    if ([appType isEqualToString:@"integration_remote_url"]
        || [appType isEqualToString:@"integration_local_h5"]) {
        //cip应用
        [self saveCipApp:appId appType:appType bundleName:bundle_name param:param openType:(CMPTopScreenOpenTypeLoadApp)];
        return;
    }else if ([appType isEqualToString:@"default"]){
        //标准应用
        [self saveDefaultApp:appId appType:appType bundleName:bundle_name param:param openType:(CMPTopScreenOpenTypeLoadApp)];
        return;
    }
    
}

//pushPage
- (void)pushPageClickByParam:(NSDictionary *)param{
    
    //去掉业务应用会先走downloadApp再走business页面的两次记录
//    NSDictionary *pageParam = param[@"hasRecordPageParam"];
//    if (pageParam
//        && [pageParam[@"param"] isKindOfClass:NSDictionary.class]
//        && [param[@"param"] isKindOfClass:NSDictionary.class]) {
//        NSDictionary *oldParam = pageParam[@"param"];
//        NSDictionary *newParam = param[@"param"];
//        
//        NSString *bizIdOld = (oldParam[@"portalId"]?:oldParam[@"id"])?:oldParam[@"menuId"];
//        NSString *bizIdNew = (newParam[@"portalId"]?:newParam[@"id"])?:newParam[@"menuId"];
//        
//        if ([bizIdOld isKindOfClass:NSString.class]
//            && [bizIdNew isKindOfClass:NSString.class]
//            && [bizIdOld isEqualToString:bizIdNew]) {
//            return;
//        }
//    }
    
    if ([param[@"param"] isKindOfClass:NSDictionary.class]) {
        NSDictionary *p = param[@"param"];
        
        //底导航不记录
        NSString *m3from = p[@"m3from"];
        if ([m3from isEqualToString:@"navbar"]) {
            return;
        }
        
        NSString *bizId = (p[@"portalId"]?:p[@"id"])?:p[@"menuId"];
        if (bizId.length) {
            [self saveBizApp:bizId appType:@"biz" param:param openType:(CMPTopScreenOpenTypePushPage)];
        }else{
            NSString *url = param[@"url"];
            NSURLComponents *components = [NSURLComponents componentsWithString:url];
            NSString *bundleName = [components.host componentsSeparatedByString:@"."].firstObject;
            if ([bundleName isEqualToString:@"search"]) {//通讯录
                bundleName = @"addressbook";
                [self saveDefaultAppByBundleName:bundleName param:param openType:(CMPTopScreenOpenTypePushPage)];
            }else if ([@[@"todo",@"inspect"] containsObject:bundleName]) {
                id fromPage = p[@"fromPage"];
                if ([fromPage isKindOfClass:NSString.class] && [fromPage isEqualToString:@"app"]) {
                    //待办、一键体检
                    [self saveDefaultAppByBundleName:bundleName param:param openType:(CMPTopScreenOpenTypePushPage)];
                }
            }
        }
        
    }else{//param不是字典的情况
        NSString *url = param[@"url"];
        NSURLComponents *components = [NSURLComponents componentsWithString:url];
        NSString *menuId = @"";//url中取menuId
        for (NSURLQueryItem *item in components.queryItems) {
            if ([item.name.lowercaseString containsString:@"menuid"]) {
                menuId = item.value;
                break;
            }
        }
        if (menuId.length) {
            [self saveBizApp:menuId appType:@"biz" param:param openType:(CMPTopScreenOpenTypePushPage)];
        }else{
            NSString *bundleName = [components.host componentsSeparatedByString:@"."].firstObject;
            if ([bundleName isEqualToString:@"search"]) {//通讯录
                bundleName = @"addressbook";
                [self saveDefaultAppByBundleName:bundleName param:param openType:(CMPTopScreenOpenTypePushPage)];
            }else if ([@[@"todo",@"inspect"] containsObject:bundleName]) {
                //待办、一键体检
                [self saveDefaultAppByBundleName:bundleName param:param openType:(CMPTopScreenOpenTypePushPage)];
            }
        }
        
    }
}

//标准应用
- (void)saveDefaultApp:(NSString *)appId appType:(NSString *)appType bundleName:(NSString *)bundleName param:(NSDictionary *)param openType:(CMPTopScreenOpenType)openType{
    if ([appType isEqualToString:@"default"]) {
        CMPAppList_2 *appInfo = [self getAppInfoByType:appType bundleName:bundleName appId:appId];
        if (appInfo) {
            NSString *uniqueId = [NSString stringWithFormat:@"%@_%@_%@_%@_%@",kCMP_ServerID,CMP_USERID,appInfo.localAppId,bundleName,appType];
            BOOL success = [self saveDataWithAppInfo:appInfo uniqueId:uniqueId openType:openType goToParam:param];
            NSLog(@"saveDefaultApp:success=%d",success);
        }
    }
}

- (void)saveDefaultAppByBundleName:(NSString *)bundleName param:(NSDictionary *)param openType:(CMPTopScreenOpenType)openType{
    NSString *appType = @"default";
    CMPAppList_2 *appInfo = [self getAppInfoByType:appType bundleName:bundleName];
    if (appInfo) {
        NSString *uniqueId = [NSString stringWithFormat:@"%@_%@_%@_%@_%@",kCMP_ServerID,CMP_USERID,appInfo.appId,bundleName,appType];
        BOOL success = [self saveDataWithAppInfo:appInfo uniqueId:uniqueId openType:openType goToParam:param];
        NSLog(@"saveDefaultAppByBundleName:success=%d",success);
    }
}

//cip应用，现loadApp再pushPage  【appId唯一，必须loadApp打开】
- (void)saveCipApp:(NSString *)appId appType:(NSString *)appType bundleName:(NSString *)bundleName param:(NSDictionary *)param openType:(CMPTopScreenOpenType)openType{
    if ([appType isEqualToString:@"integration_remote_url"]
        || [appType isEqualToString:@"integration_local_h5"]) {
        CMPAppList_2 *appInfo = [self getAppInfoByAppId:appId];
        if (appInfo) {
            NSString *uniqueId = [NSString stringWithFormat:@"%@_%@_%@_%@_%@",kCMP_ServerID,CMP_USERID,appInfo.appId,appInfo.bundleName,appInfo.appType];
            BOOL success = [self saveDataWithAppInfo:appInfo uniqueId:uniqueId openType:openType goToParam:param];
            NSLog(@"saveCipApp:success=%d",success);
        }
    }
}

//业务应用 - 先downloadApp页面->business页面 【必须从downloadApp页面打开】
- (void)saveBizApp:(NSString *)bizId appType:(NSString *)appType param:(NSDictionary *)param openType:(CMPTopScreenOpenType)openType{
    if ([appType isEqualToString:@"biz"]) {
        CMPAppList_2 *appInfo = [self getAppInfoByUniqueId:bizId];//业务id
        if (appInfo) {
            NSString *uniqueId = [NSString stringWithFormat:@"%@_%@_%@",kCMP_ServerID,CMP_USERID,bizId];
            BOOL success = [self saveDataWithAppInfo:appInfo uniqueId:uniqueId openType:openType goToParam:param];
            NSLog(@"saveBizApp:success=%d",success);
        }
    }
}

//保存插件调用的数据
- (void)savePulginWithId:(NSString *)iid appName:(NSString *)appName iconUrl:(NSString *)iconUrl param:(NSDictionary *)param openType:(CMPTopScreenOpenType)openType{
    
    NSString *uniqueId = [NSString stringWithFormat:@"%@_%@_%@",kCMP_ServerID,CMP_USERID,iid];
    CMPTopScreenModel *model = [CMPTopScreenModel new];
    model.appId = iid;
    model.appType = @"plugin";
    model.openType = openType;
    model.uniqueId = uniqueId;//唯一id
    model.appName = appName;
    model.iconUrl = iconUrl;
    model.goToParam = [param mj_JSONString];
    model.serverVersion = [CMPCore sharedInstance].serverVersion;
    
    BOOL success = [self.db addAppClick:model];
    if (success) {
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationTopScreenRefreshData_Common object:nil];
    }
}


//保存appinfo到数据库
- (BOOL)saveDataWithAppInfo:(CMPAppList_2 *)appInfo uniqueId:(NSString *)uniqueId openType:(CMPTopScreenOpenType)openType goToParam:(NSDictionary *)goToParam{
    if (!appInfo) {
        return NO;
    }
    CMPTopScreenModel *model = [CMPTopScreenModel new];
    model.appId = appInfo.appId;
    model.appType = appInfo.appType;
    model.bundleName = appInfo.bundleName;
    model.openType = openType;
    model.uniqueId = uniqueId;//唯一id
    model.appName = appInfo.appName;
    model.iconUrl = appInfo.iconUrl;
    model.goToParam = [goToParam mj_JSONString];
    
    BOOL success = [self.db addAppClick:model];
    if (success) {
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationTopScreenRefreshData_Common object:nil];
    }
    
    return success;
}

//获取本地常用
- (NSArray *)getTopData{
    NSArray *arr = [self.db getTopAppClickCount:6];
    return arr;
}
//删除所有本地常用
- (BOOL)delAllTopData{
    return [self.db delAllTopApp];
}

//点击常用app跳转
- (void)jumpPage:(CMPTopScreenModel *)model fromVC:(UIViewController *)fromVC{
    if (model.openType == CMPTopScreenOpenTypeLoadApp) {
        CMPAppManagerPlugin *plugin = [CMPAppManagerPlugin new];
        plugin.viewController = fromVC;
        NSDictionary *gotoParam = [model.goToParam mj_JSONObject];
        [self loadAppClickByParam:gotoParam];//点击需要再次记录        
        [plugin loadAppAction:gotoParam];
    }else if (model.openType == CMPTopScreenOpenTypePushPage) {
        // 如果新开webview，不需要入当前page堆栈
        NSDictionary *aParam = [model.goToParam mj_JSONObject];
        
        [self pushPageClickByParam:aParam];//点击需要再次记录
        
        CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
        aCMPBannerViewController.pageParam = aParam;
        
        // 存储当前的
        NSString *href = [aParam objectForKey:@"url"];
        href = [href urlCFEncoded];
        NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:href]];
        if ([NSString isNotNull:localHref]) {
            href = localHref;
        }
        
        BOOL useNativebanner = [[[aParam objectForKey:@"options"] objectForKey:@"useNativebanner"] boolValue];
        aCMPBannerViewController.hideBannerNavBar = !useNativebanner;
        
        if ([NSString isNotNull:localHref]) {
            aCMPBannerViewController.allowRotation = ((CMPBannerWebViewController *)fromVC.navigationController.topViewController).allowRotation;
        }else {
            aCMPBannerViewController.closeButtonHidden = NO;
        }
        aCMPBannerViewController.startPage = href;
        
        [fromVC.navigationController pushViewController:aCMPBannerViewController animated:YES];
        
    }
}


#pragma mark - getter
- (CMPTopScreenDB *)db{
    if (!_db) {
        _db = [CMPTopScreenDB new];
    }
    return _db;
}

- (CMPTopScreenDataProvider *)dataProvider{
    if (!_dataProvider) {
        _dataProvider = [CMPTopScreenDataProvider new];
    }
    return _dataProvider;
}

#pragma mark - 获取AppInfo
- (CMPAppList_2 *)getAppInfoByType:(NSString *)appType bundleName:(NSString *)bundleName appId:(NSString *)appId{
    NSString *appList = [CMPCore sharedInstance].currentUser.appList;
    CMPAppListModel_2 *appListModel = [CMPAppListModel_2 yy_modelWithJSON:appList];
    CMPAppList_2 *appInfo = [appListModel appInfoWithType:appType bundleName:bundleName appId:appId];
    return appInfo;
}

- (CMPAppList_2 *)getAppInfoByUniqueId:(NSString *)uniqueId{
    NSString *appList = [CMPCore sharedInstance].currentUser.appList;
    CMPAppListModel_2 *appListModel = [CMPAppListModel_2 yy_modelWithJSON:appList];
    CMPAppList_2 *appInfo = [appListModel appInfoWithBizId:uniqueId];
    return appInfo;
}

- (CMPAppList_2 *)getAppInfoByType:(NSString *)appType bundleName:(NSString *)bundleName{
    NSString *appList = [CMPCore sharedInstance].currentUser.appList;
    CMPAppListModel_2 *appListModel = [CMPAppListModel_2 yy_modelWithJSON:appList];
    CMPAppList_2 *appInfo = [appListModel appInfoWithType:appType bundleName:bundleName];
    return appInfo;
}

- (CMPAppList_2 *)getAppInfoByAppId:(NSString *)appId{
    NSString *appList = [CMPCore sharedInstance].currentUser.appList;
    CMPAppListModel_2 *appListModel = [CMPAppListModel_2 yy_modelWithJSON:appList];
    CMPAppList_2 *appInfo = [appListModel appInfoWithAppId:appId];
    return appInfo;
}
@end
