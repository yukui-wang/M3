//
//  BFLibraryManager.h
//  M3
//
//  Created by wujiansheng on 2018/12/17.
//

#import <Foundation/Foundation.h>
#import "BFParameterConfig.h"

@interface BFLibraryManager : NSObject
@property (nonatomic, readwrite, retain) NSString *groupId;
+ (instancetype)sharedInstance;

//人脸识别基础设置
- (void)setupFaceSDKInfo;
//设置权限
- (void)settingAuthentication;
- (void)cleanData;

//人脸注册
- (void)createFace:(NSString *)imageStr
            userId:(NSString *)userId
          userInfo:(NSString *)userInfo
        completion:(void (^)(NSDictionary *result , NSError *error))completionBlock;
//人脸更新
- (void)updateFace:(NSString *)imageStr
            userId:(NSString *)userId
          userInfo:(NSString *)userInfo
        completion:(void (^)(NSDictionary *result , NSError *error))completionBlock;
//人脸删除(删除用户)--- 删除人脸连数据
- (void)removeFaceWithUserId:(NSString *)userId
                  completion:(void (^)(NSDictionary *result , NSError *error))completionBlock;
//--- 判断识别人员是否是某个人员（通过userId返回bool）
- (void)checkFace:(NSString *)imageStr
           userId:(NSString *)userId
       completion:(void (^)(NSDictionary *result , NSError *error))completionBlock;
//--- 判断识别人员是谁（返回userid）
- (void)obtainFace:(NSString *)imageStr
        completion:(void (^)(NSDictionary *result , NSError *error))completionBlock;
//是否注册过人脸
- (void)isRegisteredFace:(NSString *)userId
              completion:(void (^)(NSDictionary *result , NSError *error))completionBlock;
@end
