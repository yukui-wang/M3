//
//  CMPPopOverManager.h
//  CMPLib
//
//  Created by MacBook on 2019/12/23.
//  Copyright © 2019 crmo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPPopOverManager : NSObject

+ (instancetype)sharedManager;

#pragma mark View显示隐藏

/// 显示视频播放界面长按弹框界面
- (void)showVideoSelectViewWithModel:(id)msgModel url:(nullable NSString *)url vc:(UIViewController *)fromVc from:(nullable NSString *)from fromType:(nullable NSString *)fromType fileId:(nullable NSString *)fileId canNotShare:(BOOL)canNotShare canNotCollect:(BOOL)canNotCollect canNotSave:(BOOL)canNotSave isUc:(BOOL)isUc fileName:(NSString *)fileName;
- (void)showVideoSelectViewWithModel:(id)msgModel url:(nullable NSString *)url vc:(UIViewController *)fromVc from:(nullable NSString *)from fromType:(nullable NSString *)fromType fileId:(nullable NSString *)fileId fileName:(NSString *)fileName;

/// 显示分享完致信后的提示页面
- (void)showShareToUCFinishedViewWithVc:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
