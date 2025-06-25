//
//  CMPContactsManager.h
//  CMPCore
//
//  Created by wujiansheng on 2016/12/28.
//
//

#import <CMPLib/CMPObject.h>
#import "CMPContactsResult.h"
#import <CMPLib/CMPOfflineContactMember.h>
#import "CMPContactsTableManager.h"

#define kContactsUpdate_Fail @"kContactsUpdate_Fail"
#define kContactsUpdate_Finish @"kContactsUpdate_Finish"
#define kContactsUpdate_Begin @"kContactsUpdate_Begin"
#define kFequestLoadFinish @"fequestLoadFinish"

typedef void (^NameBlock)(NSArray *,BOOL);


typedef NS_ENUM(NSInteger, OfflineStatus){
    OfflineStatusNormal = 0,
    OfflineStatusUpating,
    OfflineStatusFinish,
    OfflineStatusFail
};
typedef NS_ENUM(NSInteger, OfflineTableStatus){
    OfflineTableStatusNormal,
    OfflineTableStatusInserting,//正在插入数据库
};

typedef void(^CMPContactsManagerCompleteBlock)(BOOL isSuccessful,id data, NSError *error);

@class OfflineOrgUnit;

@protocol CMPContactsManagerDelegate;

@interface CMPContactsManager : CMPObject

+ (CMPContactsManager *)defaultManager;
- (void)beginUpdate;
- (OfflineStatus)offlineStatus;//跟新状态
- (void)allMemberInAz:(void (^)(CMPContactsResult *))block;
//根据人员Id 部门id 单位id 查询人员信息
- (void)memberInfoForId:(NSString *)memberId
           departmentId:(NSString *)departmentId
              accpuntId:(NSString *)accpuntId
             completion:(void (^)(CMPOfflineContactMember *))completion;
- (void)memberNameList:(NameBlock)block;
- (void)allFrequentContact:(void (^)(CMPContactsResult *))block;
/*
 目前仅小致使用
 tbName 表的名称 kContactsTempTable：通讯录  kFlowTempTable：选人
 */
- (void)memberListForNameArray:(NSArray *)nameArray
                        tbName:(NSString *)tbName
                    completion:(void (^)(NSArray *))completion;

- (void)memberListForName:(NSString *)name completion:(void (^)(NSArray *))completion;
- (void)memberListForPinYin:(NSString *)name completion:(void (^)(NSArray *))completion;

/*
 目前仅小致使用
 tbName 表的名称 kContactsTempTable：通讯录  kFlowTempTable：选人
 */
- (void)searchMemberWithKey:(NSString *)key
                     tbName:(NSString *)tbName
                 completion:(void (^)(NSArray *))completion;

- (void)memberNameForId:(NSString *)memberId completion:(void (^)(NSString *))completion;
- (void)memberNamefromServerForId:(NSString *)memberId completion:(void (^)(NSString *))completion;
- (void)memberNamesForIds:(NSArray *)memberIds completion:(void (^)(NSDictionary *))completion;
- (void)phoneForId:(NSString *)memberId completion:(void (^)(NSString *))completion;
//常用联系人前十位
- (void)topTenFrequentContact:(void (^)(NSArray *))block addressbook:(BOOL)adressbook;

#pragma mark-
#pragma mark-组织架构离线
// 根据单位ID，获取单位信息
- (void)accountInfoWithAccountID:(NSString *)accountID
                      completion:(void (^)(BOOL isContactReady, OfflineOrgUnit *account))completion;

// 根据单位ID，获取部门列表
- (void)departmentsWithAccountID:(NSString *)accountID
                      completion:(void (^)(BOOL isContactReady, OfflineOrgUnit *myDepartment, NSArray<OfflineOrgUnit *> *childDepartments))completion;

// 根据单位ID、部门ID，获取人员列表、子部门列表
- (void)childrensWithAccoundID:(NSString *)accoundID
                  departmentID:(NSString *)departmentID
                       pageNum:(NSNumber *)pageNum
                   memberFirst:(BOOL)memberFirst
                    completion:(void (^)(BOOL isContactReady, NSInteger total, NSArray<OfflineOrgUnit *> *childDepartments, NSArray<CMPOfflineContactMember *> *members))completion;

//根据人员Id 单位id 查询人员信息
- (void)memberInfoForID:(NSString *)memberID
              accountID:(NSString *)accountID
             completion:(void (^)(CMPOfflineContactMember *))completion;

// 获取全部人员
- (void)allMembersCompletion:(void(^)(NSArray<CMPOfflineContactMember *> *allMembers))completion;
//更新常用联系人的信息
- (void)updateFrequentMemberInfo:(NSArray *)memberList completion:(void (^)(NSArray *))completion;
@end

