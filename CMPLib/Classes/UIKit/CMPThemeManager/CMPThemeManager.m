//
//  CMPThemeManager.m
//  M3
//
//  Created by 程昆 on 2019/7/29.
//

#import "CMPThemeManager.h"
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/CMPFeatureSupportControlHeader.h>

NSString *_CMPThemeUserAgent = @"";

@interface UIWindow(CMPThemeManager)

@end

@implementation UIWindow(CMPThemeManager)

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    CMPThemeManager *themeManager = [CMPThemeManager sharedManager];
    if (![themeManager isSupportUserInterfaceStyleDark]) {
        return;
    }
    if (self != [UIApplication sharedApplication].delegate.window) {
        return;
    }
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        return;
    }
    if (![themeManager.currentThemeInterfaceStyle isEqualToString:CMPThemeInterfaceStyleFillowSystem]) {
        return;
    }
    
    if (@available(iOS 13.0, *)) {
        UIUserInterfaceStyle previousUserInterfaceStyle =  previousTraitCollection.userInterfaceStyle;
        UIUserInterfaceStyle currentUserInterfaceStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
        if (currentUserInterfaceStyle == previousUserInterfaceStyle) {
            return;
        }
    } else {
        return;
    }

    [themeManager setUserInterfaceStyle];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
     [[UIApplication sharedApplication].delegate performSelector:@selector(reloadApp)];
    #pragma clang diagnostic pop
}

@end

#pragma mark - Class UIColor(CMPThemeManager)

@implementation UIColor(CMPThemeManager)

+ (UIColor *)cmp_colorWithName:(NSString *)name {
    //无透明色
    if ([CMPThemeManager sharedManager].skinThemeColor
        && [@[@"theme-bdc",@"theme-fc",@"hl-fc1",@"theme-bgc"] containsObject:name]
        ) {
        return [CMPThemeManager sharedManager].skinThemeColor;
    }
    
    NSDictionary *colorInfoDic = [[CMPThemeManager sharedManager].themeColorInfoDic copy];
    NSDictionary *colorDic = colorInfoDic[name];
    NSString *value = colorDic[@"value"];
    double alpha = [colorDic[@"alpha"] doubleValue];
    
    //有透明色
    if ([CMPThemeManager sharedManager].skinThemeColor
        && [@[@"qk-bg-scan",@"cont-bgc"] containsObject:name]) {
        return [[CMPThemeManager sharedManager].skinThemeColor colorWithAlphaComponent:alpha];
    }
    
    UIColor *color = [UIColor colorWithHexString:value alpha:alpha];
    return color;
}

//指定无更改的颜色
+ (UIColor *)cmp_specColorWithName:(NSString *)name {
    NSDictionary *colorInfoDic = [[CMPThemeManager sharedManager].themeColorInfoDic copy];
    NSDictionary *colorDic = colorInfoDic[name];
    NSString *value = colorDic[@"value"];
    double alpha = [colorDic[@"alpha"] doubleValue];
    UIColor *color = [UIColor colorWithHexString:value alpha:alpha];
    return color;
}


@end

@implementation UIImage(CMPThemeManager)

+ (UIImage *)cmp_autoImageNamed:(NSString *)name {
    NSString *darkName = [[name.stringByDeletingPathExtension stringByAppendingString:@"_dark"] stringByAppendingPathExtension:name.pathExtension];
   return [self cmp_autoImageNamed:name darkNamed:darkName];
}

+ (UIImage *)cmp_autoImageNamed:(NSString *)name darkNamed:(NSString *)darkName {
    if (CMPThemeManager.sharedManager.isDisplayDrak) {
        return [UIImage imageNamed:darkName];
    } else {
        return [UIImage imageNamed:name];
    }
}

@end

#pragma mark - Class CMPThemeManager

NSString *const CMPThemeSettingKey = @"CMPThemeSettingKey";
NSString *const CMPThemeColorKey = @"Color";
CMPThemeInterfaceStyle const CMPThemeInterfaceStyleFillowSystem = @"CMPThemeInterfaceStyleFillowSystem";
CMPThemeInterfaceStyle const CMPThemeInterfaceStyleLight = @"CMPThemeInterfaceStyleLight";
CMPThemeInterfaceStyle const CMPThemeInterfaceStyleDark = @"CMPThemeInterfaceStyleDark";

@interface CMPThemeManager()

@end

@implementation CMPThemeManager

@synthesize currentThemeInterfaceStyle = _currentThemeInterfaceStyle;

+ (instancetype)sharedManager {
    static CMPThemeManager *_instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

//-------换肤begin-----------
- (void)setUiSkin:(NSDictionary *)uiSkin{
    _uiSkin = uiSkin;
    if (!uiSkin) {//如果没有值，则把原先设置的清空
        _skinThemeColor = nil;
    }
    _brandColor2 = nil;//每次修改主题色数据，需要重新获取brand2的颜色
    _brandColor7 = nil;
}

- (UIColor *)skinThemeColor{
    if (!_skinThemeColor) {
        _skinThemeColor = [self getBrandColorWithKey:@"brand6"];
    }
    return _skinThemeColor;
}

//根据图片名字返回修改skin颜色的图片
- (UIImage *)skinColorImageWithName:(NSString *)imageName{
    if (self.skinThemeColor) {
        return [[UIImage imageNamed:imageName] cmp_imageWithTintColor:_skinThemeColor];
    }
    return [UIImage imageNamed:imageName];
}

//使用图片去返回修改skin颜色的图片
- (UIImage *)skinColorImageWithImage:(UIImage *)image{
    if (self.skinThemeColor) {
        return [image cmp_imageWithTintColor:_skinThemeColor];
    }
    return image;
}

//使用【图片】和【指定颜色字符串】去返回修改skin颜色的图片
- (UIImage *)skinColorImageWithImage:(UIImage *)image colorStr:(NSString *)colorStr{
    if (self.skinThemeColor) {
        UIColor *color = [UIColor colorWithHexString:colorStr];
        if (color) {
            return [image cmp_imageWithTintColor:color];
        }
    }
    return image;
}
//使用【图片】和【指定颜色】去返回修改skin颜色的图片
- (UIImage *)skinColorImageWithImage:(UIImage *)image color:(UIColor *)color{
    if (self.skinThemeColor) {
        if (color) {
            return [image cmp_imageWithTintColor:color];
        }
    }
    return image;
}

- (UIImage *)skinBrand2ColorWithImage:(UIImage *)image{
    if (self.brandColor2) {
        return self.isDisplayDrak?[image cmp_imageWithTintColor:self.brandColor7]:[image cmp_imageWithTintColor:self.brandColor2];
    }
    return image;
}

- (UIColor *)brandColor2{
    if (!_brandColor2) {
        _brandColor2 = [self getBrandColorWithKey:@"brand2"];
    }
    return _brandColor2;
}

- (UIColor *)brandColor7{
    if (!_brandColor7) {
        _brandColor7 = [self getBrandColorWithKey:@"brand7"];
    }
    return _brandColor7;
}

- (UIColor *)getBrandColorWithKey:(NSString *)key{
    UIColor *brandColor = nil;
    if (self.uiSkin) {
        NSDictionary *brandDict = [self.uiSkin objectForKey:@"brandColor"];
        if ([brandDict isKindOfClass:NSDictionary.class]) {
            NSString *brand = [brandDict objectForKey:key];
            if ([brand isKindOfClass:NSString.class] && brand.length) {
                brandColor = [UIColor colorWithHexString:brand];
            }
        }
    }
    return brandColor;
}
//-------换肤end-----------

- (NSDictionary *)themeInterfaceStyleMapDic {
    return @{
        CMPThemeInterfaceStyleFillowSystem : @"sys",
        CMPThemeInterfaceStyleLight: @"white",
        CMPThemeInterfaceStyleDark : @"black"
    };
}

- (UIColor *)themeColor {
    if (![CMPCore isLoginState]) {//未登陆
        return [UIColor cmp_colorWithName:@"theme-bgc"];
    } else if ([CMPCore sharedInstance].serverIsLaterV7_1_SP1) {
        return [UIColor cmp_colorWithName:@"theme-bgc"];
    } else {
        return UIColorFromRGB(0x3AADFB);
    }
}

- (UIColor *)iconColor {
    if ([CMPFeatureSupportControl isIconColorUseMainFc]) {
        return [UIColor cmp_colorWithName:@"main-fc"];
    } else {
        return self.themeColor;
    }
}

- (UIStatusBarStyle)automaticStatusBarStyleDefault {
    if (@available(iOS 13.0, *)) {
        return UIStatusBarStyleDefault;
    }
    CMPThemeInterfaceStyle style = self.currentThemeInterfaceStyle;
    if ([style isEqualToString:CMPThemeInterfaceStyleFillowSystem]) {
        return UIStatusBarStyleDefault;
    }
    if ([style isEqualToString:CMPThemeInterfaceStyleLight]) {
        return UIStatusBarStyleDefault;
    }
    if ([style isEqualToString:CMPThemeInterfaceStyleDark]) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleLightContent;
}

- (CMPThemeInterfaceStyle)currentThemeInterfaceStyle {
    if (!_currentThemeInterfaceStyle) {
        _currentThemeInterfaceStyle = [[NSUserDefaults standardUserDefaults] objectForKey:CMPThemeSettingKey];
        if ([NSString isNull:_currentThemeInterfaceStyle]) {
            _currentThemeInterfaceStyle = CMPThemeInterfaceStyleLight;
            [[NSUserDefaults standardUserDefaults] setObject:_currentThemeInterfaceStyle forKey:CMPThemeSettingKey];
        }
    }
    return _currentThemeInterfaceStyle;
}

- (NSString *)currentThemeInterfaceStyleMapValue {
    return self.themeInterfaceStyleMapDic[self.currentThemeInterfaceStyle];
}

- (void)setCurrentThemeInterfaceStyle:(CMPThemeInterfaceStyle)currentThemeInterfaceStyle {
    _currentThemeInterfaceStyle = currentThemeInterfaceStyle;
    [[NSUserDefaults standardUserDefaults] setObject:_currentThemeInterfaceStyle forKey:CMPThemeSettingKey];
    [self forcedSetSystemUserInterfaceStyle:_currentThemeInterfaceStyle];
}

- (void)setUserInterfaceStyle {
    if (![CMPCore sharedInstance].serverIsLaterV8_0) {
        [self forcedSetSystemUserInterfaceStyle:CMPThemeInterfaceStyleLight];
        return;
    }
    [self forcedSetSystemUserInterfaceStyle:self.currentThemeInterfaceStyle];
}

- (BOOL)isSupportUserInterfaceStyleDark {
    if (@available(iOS 13.0, *)) {
        return YES;
    } else {
        return NO;
    }
}

- (void)setThemeUserAgentWithThemeInterfaceStyle:(CMPThemeInterfaceStyle)style {
    if (@available(iOS 13.0, *)) {
        if ([style isEqualToString:CMPThemeInterfaceStyleFillowSystem]) {
            if ([UITraitCollection currentTraitCollection].userInterfaceStyle == UIUserInterfaceStyleLight) {
                _CMPThemeUserAgent = self.themeInterfaceStyleMapDic[@"CMPThemeInterfaceStyleLight"];
                [self setThemeColorInfoDicWithThemeInterfaceStyle:CMPThemeInterfaceStyleLight];
                self.isDisplayDrak = NO;
            }
            else if ([UITraitCollection currentTraitCollection].userInterfaceStyle == UIUserInterfaceStyleDark) {
                _CMPThemeUserAgent = self.themeInterfaceStyleMapDic[@"CMPThemeInterfaceStyleDark"];
               [self setThemeColorInfoDicWithThemeInterfaceStyle:CMPThemeInterfaceStyleDark];
               self.isDisplayDrak = YES;
            }
            return;
        }
    }
    
    if ([style isEqualToString:CMPThemeInterfaceStyleFillowSystem]) {
        _CMPThemeUserAgent = self.themeInterfaceStyleMapDic[@"CMPThemeInterfaceStyleLight"];
        [self setThemeColorInfoDicWithThemeInterfaceStyle:CMPThemeInterfaceStyleLight];
        self.isDisplayDrak = NO;
    }
    if ([style isEqualToString:CMPThemeInterfaceStyleLight]) {
        _CMPThemeUserAgent = self.themeInterfaceStyleMapDic[@"CMPThemeInterfaceStyleLight"];
        [self setThemeColorInfoDicWithThemeInterfaceStyle:CMPThemeInterfaceStyleLight];
         self.isDisplayDrak = NO;
    }
    else if ([style isEqualToString:CMPThemeInterfaceStyleDark]) {
        _CMPThemeUserAgent = self.themeInterfaceStyleMapDic[@"CMPThemeInterfaceStyleDark"];
        [self setThemeColorInfoDicWithThemeInterfaceStyle:CMPThemeInterfaceStyleDark];
        self.isDisplayDrak = YES;
    }
}

- (void)serverDidChange {
    [self setUserInterfaceStyle];
}

- (void)setThemeColorInfoDicWithThemeInterfaceStyle:(CMPThemeInterfaceStyle)style {
    _themeColorInfoDic = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"CMPThmeInfo.plist"
    withExtension:nil]][style][CMPThemeColorKey];
}


- (void)forcedSetSystemUserInterfaceStyle:(CMPThemeInterfaceStyle)style {
    [self setThemeUserAgentWithThemeInterfaceStyle:style];
    if ([style isEqualToString:CMPThemeInterfaceStyleLight]) {
        if (@available(iOS 13.0, *)) {
            NSArray *windows = [UIApplication sharedApplication].windows;
            for (UIWindow *window in windows) {
               window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
            }
        }
    }
    else if ([style isEqualToString:CMPThemeInterfaceStyleDark]) {
        if (@available(iOS 13.0, *)) {
            NSArray *windows = [UIApplication sharedApplication].windows;
            for (UIWindow *window in windows) {
               window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
            }
        }
    }
    else if ([style isEqualToString:CMPThemeInterfaceStyleFillowSystem]) {
        if (@available(iOS 13.0, *)) {
            NSArray *windows = [UIApplication sharedApplication].windows;
            for (UIWindow *window in windows) {
               window.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
            }
        }
    }
}

@end

