//
//  CMPShareToUcManager.h
//  M3
//
//  Created by MacBook on 2019/12/2.
//

#import <Foundation/Foundation.h>
#import "CMPMessageObject.h"


NS_ASSUME_NONNULL_BEGIN

@interface CMPShareToUcManager : NSObject

+ (instancetype)manager;

#pragma mark 文件分享到致信

- (void)showForwardMessageViewWithFilePath:(NSString *)filePath inVC:(UIViewController *)inVC;

- (void)showSelectContactViewWithFilePaths:(NSArray *)filePaths inVC:(UIViewController *)inVC willForwardMsg:(void(^)(void))willForwardMsg forwardSucess:(void(^)(void))forwardSucess forwardSucessWithMsgObj:(void(^)(CMPMessageObject *msgObj, NSArray *fileList))forwardSucessforwardSucessWithMsgObj forwardFailed:(void(^)(void))forwardFailed;

/// 显示 选择联系人 view 非文件分享
- (void)showSelectContactViewInVC:(UIViewController *)inVC param:(NSDictionary *)param willForwardMsg:(void(^)(void))willForwardMsg forwardSucess:(void(^)(CMPMessageObject *msgObj))forwardSucess forwardFailed:(void(^)(void))forwardFailed;


@end

NS_ASSUME_NONNULL_END
