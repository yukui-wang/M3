//
//  CMPContactsSearchMemberResponse.h
//  M3
//
//  Created by CRMO on 2017/11/24.
//

#import "CMPBaseResponse.h"

@interface CMPContactsSearchMemberResponseChildren : CMPObject
/**
 * 人员头像
 */
@property (nonatomic , copy) NSString              * img;
/**
 * 类型
 */
@property (nonatomic , copy) NSString              * t;
/**
 * 所属岗位id
 */
@property (nonatomic , copy) NSString              * pId;
/**
 * 所属部门名称
 */
@property (nonatomic , copy) NSString              * dN;
/**
 * 所属部门id
 */
@property (nonatomic , copy) NSString              * dId;
/**
 * id
 */
@property (nonatomic , copy) NSString              * i;
/**
 * 姓名
 */
@property (nonatomic , copy) NSString              * n;
/**
 * 所属岗位名称
 */
@property (nonatomic , copy) NSString              * pN;
/**
 * 所属单位id
 */
@property (nonatomic , copy) NSString              * aId;
/**
 * 手机号码
 */
@property (nonatomic , copy) NSString              * tNm;
/**
 * 办公电话（单位电话）
 */
@property (nonatomic , copy) NSString              * oNm;

// 多维组织搜索专用参数
@property (copy, nonatomic) NSString *p;
@property (copy, nonatomic) NSString *icon;
@property (copy, nonatomic) NSString *orgID;


/** 8.1 新增
 * 所属部门父级。 eg: 致信测试/致信开发部
 */
@property (nonatomic , copy) NSString              * dfn;

@end

@interface CMPContactsSearchMemberResponse : CMPBaseResponse
@property (nonatomic , copy) NSArray<CMPContactsSearchMemberResponseChildren *>              * children;
@property (nonatomic , copy) NSString              * mId;
@property (nonatomic , copy) NSString              * waterMarkName;
@property (nonatomic , copy) NSString              * waterMarkTime;
@property (nonatomic , copy) NSString              * waterMarkEnable;
@property (nonatomic , copy) NSString              * waterMarkDeptName;
@property (nonatomic , copy) NSString              * total;
@property (nonatomic , copy) NSString              * type;
@property (nonatomic , copy) NSString              * name;
@end
