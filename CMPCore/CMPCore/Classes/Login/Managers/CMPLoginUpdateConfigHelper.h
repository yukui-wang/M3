//
//  CMPLoginUpdateConfigHelper.h
//  M3
//  1130移动专版token登录，更新配置信息
//
//  Created by CRMO on 2018/9/27.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

/**
 更新完成回调

 @param success 是否更新成功
 */
typedef void(^CMPLoginUpdateDoneBlock)(BOOL success);

@interface CMPLoginUpdateConfigHelper : CMPObject
/** appList同步完成 **/
@property (assign, readonly, nonatomic) BOOL appListSyncDone;
/** configInfo同步完成 **/
@property (assign, readonly, nonatomic) BOOL configInfoSyncDone;
/** userInfo同步完成 **/
@property (assign, readonly, nonatomic) BOOL userInfoSyncDone;

/**
 异步更新更新ConfigInfo
*/
- (void)updateConfigInfo:(nullable CMPLoginUpdateDoneBlock)doneBlock;

/**
 异步更新AppList
 */
- (void)updateAppList:(nullable CMPLoginUpdateDoneBlock)doneBlock;

/**
 更新人员信息
 */
- (void)updateUserInfo:(nullable CMPLoginUpdateDoneBlock)doneBlock;

/**
 所有更新成功
 */
- (void)allUpdateDone;

/**
 上报登录位置信息
 */
- (void)reportLoginLocation;

/**
 重置异步更新状态
 */
- (void)allUpdateReLoad;


@end

NS_ASSUME_NONNULL_END
