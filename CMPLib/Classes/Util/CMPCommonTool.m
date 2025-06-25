//
//  CMPCommonTool.m
//  CMPLib
//
//  Created by MacBook on 2019/10/10.
//  Copyright © 2019 crmo. All rights reserved.
//  这个类用于实现项目中很多地方都会用到的方法

#import "CMPCommonTool.h"
#import "CMPStringConst.h"
#import "CMPAVPlayerViewController.h"

#import <CommonCrypto/CommonCrypto.h>
#import <CMPLib/CMPSplitViewController.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPStringConst.h>
#import <CMPLib/CMPCore.h>
#import <CMPLib/RDVTabBarController.h>
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPBannerWebViewController+Create.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/AFNetworking.h>
#import <CMPLib/NSURL+CMPURL.h>
#import <CMPLib/FCFileManager.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CMPLib/CMPNavigationController.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/YBImage.h>
#import <CMPLib/YBImageBrowserTipView.h>
#import <Photos/Photos.h>
#import <CMPLib/NSString+CMPString.h>

static id instance_ = nil;
static CGFloat const unit = 1024.f;

@interface CMPCommonTool()<NSCopying>

@end

@implementation CMPCommonTool

#pragma mark - 单例实现

+ (instancetype)sharedTool {
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

#pragma mark - 外部方法

/// 是否安装微信
+ (BOOL)isInstalledWechat {
    BOOL installed = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"wechat://"]];
    return installed;
}

/// 解决iOS13取不到searchField的问题
+ (UITextField *)getSearchFieldWithSearchBar:(UISearchBar *)searchBar {
    UITextField *tf = nil;
    if (@available(iOS 13.0, *)) {
        tf = [searchBar performSelector:@selector(searchTextField)];
    }else {
         tf = [searchBar valueForKeyPath:@"_searchField"];
    }
    return tf;
}

/// 解决iOS13取不到cancelButton的问题
+ (UIButton *)getCancelButtonWithSearchBar:(UISearchBar *)searchBar {
    UIButton *bt = nil;
    if (@available(iOS 13.0, *)) {
        //这里不能用网上一些人说的直接取去掉下划线的方法去获取，否则绝大部分时候获取到的都是个空值
        for(id subView1 in [searchBar subviews]) {
            for (id subView2 in [subView1 subviews]) {
                for (id subView3 in [subView2 subviews]) {
                    if([subView3 isKindOfClass:[UIButton class]]){
                        UIButton *cancelButton = (UIButton *)subView3;
                        bt = cancelButton;
                    }
                    
                }
            }
            
        }
    }else {
         bt = [searchBar valueForKeyPath:@"_cancelButton"];
    }
    return bt;
}

#pragma mark UIImage和字符串互转

///图片转字符串
+ (NSString *)imageToMD5Str:(UIImage *)image {
    NSString *base64Str = [self imageToBase64Str:image];
    return [self MD5DigestWithString:base64Str];
}


/// 图片转字符串
+ (NSString *)imageToBase64Str:(UIImage *) image
{
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    return encodedImageStr;
}


+ (NSString *)MD5DigestWithString:(NSString *)string {

    //要进行UTF8的转码
    const char* input = string.UTF8String;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }

    return digest;
}

+(NSString *)trransFromMD532ToMD516:(NSString *)MD532{

    NSString  * string;

    for (int i=0; i<24; i++) {

        string=[MD532 substringWithRange:NSMakeRange(8, 16)];

    }

    return string;
}

+ (NSString *)imageToMD5StringWithImage:(UIImage *)image {
    unsigned char result[16];
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
    CC_MD5((__bridge const void *)(imageData), imageData.length, result);
    NSString *imageHash = [NSString stringWithFormat:
                                               @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                                               result[0], result[1], result[2], result[3],
                                               result[4], result[5], result[6], result[7],
                                               result[8], result[9], result[10], result[11],
                                               result[12], result[13], result[14], result[15]
                           ];
    return imageHash;
}

// 64base字符串转图片
+ (UIImage *)base64StringToImage:(NSString *)str {
    NSData *imageData =[[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *photo = [UIImage imageWithData:imageData ];
    return photo;

}


#pragma mark 时间转换毫秒

+ (long long)getCurrentTimeStamp {
    long long timeSp = [[NSNumber numberWithDouble:[NSDate.date timeIntervalSince1970]] longValue];
    timeSp *= 1000;
    return timeSp;
}

#pragma mark - ipad适配

+ (void)pushInDetailWithViewController:(UIViewController *)vc in:(UIViewController *)parentVc {
    if (CMP_IPAD_MODE &&
        [parentVc cmp_canPushInDetail]) {
        [parentVc cmp_clearDetailViewController];
        [parentVc cmp_showDetailViewController:vc];
    } else {
        if (parentVc.navigationController) {
            [parentVc.navigationController pushViewController:vc animated:YES];
        }else {
            CMPNavigationController *nav = [[CMPNavigationController alloc] initWithRootViewController:vc];
            [parentVc presentViewController:nav animated:YES completion:nil];
        }
        
    }
}

+ (void)pushInMasterWithViewController:(UIViewController *)vc in:(UIViewController *)parentVc {
    if (CMP_IPAD_MODE) {
        [parentVc cmp_clearDetailViewController];
        [parentVc cmp_pushPageInMasterView:vc navigation:parentVc.navigationController];
    } else {
        [parentVc.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark 获取当前显示的VC

+ (void)handleCurrentSelectVC {
    
    if ([self shortCutViewAvoidMultiTapping]) {
        UIViewController *currentVc = [self getCurrentShowViewController];
        [currentVc.navigationController popViewControllerAnimated:NO];
    }
    
    UIApplication *app = UIApplication.sharedApplication;
    UIViewController *rootVC = app.keyWindow.rootViewController;
    if ([rootVC isKindOfClass: [RDVTabBarController class]]) {
        RDVTabBarController *tmpVC = (RDVTabBarController *)rootVC;
        UIViewController *vc = tmpVC.selectedViewController;
        CMPBannerWebViewController *webVC = [CMPBannerWebViewController bannerWebViewWithUrl:CMPScreenMirroringUrl params:NSDictionary.dictionary];
        
        if ([vc isKindOfClass: UINavigationController.class]) {
            UINavigationController *tmpNav = (UINavigationController *)vc;
            [CMPCommonTool pushInDetailWithViewController:webVC in:tmpNav.childViewControllers.firstObject];
        }else {
            CMPSplitViewController *tmpVc = (CMPSplitViewController *)vc;
            [tmpVC cmp_pushPageInMasterView:webVC navigation:(UINavigationController *)tmpVc.detailNavigation];
        }
    }
}

+ (BOOL)shortCutViewAvoidMultiTapping {
    //检验，防止多次进入此页面
    if (CMP_IPAD_MODE) {
        NSString *requestUrl = [CMPCommonTool getCurrentShowingVCRequestUrlString];
        NSArray *urls = [CMPShortCutVeriUrls componentsSeparatedByString:@","];
        for (NSString *str in urls) {
            if ([NSString isNotNull:str] && [requestUrl containsString:str]) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark 保存图片

/// 保存图片到本地
/// @param image 图片
/// @param imgName 图片名
/// @param fromSring 图片来源
- (void)saveImageToLocalWithImage:(UIImage *)image imageData:(NSData *)imageData imgName:(NSString *)imgName from:(NSString *)fromSring fromType:(CMPFileFromType)fromType fileId:(nullable NSString *)fileId isShowSavedTips:(BOOL)isShowSavedTips {
    if (!image) return;
    
    //异步子线程执行，这样可以防止存储时界面卡住的现象
    dispatch_queue_t queue = dispatch_queue_create("photoSaveQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        if (isShowSavedTips) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                
            });
        }
        
//        NSString *path = NSHomeDirectory();
        NSString *imgString = imgName;
        NSString *from = fromSring;
        NSString *fromTypeString = fromType;
        
        if ([NSString isNull:fromSring]) {
            from = @"";
        }
        
        if ([NSString isNull:fromTypeString]) {
            fromTypeString = @"";
        }
        
        NSString *imgPath = nil;
        YYImageType imgType = YYImageTypeUnknown;
        NSString *pathExtension = @".png";
        if ([image isKindOfClass:YBImage.class]) {
            YBImage *tmpImg = (YBImage *)image;
            imgType = tmpImg.animatedImageType;
        }
        if ([image respondsToSelector:@selector(animatedImageData)] && imgType == YYImageTypeGIF) {
            pathExtension = @".gif";
            if ([NSString isNull:imgString]) {
                imgString = [fileId stringByAppendingString:pathExtension];
            }
            if ([NSString isNull:imgString.pathExtension]) {
                imgString = [fileId stringByAppendingString:pathExtension];
            }
            imgPath = [CMPFileManager downloadFileTempPathWithFileName:imgString];
//            NSData *gifData = [image performSelector:@selector(animatedImageData)];
            [imageData writeToFile:imgPath atomically:YES];
            
        }else {
            if ([NSString isNull:imgString]) {
                imgString = [fileId stringByAppendingString:pathExtension];
            }
            if ([NSString isNull:imgString.pathExtension]) {
                imgString = [fileId stringByAppendingString:pathExtension];
            }
            imgPath = [CMPFileManager downloadFileTempPathWithFileName:imgString];
            [imageData writeToFile:imgPath atomically:YES];
        }
        
        CMPFile *aFile = [[CMPFile alloc] init];
        aFile.filePath = imgPath;
        aFile.fileID = fileId;
        aFile.fileName = imgString;
        aFile.from = from;
        aFile.fromType = fromTypeString;
        aFile.origin = fileId;
        [CMPFileManager.defaultManager saveFile:aFile];
        
//        if ([imgName containsSpecialCharacters]) {
//            [CMPFileManager.defaultManager saveFile:imgPath isImage:YES from:from fileId:fileId origin:fileId imgName:imgName];
//        }else {
//            [CMPFileManager.defaultManager saveFile:imgPath isImage:YES from:from fileId:fileId origin:fileId imgName:imgString];
//        }
        
        if (isShowSavedTips) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication].keyWindow yb_showHookTipView:SY_STRING(@"review_image_saveToPhotoAlbumSuccess")];
            });
        }
        
        
    });
    
    
}

- (NSString *)handleImageString:(NSString *)imgString {
    if ([imgString containsSpecialCharacters]) {
        NSString *tmpExtension = [@"." stringByAppendingString:imgString.pathExtension];
        imgString = [imgString stringByReplacingOccurrencesOfString:tmpExtension withString:@""];
        imgString = [imgString.sha1 stringByAppendingString:tmpExtension];
    }
    return imgString;
}

/// 保存图片到相册，如果target有值的话，就会将存储后的回调处理交给action参数传过来的响应方法
/// @param image 图片
/// @param target 接收存储后的回调方法的接收者
/// @param action 接收回调的响应方法
- (void)savePhotoWithImage:(UIImage *)image target:(nullable id)target action:(nullable SEL)action {
    id t = self;
    SEL act = @selector(image:didFinishSavingWithError:contextInfo:);
    if (target) {
        t = target;
        act = action;
    }
    UIImageWriteToSavedPhotosAlbum(image, t, act, nil);
}
//保存图片到相册，包括gif
- (void)savePhotoToLocalWithImagePath:(NSString *)aPath completionHandler:(nullable void(^)(BOOL success, NSError * error))completionHandler {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto fileURL:[NSURL URLWithPathString:aPath] options:nil];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (completionHandler) {
            completionHandler(success,error);
        }
    }];
}


#pragma mark 默认保存到相册后的回调方法，当上面那个方法的target为空的时候调用默认的这个回调方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error != NULL) {
        //失败
        UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:nil
                                       message:NSLocalizedStringFromTable(@"SavePhotoFailed", @"RongCloudKit", nil)
                                      delegate:nil
                             cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)
                             otherButtonTitles:nil];
        [alert show];
    } else {
        //成功
        UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:nil
                                       message:NSLocalizedStringFromTable(@"SavePhotoSuccess", @"RongCloudKit", nil)
                                      delegate:nil
                             cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)
                             otherButtonTitles:nil];
        [alert show];
    }
}


/// json转字典
/// @param jsonString json字符串
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


/// 字典转json字符串
/// @param dict 字典
+ (NSString *)convertToJsonData:(NSDictionary *)dict

{

    NSError *error;

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];

    NSString *jsonString;

    if (!jsonData) {

        NSLog(@"%@",error);

    }else{

        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];

    }

    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];

    NSRange range = {0,jsonString.length};

    //去掉字符串中的空格

    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];

    NSRange range2 = {0,mutStr.length};

    //去掉字符串中的换行符

    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];

    return mutStr;
    
}

+ (void)sendPluginCallbackErrorMsgWithCallbackId:(NSString *)callbackId commandDelegate:(id<CDVCommandDelegate>)commandDelegate {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"params is null"];
    [commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

/// 获取当前显示vc的requestUrl
+ (NSString *)getCurrentShowingVCRequestUrlString {
    NSString *url = nil;
    UIViewController *frontVc = [self getCurrentShowViewController];
    if ([frontVc isKindOfClass: CDVViewController.class]) {
        if ([frontVc isKindOfClass: CMPBannerWebViewController.class]) {
            CMPBannerWebViewController *tmpVC = (CMPBannerWebViewController *)frontVc;
            WKWebView *tmpWebview = (WKWebView *)tmpVC.webView;
            url = tmpWebview.URL.absoluteString;
        }else {
            CDVViewController *tmpVC = (CDVViewController *)frontVc;
            if ([tmpVC.webView isKindOfClass: WKWebView.class]) {
                WKWebView *tmpWebview = (WKWebView *)tmpVC.webView;
                url = tmpWebview.URL.absoluteString;
            }
        }
        
    }
    return url;
}

/// 获取当前显示vc的title
+ (NSString *)getCurrentShowingVCTitle {
    NSString *title = nil;
    UIViewController *frontVc = [self getCurrentShowViewController];
    if ([frontVc respondsToSelector:@selector(currentPageScreenshotControlTitle)]) {
        title = [(id)frontVc currentPageScreenshotControlTitle];
    }
    
    if ([NSString isNull:title]) {
        title = NSStringFromClass(frontVc.class);
    }
    
    return title;
}

/** 查找当前显示的ViewController */
+ (UIViewController *)getCurrentShowViewController {
    UIViewController *rootVC = UIApplication.sharedApplication.keyWindow.rootViewController;
    UIViewController *currentShowVC = [self recursiveFindCurrentShowViewControllerFromViewController:rootVC];
    return currentShowVC;

}
/** 递归查找当前显示的VC */
+ (UIViewController *)recursiveFindCurrentShowViewControllerFromViewController:(UIViewController *)fromVC {
    if ([fromVC isKindOfClass:[UINavigationController class]]) {
        return [self recursiveFindCurrentShowViewControllerFromViewController:[((UINavigationController *)fromVC) visibleViewController]];

    } else if ([fromVC isKindOfClass:[RDVTabBarController class]]) {
        
        return [self recursiveFindCurrentShowViewControllerFromViewController:[((RDVTabBarController *)fromVC) selectedViewController]];
    } else if ([fromVC isKindOfClass:[CMPSplitViewController class]]) {
        CMPSplitViewController *splitVc = (CMPSplitViewController *)fromVC;
//        return [self recursiveFindCurrentShowViewControllerFromViewController:(UIViewController *)splitVc.detailNavigation];
        if (splitVc.presentedViewController) {
            return [self recursiveFindCurrentShowViewControllerFromViewController:splitVc.presentedViewController];
        }
        return splitVc;
    } else {
        if (fromVC.presentedViewController) {
            return [self recursiveFindCurrentShowViewControllerFromViewController:fromVC.presentedViewController];
        } else {
            
            return fromVC;
        }

    }

}

+ (UIView *)getSubViewWithClassName:(NSString *)className inView:(UIView *)inView {
    if (!inView || !inView.subviews.count || !className.length) return nil;
    
    UIView *foundView = nil;
    for (UIView *view in inView.subviews) {
        if ([view isKindOfClass:NSClassFromString(className)]) {
            foundView = view;
            break;
        }
        
        foundView = [self getSubViewWithClassName:className inView:view];
        if (foundView) break;
    }
    return foundView;
}

+ (UIViewController *)getSubViewControllerWithClassName:(NSString *)className inVC:(UIViewController *)inVC {
    if (!inVC || !inVC.childViewControllers.count || !className.length) return nil;
    
    UIViewController *foundVc = nil;
    for (UIViewController *vc in inVC.childViewControllers) {
        if ([vc isKindOfClass:NSClassFromString(className)]) {
            foundVc = vc;
            break;
        }
        
        foundVc = [self getSubViewControllerWithClassName:className inVC:vc];
        if (foundVc) break;
    }
    return foundVc;
}

+ (NSData *)gifData
{

    ALAssetRepresentation *re = [ALAsset.new representationForUTI:(__bridge NSString *)kUTTypeGIF];;
    long long size = re.size;
    uint8_t *buffer = malloc(size);
    NSError *error;
    NSUInteger bytes = [re getBytes:buffer fromOffset:0 length:size error:&error];
    NSData *data = [NSData dataWithBytes:buffer length:bytes];
    free(buffer);
    return data;
}

#pragma mark - 视频相关
/// 获取视频文件宽高
/// @param url 视频的url
+ (CGSize)getVideoSizeWithUrl:(NSString *)url {
    if (!url.length) return CGSizeZero;
    
    AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithPathString:url]];
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
    CGSize videoSize = CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform);
    videoSize = CGSizeMake(fabs(videoSize.width), fabs(videoSize.height));
    return videoSize;
}

/// 获取视频文件的时长
/// @param url 视频url
+ (NSInteger)getVideoTimeByUrlString:(NSString *)url {
    if (!url.length) return 0;
    
    AVURLAsset * asset = [AVURLAsset assetWithURL:[NSURL URLWithPathString:url]];
    CMTime   time = [asset duration];
    NSInteger seconds = ceil(time.value/time.timescale);
    return seconds * 1000;
}

+ (UIImage *)getScreenShotImageFromVideoUrl:(NSString *)url size:(CGSize)size {
    UIImage *shotImage;
    //视频路径URL
    NSURL *fileURL = [NSURL URLWithPathString:url];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    gen.maximumSize = CGSizeMake(size.width, size.height);
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    shotImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    
    return shotImage;
    
}

/// 压缩视频
/// outputUrl 压缩后输出视频url，将会把压缩后的视频存储到这个url所在的路径
/// @param inputURL 压缩前视频url
/// @param handler 压缩成功回调。。如果需要失败回调，后续可增加
+ (void)convertVideoQuailtyWithInputURL:(NSURL*)inputURL
                        completeHandler:(void (^)(NSString *outputUrl))handler
{
    //用时间给文件全名，以免重复，在测试的时候其实可以判断文件是否存在若存在，则删除，重新生成文件即可
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];//存储到服务器的文件名中不能存在冒号
    NSString *outputURLString = [CMPFileManager.fileTempPath stringByAppendingString:[NSString stringWithFormat:@"/%@.mp4",[formater stringFromDate:NSDate.date]]];
    outputURLString = [@"file://" stringByAppendingString:outputURLString];
    NSURL *outputURL = [NSURL URLWithPathString:outputURLString];
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse= YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
    {
         switch (exportSession.status) {
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"AVAssetExportSessionStatusCancelled");
                 break;
             case AVAssetExportSessionStatusUnknown:
                 NSLog(@"AVAssetExportSessionStatusUnknown");
                 break;
             case AVAssetExportSessionStatusWaiting:
                 NSLog(@"AVAssetExportSessionStatusWaiting");
                 break;
             case AVAssetExportSessionStatusExporting:
                 NSLog(@"AVAssetExportSessionStatusExporting");
                 break;
             case AVAssetExportSessionStatusCompleted:
             {
                 NSLog(@"AVAssetExportSessionStatusCompleted");
                 dispatch_sync(dispatch_get_main_queue(), ^{
                     if (handler) {
                         handler(outputURL.absoluteString);
                     }
                 });
             }
                 
                 break;
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"AVAssetExportSessionStatusFailed");
                 break;
                 
         }
        
        if ([[NSFileManager defaultManager] removeItemAtPath:inputURL.path error:nil]) {
            NSLog(@"zl----删除压缩前视频文件成功-----");
        }else {
            NSLog(@"zl----删除压缩前视频文件失败-----");
        }
         
     }];
}

/// 获取fileId
/// @param url url
+ (NSString *)getSourceIdWithUrl:(NSString *)url {
    NSString *sourceId = url;
    NSRange range0 = [url rangeOfString:@"/-"];
    NSRange range1 = [url rangeOfString:@"?ucFlag"];
    if ([url containsString:@"http"]) {
        if (range0.length && range1.length) {
            sourceId = [url substringWithRange:NSMakeRange(range0.location + 1, range1.location - range0.location - 1)];
        }
    }
    
    if (!sourceId.length || [sourceId containsString:@"http"]) {
        NSArray *components = [url componentsSeparatedByString:@"/"];
        NSInteger count = components.count;
        for (NSInteger i = 0; i < count; i++) {
            NSString *c = components[i];
            if ([c isEqualToString:@"file"] && i < (count - 1)) {
                sourceId = components[i+1];
                break;
            }
        }
    }
    
    if (!sourceId.length || [sourceId containsString:@"http"]) {
        NSArray *components = [url componentsSeparatedByString:@"="];
        NSInteger count = components.count;
        for (NSInteger i = 0; i < count; i++) {
            NSString *c = components[i];
            if (([c containsString:@"&id"]||[c containsString:@"?id"]) && i < (count - 1)) {
                sourceId = components[i+1];
//                sourceId = [sourceId stringByReplacingOccurrencesOfString:@"&" withString:@""];
                sourceId = [sourceId componentsSeparatedByString:@"&"].firstObject;
                //增加by raosj ||[c containsString:@"?id"] 判断和 [sourceId componentsSeparatedByString:@"&"].firstObject;其他逻辑不敢修改
                break;
            }
        }
    }
    
    if ([sourceId containsString:@"?ucFlag"]) {
        NSRange range = [sourceId rangeOfString:@"?ucFlag"];
        if (range.length) {
            sourceId = [sourceId substringToIndex:range.location];
        }
    }
    
    return sourceId;
}

/// 识别图中是否有二维码
/// @param image 图片
+ (BOOL)detectQRCodeWithImage:(UIImage *)image {
    
    // CIDetector(CIDetector可用于人脸识别)进行图片解析，从而使我们可以便捷的从相册中获取到二维码
    // 声明一个 CIDetector，并设定识别类型 CIDetectorTypeText
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    
    // 取得识别结果
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    
    if (features.count == 0) {
        CMPLog(@"暂未识别 - - %@", features);
        return NO;
    } else {
        return YES;
    }
}
/// 识别图中的二维码结果
/// @param image 图片
+ (NSArray<NSString *> *)scanQRCodeWithImage:(UIImage *)image {
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    //取得识别结果
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (features.count == 0) {
        return nil;
    }else{
        NSMutableArray *contentArr = [NSMutableArray new];
        for (CIQRCodeFeature *result in features) {
            if (result.messageString.length) {
                [contentArr addObject:result.messageString];
            }
        }
        return contentArr;
    }
}

+ (NSString *)fileSizeFormat:(long long )fileSize {
    if (fileSize < unit) {
        return [NSString stringWithFormat:@"%lldB",fileSize];
    }
    else if (fileSize < unit*unit){
        return [NSString stringWithFormat:@"%.1fKB",fileSize/unit];
    }
    else if (fileSize < unit*unit*unit){
        return [NSString stringWithFormat:@"%.1fMB",fileSize/unit/unit];
    }
    return @"0K";
}


+(NSMutableAttributedString *)searchResultAttributeStringInString:(NSString *)inString searchText:(NSString *)searchText
{
    if (!inString || inString.length == 0) return [[NSMutableAttributedString alloc] initWithString:@""];
    if (!searchText || searchText.length==0) return [[NSMutableAttributedString alloc] initWithString:inString];
    
    NSMutableSet *set = [NSMutableSet set];
    NSMutableArray *ranges = [NSMutableArray array];
    for (int i = 0; i <= searchText.length-1; i++) {
        NSString *s = [searchText substringWithRange:NSMakeRange(i, 1)];
        if (![set containsObject:s]) {
            [set addObject:s];
            [inString cmp_enumerateRangeOfString:s usingBlock:^(NSRange searchStringRange, NSUInteger idx, BOOL *stop) {
                [ranges addObject:@{@"loc":@(searchStringRange.location),@"len":@(searchStringRange.length)}];
            }];
        }
    }
    NSMutableAttributedString *attstr = [[NSMutableAttributedString alloc] initWithString:inString];
    for (NSDictionary *dic in ranges) {
        NSRange r = NSMakeRange(((NSNumber *)dic[@"loc"]).integerValue, ((NSNumber *)dic[@"len"]).integerValue);
        [attstr setAttributes:@{NSForegroundColorAttributeName:[UIColor cmp_colorWithName:@"theme-bdc"],NSBackgroundColorAttributeName:[[UIColor cmp_colorWithName:@"theme-bdc"] colorWithAlphaComponent:0.1]} range:r];
    }
    return attstr;
}

@end

#pragma mark - C/C++函数

/// 为了适配界面而重写的CGRectMake函数
/// @param x x
/// @param y y
/// @param width w
/// @param height h
CGRect CMPRectMake(CGFloat x, CGFloat y, CGFloat width, CGFloat height) {
    //宽度比例
    CGFloat widthRatio = UIScreen.mainScreen.bounds.size.width/375.f;
    //高度比例
    CGFloat heightRatio = UIScreen.mainScreen.bounds.size.height/667.f;
    
    return CGRectMake(x*widthRatio, y*heightRatio, width*widthRatio, height*heightRatio);
}

