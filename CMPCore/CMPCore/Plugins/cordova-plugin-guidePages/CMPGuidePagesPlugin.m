//
//  CMPGuidePagesPlugin.m
//  CMPCore
//
//  Created by wujiansheng on 16/8/19.
//
//

#import "CMPGuidePagesPlugin.h"
#import "CMPGuidePagesView.h"
#import <CMPLib/CMPBannerWebViewController.h>
#import "CMPGuidePagesViewHelper.h"

#import "CMPGuideManager.h"

@interface CMPGuidePagesPlugin ()<CMPGuidePagesViewDelegate>
{
    CMPGuidePagesView *_guidePagesView;
    CMPGuidePagesViewHelper *_guidePagesViewHelper;
}
@property (nonatomic, copy)NSString *callbackId;

@end


@implementation CMPGuidePagesPlugin

- (void)dealloc{
    self.callbackId = nil;
    
    [_guidePagesViewHelper release];
    _guidePagesViewHelper = nil;
    
//    [_guidePagesView release];
//    _guidePagesView = nil;
    
    [super dealloc];
}

- (void)canShowGuidePage:(CDVInvokedUrlCommand*)command{
    BOOL common_shown = [CMPGuideManager commonGuidePageShown];
    if (common_shown && ![CMPGuideManager sharedInstance].showingCommonGuidePage) {//已经展示 && 不是正在显示
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }else{
        //等待【点击我知道了】通知
        __weak typeof(self) weakSelf = self;
        [CMPGuideManager sharedInstance].waitTapIknowButtonCompletion = ^{
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [weakSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        };
    }
    
}

- (void)showGuidePages:(CDVInvokedUrlCommand*)command{
    self.callbackId = command.callbackId;
    NSDictionary *paramDictionary = [command.arguments firstObject];
    NSArray *imagePathArray = [paramDictionary objectForKey:@"imagePaths"];
//    if (!_guidePagesView) {
//        _guidePagesView = [[CMPGuidePagesView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//        _guidePagesView.delegate = self;
//    }
//    [_guidePagesView fillImageByInfoArray:imagePathArray];
//    [_guidePagesView removeFromSuperview];
//    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
//    [window addSubview:_guidePagesView];
//    [window bringSubviewToFront:_guidePagesView];
    if (!_guidePagesViewHelper) {
        
        _guidePagesViewHelper = [[CMPGuidePagesViewHelper alloc] init];
        
    }
    [_guidePagesViewHelper showGuidePagesView:imagePathArray dismissComplete:nil];
    
    //
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

#pragma mark CMPGuidePagesViewDelegate
- (void)guidePagesView:(CMPGuidePagesView *)welcomeView buttonTag:(NSInteger)tag
{
    [UIView animateWithDuration:0.7 animations:^{
        _guidePagesView.alpha = 0.01;
        _guidePagesView.transform = CGAffineTransformMakeScale(3.0f, 3.0f);
    } completion:^(BOOL finished) {
        [_guidePagesView removeFromSuperview];
        [_guidePagesView release];
        _guidePagesView = nil;
        
        //tag = 1:立即体验   tag = 2:跳过
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:tag];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
        // 发通知当前引导页关闭
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_HideGuidePagesView object:nil];
    }];
}

@end
