//
//  CMPTransferDataPlugin.h
//  M3
//
//  Created by CRMO on 2018/10/17.
//

#import <CordovaLib/CDVPlugin.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPTransferDataPlugin : CDVPlugin

/**
 参数：key
 返回值：data

 @param command 存放中转临时变量
 */
- (void)getData:(CDVInvokedUrlCommand*)command;


/**
 往临时中转数据中心存数据

 @param data 需要存储的数据
 @return 存储的key，用时间戳生成
 */
NSString* saveData(NSString *data);

@end

NS_ASSUME_NONNULL_END
