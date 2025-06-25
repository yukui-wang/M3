//
//  CMPShareManager.m
//  M3
//
//  Created by MacBook on 2019/10/24.
//

#import "CMPShareManager.h"
#import "CMPShareToInnerViewController.h"
#import "CMPShareView.h"
#import "M3-Swift.h"
#import "CMPSharePlugin.h"
#import "CMPShareToOtherAppKit.h"
#import "CMPMessageManager.h"
#import "CMPShareToUcManager.h"
#import "CMPCommonManager.h"
#import "CMPMessageManager.h"
#import "CMPShareCellModel.h"
#import "M3LoginManager.h"

#import <CMPLib/CMPPopOverManager.h>
#import <CMPlib/CMPPopFromBottomViewController.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/CMPFileManagementRecord.h>
#import <CMPLib/CMPStringConst.h>
#import <CMPLib/CMPPopoverViewController.h>
#import <CMPLib/CMPScreenMirrorTipsView.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPNavigationController.h>
#import <CMPLib/CMPCAAnimation.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <ShareSDK/ShareSDK.h>
#import <CMPLib/CMPPrintTools.h>
#import <CMPLib/FCFileManager.h>
#import <CMPLib/CMPCommonDataProviderTool.h>
#import <CMPLib/CMPUploadFileTool.h>
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/YBImageBrowserTipView.h>
#import <CMPLib/NSURL+CMPURL.h>
#import "CMPSelectContactViewController.h"
#import <MOBFoundation/MobSDK+Privacy.h>
#import "CMPCustomManager.h"
#import <CMPLib/CMPStringConst.h>
#import <CMPLib/KSSysShareManager.h>

static NSString * const kFilterTypeNames = @"uc,wechat,qq,other,wechatMoments";

static NSString * const kWindowBgBlackColor = @"0x333333";

static CGFloat const kShareViewH = 322.f;
static CGFloat const kScreenMirroringViewW = 315.f;
static CGFloat const kScreenMirroringViewH = 360.f;

static NSMutableArray *windowsArray_ = nil;
static id instance_ = nil;

@interface CMPShareManager()<NSCopying,CMPDataProviderDelegate,UIDocumentInteractionControllerDelegate,TencentSessionDelegate>

/* 分享权限数据 */
@property (strong, nonatomic) NSDictionary *shareAuthData;
/* 系统自带分享界面 */
@property (strong, nonatomic) UIDocumentInteractionController *fileInteractionController;
/* showVc */
@property (weak, nonatomic) UIViewController *showVc;
/* TencentOAuth */
@property (strong, nonatomic) TencentOAuth *to;

@property (nonatomic, strong) CMPPrintTools *printTool;

@end

@implementation CMPShareManager

#pragma mark - lazy loading
- (UIWindow *)initialiseWindow {
    
    if (!windowsArray_) {
        windowsArray_ = [NSMutableArray array];
    }
    
    UIWindow *window = [UIWindow.alloc initWithFrame: UIScreen.mainScreen.bounds];
    window.backgroundColor = [[UIColor cmp_colorWithName:@"mask-bgc"] colorWithAlphaComponent:0];
    window.windowLevel = UIWindowLevelAlert;
    window.hidden = NO;
    [CMPThemeManager.sharedManager setUserInterfaceStyle];
    
    [windowsArray_ addObject:window];
    return window;
}

- (void)hideWindowWithAnimation {
    if (windowsArray_.count == 0) return;
    
    UIWindow *window = windowsArray_.lastObject;
    [UIView animateWithDuration:CMPShowingViewTimeInterval - 0.03f animations:^{
        window.backgroundColor = [[UIColor cmp_colorWithName:@"mask-bgc"] colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        window.hidden = YES;
        window.rootViewController = nil;
        [windowsArray_ removeObject:window];
    }];
}

- (void)hideWindowWithoutAnimationWithWindow:(UIWindow *)window {
    if (windowsArray_.count == 0) return;
    if (window == nil) return;
    
    window.hidden = YES;
    window.rootViewController = nil;
    [windowsArray_ removeObject:window];
    window = nil;
}

#pragma mark singleton
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = CMPShareManager.alloc.init;
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
        //        调了2次，干掉
        //        [self requestShareAuthData];
    }
    return self;
}

+ (void)load {
    [self addNotis];
}

+ (void)addNotis {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(attachReaderVCShareClicked:) name:CMPAttachReaderShareClickedNoti object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(screenMirrorClicked:) name:CMPShortcutViewScreenMirroringClickedNoti object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(showBlankScanVC:) name:CMPShowBlankScanVCNoti object:nil];
}

#pragma mark 附件文件查看页面 分享点击通知

+ (void)attachReaderVCShareClicked:(NSNotification *)noti {
    NSDictionary *dic = noti.object;
    if (!dic) return;
    
    CMPFileManagementRecord *mfr = dic[@"mfr"];
    if (mfr.fileName.length) {
        NSString *tmpName = [mfr.fileName stringByRemovingPercentEncoding];
        if (tmpName.length) {
            mfr.fileName = tmpName;
        }
    }else {
        NSString *tmpName = [mfr.filePath.lastPathComponent stringByRemovingPercentEncoding];
        if (tmpName.length) {
            mfr.fileName = tmpName;
        }
    }
    
    if (![mfr.fileName isEqualToString:mfr.filePath.lastPathComponent]) {
        NSString *newFilePath = [CMPFileManager.fileTempPath stringByAppendingPathComponent:mfr.fileName];
        NSString *s = [FCFileManager copyFile:mfr.filePath toPath:newFilePath];
        if (s) {
            mfr.filePath = s;
        }
    }
    
    if (mfr.filePath.length) {
        NSString *tmpPath = [mfr.filePath stringByRemovingPercentEncoding];
        if (tmpPath.length) {
            mfr.filePath = tmpPath;
        }
    }
    UIViewController *pushVC = dic[@"pushVC"];
    UIView *webview = dic[@"webview"];
    [CMPShareManager.sharedManager initShareSDK];
    [CMPShareManager.sharedManager showShareViewWithList:nil mfr:mfr pushVC:pushVC isUc:mfr.isUc webview:webview];
}

+ (void)screenMirrorClicked:(NSNotification *)noti {
    
    [CMPShareManager.sharedManager showScreenMirrorTipsView];
}



+ (void)showBlankScanVC:(NSNotification *)noti {
    NSDictionary *params = noti.object;
    UIViewController *vc = params[@"vc"];
    UIImage *scanImage = params[@"scanImage"];
    [CMPMessageManager.sharedManager showScanViewWithUrl:nil viewController:vc scanImage:scanImage];
}

#pragma mark shareView显示隐藏

- (void)showShareViewWithList:(CMPShareFileModel *)shareFileModel mfr:(CMPFileManagementRecord *)mfr pushVC:(UIViewController *)pushVC {
    [self showShareViewWithList:shareFileModel mfr:mfr pushVC:pushVC isUc:NO webview:nil];
}

- (void)showShareViewWithList:(nullable CMPShareFileModel *)shareFileModel mfr:(nullable CMPFileManagementRecord *)mfr pushVC:(nonnull UIViewController *)pushVC isUc:(BOOL)isUc webview:(UIView *)webview {
    __weak UIWindow *window = [self initialiseWindow];
    if (!windowsArray_.count) return;
    
    CMPPopFromBottomViewController *shareVC = CMPPopFromBottomViewController.alloc.init;
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = UIScreen.mainScreen.bounds.size.width;
    CGFloat h = kShareViewH;
    CMPShareView *shareView = [CMPShareView shareViewWithFrame:CGRectMake(x, y, w, h) shareFileModel:shareFileModel];
    shareView.mfr = mfr;
    shareVC.showingView = shareView;
    shareView.viewController = shareVC;
    shareView.pushVC = pushVC;
    shareView.isUc = isUc;
    shareView.webview = webview;
    window.rootViewController = shareVC;
    
    __weak typeof(self) weakSelf = self;
    shareVC.viewClicked = ^(BOOL hasAnimation) {
        if (hasAnimation) {
            //有动画时，动画消失window
            [weakSelf hideWindowWithAnimation];
        }else {
            //没有动画
            [weakSelf hideWindowWithoutAnimationWithWindow:window];
        }
        
    };
    
    [UIView animateWithDuration:CMPShowingViewTimeInterval animations:^{
        window.backgroundColor = [[UIColor cmp_colorWithName:@"mask-bgc"] colorWithAlphaComponent:0.5f];
    }];
}


- (void)ksCommonShare:(NSDictionary *)params ext:(__nullable id)ext result:(void(^)(NSInteger step,NSDictionary *actInfo, NSError *err, __nullable id ext))result
{
    if (!params) {
        if (result) {
            result(0,nil,[NSError errorWithDomain:@"params nil" code:-1 userInfo:nil],nil);
        }
        return;
    }
    __weak UIWindow *window = [self initialiseWindow];
    if (!windowsArray_.count) return;
    
    CMPPopFromBottomViewController *shareVC = CMPPopFromBottomViewController.alloc.init;
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = UIScreen.mainScreen.bounds.size.width;
    CGFloat h = kShareViewH;
    
    __weak typeof(self) weakSelf = self;
    CMPShareView *shareView = [[CMPShareView alloc] initWithFrame:CGRectMake(x, y, w, h) ksCommonParams:params ksCommonRsltBlk:^(NSInteger step, NSDictionary * _Nonnull actInfo, NSError * _Nonnull err, id  _Nullable ext) {
        if (err) {
            if (result) {
                result(step,actInfo,err,ext);
            }
            return;
        }
        if (step == 1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                CMPShareManager *shareMgr = CMPShareManager.sharedManager;
                NSString *type = actInfo[@"key"];
                id data = params[@"data"];
                if ([type isEqualToString:CMPShareComponentUCString]) {
                    //致信
                    __block UIViewController *vc = [CMPCommonTool getCurrentShowViewController];
                    [CMPShareToUcManager.manager showSelectContactViewInVC:vc param:data willForwardMsg:^{
                        
                    } forwardSucess:^(CMPMessageObject * _Nonnull msgObj) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            vc = [CMPCommonTool getCurrentShowViewController];
                            if ([vc isKindOfClass:[CMPSelectContactViewController class]] == NO) {
                                [vc dismissViewControllerAnimated:NO completion:^{
                                    [CMPMessageManager.sharedManager showChatViewAfterShare:msgObj vc:nil filePaths:nil];
                                }];
                            } else {
                                 [vc.navigationController popViewControllerAnimated:NO];
                                 [CMPMessageManager.sharedManager showChatViewAfterShare:msgObj vc:vc filePaths:nil];
                            }
                            
                            if (result) {
                                result(33,actInfo,nil,ext);
                            }
                        });
                        
                    } forwardFailed:^{
                        if (result) {
                            result(2,nil,[NSError errorWithDomain:@"uc share fail" code:-1 userInfo:nil],ext);
                        }
                    }];
                }else if ([type isEqualToString:@"refresh"]) {
                    //刷新
                    UIViewController *vc = [CMPCommonTool getCurrentShowViewController];
                    if ([vc isKindOfClass:CMPBaseWebViewController.class]) {
                        [(CMPBaseWebViewController *)vc refresh];
                    }else if ([vc isKindOfClass:NSClassFromString(@"CMPCommonWebViewController")]) {
                        SEL sel = NSSelectorFromString(@"reload");
                        if ([vc respondsToSelector:sel]) {
                            [vc performSelector:sel];
                        }
                    }
                }else if ([type isEqualToString:@"copy"]) {
                    //复制
                    NSString *content = data[@"url"];
                    if (content) {
                        [[UIPasteboard generalPasteboard] setString:content];
                        [weakSelf cmp_showHUDWithText:@"已复制"];
                    }
                }else if ([type isEqualToString:CMPShareComponentOtherString]
                          ||[type isEqualToString:CMPShareComponentOSSystemString]){
                    //系统分享
                    UIViewController *topCtrl = [CMPCommonTool getCurrentShowViewController];
                    NSString *urlStr = data[@"url"];
                    NSString *typeStr = data[@"mediaType"];
                    NSData *mediaData = data[@"mediaData"];
                    NSMutableArray *arr = [NSMutableArray array];
                    if (urlStr.length>0 && ![@"image" isEqualToString:typeStr]) {
                        [arr addObject:[NSURL URLWithString:urlStr]];
                    }
                    if (mediaData) {
                        [arr addObject:mediaData];
                    }
                    if (arr.count>0) {
                        [[KSSysShareManager shareInstance] presentActivityViewControllerOn:topCtrl sourceView:topCtrl.view shareItemsArr:arr unSupportTypes:@[] completionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {

                            if (completed && !activityError) {
                                if (result) {
                                    result(33,actInfo,nil,ext);
                                }
                            }else{
                                if (result) {
                                    result(2,nil,[NSError errorWithDomain:@"os sys share fail" code:-1 userInfo:nil],ext);
                                }
                            }
                        }];
                    }else{
                        if (result) {
                            result(2,nil,[NSError errorWithDomain:@"os sys share fail" code:-1 userInfo:nil],ext);
                        }
                    }
                }else if ([type isEqualToString:CMPShareComponentWechatString]
                          ||[type isEqualToString:CMPShareComponentWechatTimelineString]) {
                    //微信
                    NSString *mediaType = data[@"mediaType"];
                    NSString *mediaTitle = data[@"title"];
                    NSData *mediaData = data[@"mediaData"];
                    int scene = [type isEqualToString:CMPShareComponentWechatTimelineString] ? WXSceneTimeline : WXSceneSession;
                    [shareMgr ksShareToWechatWithMediaType:mediaType mediaTitle:mediaTitle mediaData:mediaData extInfo:data scene:scene completion:^(BOOL success, NSError *error, id  _Nullable ext) {
                        if (success) {
                            if (result) {
                                result(33,actInfo,nil,ext);
                            }
                        }else{
                            if (result) {
                                result(2,nil,[NSError errorWithDomain:@"os sys share fail" code:-1 userInfo:nil],ext);
                            }
                        }
                    }];
                }
            });
        }
    }];
    shareView.viewController = shareVC;
    shareVC.showingView = shareView;
    window.rootViewController = shareVC;
    
    shareVC.viewClicked = ^(BOOL hasAnimation) {
        if (hasAnimation) {
            //有动画时，动画消失window
            [weakSelf hideWindowWithAnimation];
        }else {
            //没有动画
            [weakSelf hideWindowWithoutAnimationWithWindow:window];
        }
        
    };
    
    [UIView animateWithDuration:CMPShowingViewTimeInterval animations:^{
        window.backgroundColor = [[UIColor cmp_colorWithName:@"mask-bgc"] colorWithAlphaComponent:0.5f];
    }];
    
    [CMPShareManager.sharedManager initShareSDK];
}

/// ks分享到微信
///mediaType:file image text url video music location
///mediaTitle:分享的主标题，对应的type有就传，无则不传
///extInfo：对应type的扩展信息，包含filePath，url等信息
///scene：WXSceneSession WXSceneTimeline
- (void)ksShareToWechatWithMediaType:(NSString *)mediaType mediaTitle:(NSString *)mediaTitle mediaData:(NSData *)mediaData extInfo:(_Nullable id)extInfo scene:(int)scene completion:(void(^)(BOOL success,NSError *error,__nullable id ext))completion  {
    
    if (!mediaType) {
        [MBProgressHUD cmp_showHUDWithText:SY_STRING(@"common_send_fail")];
        if (completion) {
            completion(NO,[NSError errorWithDomain:@"mediaType nil" code:-101 userInfo:nil],nil);
        }
        return;
    }
    
    WXMediaMessage *mediaMsg = WXMediaMessage.message;
    id mediaObj; NSString *title;
    if ([@"file" isEqualToString:mediaType]) {
        if (!mediaData) {
            [MBProgressHUD cmp_showHUDWithText:SY_STRING(@"common_send_fail")];
            if (completion) {
                completion(NO,[NSError errorWithDomain:@"mediaData nil" code:-101 userInfo:nil],nil);
            }
            return;
        }
        if (mediaData.length > 1024*1024 *10) {
            [MBProgressHUD cmp_showHUDWithText:SY_STRING(@"share_wechat_limit_10M")];
            if (completion) {
                completion(NO,[NSError errorWithDomain:@"over max length(10M)" code:-101 userInfo:nil],nil);
            }
            return;
        }
        WXFileObject *fileObj = WXFileObject.object;
        fileObj.fileData = mediaData;
        NSString *filePath = extInfo ? extInfo[@"filePath"] : nil;
        if (filePath) {
            fileObj.fileExtension = [filePath.lastPathComponent componentsSeparatedByString:@"."].lastObject;
            title = filePath.lastPathComponent;
        }
        mediaObj = fileObj;
    } else if ([@"image" isEqualToString:mediaType]) {
        if (!mediaData) {
            [MBProgressHUD cmp_showHUDWithText:SY_STRING(@"common_send_fail")];
            if (completion) {
                completion(NO,[NSError errorWithDomain:@"mediaData nil" code:-101 userInfo:nil],nil);
            }
            return;
        }
        if (mediaData.length > 1024*1024 *10) {
            [MBProgressHUD cmp_showHUDWithText:SY_STRING(@"share_wechat_limit_10M")];
            if (completion) {
                completion(NO,[NSError errorWithDomain:@"over max length(10M)" code:-101 userInfo:nil],nil);
            }
            return;
        }
        WXImageObject *imageObj = WXImageObject.object;
        imageObj.imageData = mediaData;
        mediaObj = imageObj;
        //对原图size缩小和压缩
        UIImage *mediaImage = [UIImage imageWithData:mediaData];
        UIImage *small_mediaImage = [self imageWithImage:mediaImage scaledToSize:CGSizeMake(mediaImage.size.width/4.0, mediaImage.size.height/4.0)];
        UIImage *thumbImage = [UIImage imageWithData:[self compressImage:small_mediaImage toMaxFileSize:64*1000]];
        //设置thumbImage
        [mediaMsg setThumbImage:thumbImage];
    } else if ([@"video" isEqualToString:mediaType]) {
        
    } else if ([@"music" isEqualToString:mediaType]) {
        
    } else if ([@"text" isEqualToString:mediaType]) {
        WXTextObject *textObj = WXTextObject.object;
        textObj.contentText = mediaTitle;
        mediaObj = textObj;
    }
    
    if (!mediaObj) {
        if (completion) {
            completion(NO,[NSError errorWithDomain:[@"no match type:" stringByAppendingString:mediaType] code:-103 userInfo:nil],nil);
        }
        return;
    }
    mediaMsg.mediaObject = mediaObj;
    mediaMsg.title = title ? : @"";
    mediaMsg.description = @"M3分享文件到微信";
    
    SendMessageToWXReq *wxReq = SendMessageToWXReq.alloc.init;
    wxReq.message = mediaMsg;
    wxReq.bText = [mediaObj isKindOfClass:WXTextObject.class];
    wxReq.scene = scene;
    [WXApi sendReq:wxReq completion:^(BOOL success) {
        if (success) {
            //发送成功
            [MBProgressHUD cmp_showHUDWithText:SY_STRING(@"common_send_success")];
            if (completion) {
                completion(YES,nil,nil);
            }
        }else {
            //发送失败
            [MBProgressHUD cmp_showHUDWithText:SY_STRING(@"common_send_fail")];
            if (completion) {
                completion(NO,[NSError errorWithDomain:@"no err info" code:-102 userInfo:nil],nil);
            }
        }
    }];
}
- (UIImage *)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];//根据newSize对图片进行裁剪
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [UIImage imageWithData:UIImageJPEGRepresentation(newImage, 0.5)];//压缩50%
}
- (NSData *)compressImage:(UIImage *)image toMaxFileSize:(NSInteger)maxFileSize {
    CGFloat maxQuality = 1.0;
    CGFloat minQuality = 0.0;
    NSData *compressedData = UIImageJPEGRepresentation(image, maxQuality);
    
    while (maxQuality - minQuality > 0.01) {
        CGFloat midQuality = (minQuality + maxQuality) / 2;
        compressedData = UIImageJPEGRepresentation(image, midQuality);
        
        if (compressedData.length < maxFileSize) {
            minQuality = midQuality;
        } else {
            maxQuality = midQuality;
        }
    }
    
    return compressedData;
}

#pragma mark 外部分享到M3 view

- (void)showShareToInnerViewWithFilePaths:(NSArray *)filePaths fromVC:(nonnull UIViewController *)fromVC {
    [self initialiseWindow];
    if (!windowsArray_.count) return;
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    UIWindow *window = windowsArray_.lastObject;
    CMPShareToInnerViewController *vc = [[CMPShareToInnerViewController alloc] init];
    vc.filePaths = filePaths;
    vc.fromVC = fromVC;
    vc.fromWindow = window;
    
    window.backgroundColor = UIColor.clearColor;
    UIViewController *rootVC = [[UIViewController alloc] init];
    rootVC.view.backgroundColor = UIColor.clearColor;
    window.rootViewController = rootVC;
    
    CMPNavigationController *nav = [[CMPNavigationController alloc] initWithRootViewController:vc];
    [window.rootViewController presentViewController:nav animated:YES completion:nil];
    vc.vcDissmissed = ^{
        window.hidden = YES;
        window.rootViewController = nil;
        [windowsArray_ removeObject:window];
    };
}

#pragma mark 显示投屏提示view
- (void)showScreenMirrorTipsView {
    UIWindow *window = [self initialiseWindow];
    if (!windowsArray_.count) return;
    
    CMPPopoverViewController *popoverVC = CMPPopoverViewController.alloc.init;
    CGFloat w = kScreenMirroringViewW;
    CGFloat h = kScreenMirroringViewH;
    CMPScreenMirrorTipsView *smtView = [CMPScreenMirrorTipsView viewWithFrame:CGRectMake(0, 0, w, h)];
    smtView.center = CGPointMake(CMP_SCREEN_WIDTH/2.f, CMP_SCREEN_HEIGHT/2.f);
    popoverVC.showingView = smtView;
    __weak typeof(self) weakSelf = self;
    smtView.checkClicked = ^{
        [NSNotificationCenter.defaultCenter postNotificationName:CMPCloseCurrentViewAfterScanFinishedNoti object:nil];
        [weakSelf hideWindowWithoutAnimationWithWindow:window];
        [CMPCommonTool handleCurrentSelectVC];
    };
    window.rootViewController = popoverVC;
    popoverVC.viewClicked = ^(BOOL hasAnimation) {
        if (hasAnimation) {
            //有动画时，动画消失window
            [weakSelf hideWindowWithAnimation];
        }else {
            //没有动画
            [weakSelf hideWindowWithoutAnimationWithWindow:window];
        }
        
    };
    
    [UIView animateWithDuration:CMPPopoverShowingViewTimeInterval animations:^{
        window.backgroundColor = [[UIColor cmp_colorWithName:@"mask-bgc"] colorWithAlphaComponent:0.5f];
    }];
}

#pragma mark 显示分享到外部的授权弹框
- (void)showShareToAppsAuthViewWithArgu:(NSDictionary *)argu ClickedResult:(void (^)(NSString *))clickedResult {
    UIWindow *window = [self initialiseWindow];
    if (!windowsArray_.count) return;
    
    CMPPopoverViewController *popoverVC = CMPPopoverViewController.alloc.init;
    CGFloat w = 300.f;
    CGFloat h = 150.f;
    CMPShareToAppsAuthView *view = [CMPShareToAppsAuthView.alloc initWithFrame:CGRectMake(0, 0, w, h)];
    view.center = CGPointMake(CMP_SCREEN_WIDTH/2.f, CMP_SCREEN_HEIGHT/2.f);
    NSString *btn1Title = nil;
    NSString *btn2Title = nil;
    NSString *showTitle = nil;
    if (argu) {
        NSArray *options = argu[@"options"];
        showTitle = argu[@"content"];
        if (options.count > 0) {
            btn1Title = options.firstObject[@"name"];
        }
        if (options.count > 1) {
            btn2Title = options[1][@"name"];
        }
    }
    view.showTitleString = showTitle;
    view.btn1Title = btn1Title;
    view.btn2Title =  btn2Title;
    popoverVC.showingView = view;
    __weak typeof(self) weakSelf = self;
    window.rootViewController = popoverVC;
    popoverVC.viewClicked = ^(BOOL hasAnimation) {
        if (clickedResult) {
            clickedResult(@"-1");
        }
        
        if (hasAnimation) {
            //有动画时，动画消失window
            [weakSelf hideWindowWithAnimation];
        }else {
            //没有动画
            [weakSelf hideWindowWithoutAnimationWithWindow:window];
        }
        
    };
    
    view.cofirmClickedClosure = ^(NSInteger result) {
        if (clickedResult) {
            clickedResult([NSString stringWithFormat:@"%ld",(long)result]);
        }
        [weakSelf hideWindowWithoutAnimationWithWindow:window];
    };
    
    [UIView animateWithDuration:CMPPopoverShowingViewTimeInterval animations:^{
        window.backgroundColor = [[UIColor cmp_colorWithName:@"mask-bgc"] colorWithAlphaComponent:0.5f];
    }];
    
}

#pragma mark 外部关闭弹框

- (void)hideViewWithAnimation:(BOOL)animation {
    if (animation) {
        [self hideWindowWithAnimation];
    }else {
        [self hideWindowWithoutAnimationWithWindow:windowsArray_.lastObject];
    }
}

#pragma mark - 分享相关
- (void)initShareSDK {
    /**
     *  设置ShareSDK的appKey，如果尚未在ShareSDK官网注册过App，请移步到http://mob.com/login 登录后台进行应用注册
     *  在将生成的AppKey传入到此方法中。
     *  方法中的第二个第三个参数为需要连接社交平台SDK时触发，
     *  在此事件中写入连接代码。第四个参数则为配置本地社交平台时触发，根据返回的平台类型来配置平台信息。
     *  如果你使用的时服务端托管平台信息时，第二、四项参数可以传入nil，第三项参数则根据服务端托管平台来决定要连接的社交SDK。
     */
    
    /*
     *账号：m1@seeyon.com
     *密码：Seeyon@159
     */
    
    [MobSDK uploadPrivacyPermissionStatus:YES onResult:^(BOOL success) {

    }];
    
    NSString *qqAppId = [CMPCustomManager matchValueFromOri:@"1105676961" andCus:[CMPCustomManager sharedInstance].cusModel.qqAppId];
    NSString *qqAppKey = [CMPCustomManager matchValueFromOri:@"8k86df8FtxPAia0O" andCus:[CMPCustomManager sharedInstance].cusModel.qqAppKey];
    NSString *qqUnilink = [CMPCustomManager matchValueFromOri:@"https://m3.seeyon.com/m3/jump/" andCus:[CMPCustomManager sharedInstance].cusModel.qqUniversalLink];
    
    NSString *wcAppId = [CMPCustomManager matchValueFromOri:@"wx69d33515b83bf2d9" andCus:[CMPCustomManager sharedInstance].cusModel.wcAppId];
    NSString *wcAppKey = [CMPCustomManager matchValueFromOri:@"79769f5029b36699075d2057199d0ac5" andCus:[CMPCustomManager sharedInstance].cusModel.wcAppKey];
    NSString *wcUnilink = [CMPCustomManager matchValueFromOri:@"https://m3.seeyon.com/m3/jump/" andCus:[CMPCustomManager sharedInstance].cusModel.wcUniversalLink];
    
    NSString *dingAppId = [CMPCustomManager matchValueFromOri:([CMPCommonManager isM3InHouse] ? @"dingoa60rtlsol9qbhbian" : @"dingoa3args05ss9frnvg1") andCus:[CMPCustomManager sharedInstance].cusModel.dingAppId];
    
    [ShareSDK registPlatforms:^(SSDKRegister *platformsRegister) {
        //QQ
        [platformsRegister setupQQWithAppId:qqAppId appkey:qqAppKey enableUniversalLink:YES universalLink:qqUnilink];
        //微信
        [platformsRegister setupWeChatWithAppId:wcAppId appSecret:wcAppKey universalLink:wcUnilink];
        //钉钉
        // 299:dingoa60rtlsol9qbhbian
        // 99:dingoa3args05ss9frnvg1
        [platformsRegister setupDingTalkWithAppId:dingAppId];
    }];
    
    [WXApi registerApp:wcAppId universalLink:wcUnilink];
    
    //注册tencentOAuth前需要先同意协议
    if (![TencentOAuth isUserAgreedAuthorization]) {
        [TencentOAuth setIsUserAgreedAuthorization:YES];
    }
    _to = [TencentOAuth.alloc initWithAppId:qqAppId andDelegate:self];
    
    [DTOpenAPI registerApp:dingAppId];
    
}

/// 筛选分享入口
/// @param appId 分享过来的appid
/// @param keys 要进行筛选的入口数组
+ (NSArray *)filterShareTypeWithAppId:(NSString *)appId keys:(NSArray *)keys {
    //appId用于请求后台权限操作
    NSMutableArray *resultArr = NSMutableArray.array;
    NSDictionary *authDic = [CMPShareManager.sharedManager.shareAuthData[appId] copy];
    
    //FIXME: 还有请求后台权限操作
    for (id keyObj in keys) {
        if ([keyObj isKindOfClass:NSDictionary.class])
        {//这里是从CMPShare方法过来的
            NSDictionary *keyDic = keyObj;
            NSString *key = keyDic[@"key"];
            if ([self p_filterShareTypeWithKey:key authDic:authDic resultArr:resultArr obj:keyDic]) continue;
            
        }
        else if ([keyObj isKindOfClass: NSString.class])
        {//这个是从getPermissionedShareKey方法过来的
            NSString *key = keyObj;
            if ([self p_filterShareTypeWithKey:key authDic:authDic resultArr:resultArr obj:key]) continue;
        }
    }
    return resultArr.copy;
}

+ (BOOL)p_filterShareTypeWithKey:(NSString *)key authDic:(NSDictionary *)authDic resultArr:(NSMutableArray *)resultArr obj:(id)obj {
    if ([kFilterTypeNames containsString:key]) {
        if (!authDic || [authDic[key] isEqualToString:@"false"]) return YES;
        
        if ([key isEqualToString:@"qq"]) {
            if (QQApiInterface.isQQInstalled) [resultArr addObject:obj];
        }else if ([key isEqualToString:@"uc"]) {
            if (CMPMessageManager.sharedManager.hasZhiXinPermissionAndServerAvailable) [resultArr addObject:obj];
        }else if ([key isEqualToString:@"wechat"] || [key isEqualToString:@"wechatMoments"]) {
            if (CMPCommonTool.isInstalledWechat) [resultArr addObject:obj];
        }else if ([key isEqualToString:@"other"]) {
            [resultArr addObject:obj];
        }
    }
    else if ([key isEqualToString:@"print"]) {
        if ([CMPFeatureSupportControl isSupportPrint]) {
            [resultArr addObject:obj];
        }
    }
    else if ([key isEqualToString:CMPShareComponentCollectString]) {
        if ([CMPFeatureSupportControl isSupportCollect]) {
            [resultArr addObject:obj];
        }
    }
    else {
        [resultArr addObject:obj];
    }
    return NO;
}

#pragma mark 分享东西到其他，包括qq、微信、钉钉、企业微信

/// 分享到QQ 只支持图片分享到QQ
/// @param filePath 文件路径
- (void)shareToQQWithFilePath:(NSString *)filePath {
    
    //    NSData *imgData = UIImageJPEGRepresentation([UIImage imageNamed:@"screen_mirroring_icon"], 1);
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSString *tiltle = filePath.lastPathComponent;
    
    NSString *fileType = filePath.pathExtension;
    NSString *mineType = [CMPFileTypeHandler mineTypeWithPathExtension:fileType];
    CMPFileMineType fileMineType = [CMPFileTypeHandler fileMineTypeWithMineType:mineType];
    
    QQApiObject *fileObj = nil;
    if (fileMineType == CMPFileMineTypeImage) {
        //预览图,描述无效
        fileObj = [QQApiImageObject objectWithData:fileData previewImageData:nil title:tiltle description:@"M3分享图片到QQ"];
    } else  {
        [MBProgressHUD cmp_showHUDWithText:SY_STRING(@"common_send_fail")];
        return;
    }
    
    //    NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
    //    NSURL *preimageUrl = [NSURL URLWithString:@"http://www.sizzee.com/index.php/catalog/product/view/id/55730/s/10196171/?SID=au0lhpg54f11nenmrjvhsh0rq6?uk=Y3VzdG9tZXJfaWQ9Mjc0fHByb2R1Y3RfaWQ9NTU3MzA"];
    //    QQApiNewsObject *img = [QQApiNewsObject objectWithURL:url title:@"测试分享" description:[NSString stringWithFormat:@"分享内容------新闻URL对象分享 ------test"] previewImageURL:preimageUrl];
    SendMessageToQQReq *qqReq = [SendMessageToQQReq reqWithContent:fileObj];
    QQApiSendResultCode resultCode = [QQApiInterface sendReq:qqReq];
    if (EQQAPISENDSUCESS == resultCode) {
        //发送成功
        [MBProgressHUD cmp_showHUDWithText:SY_STRING(@"common_send_success")];
    }else {
        //发送失败
        [MBProgressHUD cmp_showHUDWithText:SY_STRING(@"common_send_fail")];
    }
}

/// 分享到微信
/// @param filePath 文件路径
- (void)shareToWechatWithFilePath:(NSString *)filePath {
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:filePath]){
        [MBProgressHUD cmp_showHUDWithText:SY_STRING(@"common_send_fail")];
        return;
    }
    long long fileSize = [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    if (fileSize > 1024*1024 *10) {
        [MBProgressHUD cmp_showHUDWithText:SY_STRING(@"share_wechat_limit_10M")];
        return;
    }
    
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    WXFileObject *fileObj = WXFileObject.object;
    fileObj.fileData = fileData;
    fileObj.fileExtension = [filePath.lastPathComponent componentsSeparatedByString:@"."].lastObject;
    WXMediaMessage *mediaMsg = WXMediaMessage.message;
    mediaMsg.mediaObject = fileObj;
    mediaMsg.title = filePath.lastPathComponent;
    mediaMsg.description = @"M3分享文件到微信";
    
    SendMessageToWXReq *wxReq = SendMessageToWXReq.alloc.init;
    wxReq.message = mediaMsg;
    wxReq.bText = NO;
    wxReq.scene = WXSceneSession;
    [WXApi sendReq:wxReq completion:^(BOOL success) {
        if (success) {
            //发送成功
            [MBProgressHUD cmp_showHUDWithText:SY_STRING(@"common_send_success")];
        }else {
            //发送失败
            [MBProgressHUD cmp_showHUDWithText:SY_STRING(@"common_send_fail")];
        }
    }];
}

/// 分享到致信
/// @param filePath 文件路径
- (void)shareToUcWithFilePaths:(NSArray *)filePaths commandDelegate:(nullable id<CDVCommandDelegate>)commandDelegate callbackId:(nullable NSString *)callbackId showVc:(UIViewController *)showVc {
    
    [CMPShareToUcManager.manager showSelectContactViewWithFilePaths:filePaths inVC:showVc willForwardMsg:nil forwardSucess:nil forwardSucessWithMsgObj:^(CMPMessageObject * _Nonnull msgObj, NSArray * _Nonnull fileList) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD cmp_hideProgressHUD];
            UIViewController *vc =  showVc.navigationController.topViewController;
            if ([vc isKindOfClass:[CMPSelectContactViewController class]] == NO) {
               [showVc dismissViewControllerAnimated:NO completion:^{
                  [CMPMessageManager.sharedManager showChatViewAfterShare:msgObj vc:nil filePaths:fileList];
               }];
            } else {
               [showVc.navigationController popViewControllerAnimated:NO];
               [CMPMessageManager.sharedManager showChatViewAfterShare:msgObj vc:showVc filePaths:fileList];
            }

            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [commandDelegate sendPluginResult:result callbackId:callbackId];
            
        });
    } forwardFailed:^{
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [commandDelegate sendPluginResult:result callbackId:callbackId];
    }];
}

/// 用系统分享打开
/// @param filePath 文件路径
- (void)shareToOtherWithFilePath:(NSString *)filePath showVc:(UIViewController *)showVc {
    if (filePath) {
        self.showVc = showVc;
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSURL *file_URL = [NSURL fileURLWithPath:filePath];
        if ([fileManager fileExistsAtPath:filePath]) {
            if (!_fileInteractionController) {
                _fileInteractionController = [UIDocumentInteractionController interactionControllerWithURL:file_URL];
            }else {
                _fileInteractionController.URL = file_URL;
            }
            _fileInteractionController.delegate = self;
            [_fileInteractionController presentOptionsMenuFromRect:CGRectMake(0, 0, 0, 0) inView:showVc.view animated:YES];
            [self beginShowInThirdApp];
        }
    }
}


/// 分享到企业微信
/// @param filePath 文件路径
- (void)shareToWWechatWithFilePath:(NSString *)filePath {
    
}

/// 分享到钉钉
/// @param filePath 文件路径
- (void)shareToDingtalkWithFilePath:(NSString *)filePath {
    
}

/// 弹出无线投屏提示框
- (void)shareToOpenScreenMirroring {
    [self showScreenMirrorTipsView];
}

/// 下载文件
/// @param filePath 文件路径
- (void)shareToDownloadWithFilePath:(NSString *)filePath from:(NSString *)from fromType:(CMPFileFromType)fromType fileId:(NSString *)fileId origin:(nullable NSString *)origin {
    NSInteger attType = [CMPFileManager getFileType:filePath];
    if (attType == QK_AttchmentType_Image) {
        //是图片就保存到相册
        UIImage *img = [UIImage imageWithContentsOfFile:filePath];
        NSData *imageData = [NSData dataWithContentsOfFile:filePath];
        [CMPCommonTool.sharedTool saveImageToLocalWithImage:img imageData:imageData imgName:filePath.lastPathComponent from:from fromType:fromType fileId:fileId isShowSavedTips:YES];
        [CMPCommonTool.sharedTool savePhotoWithImage:img target:self action:@selector(image:didFinishSavingWithError:contextInfo:)];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //        [CMPFileManager.defaultManager saveFile:filePath isImage:NO from:from fileId:fileId origin:fileId imgName:nil];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [MBProgressHUD cmp_showProgressHUD];
        });
        CMPFile *aFile = [[CMPFile alloc] init];
        aFile.filePath = filePath;
        aFile.fileID = fileId;
        aFile.fileName = filePath.lastPathComponent;
        aFile.from = from;
        aFile.fromType = fromType;
        aFile.origin = fileId;
        [CMPFileManager.defaultManager saveFile:aFile];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [MBProgressHUD cmp_showHUDWithText:SY_STRING(@"common_save_success")];
        });
    });
    
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
}

/// 打印
/// @param filePath 文件路径
/// @param webview webview
- (void)shareToPrintFileWithPath:(NSString *)filePath webview:(UIView *)webview {
    if (!_printTool) {
        _printTool = [[CMPPrintTools alloc] init];
    }
    
    long long fileSize = [CMPFileManager fileSizeAtPath:filePath];
    long long maxFileSize = 15 * 1024 * 1024;
    if (fileSize > maxFileSize) {
        [MBProgressHUD cmp_showHUDWithText:SY_STRING(@"print_more_than_size")];
        return;
    }
    
    [self.printTool printWithFilePath:filePath webview:webview success:^{
        
    } fail:^(NSError *error) {
        
    }];
}

/// 收藏文件
/// @param filePath 文件路径
/// @param fileId 文件id
- (void)shareToCollectWithFilePath:(NSString *)filePath fileId:(NSString *)fileId isUc:(BOOL)isUc {
    if (!fileId.justContainsNumber) {
        //这样的是需要进行上传的
        [CMPUploadFileTool.sharedTool requestToUploadFileWithFilePath:filePath startBlock:^{
            [MBProgressHUD cmp_showProgressHUD];
        } successBlock:^(NSString * _Nonnull fileId) {
            [CMPCommonDataProviderTool.sharedTool requestToCollectWithSourceId:fileId isUc:isUc filePath:nil];
        } failedBlock:nil];
        
    }else {
        [CMPCommonDataProviderTool.sharedTool requestToCollectWithSourceId:fileId isUc:isUc filePath:filePath];
    }
}

#pragma mark - 外部分享相关

/// 处理外部分享至M3的文件和图片
/// @param path 文件\图片 路径
+ (void)handleThirdAppForwardingWithPaths:(NSString *)paths {
    if (!paths.length) {
        return;
    }

    NSArray *filePaths = [paths componentsSeparatedByString:@"file://"];
    if (!filePaths) {
        filePaths = @[paths];//单个视频或文档、图片
    }
    
    NSMutableArray *newPaths = NSMutableArray.array;
    for (NSString *path in filePaths) {
        if ([NSString isNull:path]) {
            continue;
        }
        NSString *tmpPath = [@"file://" stringByAppendingString:path];
        NSURL *pathURL = [NSURL URLWithString:tmpPath];
        tmpPath = [tmpPath stringByRemovingPercentEncoding];//去除url%编码
        if (pathURL) {
            if ([pathURL startAccessingSecurityScopedResource]) {
                NSString *newPath = [self getNewPath:tmpPath];
                if (newPath.length) {
                    [newPaths addObject:newPath];
                }
                [pathURL stopAccessingSecurityScopedResource];
            }else {
                NSData *data = [NSData dataWithContentsOfURL:pathURL];
                if (data) {
                    NSString *newPath = [self copyData:data withPath:tmpPath];
                    if (newPath.length) {
                        [newPaths addObject:newPath];
                    }
                }
            }
        }
    }
    
    [self showFileViewWithPathArr:newPaths];
}

//直接处理application:openURL传回的url，自己封装的获取不到data
+ (void)handleThirdAppForwardingWithOriginUrl:(NSURL *)url {
    BOOL canAccess = [url startAccessingSecurityScopedResource];//请求获取文件权限
    if (canAccess) {
        NSError *err;
        NSString *tempPath = [CMPFileManager fileTempPath];
        NSString *pathExtension = url.lastPathComponent;
        pathExtension = [pathExtension stringByRemovingPercentEncoding];//去除url%编码
        tempPath = [tempPath stringByAppendingPathComponent:pathExtension];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        if ([fileMgr fileExistsAtPath:tempPath]) {
            [fileMgr removeItemAtPath:tempPath error:&err];
        }
        NSURL *newURL = [NSURL fileURLWithPath:tempPath];
        BOOL success = [NSFileManager.defaultManager copyItemAtURL:url toURL:newURL error:&err];
        [url stopAccessingSecurityScopedResource]; //结束权限请求
        
        if (success && tempPath.length) {
            [self showFileViewWithPathArr:@[tempPath]];
            return;
        }
    }else {
        [self handleThirdAppForwardingWithPaths:url.relativeString];
    }
}


+(void)showFileViewWithPathArr:(NSArray *)newPaths{
    if (newPaths.count > 0) {
        if (M3LoginManager.sharedInstance.isLogin) {
            //如果在登录后的界面，就进行文件分享操作
            [CMPShareManager.sharedManager showShareToInnerViewWithFilePaths:newPaths fromVC:[CMPCommonTool getCurrentShowViewController]];
        }
        else {
            //如果不在登录界面，就讲分享过来的数据保存到本地，登录成功后再取
            CMPCore.sharedInstance.hasSavedFileFromOtherApps = YES;
            NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
            if (![userDefaults objectForKey:CMPSavedFileFromOtherAppsKey]) {
                [userDefaults setObject:nil forKey:CMPSavedFileFromOtherAppsKey];
            }
            
            NSMutableDictionary *dic = NSMutableDictionary.dictionary;
            dic[@"path"] = newPaths;
            [userDefaults setObject:dic forKey:CMPSavedFileFromOtherAppsKey];
            [userDefaults synchronize];
        }
    }
}

+ (NSString *)getNewPath:(NSString *)path {
    path = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
//    NSString *destPath = [FCFileManager moveFileToTempWithPath:path];
    NSString *destPath = [FCFileManager copyFileToTempWithPath:path];
    return destPath;
}

+ (NSString *)copyData:(NSData *)data withPath:(NSString *)path {
    NSString *tempPath = [CMPFileManager fileTempPath];
    NSString *pathExtension = path.lastPathComponent;
    tempPath = [tempPath stringByAppendingPathComponent:pathExtension];
    BOOL success = [data writeToFile:tempPath atomically:YES];
    return success?tempPath:nil;
}

#pragma mark 打开系统分享

- (void)beginShowInThirdApp {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_ThirdAppMenuWillShow object:nil];
}

- (void)endShowInThirdApp {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_ThirdAppMenuWillHide object:nil];
}

#pragma mark UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    return self.showVc;
}

- (void)documentInteractionControllerDidDismissOptionsMenu:(UIDocumentInteractionController *)controller
{
    [self endShowInThirdApp];
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    [self endShowInThirdApp];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(nullable NSString *)application{
    
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(nullable NSString *)application
{
    
}

#pragma mark - 数据请求

/// 获取分享权限数据
- (void)requestShareAuthData{
    if (!CMPCore.sharedInstance.serverIsLaterV8_0) return;
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPath:CMPGetShareAuth];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"GET";
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.httpShouldHandleCookies = NO;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider
                      request:(CMPDataRequest *)aRequest
                     response:(CMPDataResponse *)aResponse {
    NSDictionary *strDic = [aResponse.responseStr JSONValue];
    if (strDic) {
        NSLog(@"zl-------获取分享权限数据成功");
        self.shareAuthData = strDic.copy;
    } else {
        NSLog(@"zl------获取分享权限数据失败");
    }
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    NSLog(@"zl-----获取分享权限数据失败");
    
}

@end
