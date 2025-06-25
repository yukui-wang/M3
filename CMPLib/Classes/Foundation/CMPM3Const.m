//
//  CMPM3Const.m
//  CMPLib
//
//  Created by MacBook on 2019/10/14.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "CMPM3Const.h"

#pragma mark - 通知
//查看附件页面的分享按钮点击时的通知名
NSString * const CMPAttachReaderShareClickedNoti = @"CMPAttachReaderShareClickedNoti";

//快捷键页面投屏按钮点击
NSString * const CMPShortcutViewScreenMirroringClickedNoti = @"CMPShortcutViewScreenMirroringClickedNoti";

//屏幕旋转成横屏结束后通知
NSString * const CMPSplitViewContrllerDidBecomeLandscapeNoti = @"CMPSplitViewContrllerDidBecomeLandscapeNoti";

//YBImageBrowser通知   转发通知
NSString * const CMPYBImageBrowserForwardNoti = @"CMPYBImageBrowserForwardNoti";
//YBImageBrowser通知   收藏通知
NSString * const CMPYBImageBrowserCollectNoti = @"CMPYBImageBrowserCollectNoti";

//删除图片通知
NSString * const CMPDelteSelectedRcImgModelsPicNoti = @"CMPDelteSelectedRcImgModelsPicNoti";

//banner点击事件，用于头部点击事件
NSString * const CMPBannerViewTitleClickedNoti = @"CMPBannerViewTitleClickedNoti";

//显示空白扫描页面通知
NSString * const CMPShowBlankScanVCNoti = @"CMPShowBlankScanVCNoti";

//扫描完成后关闭当前页面通知
NSString * const CMPCloseCurrentViewAfterScanFinishedNoti = @"CMPCloseCurrentViewAfterScanFinishedNoti";

#pragma mark - url接口

//文件管理首页
NSString * const CMPFileManagementIndexUrl = @"http://fileManage.m3.cmp/layout/fileManage-index.html";
//分享组件点击分享各个按钮后的中转页面
NSString * const CMPShareForwardUrl = @"http://cmp/v1.0.0/page/cmp-app-share.html";

//投屏提示页
NSString * const CMPScreenMirroringUrl = @"http://cmp/v1.0.0/page/cmp-throwing-screen.html";
//投屏验证相关
NSString * const CMPScreenMirroringVeriUrl = @"/cmp-throwing-screen.html?";
//快捷按钮点击验证
NSString * const CMPShortCutVeriUrls = @"newCollaboration.html,templateIndex.html,taskEditor.html,meetingCreate.html,newCalEvent.html,attendanceIndex.html,ucStartChatPage.html,m3-scan-page.html,cmp-throwing-screen.html";

//外部分享 - 分享到 我的文档/其他文档
NSString * const CMPShareFromAppsToMyDoUrl = @"http://cmp/v1.0.0/page/cmp-app-share.html";

//获取手机验证码接口
NSString * const CMPGetSMSCodeUrl = @"/seeyon/rest/authentication/sms2/tel/";
//截屏上传日志接口
NSString * const CMPUploadScreenshotLog = @"/seeyon/rest/m3/common/applog";

//获取分享权限接口
NSString * const CMPGetShareAuth = @"/rest/shareRecord/settings";

//收藏接口
// /seeyon/rest/doc/favorite?cmprnd=21625763&sourceId=-7829805720850775085&favoriteType=3&appKey=3&hasAtt=false&option.n_a_s=1
NSString * const CMPCollectToDoc = @"/rest/doc/favorite";

#pragma mark - 分享入口string
NSString * const CMPShareComponentUCString = @"uc";
NSString * const CMPShareComponentWechatString = @"wechat";
NSString * const CMPShareComponentQQString = @"qq";
NSString * const CMPShareComponentTelConfString = @"tell_meeting";
NSString * const CMPShareComponentWWechatString = @"qiyeWechat";
NSString * const CMPShareComponentDingtalkString = @"dingding";
NSString * const CMPShareComponentOtherString = @"other";

NSString * const CMPShareComponentScreenMirroringString = @"screen_display";
NSString * const CMPShareComponentQRCodeString = @"qr_code";
NSString * const CMPShareComponentCollectString = @"collect";
NSString * const CMPShareComponentPrintString = @"print";
NSString * const CMPShareComponentDownloadString = @"download";

#pragma mark - 文件来源

NSString * const CMPFileFromTypeSendTo = @"file_management_from_sendto";
NSString * const CMPFileFromTypeComeFrom = @"file_management_from_comefrom";
NSString * const CMPFileFromTypeSendToGroup = @"file_management_from_sendto_group";
NSString * const CMPFileFromTypeComeFromGroup = @"file_management_from_comefrom_group";


#pragma mark - 颜色值
//全局蓝色
NSString * const CMPGlobalBlueColor = @"#297ffb";

#pragma mark - keys

NSString *const CMPGoogleMapsAPIKey = @"AIzaSyBHtDLGM_Nbv6tyFCfL6bkle2oL_ZX_Mio";


#pragma mark - other

NSString * const CMPSavedFileFromOtherAppsKey = @"CMPSavedFileFromOtherAppsKey";



