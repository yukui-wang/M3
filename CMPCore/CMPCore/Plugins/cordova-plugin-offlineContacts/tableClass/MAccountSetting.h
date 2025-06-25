//
//  MAccountSetting.h
//  CMPCore
//
//  Created by wujiansheng on 2017/1/11.
//
//

#import <CMPLib/CMPObject.h>

@interface MAccountSetting : CMPObject
/*   查看范围设置
*/
@property(nonatomic, assign)int viewSetType;
/**
 * 关键信息设置  1公开 ，2 公开但对keyInfoList中的隐藏，3隐藏 但对keyInfoList公共
 */
@property(nonatomic, assign)int keyInfoSet;
/**
 * 对哪些关键信息隐藏。 1 职务加手机号，2 手机 3 职务
 */
@property(nonatomic, assign)int keyInfoType;
/**
 * 单个控制
 */
@property(nonatomic, retain)NSArray *viewScopeList;
@property(nonatomic, retain)NSArray *keyInfoList;
@end
