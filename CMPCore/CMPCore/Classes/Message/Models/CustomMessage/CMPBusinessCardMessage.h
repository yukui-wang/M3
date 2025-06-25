//
//  CMPBusinessCardMessage.h
//  M3
//
//  Created by 程昆 on 2019/10/28.
//

#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPBusinessCardMessage : RCMessageContent


/*!
 人员ID
 */
@property (nonatomic,copy) NSString *personnelId;
/*!
 姓名
 */
@property (nonatomic,copy) NSString *name;
/*!
部门
*/
@property (nonatomic,copy) NSString *department;
/*!
岗位
*/
@property (nonatomic,copy) NSString *post;
/*!
扩展字段
*/
@property (nonatomic,copy) NSString *extraData;


@end

NS_ASSUME_NONNULL_END
