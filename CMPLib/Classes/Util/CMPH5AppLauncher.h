//
//  CMPH5AppLauncher.h
//  CMPLib
//
//  Created by CRMO on 2019/4/17.
//  Copyright © 2019 crmo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPH5AppLauncher : NSObject


/**
 跳转到H5应用

 @param param 跳转参数
 @param vc 当前调用vc
 */
+ (void)launchH5AppWithParam:(NSDictionary *)param
                inController:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
