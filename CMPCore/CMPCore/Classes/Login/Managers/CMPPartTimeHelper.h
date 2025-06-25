//
//  CMPPartTimeHelper.h
//  M3
//
//  Created by CRMO on 2018/6/26.
//

#import <CMPLib/CMPObject.h>
#import <CMPLib/CMPPartTimeModel.h>

typedef void(^CMPPartTimeHelperSwitchDidFinish)(CMPPartTimeModel *partTime, NSError *error);

@interface CMPPartTimeHelper : CMPObject

/**
 获取当前登录账号的兼职单位列表
 从数据库中获取。同时触发refreshPartTimeList
 
 @return 兼职单位数组
 */
- (NSArray<CMPPartTimeModel *> *)partTimeList;

/**
 当前兼职单位信息
 */
- (CMPPartTimeModel *)currentPartTime;

- (NSString *)currentAccountShortName;

/**
 更新当前登录账号的兼职单位列表
 更新完成后存到数据库中
 */
- (void)refreshPartTimeList;

/**
 切换兼职单位

 @param partTime 需要切换到的单位
 */
- (void)switchPartTime:(CMPPartTimeModel *)partTime
            completion:(CMPPartTimeHelperSwitchDidFinish)completion;

@end
