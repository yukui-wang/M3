//
//  UIDevice+TFDevice.m
//  CMPLib
//
//  Created by youlin on 2018/7/3.
//  Copyright © 2018年 CMPCore. All rights reserved.
//

#import "UIDevice+TFDevice.h"
#import "CMPConstant.h"
#import "CMPCore.h"

bool DeviceInterfaceOrientationIsPortrait(void) {
    if (@available(iOS 16.0, *)) {
        NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
        UIWindowScene *ws = (UIWindowScene *)(array.firstObject);
        return UIInterfaceOrientationIsPortrait(ws.interfaceOrientation);
    }
    return InterfaceOrientationIsPortrait;
}

@implementation UIDevice (TFDevice)

/**
 * @interfaceOrientation 输入要强制转屏的方向
 */
+ (void)switchNewOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (INTERFACE_IS_PAD /*&& [CMPCore sharedInstance].serverIsLaterV7_0_SP1*/) {
        return;
    }
    [UIDevice newApiForSetOrientation:UIInterfaceOrientationUnknown];
    [UIDevice newApiForSetOrientation:interfaceOrientation];
}

/**
 * @interfaceOrientation 输入要强制转屏的方向
 */
+ (void)switchNewOrientationIncludingIPad:(UIInterfaceOrientation)interfaceOrientation {
    int currentOrientation = [[[UIDevice currentDevice] valueForKeyPath:@"orientation"] intValue];
    if (currentOrientation == interfaceOrientation) return;
    
    [UIDevice newApiForSetOrientation:UIInterfaceOrientationUnknown];
    [UIDevice newApiForSetOrientation:interfaceOrientation];
}

+(void)newApiForSetOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSNumber *orientationTarget = [NSNumber numberWithInteger:interfaceOrientation];
    if (@available(iOS 16.0, *)) {
        if (UIInterfaceOrientationUnknown == interfaceOrientation) return;
        UIInterfaceOrientationMask oriMask = 1 << interfaceOrientation;
        orientationTarget = [NSNumber numberWithInteger:oriMask];
    }
    [UIDevice newApiForSetOrientationValue:orientationTarget vc:nil];
}

+(void)newApiForSetOrientationValue:(NSNumber *)interfaceOrientationVal vc:(UIViewController *)vc
{
    if (@available(iOS 16.0, *)) {//ks add -- 适配iOS16，但也需要兼容客开使用低版本xcode打包找不到新增类报错的问题，所以使用了string查找方式
        @try {
            
            SEL ss = NSSelectorFromString(@"setNeedsUpdateOfSupportedInterfaceOrientations");
            if (vc && [vc respondsToSelector:ss]) {
                [vc performSelector:ss];
            }
            NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
            UIWindowScene *ws = (UIWindowScene *)array[0];
            NSInteger i = ws.interfaceOrientation;
            if ((1 << i) == interfaceOrientationVal.intValue) return;
            Class GeometryPreferences = NSClassFromString(@"UIWindowSceneGeometryPreferencesIOS");
            id geometryPreferences = [[GeometryPreferences alloc] init];
            [geometryPreferences setValue:interfaceOrientationVal forKey:@"interfaceOrientations"];
            SEL sel_method = NSSelectorFromString(@"requestGeometryUpdateWithPreferences:errorHandler:");
            void (^ErrorBlock)(NSError *err) = ^(NSError *err){

            };
            if ([ws respondsToSelector:sel_method]) {
                (((void (*)(id, SEL,id,id))[ws methodForSelector:sel_method])(ws, sel_method,geometryPreferences,ErrorBlock));
            }
        } @catch (NSException *exception) {
            //异常处理
        } @finally {
            
        }
    }else{
        [[UIDevice currentDevice] setValue:interfaceOrientationVal forKey:@"orientation"];
    }
}

@end
