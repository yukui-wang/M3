//
//  CMPLoginConfigInfoModel.m
//  M3
//
//  Created by CRMO on 2017/11/6.
//

#import "CMPLoginConfigInfoModel.h"
#import <CMPLib/CMPThemeManager.h>

@implementation CMPLoginConfigMapKey

@end

@implementation CMPLoginConfigInfo
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"mapKey" : [CMPLoginConfigMapKey class],
    };
}
@end

@implementation CMPLoginConfigTabBarModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
//            @"tabbarAttribute" : @"navBarAttribute",
             @"tabbarList" : @"navBarList",
             @"tabbarAttributes" : @"navBarAttribute",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"tabbarList" : [CMPTabBarItemAttribute class],
             @"tabbarAttributes" : [CMPTabBarAttribute class]
    };
}

- (BOOL)hasShortCut {
    for (CMPTabBarItemAttribute *item in _tabbarList) {
        if ([item.appID isEqualToString:kM3AppID_Shortcut] &&
            item.isShow) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    CMPLoginConfigTabBarModel *aObject = (CMPLoginConfigTabBarModel *)object;
    //仅判断底导航按钮就好
    if (self.tabbarList.count != aObject.tabbarList.count) {
        return NO;
    }
    
    for (int i = 0; i < self.tabbarList.count; i++) {
        if (![self.tabbarList[i] isEqual:aObject.tabbarList[i]]) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)needOnlyReloadTabbarItem:(CMPLoginConfigTabBarModel *)aObject{
    if (![aObject isKindOfClass:[self class]]) {
        return YES;
    }
    if (self.tabbarList.count != aObject.tabbarList.count) {
        return YES;
    }
    //先判断整体风格
    if (self.tabbarAttributes.count > 0) {
        for (int i = 0; i < self.tabbarAttributes.count; i++) {
            if (![self.tabbarAttributes[i] isEqual:aObject.tabbarAttributes[i]]) {
                return YES;
            }
        }
    }
    else {
        if (![self.tabbarAttribute isEqual:aObject.tabbarAttribute]) {
            return YES;
        }
    }
    //判断底导航按钮标题icon
    for (int i = 0; i < self.tabbarList.count; i++) {
        CMPTabBarItemAttribute *myObj = self.tabbarList[i];
        CMPTabBarItemAttribute *otherObj = aObject.tabbarList[i];
        if (![myObj.chTitle isEqualToString:otherObj.chTitle] ||
            ![myObj.enTitle isEqualToString:otherObj.enTitle] ||
            ![myObj.normalImage isEqualToString:otherObj.normalImage] ||
            ![myObj.selectedImage isEqualToString:otherObj.selectedImage]) {
            //只刷新底导航，不刷新界面
            return YES;
        }
    }
    return NO;
}

-(CMPTabBarAttribute *)tabbarAttribute {
    if (_tabbarAttribute) {//监测切换主题后的属性是否相符，如果不符则置空
        if (CMPThemeManager.sharedManager.isDisplayDrak) {
            if ([_tabbarAttribute.theme isEqualToString:@"white"]) {
                _tabbarAttribute = nil;
            }
        }else{
            if ([_tabbarAttribute.theme isEqualToString:@"black"]) {
                _tabbarAttribute = nil;
            }
        }
        
    }
    if (!_tabbarAttribute &&  self.tabbarAttributes.count > 0) {
        for (CMPTabBarAttribute *tabbarAttribute in self.tabbarAttributes) {
            if (CMPThemeManager.sharedManager.isDisplayDrak) {
                if ([tabbarAttribute.theme isEqualToString:@"black"]) {
                    _tabbarAttribute = tabbarAttribute;
                    return _tabbarAttribute;
                }
            } else {
                if ([tabbarAttribute.theme isEqualToString:@"white"]) {
                    _tabbarAttribute = tabbarAttribute;
                    return _tabbarAttribute;
                }
            }
        }
    }
    return _tabbarAttribute;
}

@end

@implementation CMPLoginConfigPortalModel
@end

@implementation CMPLoginConfigInfoModel
@end

@implementation CMPLoginConfigInfoModel_2

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"tabBar" : @"data.navBar",
             @"expandNavBar" : @"data.expandNavBar",
             @"config" : @"data.config",
             @"firstShow" : @"data.addressBookSet.firstShow",
             @"fieldViewSet" : @"data.addressBookSet.fieldViewSettings",
             @"portals" : @"data.portal",
             @"wifiClockIn" : @"data.fastPunchSet",
             @"hasUcMsgServerDel" : @"data.hasUcMsgServerDel",
             };
}

+ (NSArray *)modelPropertyBlacklist {
    return @[@"portal"];
}

- (NSString *)getH5CacheStr {
    CMPLoginConfigInfoModel *oldModel = [[CMPLoginConfigInfoModel alloc] init];
    oldModel.code = self.code;
    oldModel.data = self.config;
    oldModel.time = self.time;
    oldModel.message = self.message;
    oldModel.version = self.version;
    NSString *result = [oldModel yy_modelToJSONString];
    return result;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"portals" : [CMPLoginConfigPortalModel class]};
}

- (CMPLoginConfigTabBarModel *)tabBar {
    // 7.1之前版本，_tabBar能直接取到值，不需要做兼容
    if (!_tabBar) {
        // 7.1版本，_tabBar放到了portal里，需要做特殊处理
        _tabBar = self.portal.navBar;
    }
    return _tabBar;
}

- (CMPLoginConfigPortalModel *)portal {
    if (!_portal) {
        _portal = self.portals.firstObject;
    }
    return _portal;
}

@end
