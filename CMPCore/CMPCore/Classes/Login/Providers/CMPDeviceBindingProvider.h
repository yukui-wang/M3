//
//  CMPDeviceBindingProvider.h
//  M3
//
//  Created by CRMO on 2018/9/11.
//

#import <CMPLib/CMPObject.h>

typedef void(^DeviceBindingDidSuccess)(NSString *successMesssage);
typedef void(^DeviceBindingDidFail)(NSString *failMesssage);

@interface CMPDeviceBindingProvider : CMPObject


/**
 绑定设备

 @param success 成功回调
 @param fail 失败回调
 */
- (void)deviceBindingSuccess:(DeviceBindingDidSuccess)success
                        fail:(DeviceBindingDidFail)fail;

@end
