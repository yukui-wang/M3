//
//  CMPPartTimeProvider.h
//  M3
//
//  Created by CRMO on 2018/6/26.
//

#import <CMPLib/CMPObject.h>
#import <CMPLib/CMPPartTimeModel.h>

typedef void(^CMPPartTimeListDoneBlock)(NSArray<CMPPartTimeModel *> *partTimes, NSError *error);
typedef void(^CMPPartTimeSwitchDoneBlock)(CMPPartTimeModel *partTime, NSError *error);

@interface CMPPartTimeProvider : CMPObject

/**
 获取兼职单位列表

 @param block 结果回调，如果发生错误，返回error，如果成功error为nil
 */
- (void)partTimeListCompletion:(CMPPartTimeListDoneBlock)block;

/**
 切换兼职单位

 @param accountID 要切换的单位ID
 @param block 切换结果回调，如果发生错误，返回error，如果成功error为nil
 */
- (void)switchPartTimeWithAccountID:(NSString *)accountID
                         completion:(CMPPartTimeSwitchDoneBlock)block;

@end
