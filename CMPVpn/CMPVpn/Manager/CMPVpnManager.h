//
//  CMPVpnManager.h
//  CMPVpn
//
//  Created by Shoujian Rao on 2022/4/11.
//

#import <Foundation/Foundation.h>
//#import <CMPVpn/CMPVpnConfigModel.h>

#define USE_SANGFOR_VPN 1  //注释本句，可以打包noVPN的包。【需要删除**（两个）**SangforSDK.framework】
@class CMPServerVpnModel;

typedef void(^VpnCommonRsltBlk)(id obj,id ext);
typedef BOOL(^VpnCheckRsltBlk)(id obj,id ext,CMPServerVpnModel *preVpnConfig);

typedef enum : NSUInteger {
    CheckRollbackType_No = 0,
    CheckRollbackType_WhenFail,
    CheckRollbackType_All,
} CheckRollbackType;

#define kVPNNotificationName_ProcessRenewPwd @"kVPNNotificationName_ProcessRenewPwd"

@interface CMPVpnManager : NSObject

@property (nonatomic,assign,readonly) BOOL globalClose;
@property (nonatomic,strong,readonly) CMPServerVpnModel *vpnConfig;
@property (nonatomic,copy, readonly) NSString *resetPwdRuleJson;

+ (instancetype)sharedInstance;

//- (void)loginVpnWithVpnUrl:(NSString *)vpnUrl vpnName:(NSString *)vpnName vpnPwd:(NSString *)vpnPwd success:(void(^)(void))successBlock fail:(void(^)(NSString *errStr))failedBlock;
- (void)loginVpnWithConfig:(CMPServerVpnModel *)config
                   process:(VpnCommonRsltBlk)processBlock
                   success:(VpnCommonRsltBlk)successBlock
                      fail:(VpnCommonRsltBlk)failedBlock;

-(void)checkVpnConfig:(CMPServerVpnModel *)checkVpnConfig
         checkProcess:(VpnCheckRsltBlk)checkProcessBlock
         checkSuccess:(VpnCheckRsltBlk)checkSuccessBlock
            checkFail:(VpnCheckRsltBlk)checkFailedBlock
         needRollback:(CheckRollbackType)needRollback
      rollbackProcess:(VpnCommonRsltBlk)rollbackProcessBlock
      rollbackSuccess:(VpnCommonRsltBlk)rollbackSuccessBlock
rollbackFail:(VpnCommonRsltBlk)rollbackFailedBlock;

- (void)logoutVpnWithResult:(VpnCommonRsltBlk)resultBlock;


+ (void)saveVpnWithServerId:(NSString *)serverID
                     vpnUrl:(NSString *)vpnUrl
               vpnLoginName:(NSString *)vpnLoginName
                vpnLoginPwd:(NSString *)vpnLoginPwd
                     vpnSPA:(NSString *)spa;

+ (void)deleteVpnByServerID:(NSString *)serverID;

+ (CMPServerVpnModel *)getVpnModelByServerID:(NSString *)serverID;

//error alert
+ (void)showAlertWithError:(NSString *)errStr sureAction:(void(^)(void))sureBlock;

+ (BOOL)isVpnConnected;

+(void)openLog:(BOOL)open;

+(NSString *)archieveLog:(NSString *)logPath;

+(void)setManagerBlk:(void(^)(NSInteger,id))blk;

-(void)showRenewPwdAlert;

-(BOOL)setLanguage:(NSString *)language;

-(BOOL)updatePwd:(NSString *)newPwd;

-(VpnCommonRsltBlk)loginProcessBlock;

@end

