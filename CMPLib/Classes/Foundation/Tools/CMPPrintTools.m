//
//  CMPPrintTools.m
//  CMPLib
//
//  Created by youlin on 2019/7/3.
//  Copyright © 2019年 crmo. All rights reserved.
//

#import "CMPPrintTools.h"
#import "CMPFileManager.h"
#import <WebKit/WebKit.h>

@interface CMPPrintTools ()<WKNavigationDelegate,UIPrintInteractionControllerDelegate>

@property (nonatomic,strong)WKWebView *printWebview;

@end

@implementation CMPPrintTools

- (void)printWithFilePath:(NSString *)aFilePath webview:(UIView *)aWebview success:(void(^)(void))success fail:(void(^)(NSError *error))fail
{
    QK_AttchmentType type = [CMPFileManager getFileType:aFilePath];
    if (type == QK_AttchmentType_Image ||
        type == QK_AttchmentType_Office_Pdf ||
        type == QK_AttchmentType_Gif) {
        aFilePath = [aFilePath replaceCharacter:@"file://" withString:@""];
        NSData *data = [NSData dataWithContentsOfFile:aFilePath];
        UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
        printController.printingItem = data;
        printController.delegate = self;////OA-210904 图片打印时x打印界面被遮挡了
        
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = (type == QK_AttchmentType_Image || type == QK_AttchmentType_Gif)?UIPrintInfoOutputPhoto:UIPrintInfoOutputGeneral;
        printController.printInfo = printInfo;
        
        [printController presentAnimated:YES completionHandler:nil];
    } else {
        if (aWebview) {
            [self printWithWebView:aWebview];
        }
        else {
            if (!_printWebview) {
                _printWebview = [[WKWebView alloc] init];
                _printWebview.navigationDelegate = self;
                _printWebview.frame = [UIScreen mainScreen].bounds;
            }
            NSURL *url = [NSURL fileURLWithPath:aFilePath];
            NSURL *accessURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] objectAtIndex:0];
            [self.printWebview loadFileURL:url allowingReadAccessToURL:accessURL];
        }
    }
}

- (void)printWithData:(NSData *)aData success:(void(^)(void))success fail:(void(^)(NSError *error))fail
{
    UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
    printController.printingItem = aData;
    [printController presentAnimated:YES completionHandler:nil];
}

- (void)printWithWebView:(UIView *)aWebView
{
    UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
    UIViewPrintFormatter *viewFormatter = [aWebView viewPrintFormatter];
    printController.printFormatter = viewFormatter;
    [printController presentAnimated:YES completionHandler:nil];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self printWithWebView:self.printWebview];
       });
}

#pragma mark UIPrintInteractionControllerDelegate
//OA-210904 【M3---我的文件】（png,jpg）图片点击 分享组件里的打印后，要点击一下屏幕，才显示打印页面
- ( UIViewController * _Nullable )printInteractionControllerParentViewController:(UIPrintInteractionController *)printInteractionController {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (keyWindow.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow *temp in windows) {
            if (temp.windowLevel == UIWindowLevelNormal) {
                keyWindow = temp;
                break;
            }
        }
        if (!keyWindow) {
            keyWindow = windows.lastObject;
        }
        
        UIPrintInfo *printInfo = printInteractionController.printInfo;
        QK_AttchmentType type = printInfo.outputType == UIPrintInfoOutputPhoto?QK_AttchmentType_Image:QK_AttchmentType_Office_Pdf;
        if (type == QK_AttchmentType_Image || type == QK_AttchmentType_Gif) {
            keyWindow = windows.lastObject;//分享这里的图片打印需要特殊处理
        }
    }

    UIViewController *vc = keyWindow.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = [(UINavigationController *)vc visibleViewController];
        } else if ([vc respondsToSelector:@selector(selectedViewController)]) {
            vc = [(UITabBarController *)vc selectedViewController];
        }
    }
    return vc;
}
@end
