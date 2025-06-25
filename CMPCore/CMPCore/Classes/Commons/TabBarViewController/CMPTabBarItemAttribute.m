//
//  CMPTabBarItemAttribute.m
//  CMPCore
//
//  Created by yang on 2017/2/13.
//
//

#import "CMPTabBarItemAttribute.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import <CMPLib/CMPCore.h>

@implementation CMPTabBarItemAttribute

- (UIImage *)normalImg {
    
    if (![NSString isNull:self.normalImageUrl]) {
        NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:self.normalImageUrl]];
        localHref = [localHref replaceCharacter:@"file://" withString:@""];
        NSFileManager *fileManager =[NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:localHref]) {
            NSData *data = [NSData dataWithContentsOfFile:localHref];
            UIImage *image = [UIImage imageWithData:data scale:2];
            if (image) {
                image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                return image;
            }
        }
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"app.png",@"52",@"contacts.png",@"62",@"message.png",@"55",@"my.png",@"56",@"todo.png",@"58",@"work.png",@"52_work", nil];
    NSString *appID = [self.enTitle.lowercaseString isEqualToString:@"workbench"] ?@"52_work":self.appID;
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"tabBar.bundle/%@",[dic objectForKey:appID]]];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return image;
}

- (UIImage *)selectedImg {
    if (![NSString isNull:self.selectedImageUrl]) {
        NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:self.selectedImageUrl]];
        localHref = [localHref replaceCharacter:@"file://" withString:@""];
        NSFileManager *fileManager =[NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:localHref]) {
            NSData *data = [NSData dataWithContentsOfFile:localHref];
            UIImage *image = [UIImage imageWithData:data scale:2];
            if (image) {
                image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                return image;
            }
        }
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"app_select.png",@"52",@"contacts_select.png",@"62",@"message_select.png",@"55",@"my_select.png",@"56",@"todo_select.png",@"58",@"work_select.png",@"52_work",nil];
    NSString *appID = [self.enTitle.lowercaseString isEqualToString:@"workbench"] ?@"52_work":self.appID;
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"tabBar.bundle/%@",[dic objectForKey:appID]]];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return image;
}

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"appID" : @"appId"};
}

- (BOOL)isShow {
    // V7.1版本之前服务器返回的底导航item都是要展示的
    if (![CMPCore sharedInstance].serverIsLaterV7_1) {
        return YES;
    } else {
        return _isShow;
    }
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    CMPTabBarItemAttribute *aObject = (CMPTabBarItemAttribute *)object;
    
    // 如果 oldIsShow == false  newIsShow == false 不管其他数据有没有变化算item没有变化
    if (!self.isShow && !aObject.isShow) {
        return YES;
    }
    
    if (([self.appUniqueId isEqualToString:aObject.appUniqueId] || !self.appUniqueId) &&
        [self.appID isEqualToString:aObject.appID] &&
        [self.sortNum isEqual:aObject.sortNum] &&
        self.isShow == aObject.isShow) {
        return YES;
    }
    
    return NO;
}

@end

@implementation CMPTabBarItemAttributeList

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"navBarList" : [CMPTabBarItemAttribute class]};
}

@end
