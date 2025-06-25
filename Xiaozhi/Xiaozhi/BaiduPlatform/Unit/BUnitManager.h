//
//  BUnitManager.h
//  BUnitManager
//
//  Created by 阿凡树 on 2017/7/27.
//  Copyright © 2017年 Baidu. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "BUnitResult.h"
@interface BUnitManager : NSObject

@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) NSString *session;

//版本
@property (nonatomic, retain) NSString *version;

/**2.0使用 start**/
//开发者需要在客户端生成的唯一id，用来定位请求，响应中会返回该字段。对话中每轮请求都需要一个log_id

@property (nonatomic, readwrite, retain) NSString *logId;
//与BOT对话的用户id（如果BOT客户端是用户未登录状态情况下对话的，也需要尽量通过其他标识（比如设备id）来唯一区分用户），方便今后在平台的日志分析模块定位分析问题、从用户维度统计分析相关对话情况。
@property (nonatomic, readwrite, retain) NSString *userId;
/**2.0使用 end**/

+ (instancetype)sharedInstance;

// 设置场景ID，场景ID在官网后台创建。
- (void)setSceneID:(NSInteger)sceneID;

// 重置对话状态
- (void)resetDialogueState;

// 获取accessToken
- (void)getAccessTokenWithAK:(NSString *)ak SK:(NSString *)sk
                  completion:(void (^)(NSError *error, NSString* token))completionBlock;

// 和bot进行对话
- (void)askWord:(NSString *)word completion:(void (^)(NSError *error, BUnitResult* resultObject))completionBlock;

@end
