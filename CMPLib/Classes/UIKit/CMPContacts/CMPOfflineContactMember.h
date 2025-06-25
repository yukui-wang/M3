//
//  CMPOfflineContactMember.h
//  CMPCore
//
//  Created by wujiansheng on 2017/1/5.
//
//

#import "CMPObject.h"

#define kContactMemberHideVaule @"******"

@interface CMPOfflineContactMember : CMPObject
@property(nonatomic, copy)NSString *orgID;//人员id
@property(nonatomic, copy)NSString *sort;
@property(nonatomic, copy)NSString *name;//人员名字
@property(nonatomic, copy)NSString *nameSpell;//人员拼音
@property(nonatomic, copy)NSString *nameSpellHead;//人员拼音首字母
@property(nonatomic, copy)NSString *tel;//办公电话
@property(nonatomic, copy)NSString *mobilePhone;//移动电话
@property(nonatomic, copy)NSString *mail;//邮箱
@property(nonatomic, copy)NSString *mark;
@property(nonatomic, copy)NSString *postName;//主岗

@property(nonatomic, copy)NSString *department;//部门
@property(nonatomic, copy)NSString *departmentId;//部门
@property(nonatomic, copy)NSString *account;//单位
@property(nonatomic, copy)NSString *accountId;//单位Id
@property(nonatomic, copy)NSString *level;//职务级别
@property(nonatomic, copy)NSString *levelId;//职务级别id
@property(nonatomic, copy)NSString *postId;//主岗

// 1130新增字段
@property (strong, nonatomic) NSArray *parentDepts; // 父部门信息
@property (strong, nonatomic) NSArray *deputyPost; // 副岗信息
@property (strong, nonatomic) NSString *workAddr; // 工作地址
@property (strong, nonatomic) NSString *wx; // 微信
@property (strong, nonatomic) NSString *wb; // 微博
@property (strong, nonatomic) NSString *homeAddr; // 家庭住址
@property (strong, nonatomic) NSString *port; // 邮编
@property (strong, nonatomic) NSString *communicationAddr; // 通讯地址
@property (copy, nonatomic) NSString *ins; // 人员是否是编外(1-内部  0-编外)
@property (copy, nonatomic) NSString *internal; // 人员所属部门是否是编外(1-内部  0-编外)

//手机号码是否可用
- (BOOL)mobilePhoneAvailable;

@end
