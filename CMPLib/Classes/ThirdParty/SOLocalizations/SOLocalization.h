//
//  SOLocalization.h
//  LocalizationExample
//
//  Created by scfhao on 2017/11/27.
//  Copyright © 2017年 scfhao. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SOLocalizedStringFromTable(key, tbl) \
[[SOLocalization sharedLocalization] localizedStringForKey:(key) inTable:(tbl)]

#define SOLocalizedString(key, comment) SOLocalizedStringFromTable(key, nil)

@interface SOLocalization : NSObject

/**
 当前使用的语言
 使用本地化文件夹的名称，比如英文的本地化文件夹叫 en.lproj，这里就用 en 代表英文，为了方便使用，本文件底部定义了 英文、简体中文、繁体中文 三个常量，可直接使用
 */
@property (copy, nonatomic) NSString *region;

/**
 默认语言
 */
@property (copy, nonatomic) NSString *fallbackRegion;

/**
 当前使用的语言
 使用本地化文件夹的名称，比如英文的本地化文件夹叫 en.lproj，这里就用 en 代表英文，为了方便使用，本文件底部定义了 英文、简体中文、繁体中文 三个常量，可直接使用
 */
@property (strong, nonatomic) NSArray *supportRegions;

/**
 缓存语言设置对应的服务器ID
 */
@property (copy, nonatomic) NSString *serverId;

/**
 获取 SOLocalization 语言设置对应的 NSLocale 对象。
 */
@property (strong, readonly, nonatomic) NSLocale *currentLocale;

/**
 设置支持的语言及默认语言
 如果当前系统中的语言包含在支持的语言数组中，则使用系统的语言，否则使用 fallbackRegion。注意此方法应该先于 SOLocalization 的其他方法执行，否则不起作用。
 */
+ (void)configSupportRegions:(NSArray *)supportRegions fallbackRegion:(NSString *)fallbackRegion serverId:(NSString *)serverId;

/**
 获取一个单例对象，可以通过此对象获取或修改当前设置的语言
 */
+ (instancetype)sharedLocalization;

/**
 获取指定的 key 在当前语言环境下的本地化字符串。
 为方便使用，SOLocalization 提供了一系列 UIKit Category，方便对常见的 UIKit 元素设置本地化字符串内容，使用这种方式设置本地化字符串后，当 SOLocalization 中的语言变化时，UIKit 元素会自动切换其语言内容。
 @param key 使用的本地化（strings）文件中等号左边的字符串
 @param table 要使用的本地化文件名，传 nil 时使用 Localizable.strings
 @see SOLocalizedStringFromTable(key, tbl)
 */
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value inTable:(NSString *)table bundle:(NSBundle *)bundle;

/**
 设置对应服务器的语言
 @param region 需要设置的语言
 @param serverId 对应的d服务器ID
 @return 是否需要切换语言
 */
- (BOOL)setRegion:(NSString *)region serverId:(NSString *)serverId;

/**
 获取服务器语言对应的本地语言
 @param key 服务器语言
 */
- (NSString *)getRegionWithServerLanguageKey:(NSString *)key;

- (NSString *)getServerLanguageKeyWithRegion:(NSString *)region;

- (void)switchRegionWithServerId:(NSString *)serverId inSupportRegions:(NSArray *)supportRegions;

- (NSString *)getRegionWithServerId:(NSString *)serverId inSupportRegions:(NSArray *)supportRegions;

+ (NSArray *)loacalSupportRegions;
+ (NSArray *)lowerVersionLoacalSupportRegions;
+ (instancetype)staticLocalization;

@end

#pragma mark - Common Regions

FOUNDATION_EXPORT NSString * const SOLocalizationEnglish;               /* 英文 */
FOUNDATION_EXPORT NSString * const SOLocalizationSimplifiedChinese;     /* 简体中文 */
FOUNDATION_EXPORT NSString * const SOLocalizationTraditionalChinese;    /* 繁体中文 */
FOUNDATION_EXPORT NSString * const SOLocalizationKorean;                /* 韩语 */
FOUNDATION_EXPORT NSString * const SOLocalizationRussian;               /* 俄语 */
FOUNDATION_EXPORT NSString * const SOLocalizationJapanese;              /* 日语 */
FOUNDATION_EXPORT NSString * const SOLocalizationMalay;                 /* 马来语 */
FOUNDATION_EXPORT NSString * const SOLocalizationArbic;                 /* 阿拉伯语 */
FOUNDATION_EXPORT NSString * const SOLocalizationLao;                   /* 老挝语 */

