//
//  CMPSharePlugin.m
//  CMPShareDemo
//
//  Created by wujiansheng on 16/10/12.
//  Copyright © 2016年 wujiansheng. All rights reserved.
//

#import "CMPSharePlugin.h"
#import "CMPShareToOtherAppKit.h"
#import "CMPCommonManager.h"
#import "CMPShareFileModel.h"
#import "CMPShareManager.h"
#import <CMPLib/CMPCachedUrlParser.h>
#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/MJExtension.h>
#import <CMPLib/CMPFileTypeHandler.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPConstant.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <CMPLib/CMPFileTypeHandler.h>
#import <CMPLib/KSSysShareManager.h>
#import "CMPTopScreenManager.h"
#import <CMPLib/zhPopupController.h>
#import "CMPCopDrawerView.h"//抽屉view

@interface CMPSharePlugin()<UIDocumentInteractionControllerDelegate>

@property(nonatomic, retain)UIView *padSheetView;

@property(nonatomic, strong) CMPTopScreenManager *topManager;

@end

@implementation CMPSharePlugin
- (void)dealloc {
    [_padSheetView removeFromSuperview];
//    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)pluginInitialize {
    [super pluginInitialize];
    [CMPSharePlugin initShareSDK];
}

+ (void)initShareSDK {
    [CMPShareManager.sharedManager initShareSDK];
}


- (void)share:(CDVInvokedUrlCommand*)command
{
    // QQ网页分享 title、imgUrl、url不能为空!
    //微信网页分享 imgUrl url不能为空!
    
    NSDictionary *parameter = [[command arguments] lastObject];
    //标题
    NSString *title = [parameter objectForKey:@"title"];
    if ([NSString isNull:title]) {
        title = @"";
    }
    //内容
    NSString *text = [parameter objectForKey:@"text"];
    if ([NSString isNull:text]) {
        text = @"";
    }
    //打开的链接
    NSString *urlString = [parameter objectForKey:@"url"];
    if ([NSString isNull:urlString]) {
        urlString = @"";
    }
    NSURL *url = [NSURL URLWithString:urlString];

    //图片链接
//    NSString *imgUrl = [parameter objectForKey:@"imgUrl"];
//    NSURL *imageUrl = [NSURL URLWithString:imgUrl];
    UIImage *image = nil; // [UIImage imageWithData: [NSData dataWithContentsOfURL:imageUrl]];
    
    //缩略图
    NSString *thumbImgUrl = [parameter objectForKey:@"imgUrl"];//thumbImgUrl不要了
    if ([NSString isNull:thumbImgUrl]) {
        thumbImgUrl = @"";
    }

//    NSURL *thumbImageUrl = [NSURL URLWithString:thumbImgUrl];
//    UIImage *thumbImage = [UIImage imageWithData: [NSData dataWithContentsOfURL:thumbImageUrl]];

    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    SSDKContentType type = SSDKContentTypeAuto;
    
    
    [shareParams SSDKSetupShareParamsByText:text
                                     images:image
                                        url:url
                                      title:title
                                       type:type];
    // QQ好友子平台
    
    [shareParams SSDKSetupQQParamsByText:text
                                   title:title
                                     url:url
                              thumbImage:thumbImgUrl
                                   image:image
                                    type:type
                      forPlatformSubType:SSDKPlatformSubTypeQQFriend];
    
      // 微信好友平台
    [shareParams SSDKSetupWeChatParamsByText:text title:title url:url thumbImage:thumbImgUrl image:image musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil sourceFileExtension:nil sourceFileData:nil type:type forPlatformSubType:SSDKPlatformSubTypeWechatSession];
    
    // 微信朋友圈平台
    [shareParams SSDKSetupWeChatParamsByText:text title:title url:url thumbImage:thumbImgUrl image:image musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil sourceFileExtension:nil sourceFileData:nil type:type forPlatformSubType:SSDKPlatformSubTypeWechatTimeline];

    // 钉钉
    [shareParams SSDKSetupDingTalkParamsByText:text image:thumbImgUrl title:title url:url type:SSDKContentTypeWebPage];
    
    // 复制
    [shareParams SSDKSetupCopyParamsByText:text images:image url:url type:type];
    
    if (INTERFACE_IS_PAD) {
        if (!_padSheetView) {
            _padSheetView = [[UIView alloc] init];
            _padSheetView.hidden = YES;
        }
        [_padSheetView removeFromSuperview];
        CGFloat fW = self.viewController.view.frame.size.width;
        CGFloat fH = self.viewController.view.frame.size.height;
        [_padSheetView setFrame:CGRectMake(fW/2-20, fH/2-40, 40, 40)];
        [self.viewController.view addSubview:_padSheetView];
    }
    
    
    //2、分享（可以弹出我们的分享菜单和编辑界面）
    [ShareSDK showShareActionSheet:self.padSheetView //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
                             items:nil
                       shareParams:shareParams
               onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                   
                   switch (state) {
                       case SSDKResponseStateSuccess:
                       {
                           [_padSheetView removeFromSuperview];
                           CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                           [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                           break;
                       }
                       case SSDKResponseStateFail:
                       {
                           [_padSheetView removeFromSuperview];
                           NSDictionary *errorDic= [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:error.code],@"code",error.description,@"message",@"",@"detail", nil];
                           CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
                           [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                           break;
                       }
                       case SSDKResponseStateCancel:
                       {
                           [_padSheetView removeFromSuperview];
                           NSDictionary *errorDic= [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:50002],@"code",@"cancel share",@"message",@"",@"detail", nil];
                           CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
                           [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                           break;
                       }
                       default:
                           break;
                   }
               }
     ];
}


/**
 title: 标题
 description: 详细描述
 userName: 小程序的userName （必填）
 webpageUrl: 6.5.6以下版本微信会自动转化为分享链接(必填)
 path: 点击分享卡片时打开微信小程序的页面路径,关于该字段的详细说明见下文
 thumbImage 缩略图本地url , 旧版微信客户端（6.5.8及以下版本）小程序类型消息卡片使用小图卡片样式 要求图片数据小于32k
 hdThumbImage 高清缩略图本地url，建议长宽比是 5:4 ,6.5.9及以上版本微信客户端小程序类型分享使用 要求图片数据小于128k
 withShareTicket: 是否使用带 shareTicket 的转发
 miniProgramType: 分享的小程序版本（0-正式，1-开发，2-体验）
 */
- (void)shareWxMiniProgram:(CDVInvokedUrlCommand*)command {
    NSDictionary *parameter = [[command arguments] lastObject];
    NSString *title = parameter[@"title"];
    NSString *description = parameter[@"description"];
    NSString *webpageUrl = parameter[@"webpageUrl"];
    NSString *path = parameter[@"path"];
    BOOL withShareTicket = [parameter[@"withShareTicket"] boolValue];
    NSUInteger miniProgramType = [parameter[@"miniProgramType"] integerValue];
    NSString *username = parameter[@"userName"];
    
    NSString *thumbImageUrl = parameter[@"thumbImage"];
    NSString *hdThumbImageUrl = parameter[@"hdThumbImage"];
    
    thumbImageUrl = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:thumbImageUrl]];
    hdThumbImageUrl = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:hdThumbImageUrl]];
    if (!thumbImageUrl.length) {
        thumbImageUrl = parameter[@"thumbImage"];
    }
    if (!hdThumbImageUrl.length) {
        hdThumbImageUrl = parameter[@"hdThumbImage"];
    }
    thumbImageUrl = [thumbImageUrl replaceCharacter:@"file://" withString:@""];
    hdThumbImageUrl = [hdThumbImageUrl replaceCharacter:@"file://" withString:@""];
    UIImage *thumbImage = [UIImage imageWithContentsOfFile:thumbImageUrl];
    UIImage *hdThumbImage = [UIImage imageWithContentsOfFile:hdThumbImageUrl];
    
    //大于128kb是不能分享成功的，直接连微信跳转都会失败，因此需要做压缩
    NSData *thumbImageData = UIImageJPEGRepresentation(thumbImage, 1.f);
    if (thumbImageData.length >= 32*1000) {
        thumbImageData = UIImageJPEGRepresentation(thumbImage, 0.5f);
    }
    
    NSData *hdThumbImageData = UIImageJPEGRepresentation(hdThumbImage, 1.f);
    if (hdThumbImageData.length >= 128*1000) {
        hdThumbImageData = UIImageJPEGRepresentation(hdThumbImage, 0.5f);
    }
    
    if ([NSString isNull:description]) {
        description = @"";
    }
    
    WXMiniProgramObject *obj = WXMiniProgramObject.object;
    obj.webpageUrl = webpageUrl;
    obj.userName = username;
    obj.path = path;
    obj.hdImageData = hdThumbImageData;
    obj.withShareTicket = withShareTicket;
    obj.miniProgramType = miniProgramType;

    WXMediaMessage *mediaMsg = WXMediaMessage.message;
    mediaMsg.title = title;
    mediaMsg.description = description;
    mediaMsg.mediaObject = obj;
    mediaMsg.thumbData = thumbImageData;

    SendMessageToWXReq *req = SendMessageToWXReq.alloc.init;
    req.message = mediaMsg;
    req.scene = WXSceneSession;
    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            //发送成功
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }else {
            [self.viewController cmp_showHUDWithText:SY_STRING(@"share_wechat_failed")];
            //发送失败
//            NSString *message = @"failed to share to Wechat";
//            NSDictionary *errorDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:101], @"code", message, @"message", @"", @"detail", nil];
//            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
//            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
    
//    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
//    [parameters SSDKSetupWeChatMiniProgramShareParamsByTitle:title
//                                                 description:description
//                                                  webpageUrl:[NSURL URLWithString:webpageUrl]
//                                                        path:path
//                                                  thumbImage:thumbImage
//                                                hdThumbImage:hdThumbImage
//                                                    userName:username
//                                             withShareTicket:withShareTicket
//                                             miniProgramType:miniProgramType
//                                          forPlatformSubType:SSDKPlatformSubTypeWechatSession];
//
//    [ShareSDK share:SSDKPlatformSubTypeWechatSession parameters:parameters onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
//        if (state == SSDKResponseStateSuccess) {
//            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
//            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
//        } else {
//            NSString *message = @"";
//            if (error.userInfo) {
//                message = error.userInfo[@"description"];
//            }
//            NSDictionary *errorDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:error.code], @"code", message, @"message", @"", @"detail", nil];
//            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
//            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
//        }
//    }];
}

- (UIImage *)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize{
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width/2.f,newSize.height/2.f)];//根据newSize对图片进行裁剪
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [UIImage imageWithData:UIImageJPEGRepresentation(newImage, 0.5)];//压缩50%
}

#pragma mark - 分享组件接口

/// 弹出分享框
- (void)cmpShare:(CDVInvokedUrlCommand *)command {
    if (!command.arguments.lastObject) {
        [CMPCommonTool sendPluginCallbackErrorMsgWithCallbackId:command.callbackId commandDelegate:self.commandDelegate];
        return;
    }
    
    NSDictionary *dic = command.arguments.lastObject;
    //appId用于请求后台权限操作
    NSString *appId = [NSString stringWithFormat: @"%@",dic[@"appId"]];
    NSArray *keys = dic[@"shareBtnList"];
    NSArray *resultKeys = [CMPShareManager filterShareTypeWithAppId:appId keys:keys];
    
    NSDictionary *newDic = @{@"appId" : appId, @"shareBtnList" : resultKeys };
    CMPShareFileModel *shareFile = [CMPShareFileModel mj_objectWithKeyValues:newDic];
    
    NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:shareFile.shareBtnList];
    CMPShareBtnModel *btnModel = nil;
    for (CMPShareBtnModel *bm in tmpArr) {
        if ([bm.key isEqualToString:CMPShareComponentTopScreenString]) {
            btnModel = bm;
            break;
        }
    }
    if (CMP_IPAD_MODE) {
        [tmpArr removeObject:btnModel];
        if (tmpArr.count) {
            shareFile.shareBtnList = tmpArr;
            shareFile.commandId = command.callbackId;
            shareFile.commandDelegate = self.commandDelegate;
            [CMPShareManager.sharedManager showShareViewWithList:shareFile mfr:nil pushVC:self.viewController];
        }
    }else if (btnModel && btnModel.param[@"id"]) {
        __weak typeof(self) weakSelf = self;
        [self.topManager checkById:btnModel.param[@"id"] completion:^(BOOL exist,NSError *err) {
            if (err) {
                [weakSelf.viewController cmp_showHUDError:err];
            }else{
                btnModel.title = exist?SY_STRING(@"cancel_to_top_screen"):SY_STRING(@"add_to_top_screen");  //@"从二楼移除":@"添加到二楼";
                btnModel.img = exist?@"share_icon_rect_topScreen_cancel":@"share_icon_rect_topScreen";
                shareFile.commandId = command.callbackId;
                shareFile.commandDelegate = weakSelf.commandDelegate;
                [CMPShareManager.sharedManager showShareViewWithList:shareFile mfr:nil pushVC:weakSelf.viewController];
            }
        }];
    }else{
        shareFile.commandId = command.callbackId;
        shareFile.commandDelegate = self.commandDelegate;
        [CMPShareManager.sharedManager showShareViewWithList:shareFile mfr:nil pushVC:self.viewController];
    }
    
}

//添加\移除 - 我的二楼
- (void)addSecondFloor:(CDVInvokedUrlCommand *)command {
    NSDictionary *parameter = [[command arguments] lastObject];
    NSString *iid = parameter[@"id"];
//    NSString *title = parameter[@"title"];
//    NSString *icon = parameter[@"icon"];
//    NSString *appId = parameter[@"appId"];
//    NSDictionary *gotoParams = parameter[@"gotoParams"];
    //接口判断是添加还是移除
    __weak typeof(self) weakSelf = self;
    [self.topManager checkById:iid completion:^(BOOL exist,NSError *err) {
        if (err) {
            [weakSelf.viewController cmp_showHUDError:err];
        }else{
            if (exist) {
                [weakSelf.topManager topScreenDelById:iid completion:^(id  _Nonnull respData, NSError * _Nonnull error) {
                    if (error) {
                        [weakSelf.viewController cmp_showHUDError:error];
                    }else{
                        if ([respData boolValue]) {
                            [weakSelf.viewController cmp_showHUDWithText:SY_STRING(@"remove_top_screen_success")];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTopScreenRefreshData_SecondFloor object:nil];
                        }
                    }
                }];
            }else{
                [weakSelf.topManager topScreenSaveByParam:parameter completion:^(id  _Nonnull respData, NSError * _Nonnull error) {
                    if (error) {
                        [weakSelf.viewController cmp_showHUDError:error];
                    }else{
                        if ([respData boolValue]) {
                            [weakSelf.viewController cmp_showHUDWithText:SY_STRING(@"add_top_screen_success")];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTopScreenRefreshData_SecondFloor object:nil];
                        }
                    }
                }];
            }
        }
    }];
    
}

//添加【常用入口】点击次数
- (void)recordCommonClick:(CDVInvokedUrlCommand *)command {
    NSDictionary *parameter = [[command arguments] lastObject];
    NSString *iid = parameter[@"id"];
//    NSString *title = parameter[@"title"];
    NSString *icon = parameter[@"icon"];
    NSString *name = parameter[@"name"];
    NSDictionary *gotoParams = parameter[@"gotoParams"];
    [self.topManager savePulginWithId:iid appName:name iconUrl:icon param:gotoParams openType:(CMPTopScreenOpenTypePushPage)];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)commonShare:(CDVInvokedUrlCommand *)command {
    if (!command.arguments.lastObject) {
        [CMPCommonTool sendPluginCallbackErrorMsgWithCallbackId:command.callbackId commandDelegate:self.commandDelegate];
        return;
    }
    
    
    NSDictionary *dic = command.arguments.lastObject;
    //appId用于请求后台权限操作
    NSString *appId = [NSString stringWithFormat: @"%@",dic[@"appId"]];
    NSArray *keys = dic[@"shareBtnList"];
    NSArray *resultKeys = [CMPShareManager filterShareTypeWithAppId:appId keys:keys];
    NSMutableArray *arr = [NSMutableArray arrayWithArray:resultKeys];
    [arr addObjectsFromArray:@[@{@"key":@"copy",@"title":@"复制链接"},
                               @{@"key":@"refresh",@"title":@"刷新"},
                               @{@"key":@"other"}]];
    NSDictionary *newDic = @{@"appId" : appId, @"shareBtnList" : resultKeys };
    __weak typeof(self) wSelf = self;
    [CMPShareManager.sharedManager ksCommonShare:@{@"configs":arr,@"data":@{@"title":@"1111",@"url":@"https://www.baidu.com",@"params":@{@"messageCategory":@"8",@"id":@"-1403373513059712952"}}} ext:nil result:^(NSInteger step,NSDictionary *actInfo, NSError * _Nonnull err, id  _Nullable ext) {
        if (err){
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [wSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }else{
            if (step == 33) {
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [wSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }
    }];
}

/// 只分享文件，可以分享到qq、微信、钉钉、致信
/**
 params:
 {
        type:对应分享通道的key
        params:{
                filePath:[{path:本地文件路径}]
        }
 }
 */
- (void)shareFile:(CDVInvokedUrlCommand *)command {
    
    if (!command.arguments.lastObject) {
        [CMPCommonTool sendPluginCallbackErrorMsgWithCallbackId:command.callbackId commandDelegate:self.commandDelegate];
        return;
    }
    NSDictionary *params = command.arguments.lastObject;
    
    NSString *type = params[@"type"];
    NSMutableArray *filePaths = NSMutableArray.array;
    for (NSDictionary *dic in params[@"filePaths"]) {
        NSString *path = dic[@"path"];
        if (path.length) {
            path = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            [filePaths addObject:path];
        }
    }
    
    NSString *filePath0 = filePaths.firstObject;
    CMPShareManager *shareMgr = CMPShareManager.sharedManager;
    if ([type isEqualToString:CMPShareComponentQQString]) {
        //qq
        [shareMgr shareToQQWithFilePath:filePath0];
    }else if ([type isEqualToString:CMPShareComponentWechatString]) {
        //微信
        [shareMgr shareToWechatWithFilePath:filePath0];
    }else if ([type isEqualToString:CMPShareComponentUCString]) {
        //致信
        [shareMgr shareToUcWithFilePaths:filePaths commandDelegate:self.commandDelegate callbackId:command.callbackId showVc:self.viewController];
    }else if ([type isEqualToString:CMPShareComponentWWechatString]) {
        //企业微信
        [shareMgr shareToWWechatWithFilePath:filePath0];
    }else if ([type isEqualToString:CMPShareComponentDingtalkString]) {
        //钉钉
        [shareMgr shareToDingtalkWithFilePath:filePath0];
    }else if ([type isEqualToString:CMPShareComponentOtherString]) {
        //打开系统分享
        [shareMgr shareToOtherWithFilePath:filePath0 showVc:self.viewController];
    }
    else if ([type isEqualToString:CMPShareComponentOSSystemString]){
        UIViewController *topCtrl = [CMPCommonTool getCurrentShowViewController];
        __weak typeof(self) wSelf = self;
        NSString *urlStr = params[@"url"];
        if (urlStr.length>0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            [[KSSysShareManager shareInstance] presentActivityViewControllerOn:topCtrl sourceView:topCtrl.view shareItemsArr:@[url] unSupportTypes:@[] completionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {

                if (completed && !activityError) {
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                    [wSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }else{
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                    [wSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }
            }];
        }else{
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [wSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }
}


/// 分享东西到致信，可以是文件以及其他
- (void)shareToIm:(CDVInvokedUrlCommand *)command {
    if (!command.arguments.lastObject) {
        [CMPCommonTool sendPluginCallbackErrorMsgWithCallbackId:command.callbackId commandDelegate:self.commandDelegate];
        return;
    }
    
}

- (void)showPermissionDialog:(CDVInvokedUrlCommand *)command {
    if (!command.arguments.lastObject) {
        [CMPCommonTool sendPluginCallbackErrorMsgWithCallbackId:command.callbackId commandDelegate:self.commandDelegate];
        return;
    }
    
    NSDictionary *argu = command.arguments.lastObject;
    //返回值，1-允许  0-不允许 -1-取消
    [CMPShareManager.sharedManager showShareToAppsAuthViewWithArgu:argu ClickedResult:^(NSString *result) {
        NSMutableDictionary *resDic = NSMutableDictionary.dictionary;
        NSArray *options = argu[@"options"];
        if (result.intValue == 1) {
            resDic[@"result"] = options.firstObject[@"data"];
        }else if (result.intValue == 0) {
            resDic[@"result"] = options[1][@"data"];
        }else {
            resDic[@"result"] = result;
        }
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resDic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
    
}

///FIXME: 插件方法名待定
/// 关闭分享view
- (void)hideShareView:(CDVInvokedUrlCommand *)command {
    [CMPShareManager.sharedManager hideViewWithAnimation:NO];
}

/// 获取分享权限
- (void)getShareAuth:(CDVInvokedUrlCommand *)command {
    if (!command.arguments.lastObject) {
        [CMPCommonTool sendPluginCallbackErrorMsgWithCallbackId:command.callbackId commandDelegate:self.commandDelegate];
        return;
    }
    
}


/// 获取是否有微信、qq等的安装
/**
 appId:"11"  用于请求获取权限接口
 keys:["qq","wechat"]
 */
- (void)getPermissionedShareKey:(CDVInvokedUrlCommand *)command {
    if (!command.arguments.lastObject) {
        [CMPCommonTool sendPluginCallbackErrorMsgWithCallbackId:command.callbackId commandDelegate:self.commandDelegate];
        return;
    }
    
    //appId用于请求后台权限操作
    NSDictionary *argumentDic =  command.arguments.lastObject;
    NSString *appId = argumentDic[@"appId"];
    NSArray *keys = argumentDic[@"keys"];
    NSString *fileType = argumentDic[@"fileType"];
    if ([NSString isNotNull:fileType]) {
        NSString *mineType = [CMPFileTypeHandler mineTypeWithPathExtension:fileType];
        CMPFileMineType fileMineType = [CMPFileTypeHandler fileMineTypeWithMineType:mineType];
        if (fileMineType != CMPFileMineTypeImage) {
            if ([keys containsObject:CMPShareComponentQQString]) {
                NSMutableArray *mKeys = [keys mutableCopy];
                [mKeys removeObject:CMPShareComponentQQString];
                keys = [mKeys copy];
            }
        }
    }
    NSArray *resultArr = [CMPShareManager filterShareTypeWithAppId:appId keys:keys];
    
    if (CMP_IPAD_MODE) {
        NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:resultArr];
        [tmpArr removeObject:CMPShareComponentTopScreenString];
        resultArr = tmpArr;
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:resultArr];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
/// 弹出抽屉

/**
 var param = {
     appId = 2;
     shareBtnList =     (
                 {
             key = uc;
             title:"致信"//（国际化）,
             thumbImage:url,//应用包图片地址
             param =             {
                 id = 3641712131657058006;
                 messageCategory = 2;
             };
         },
                 {
             customHandle = 1;
             key = print;
         },
                 {
             key = "screen_display";
         }
     );
     shareOtherBtnList:[],
     businessBtnList:[],
 }
 */

- (void)moreShareUI:(CDVInvokedUrlCommand *)command {
    NSDictionary *dic = command.arguments.lastObject;
    //appId用于请求后台权限操作
    NSString *appId = [NSString stringWithFormat: @"%@",dic[@"appId"]];
    NSArray *shareBtnList = dic[@"shareBtnList"];

    //过滤权限
    NSArray *resultShareBtnList = [CMPShareManager filterShareTypeWithAppId:appId keys:shareBtnList];
    NSArray *shareOtherBtnList = dic[@"shareOtherBtnList"];
    NSArray *businessBtnList = dic[@"businessBtnList"];
    
    NSMutableArray<CMPCopDrawerModel *> *shareBtnListArr = [NSMutableArray arrayWithArray: [CMPCopDrawerModel mj_objectArrayWithKeyValuesArray:resultShareBtnList]];
    [shareBtnListArr addObjectsFromArray:[CMPCopDrawerModel mj_objectArrayWithKeyValuesArray:shareOtherBtnList]];
    NSArray<CMPCopDrawerModel *> *businessBtnListArr = [CMPCopDrawerModel mj_objectArrayWithKeyValuesArray:businessBtnList];
    
    CMPCopDrawerModel *drawerModel = nil;
    for (CMPCopDrawerModel *model in shareBtnListArr) {
        if([model.key isEqualToString:CMPShareComponentTopScreenString]){
            drawerModel = model;
            model.stayIn = YES;//添加到二楼时强制不收起抽屉
            break;
        }
    }
    if (CMP_IPAD_MODE) {
        [shareBtnListArr removeObject:drawerModel];
        if (businessBtnListArr.count) {//high drawer
            [self openHighWithShareArr:shareBtnListArr bizArr:businessBtnListArr command:command];
        }else{//small drawer
            [self openSmallWithShareArr:shareBtnListArr command:command];
        }
    }else if (drawerModel && drawerModel.param[@"id"]) {
        __weak typeof(self) weakSelf = self;
        [self.topManager checkById:drawerModel.param[@"id"] completion:^(BOOL exist,NSError *err) {
            if (err) {
                [weakSelf.viewController cmp_showHUDError:err];
            }else{
                drawerModel.title = exist?SY_STRING(@"cancel_to_top_screen"):SY_STRING(@"add_to_top_screen");  //@"从二楼移除":@"添加到二楼";
                drawerModel.img = exist?@"share_icon_topScreen_cancel":@"share_icon_topScreen";
                drawerModel.secondFloor = exist;
            }
            
            if (businessBtnListArr.count) {//high drawer
                [weakSelf openHighWithShareArr:shareBtnListArr bizArr:businessBtnListArr command:command];
            }else{//small drawer
                [weakSelf openSmallWithShareArr:shareBtnListArr command:command];
            }
        }];
    }else{
        if (businessBtnListArr.count) {//high drawer
            [self openHighWithShareArr:shareBtnListArr bizArr:businessBtnListArr command:command];
        }else{//small drawer
            [self openSmallWithShareArr:shareBtnListArr command:command];
        }
    }

}

//打开底部矮的抽屉
- (void)openSmallWithShareArr:(NSArray *)shareArr command:(CDVInvokedUrlCommand *)command{
    CGFloat w = UIScreen.mainScreen.bounds.size.width;
    CGFloat smallHeight = 159 + 20;//规定抽屉高度
    
    CMPCopDrawerView *view = [[CMPCopDrawerView alloc]initViewWithCollectionData:shareArr tableData:@[] withFrame:CGRectMake(0, 0, w, smallHeight) showIndicator:NO];
    
    view.ItemDidSelectedBlock = ^(CMPCopDrawerModel *dm) {
        if ([dm.key isEqualToString:CMPShareComponentTopScreenString]) {
            dm.secondFloor = !dm.secondFloor;
            dm.title = dm.secondFloor?SY_STRING(@"cancel_to_top_screen"):SY_STRING(@"add_to_top_screen");
            dm.img = dm.secondFloor?@"share_icon_topScreen_cancel":@"share_icon_topScreen";
            //更新点击的按钮
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyCMPCopDrawerItemChanged object:@{
                @"key":CMPShareComponentTopScreenString,
                @"title":dm.title,
                @"thumbImage":dm.img,
                @"stayIn":@YES,
            }];
        }
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"key" : dm.key?:@""}];
        [pluginResult setKeepCallbackAsBool:dm.stayIn];//不关闭则需要保持回调
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    };
    
    [self openSmallDrawerFromVC:self.viewController withView:view showSize:CGSizeMake(w, smallHeight)];
}

- (void)openSmallDrawerFromVC:(UIViewController *)vc withView:(CMPCopDrawerView *)drawerView showSize:(CGSize)size{
    zhPopupController *popupController = [[zhPopupController alloc] initWithView:drawerView size:size];
    popupController.layoutType = zhPopupLayoutTypeBottom;
    popupController.presentationStyle = zhPopupSlideStyleFromBottom;
    popupController.panDismissRatio = 0.5;
    popupController.panGestureEnabled = NO;//不允许拖拽
    
    popupController.smallHeight = size.height;//需要高速popup组件高度
    popupController.initTopY = UIScreen.mainScreen.bounds.size.height - size.height;
    [popupController showInView:vc.view.window completion:NULL];
    
    __weak typeof(popupController) weakPopup = popupController;
    drawerView.CloseDrawerBlock = ^{
        [weakPopup dismiss];
    };
}

//打开高抽屉
- (void)openHighWithShareArr:(NSArray *)shareArr bizArr:(NSArray *)bizArr command:(CDVInvokedUrlCommand *)command{
    CGFloat w = UIScreen.mainScreen.bounds.size.width;
    CGFloat h = UIScreen.mainScreen.bounds.size.height - 56; //492.0/812.0;规定最大高度
    
    CMPCopDrawerView *view = [[CMPCopDrawerView alloc]initViewWithCollectionData:shareArr tableData:bizArr withFrame:CGRectMake(0, 0, w, h) showIndicator:YES];
    view.ItemDidSelectedBlock = ^(CMPCopDrawerModel *dm) {
        if ([dm.key isEqualToString:CMPShareComponentTopScreenString]) {
            dm.secondFloor = !dm.secondFloor;
            dm.title = dm.secondFloor?SY_STRING(@"cancel_to_top_screen"):SY_STRING(@"add_to_top_screen");
            dm.img = dm.secondFloor?@"share_icon_topScreen_cancel":@"share_icon_topScreen";
            //更新点击的按钮
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyCMPCopDrawerItemChanged object:@{
                @"key":CMPShareComponentTopScreenString,
                @"title":dm.title,
                @"thumbImage":dm.img,
                @"stayIn":@YES,
            }];
        }
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"key" : dm.key?:@""}];
        [pluginResult setKeepCallbackAsBool:dm.stayIn];//不关闭则需要保持回调
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    };
    
    [self openHighDrawerFromVC:self.viewController withView:view showSize:CGSizeMake(w, h)];
}

- (void)openHighDrawerFromVC:(UIViewController *)vc withView:(CMPCopDrawerView *)drawerView showSize:(CGSize)size{
    zhPopupController *popupController = [[zhPopupController alloc] initWithView:drawerView size:size];
    popupController.layoutType = zhPopupLayoutTypeBottom;
    popupController.presentationStyle = zhPopupSlideStyleFromBottom;
    popupController.panGestureEnabled = YES;
    popupController.panDismissRatio = 0.5;
    
    CGFloat y = ((812.0-492.0)/812.0) * UIScreen.mainScreen.bounds.size.height;
    [drawerView setTableViewHeight:UIScreen.mainScreen.bounds.size.height - y];
    
    popupController.PositionChangedBlock = ^(CGFloat frameY) {//回调popup组件y值
        [drawerView setTableViewHeight:UIScreen.mainScreen.bounds.size.height-frameY];
    };
    
    //初始为zhPopupPositionMiddle
    [popupController showInView:vc.view.window midY:y topY:56.f initY:y initPosition:zhPopupPositionMiddle completion:nil];
    
    __weak typeof(popupController) weakPopup = popupController;
    drawerView.CloseDrawerBlock = ^{
        [weakPopup dismiss];
    };
}

/**
 用于改变抽屉组件某个item变化
 {"key":"FavoriteKey","title":"收藏","thumbImage":"","stayIn":"false","statusText":"已跟踪","statusTextColor":"#ffffff"}
 */
- (void)moreShareUI_changeItem:(CDVInvokedUrlCommand *)command{
    NSDictionary *dic = command.arguments.lastObject;
//    dic = @{@"key":@"FavoriteKey",@"title":@"收藏",@"thumbImage":@"",
//            @"stayIn":@"false",@"statusText":@"已跟踪",@"statusTextColor":@"#ffffff"};
    //appId用于请求后台权限操作
    
    NSString *key = dic[@"key"];
    if (key.length) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyCMPCopDrawerItemChanged object:dic];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (CMPTopScreenManager *)topManager{
    if (!_topManager) {
        _topManager = [CMPTopScreenManager new];
    }
    return _topManager;
}

@end
