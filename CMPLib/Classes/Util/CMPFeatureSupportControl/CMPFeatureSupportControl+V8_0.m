//
//  CMPFeatureSupportControl+V8_0.m
//  CMPLib
//
//  Created by 程昆 on 2020/3/4.
//  Copyright © 2020 crmo. All rights reserved.
//

#import "CMPFeatureSupportControl+V8_0.h"
#import <CMPLib/CMPCore.h>
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/CMPServerVersionUtils.h>
#import <CMPLib/CMPAppListModel.h>
#import "CMPFeatureSupportControl+V8_2.h"

@implementation CMPFeatureSupportControl (V8_0)

#pragma mark - 版本兼容控制

+ (BOOL)isUrlPathContainsMobilePortal:(NSString *)version {
    if ([CMPServerVersionUtils serverIsLaterV8_0WithServerVersion:version]) {
        return NO;
    }
    return YES;
}

+ (BOOL)isUrlPathUseNewPath:(NSString *)version {
    if ([CMPServerVersionUtils serverIsLaterV8_0WithServerVersion:version]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isChatViewLongTouchMenuContainsMultiSelect {
    if ([CMPServerVersionUtils serverIsLaterV8_0]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isChatViewSupportGroupKanban {
    if ([CMPServerVersionUtils serverIsLaterV8_0]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isChatViewPluginBoardSupportLightCollItems {
    if ([CMPServerVersionUtils serverIsLaterV8_0]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isChatViewUseMyFilesOpenOfflineFiles {
    if ([CMPServerVersionUtils serverIsLaterV8_0]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isChatViewCheckQuickNewEntryPrivilege {
    if ([CMPServerVersionUtils serverIsLaterV8_0]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isOfflineDownloadRequestParamAppendByPath {
    if ([CMPServerVersionUtils serverIsLaterV8_0]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isMessagListLeadershipIconEtcUseSeverImage {
    if ([CMPServerVersionUtils serverIsLaterV8_0]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isTapAppMessageUnreadCountResetZero {
    if ([CMPServerVersionUtils serverIsLaterV8_0]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isNeedHandleSessionInvalidWithErrorCode:(NSInteger )errorCode serverErrorCode:(NSInteger) serverErrorCode {
    CMPLoginAccountModelLoginType loginType = [CMPCore sharedInstance].currentUser.loginType;
    if (loginType == CMPLoginAccountModelLoginTypeMokey) {
        return NO;
    }
    if ([CMPServerVersionUtils serverIsLaterV8_0] && errorCode == 401 && (serverErrorCode == 1010 || serverErrorCode == 5001)) {
        return YES;
    }
    return NO;
}

+ (BOOL)isIconColorUseMainFc {
    NSString *serverId = [CMPCore sharedInstance].currentServer.serverID;
    if ([CMPServerVersionUtils serverIsLaterV8_0] || [NSString isNull:serverId]) {
           return YES;
    }
    return NO;
}

+ (BOOL)isSupportImageLongPress
{
    if ([CMPServerVersionUtils serverIsLaterV8_0]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isAutoSaveFile
{
    if ([CMPServerVersionUtils serverIsLaterV8_0]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isShowFileShareButton
{
    if ([CMPServerVersionUtils serverIsLaterV8_0]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isSupportCollect
{
    if ([CMPServerVersionUtils serverIsLaterV8_0]) {
        NSString *appListStr = [CMPCore sharedInstance].currentUser.appList;
        CMPAppListModel_2 *appListModel = [CMPAppListModel_2 yy_modelWithJSON:appListStr];
        CMPAppList_2 *appInfo = [appListModel appInfoWithType:@"default" ID:@"3"];
        return appInfo.isShow && [appInfo.isShow boolValue];
    }
    return NO;
}
//V8.0以后图片浏览长按应该不需要显示原图
+ (BOOL)imageBrowserShowOriginImg {
    if ([CMPServerVersionUtils serverIsLaterV8_0]) {
        return NO;
    }
    return YES;
}

//V8.0以后图片浏览长按应该不需要显示打印
+ (BOOL)isImageBrowserShowPrintPhoto {
    if ([CMPServerVersionUtils serverIsLaterV8_0]) {
        return NO;
    }
    return YES;
}

//是否支持打印
+ (BOOL)isSupportPrint {
    return [CMPCore sharedInstance].printIsOpen;
}

+ (BOOL)isNeedMapSearchMemberResponse {
   if ([CMPServerVersionUtils serverIsLaterV8_0]) {
      return YES;
   }
   return NO;
}

//登陆是否区分设备
+ (BOOL)isLoginDistinguishDevice:(NSString *)version {
    //CMPServerVersionV7_1_SP1 之后才开始区分
    return [CMPServerVersionUtils intValueOfServerVersion:version] >= CMPServerVersionV7_1_SP1;
}

+ (BOOL)isUseNewLoginViewController
{
    if (CMPCore.sharedInstance.serverVersion && !CMPCore.sharedInstance.serverIsLaterV8_0) {
        return NO;
    }
    return YES;
}

//顶部导航栏工作台icon
+ (NSString *)bannerAppIcon {
    if ([CMPServerVersionUtils serverIsLaterV8_0]) {
        return @"banner_common_app_v8";
    }
    return @"banner_common_app";
}

//顶部导航栏一级页面高度
+ (CGFloat)bannerHeight {
    if ([CMPServerVersionUtils serverIsLaterV8_0]) {
        return 60;
    }
    return 44;
}
//快捷菜单plist文件
+ (NSString *)quickModulePlistName {
    if ([CMPServerVersionUtils serverIsLaterV8_0]) {
        return @"CMPQuickModule_v8";
    }
    return @"CMPQuickModule";
}
//快捷菜单顶部显示列表
+ (NSArray *)quickModuleTopList {
    
    NSMutableArray *arr = [NSMutableArray array];
    if ([CMPServerVersionUtils serverIsLaterV8_0]) {
        [arr addObjectsFromArray:@[@"quick_scan",@"quick_chat",[CMPFeatureSupportControl quickMirrorStr]]];
        NSString *quickMeeting = [CMPFeatureSupportControl instantMeetingQuickName];
        if(quickMeeting){
            [arr insertObject:quickMeeting atIndex:2];
        }
    }
    return arr;
}
//无限投屏在快捷菜单中的名字
+ (NSString *)quickMirrorStr {
    return @"quick_mirror";
}

//v8.0后导航栏返回按钮不显示文字
+ (BOOL)isBannarBackButtonShowText {
    if ([CMPServerVersionUtils serverIsLaterV8_0] || !CMPServerVersionUtils.isServerHasSetUp) {
      return NO;
   }
   return YES;
}

//v8.0后导航栏关闭按钮按钮不显示文字,显示图标
+ (BOOL)isBannarCloseButtonShowText {
    if ([CMPServerVersionUtils serverIsLaterV8_0] || !CMPServerVersionUtils.isServerHasSetUp) {
      return NO;
   }
   return YES;
}


+ (BOOL)isShowPendingAndMessage {
    if ([CMPServerVersionUtils serverIsLaterV8_0]) {
        return NO;
    }
    return YES;
}

+ (NSString *)paramSourceTypeForCovertMission {
    if ([CMPServerVersionUtils serverIsLaterV8_0]) {
        return @"100";
    }
    return @"61";
}

+(BOOL)allowPopGesture {
    return [CMPCore sharedInstance].allowPopGesture && INTERFACE_IS_PHONE;
}

+ (BOOL)isShoweIntelligentQA {
    if ([CMPServerVersionUtils serverIsLaterV8_0]) {
        return YES;
    }
    return NO;
}

//v8.0以后显示 图片/视频页面
+ (BOOL)isShowCheckAllPicsBtn {
    if ([CMPServerVersionUtils serverIsLaterV8_0]) {
        return YES;
    }
    return NO;
}

@end
