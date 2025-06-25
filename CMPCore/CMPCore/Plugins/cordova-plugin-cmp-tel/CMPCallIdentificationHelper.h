//
//  CMPCallIdentificationHelper.h
//  M3
//
//  Created by CRMO on 2018/3/8.
//

#import <CMPLib/CMPObject.h>

UIKIT_EXTERN const NSInteger CMPCallIdentificationPluginErrorUnkown; // 未知错误
UIKIT_EXTERN const NSInteger CMPCallIdentificationPluginErrorDisabled; // 设置权限没有开启
UIKIT_EXTERN const NSInteger CMPCallIdentificationPluginErrorNoContacts; // 离线通讯录获取失败
UIKIT_EXTERN const NSInteger CMPCallIdentificationPluginErrorOpen; // 开启失败
UIKIT_EXTERN const NSInteger CMPCallIdentificationPluginErrorClose; // 关闭失败

@interface CMPCallIdentificationHelper : CMPObject

@property (assign, nonatomic, readonly) BOOL switchState;

/**
 设置来电识别开关状态

 @param state 开关状态
 @param done 设置成功回调
 */
- (void)switchCallIdentification:(BOOL)state
                      completion:(void(^)(BOOL result, NSError *error))done;

/**
 通讯更新完成后调用，刷新数据
 */
- (void)reloadCallIdentification;

/**
 关闭来电识别
 */
- (void)closeCallIdentification;

@end
