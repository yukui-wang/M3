//
//  CMPSignMessage.h
//  M3
//
//  Created by 程昆 on 2020/1/8.
//

#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPSettingMessage : RCMessageContent

/*!
 当前人id
 */
@property (nonatomic,copy) NSString *memberId;
/*!
 会话(人/组群)id
 */
@property (nonatomic,copy) NSString *talkId;
/*!
 记录类型
 0:消息免打扰
 1:顶置
 */
@property (nonatomic,assign) int recordType;
/*!
 记录值
 0:消息免打扰/置顶
 1:未设置免打扰/置顶
 */
@property (nonatomic,assign) int recordValue;
/*!
会话类型
0:个人
1:群组
*/
@property (nonatomic,assign) int talkType;

@end

NS_ASSUME_NONNULL_END

