//
//  CMPM3Const.h
//  CMPLib
//
//  Created by MacBook on 2019/10/14.
//  Copyright © 2019 crmo. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - 通知
//查看附件页面的分享按钮点击时的通知名
UIKIT_EXTERN NSString * const CMPAttachReaderShareClickedNoti;
//快捷键页面投屏按钮点击
UIKIT_EXTERN NSString * const CMPShortcutViewScreenMirroringClickedNoti;
//屏幕旋转成横屏结束后通知
UIKIT_EXTERN NSString * const CMPSplitViewContrllerDidBecomeLandscapeNoti;

//YBImageBrowser通知   转发通知
UIKIT_EXTERN NSString * const CMPYBImageBrowserForwardNoti;
//YBImageBrowser通知   收藏通知
UIKIT_EXTERN NSString * const CMPYBImageBrowserCollectNoti;
//删除图片通知
UIKIT_EXTERN NSString * const CMPDelteSelectedRcImgModelsPicNoti;
//banner点击事件，用于头部点击事件
UIKIT_EXTERN NSString * const CMPBannerViewTitleClickedNoti;

//显示空白扫描页面通知
UIKIT_EXTERN NSString * const CMPShowBlankScanVCNoti;

//扫描完成后关闭当前页面通知
UIKIT_EXTERN NSString * const CMPCloseCurrentViewAfterScanFinishedNoti;

#pragma mark - url接口
//文件管理首页
UIKIT_EXTERN NSString * const CMPFileManagementIndexUrl;
//分享组件点击分享各个按钮后的中转页面
UIKIT_EXTERN NSString * const CMPShareForwardUrl;

//投屏提示页
UIKIT_EXTERN NSString * const CMPScreenMirroringUrl;
//投屏验证相关
UIKIT_EXTERN NSString * const CMPScreenMirroringVeriUrl;
//快捷按钮点击验证
UIKIT_EXTERN NSString * const CMPShortCutVeriUrls;

//外部分享 - 分享到其他文件夹
UIKIT_EXTERN NSString * const CMPShareFromAppsToMyDoUrl;

//获取手机验证码接口
UIKIT_EXTERN NSString * const CMPGetSMSCodeUrl;
//截屏上传日志接口
UIKIT_EXTERN NSString * const CMPUploadScreenshotLog;
//获取分享权限接口
UIKIT_EXTERN NSString * const CMPGetShareAuth;

//收藏接口
UIKIT_EXTERN NSString * const CMPCollectToDoc;

#pragma mark - 分享入口string

UIKIT_EXTERN NSString * const CMPShareComponentUCString;
UIKIT_EXTERN NSString * const CMPShareComponentWechatString;
UIKIT_EXTERN NSString * const CMPShareComponentQQString;
UIKIT_EXTERN NSString * const CMPShareComponentTelConfString;
UIKIT_EXTERN NSString * const CMPShareComponentWWechatString;
UIKIT_EXTERN NSString * const CMPShareComponentDingtalkString;
UIKIT_EXTERN NSString * const CMPShareComponentOtherString;

UIKIT_EXTERN NSString * const CMPShareComponentScreenMirroringString;
UIKIT_EXTERN NSString * const CMPShareComponentQRCodeString;
UIKIT_EXTERN NSString * const CMPShareComponentCollectString;
UIKIT_EXTERN NSString * const CMPShareComponentPrintString;
UIKIT_EXTERN NSString * const CMPShareComponentDownloadString;

#pragma mark - 文件来源

typedef NSString * CMPFileFromType;

UIKIT_EXTERN NSString * const CMPFileFromTypeSendTo;
UIKIT_EXTERN NSString * const CMPFileFromTypeComeFrom;
UIKIT_EXTERN NSString * const CMPFileFromTypeSendToGroup;
UIKIT_EXTERN NSString * const CMPFileFromTypeComeFromGroup;

#pragma mark - 颜色值
//全局蓝色
UIKIT_EXTERN NSString * const CMPGlobalBlueColor;

#pragma mark - keys

UIKIT_EXTERN NSString *const CMPGoogleMapsAPIKey;


#pragma mark - other

//外部分享进APP的文件记录路径
UIKIT_EXTERN NSString * const CMPSavedFileFromOtherAppsKey;
