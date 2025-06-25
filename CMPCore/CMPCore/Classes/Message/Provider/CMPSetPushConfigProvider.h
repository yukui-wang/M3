//
//  CMPSetPushConfigProvider.h
//  M3
//
//  Created by 程昆 on 2019/10/9.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPSetPushConfigProvider : CMPObject

/**
同步手机静音设置
*/
- (void)setPushConfigMuteSetting:(NSString *)muteSetting;

@end

NS_ASSUME_NONNULL_END
