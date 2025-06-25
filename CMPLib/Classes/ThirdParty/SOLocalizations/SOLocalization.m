//
//  SOLocalization.m
//  LocalizationExample
//
//  Created by scfhao on 2017/11/27.
//  Copyright © 2017年 scfhao. All rights reserved.
//

#import "SOLocalization.h"
#import "NSBundle+SOLocalization.h"
#import "CMPDataProvider.h"

static NSString * const SOLocalizationRegionKey = @"SOLocalizationRegionKey";
static NSString * const SODeviceLocalizationRegionKey = @"AppleLanguages";

NSString * const SOLocalizationEnglish = @"en";
NSString * const SOLocalizationSimplifiedChinese = @"zh-Hans";
NSString * const SOLocalizationTraditionalChinese = @"zh-Hant";
NSString * const SOLocalizationKorean = @"ko";
NSString * const SOLocalizationRussian = @"ru";
NSString * const SOLocalizationJapanese = @"ja";
NSString * const SOLocalizationMalay = @"ms";
NSString * const SOLocalizationArbic = @"ar";
NSString * const SOLocalizationLao = @"lo";

@implementation SOLocalization

static SOLocalization *localization = nil;

+ (void)configSupportRegions:(NSArray *)supportRegions fallbackRegion:(NSString *)fallbackRegion serverId:(NSString *)serverId {
    if (!localization) {
        @synchronized(self) {
            if (!localization) {
                localization = [[SOLocalization alloc]initWithSupportRegions:supportRegions fallbackRegion:fallbackRegion serverId:serverId];
            }
        }
    } else {
        NSLog(@"[SOLocalization]: 请在程序入口处调用%@", NSStringFromSelector(_cmd));
    }
    
    [self autoRTLWithRegion:localization.region];
}

+ (instancetype)sharedLocalization {
    if (!localization) {
        @synchronized(self) {
            if (!localization) {
                localization = [[SOLocalization alloc]initWithSupportRegions:nil fallbackRegion:nil serverId:nil];
            }
        }
    }
    return localization;
}

+ (instancetype)staticLocalization {
    return localization;
}

+ (void)autoRTLWithRegion:(NSString *)region {
    if ([region isEqualToString:SOLocalizationArbic]) {
        [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        [UISearchBar appearance].semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    } else {
        [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
        [UISearchBar appearance].semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    }
}


- (instancetype)initWithSupportRegions:(NSArray *)supportRegions fallbackRegion:(NSString *)fallbackRegion serverId:(NSString *)serverId {
    self = [super init];
    if (self) {
        self.fallbackRegion = fallbackRegion;
        NSString *region = nil;
        if (serverId) {
//            NSString *languageCacheKey = [NSString stringWithFormat:@"%@_%@",serverId,SOLocalizationRegionKey];
//            region = [[NSUserDefaults standardUserDefaults]objectForKey:languageCacheKey];
            region = CMPCore.sharedInstance.languageRegion;
        }
        if (region) {
            _region = region;
            extern NSString *_CMPLanguageUserAgent;
            _CMPLanguageUserAgent = [self getServerLanguageKeyWithRegion:_region];
            if (![supportRegions count]) {
                supportRegions = @[SOLocalizationEnglish, SOLocalizationSimplifiedChinese, SOLocalizationTraditionalChinese];
            }
            self.supportRegions = supportRegions;
        } else {
            if (![supportRegions count]) {
                supportRegions = @[SOLocalizationEnglish, SOLocalizationSimplifiedChinese, SOLocalizationTraditionalChinese];
            }
            if (!fallbackRegion) {
                fallbackRegion = SOLocalizationEnglish;
            }
            self.supportRegions = supportRegions;
            NSArray *languageArray = [[NSUserDefaults standardUserDefaults]objectForKey:SODeviceLocalizationRegionKey];
            if ([languageArray count]) {
                NSString *preferrdLanguage = languageArray[0];
                for (NSString *language in supportRegions) {
                    if ([preferrdLanguage hasPrefix:language]) {
                        _region = language;
                        extern NSString *_CMPLanguageUserAgent;
                        _CMPLanguageUserAgent = [self getServerLanguageKeyWithRegion:_region];
                        break;
                    }
                }
            }
            if (!_region) {
                _region = fallbackRegion;
                extern NSString *_CMPLanguageUserAgent;
                _CMPLanguageUserAgent = [self getServerLanguageKeyWithRegion:_region];
            }
        }
    }
    return self;
}

- (void)setRegion:(NSString *)region {
    if ([_region isEqualToString:region]) return;
    [SOLocalization autoRTLWithRegion:region];
    _region = [region copy];
    _serverId = nil;
    extern NSString *_CMPLanguageUserAgent;
    _CMPLanguageUserAgent = [self getServerLanguageKeyWithRegion:_region];
    [[NSUserDefaults standardUserDefaults] setObject:region forKey:SOLocalizationRegionKey];
    [[CMPDataProvider sharedInstance] resetRequestSerialize];
    return;
}

- (BOOL)setRegion:(NSString *)region serverId:(NSString *)serverId {
    if ([_region isEqualToString:region] && [_serverId isEqualToString:serverId]) return NO;
    [SOLocalization autoRTLWithRegion:region];
    _region = [region copy];
    _serverId = [serverId copy];
    extern NSString *_CMPLanguageUserAgent;
    _CMPLanguageUserAgent = [self getServerLanguageKeyWithRegion:_region];
    [[NSUserDefaults standardUserDefaults] setObject:region forKey:SOLocalizationRegionKey];
//    NSString *languageCacheKey = [NSString stringWithFormat:@"%@_%@",serverId,SOLocalizationRegionKey];
//    [[NSUserDefaults standardUserDefaults] setObject:region forKey:languageCacheKey];
    [CMPCore.sharedInstance setLanguageRegion:region];
    [[CMPDataProvider sharedInstance] resetRequestSerialize];
    return YES;
}

- (void)switchRegionWithServerId:(NSString *)serverId inSupportRegions:(NSArray *)supportRegions{
    NSString *region = [localization getRegionWithServerId:serverId inSupportRegions:supportRegions];
    [self setRegion:region];
    return;
}


- (NSString *)getRegionWithServerId:(NSString *)serverId inSupportRegions:(NSArray *)supportRegions{
//    NSString *languageCacheKey = [NSString stringWithFormat:@"%@_%@",serverId,SOLocalizationRegionKey];
//    NSString *region = [[NSUserDefaults standardUserDefaults]objectForKey:languageCacheKey];
    NSString *region = CMPCore.sharedInstance.languageRegion;
    if (region) {
        return region;
    }
    
    if (![supportRegions count]) {
        supportRegions = @[SOLocalizationEnglish, SOLocalizationSimplifiedChinese, SOLocalizationTraditionalChinese];
    }
    self.supportRegions = supportRegions;
    
    BOOL isSupport = NO;
    NSArray *languageArray = [[NSUserDefaults standardUserDefaults]objectForKey:SODeviceLocalizationRegionKey];
    if ([languageArray count]) {
        NSString *preferrdLanguage = languageArray[0];
        for (NSString *language in self.supportRegions) {
            if ([preferrdLanguage hasPrefix:language]) {
                region = language;
                isSupport = YES;
                break;
            }
        }
    }
    
    if (!isSupport) {
        region = self.fallbackRegion;
    }
    
    return region;
}

- (NSBundle *)bundle {
    if ([self.region length]) {
        NSString *languagePath = [[NSBundle mainBundle]pathForResource:self.region ofType:@"lproj"];
        return [NSBundle bundleWithPath:languagePath];
    } else {
        return [NSBundle mainBundle];
    }
}

- (NSLocale *)currentLocale {
    return [NSLocale localeWithLocaleIdentifier:self.region];
}

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value inTable:(NSString *)table bundle:(NSBundle *)bundle {
    NSString *localTable = table ?: @"Localizable";
    NSString *localLvalue =  [[self bundle] cmp_sol_localizedStringForKey:key value:@"" table:localTable];
    
    if ([localLvalue isEqualToString:key]) {
        localLvalue = [bundle cmp_sol_localizedStringForKey:key value:value table:localTable];
        if ([localLvalue isEqualToString:key]) {
            localLvalue = [NSBundle.mainBundle cmp_sol_localizedStringForKey:key value:value table:localTable];
        }
    }
    return localLvalue;
}

- (NSString *)getRegionWithServerLanguageKey:(NSString *)key {
    NSDictionary *languagesDic = @{
                                   @"en":SOLocalizationEnglish,
                                   @"zh_CN":SOLocalizationSimplifiedChinese,
                                   @"zh_TW":SOLocalizationTraditionalChinese,
                                   @"ko":SOLocalizationKorean,
                                   @"ru":SOLocalizationRussian,
                                   @"ja":SOLocalizationJapanese,
                                   @"ms":SOLocalizationMalay,
                                   @"ar":SOLocalizationArbic,
                                   @"lo":SOLocalizationLao
                                   };
   
    return [languagesDic objectForKey:key];
}

- (NSString *)getServerLanguageKeyWithRegion:(NSString *)region {
    NSDictionary *languagesDic = @{
                                   SOLocalizationEnglish:@"en",
                                   SOLocalizationSimplifiedChinese:@"zh_CN",
                                   SOLocalizationTraditionalChinese:@"zh_TW",
                                   SOLocalizationKorean:@"ko",
                                   SOLocalizationRussian:@"ru",
                                   SOLocalizationJapanese:@"ja",
                                   SOLocalizationMalay:@"ms",
                                   SOLocalizationArbic:@"ar",
                                   SOLocalizationLao:@"lo"
                                   };
    
    return [languagesDic objectForKey:region];
}

+ (NSArray *)loacalSupportRegions {
    return @[SOLocalizationEnglish,
             SOLocalizationSimplifiedChinese,
             SOLocalizationTraditionalChinese,
             SOLocalizationKorean,
             SOLocalizationRussian,
             SOLocalizationJapanese,
             SOLocalizationMalay,
             SOLocalizationArbic,
             SOLocalizationLao];
}

+ (NSArray *)lowerVersionLoacalSupportRegions {
    return @[SOLocalizationEnglish,
             SOLocalizationSimplifiedChinese,
             SOLocalizationTraditionalChinese,
            ];
}

@end
