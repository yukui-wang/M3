//
//  CMPSafeUtils.m
//  CMPLib
//
//  Created by youlin on 2017/9/12.
//  Copyright © 2017年 CMPCore. All rights reserved.
//

#import "CMPSafeUtils.h"
#import "AntiJailbreak.h"
#import "MachOParser.h"
#import "CMPAntiDebug.h"

#define kM3AppIDInHouse @"com.seeyon.m3.inhouse.dis"    // 企业版本App ID
#define kM3AppIDInAppStore @"com.seeyon.m3.appstore.new.phone" // App store版本 APP ID

/** M3的MD5值，每次打版需要修改 **/
NSString * const kM3Md5 = @"3bb84b618add775caad1e834193d0058";

@interface CMPSafeUtils()

@property (strong, nonatomic) UIVisualEffectView *effectView;
@property (strong, nonatomic) CMPAntiDebug *antiDebug;

@end

@implementation CMPSafeUtils

#pragma mark-
#pragma mark Init

+ (instancetype)sharedInstance {
    static CMPSafeUtils *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark-
#pragma mark API

- (void)startBackgroundBlur {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)observeScreenCapture:(CMPDidScreenCapture)block {
    if (@available(iOS 11.0, *)) {
        [[NSNotificationCenter defaultCenter] addObserverForName:UIScreenCapturedDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if ([UIScreen mainScreen].isCaptured && block) {
                block();
            }
        }];
    }
}

- (void)observeScreenShot:(CMPDidScreenShot)block {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationUserDidTakeScreenshotNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if (block) {
            block();
        }
    }];
}

+ (BOOL)isJailbreak {
    return isJailbreak();
}

+ (BOOL)checkHTTPEnable {
    CFDictionaryRef proxySettings = CFNetworkCopySystemProxySettings();
    NSDictionary *dictProxy = (__bridge id)proxySettings;
    return [[dictProxy objectForKey:@"HTTPEnable"] boolValue];
}

+ (BOOL)isScreenCapture {
    if (@available(iOS 11.0, *)) {
        UIScreen *screen = [UIScreen mainScreen];
        return screen.isCaptured;
    } else {
        return NO;
    }
}

+ (BOOL)checkBundleID {
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    if ([bundleID isEqualToString:kM3AppIDInHouse] ||
        [bundleID isEqualToString:kM3AppIDInAppStore]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)checkCodeMD5 {
    MachOParser parser = MachOParser();
    NSString *md5 = parser.get_text_data_md5();
    return [md5 isEqualToString:kM3Md5];
}

- (void)startAntiDebug {
    [self.antiDebug startAntiDebug];
}

#pragma mark-
#pragma mark Notification

- (void)handleDidEnterBackground:(NSNotification *)notification {
    [[UIApplication sharedApplication].keyWindow addSubview:self.effectView];
}

- (void)handleWillEnterForeground:(NSNotification *)notification {
    [self.effectView removeFromSuperview];
    self.effectView = nil;
}

#pragma mark-
#pragma mark Getter

- (UIVisualEffectView *)effectView {
    if (!_effectView) {
        _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        _effectView.frame = [UIScreen mainScreen].bounds;
    }
    return _effectView;
}

- (CMPAntiDebug *)antiDebug {
    if (!_antiDebug) {
        _antiDebug = [[CMPAntiDebug alloc] init];
    }
    return _antiDebug;
}


@end
