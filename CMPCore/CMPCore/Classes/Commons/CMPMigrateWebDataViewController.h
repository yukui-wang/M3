//
//  CMPMigrateWebDataViewController.h
//  M3
//
//  Created by youlin on 2017/11/22.
//

#import <CordovaLib/CDVViewController.h>

@interface CMPMigrateWebDataViewController : CDVViewController

@property (nonatomic, copy) void (^migarateWebDataDidFinished)(NSError *error);
@property (assign, nonatomic) BOOL migarateFinish;

+ (CMPMigrateWebDataViewController *)shareInstance;
// 检查是否需要从H5数据迁移到原生
+ (BOOL)needMoveWebDataToNative;

// 初始化服务器版本
- (void)initSeverVersion:(NSString *)serverVersion companyID:(NSString *)companyID;

- (void)startMigrateWebDataToNative:(void(^)(NSError *error))didFinished;
- (void)saveServerInfo:(NSString *)data;
- (void)saveLoginCache:(NSString *)data loginName:(NSString *)loginName password:(NSString *)password serverVersion:(NSString *)version;
- (void)updateAccountID:(NSString *)accountID
            accountName:(NSString *)accountName
              shortName:(NSString *)shortName
            accountCode:(NSString *)accountCode
             configInfo:(NSString *)configInfo
            currentInfo:(id)currentInfo
                preInfo:(id)preInfo;
- (void)saveConfigInfo:(NSString *)data;
- (void)saveGestureState:(NSUInteger)state;
- (void)saveV5Product:(NSString *)product;
-(void)excuteJs:(NSString *)jsStr result:(void(^)(id obj,NSError* error))result;
+(void)reset;
-(void)evalAfterWebDataDidReady:(void(^)(id,NSError*))completion;
-(void)logoutWithResult:(void(^)(id obj, NSError *error))result;

@end
