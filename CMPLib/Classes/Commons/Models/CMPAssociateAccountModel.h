//
//  CMPAssociateAccountModel.h
//  M3
//
//  Created by CRMO on 2018/6/13.
//

#import "CMPObject.h"

@class CMPLoginAccountModel, CMPServerModel;
@interface CMPAssociateAccountModel : CMPObject

@property (strong, nonatomic) NSString *serverID;
@property (strong, nonatomic) NSString *serverUniqueID;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *groupID;
@property (strong, nonatomic) NSNumber *createTime;
@property (strong, nonatomic) NSNumber *switchTime;
@property (assign, nonatomic) NSInteger unreadCount;
@property (strong, nonatomic) CMPLoginAccountModel *loginAccount;
@property (strong, nonatomic) CMPServerModel *server;

@property (strong, nonatomic) NSString *extend1;
@property (strong, nonatomic) NSString *extend2;
@property (strong, nonatomic) NSString *extend3;
@property (strong, nonatomic) NSString *extend4;
@property (strong, nonatomic) NSString *extend5;
@property (strong, nonatomic) NSString *extend6;
@property (strong, nonatomic) NSString *extend7;
@property (strong, nonatomic) NSString *extend8;
@property (strong, nonatomic) NSString *extend9;
@property (strong, nonatomic) NSString *extend10;

/**
 根据当前时间戳生成groupID

 @return 新生成的groupID
 */
+ (NSString *)generateGroupID;

@end
