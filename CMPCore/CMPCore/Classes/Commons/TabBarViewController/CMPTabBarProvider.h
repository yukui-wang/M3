//
//  CMPTabBarProvider.h
//  M3
//
//  Created by CRMO on 2017/11/13.
//

#import <CMPLib/CMPObject.h>

@class CMPTabBarAttribute;
@class CMPTabBarItemAttributeList;

@interface CMPTabBarProvider : CMPObject

- (CMPTabBarItemAttributeList *)tabBarItemList;

- (void)appClick:(NSString *)appId appName:(NSString *)appName uniqueId:(NSString *)uniqueId;

@end
