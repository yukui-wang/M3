//
//  CMPSignMessage.h
//  M3
//
//  Created by 程昆 on 2020/1/8.
//

#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPSignMessage : RCMessageContent

/*!
 id
 */
@property (nonatomic,copy) NSString *m_id;
/*!
 消息类型
 */
@property (nonatomic,copy) NSString *content;
/*!
 消息内容
 */
@property (nonatomic,copy) NSString *type;

/**
 * messageCard
 */
@property (nonatomic,copy) NSDictionary *messageCard;


#pragma mark - messageCardContent 解析字段

/*!
 签到人姓名
 */
@property (nonatomic,copy) NSString *name;
/*!
 签到时间戳
 */
@property (nonatomic,assign)long long signTime;
/*!
签到类型
*/
@property (nonatomic,copy) NSString *signType;
/*!
签到地址
*/
@property (nonatomic,copy) NSString *address;
/*!
经度
*/
@property (nonatomic,assign) double latitude;
/*!
纬度
*/
@property (nonatomic,assign) double longitude;
/**
 * 应用包ID
 */
@property (nonatomic,copy) NSString *messageCategory;
/**
 * 移动端穿透参数
 */
@property (nonatomic,copy) NSString *mobileUrlParam;
/**
 * pc端穿透url
 */
@property (nonatomic,copy) NSString *pcUrl;
/**
 *  扩展字段
 */
@property (nonatomic,copy) NSString *extraData;

#pragma mark - 临时缓存字段
/**
 * appName
 */
@property (nonatomic,copy) NSString *appName;
/**
 * tagImageUrl
 */
@property (nonatomic,copy) NSString *tagImageUrl;
/**
 * addressImageUrl
 */
@property (nonatomic,copy) NSString *addressImageUrl;

@end

NS_ASSUME_NONNULL_END
