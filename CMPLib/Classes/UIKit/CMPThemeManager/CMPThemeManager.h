//
//  CMPThemeManager.h
//  M3
//
//  Created by 程昆 on 2019/7/29.
//

#import "CMPObject.h"

typedef NSString * CMPThemeInterfaceStyle;
UIKIT_EXTERN NSString *const CMPThemeSettingKey;
UIKIT_EXTERN CMPThemeInterfaceStyle const CMPThemeInterfaceStyleFillowSystem;
UIKIT_EXTERN CMPThemeInterfaceStyle const CMPThemeInterfaceStyleLight;
UIKIT_EXTERN CMPThemeInterfaceStyle const CMPThemeInterfaceStyleDark;
 
UIKIT_EXTERN NSString *_CMPThemeUserAgent;

@interface CMPThemeManager : CMPObject

@property (nonatomic,strong,readonly)UIColor *themeColor;
@property (nonatomic,strong,readonly)UIColor *iconColor;
@property (nonatomic,copy)CMPThemeInterfaceStyle currentThemeInterfaceStyle;
@property (nonatomic,strong,readonly)NSDictionary *themeColorInfoDic;

@property (nonatomic,assign)BOOL isDisplayDrak;

+ (instancetype)sharedManager;
- (BOOL)isSupportUserInterfaceStyleDark;
- (void)setThemeUserAgentWithThemeInterfaceStyle:(CMPThemeInterfaceStyle)style;
- (void)setUserInterfaceStyle;
- (NSString *)currentThemeInterfaceStyleMapValue;
- (UIStatusBarStyle)automaticStatusBarStyleDefault;
- (void)serverDidChange;

//换肤begin
@property (nonatomic,strong) UIColor *skinThemeColor;//一键换肤主题色
@property (nonatomic,strong) NSDictionary *uiSkin;
@property (nonatomic,strong) UIColor *brandColor2;
@property (nonatomic,strong) UIColor *brandColor7;

- (UIImage *)skinColorImageWithName:(NSString *)imageName;
- (UIImage *)skinColorImageWithImage:(UIImage *)image;
- (UIImage *)skinColorImageWithImage:(UIImage *)image colorStr:(NSString *)colorStr;
- (UIImage *)skinColorImageWithImage:(UIImage *)image color:(UIColor *)color;
- (UIImage *)skinBrand2ColorWithImage:(UIImage *)image;
//换肤end
@end

@interface UIColor(CMPThemeManager)

+ (UIColor *)cmp_colorWithName:(NSString *)name;
//换肤begin
+ (UIColor *)cmp_specColorWithName:(NSString *)name;//指定无更改的颜色
//换肤end
@end

@interface UIImage(CMPThemeManager)


/// 自动适配图片暗黑模式,暗黑模式图片必须为name_dark格式,否则无法显示
/// @param name 亮白模式图片名
+ (UIImage *)cmp_autoImageNamed:(NSString *)name;

/// 自动适配图片暗黑模式
/// @param name 亮白模式图片名
/// @param darkName 暗黑模式图片名
+ (UIImage *)cmp_autoImageNamed:(NSString *)name darkNamed:(NSString *)darkName;

@end

