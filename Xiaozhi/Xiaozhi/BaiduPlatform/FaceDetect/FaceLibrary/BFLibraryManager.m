//
//  BFLibraryManager.m
//  M3
//
//  Created by wujiansheng on 2018/12/17.
//

#define kBFAccessTokenUrl  @"https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=%@&client_secret=%@"
#define kBFAddFaceUrl @"https://aip.baidubce.com/rest/2.0/face/v3/faceset/user/add"
#define kBFUpdateFaceUrl @"https://aip.baidubce.com/rest/2.0/face/v3/faceset/user/update"
#define kBFDeleteFaceUrl @"https://aip.baidubce.com/rest/2.0/face/v3/faceset/user/delete"
#define kBFSearchFaceUrl @"https://aip.baidubce.com/rest/2.0/face/v3/search"
#define kBFIsRegisteredFaceUrl @"https://aip.baidubce.com/rest/2.0/face/v3/faceset/user/get"

#define kBFSimilarityScore 80.0

#import "BFLibraryManager.h"
#import "XZCore.h"
#import "SPTools.h"
#import <IDLFaceSDK/IDLFaceSDK.h>
#import <CMPLib/NSString+CMPString.h>

@interface BFLibraryManager ()

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, retain) NSURLSessionTask * task;

@end

@implementation BFLibraryManager

+ (instancetype)sharedInstance {
    static BFLibraryManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BFLibraryManager alloc] init];
    });
    return instance;
}

//人脸识别基础设置
- (void)setupFaceSDKInfo {
    // 设置最小检测人脸阈值
    [[FaceSDKManager sharedInstance] setMinFaceSize:200];
    // 设置截取人脸图片大小
    [[FaceSDKManager sharedInstance] setCropFaceSizeWidth:400];
    // 设置人脸遮挡阀值
    [[FaceSDKManager sharedInstance] setOccluThreshold:0.5];
    // 设置亮度阀值
    [[FaceSDKManager sharedInstance] setIllumThreshold:40];
    // 设置图像模糊阀值
    [[FaceSDKManager sharedInstance] setBlurThreshold:0.7];
    // 设置头部姿态角度
    [[FaceSDKManager sharedInstance] setEulurAngleThrPitch:10 yaw:10 roll:10];
    // 设置是否进行人脸图片质量检测
    [[FaceSDKManager sharedInstance] setIsCheckQuality:YES];
    // 设置超时时间
    [[FaceSDKManager sharedInstance] setConditionTimeout:BFConditionTimeout_Unliveness];
    // 设置人脸检测精度阀值
    [[FaceSDKManager sharedInstance] setNotFaceThreshold:0.6];
    // 设置照片采集张数
    [[FaceSDKManager sharedInstance] setMaxCropImageNum:1];
}

//设置权限
- (void)settingAuthentication {
    //权限
    NSString *name = [SPTools isM3InHouse] ? BFACE_LICENSE_NAME_DEV : BFACE_LICENSE_NAME_DIS;
    NSString* licensePath = [[NSBundle mainBundle] pathForResource:name ofType:BFACE_LICENSE_SUFFIX];
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:licensePath], @"license文件路径不对，请仔细查看文档");
    NSString *licenseId = [SPTools isM3InHouse] ? BFACE_LICENSE_ID_DEV : BFACE_LICENSE_ID_DIS;
    [[FaceSDKManager sharedInstance] setLicenseID:licenseId andLocalLicenceFile:licensePath];
    NSLog(@"canWork = %d",[[FaceSDKManager sharedInstance] canWork]);
    //accessToken
    
    self.accessToken = @"";
    __weak typeof(self) weakSelf = self;
    [self obtainAccessToken:^(NSString *token) {
        weakSelf.accessToken = token;
    }];
}
- (void)cleanData {
    self.groupId = nil;
    self.accessToken = nil;
    if (self.task) {
        [self.task cancel];
    }
    self.task = nil;
}

- (void)obtainAccessToken:(void (^)(NSString *token))completionBlock {
    
    NSString *key = [[[XZCore sharedInstance] baiduFaceInfo] faceDetectAPIKey];
    NSString *skey = [[[XZCore sharedInstance] baiduFaceInfo] faceDetectSecretKey];
    
    __weak typeof(self) weakSelf = self;
    NSString* url = [NSString stringWithFormat:kBFAccessTokenUrl,key,skey];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    request.HTTPShouldHandleCookies = false;
    self.task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        if (error == nil) {
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            completionBlock(dict[@"access_token"]);
        }
        weakSelf.task = nil;
    }];
    [self.task resume];
}


- (void)faceRequestWithUrl:(NSString *)url
                     param:(NSDictionary *)param
                completion:(void (^)(NSDictionary *result , NSError *error))completionBlock {
    __weak typeof(self) weakSelf = self;
    NSString *urlStr = [NSString stringWithFormat:@"%@?access_token=%@",url,self.accessToken];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    request.HTTPMethod = @"POST";
    request.HTTPShouldHandleCookies = false;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = jsonData;
    self.task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        if (error == nil) {
            NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"[face result][%@]",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            completionBlock(result,nil);
        }
        else {
            completionBlock(nil,error);
        }
        weakSelf.task = nil;
    }];
    [self.task resume];
}

- (NSString *)availableId:(NSString *)aId {
    // group_id  && user_id 由数字、字母、下划线组成
    if ([NSString isNull:aId]) {
        return @"";
    }
    return [aId replaceCharacter:@"-" withString:@"_"];
}

- (NSString *)userAvailableId:(NSString *)aId  {
    if ([NSString isNull:aId]) {
        return @"";
    }
    return [aId replaceCharacter:@"_" withString:@"-"];
}

- (void)createFace:(NSString *)imageStr
            userId:(NSString *)userId
          userInfo:(NSString *)userInfo
        completion:(void (^)(NSDictionary *result , NSError *error))completionBlock {
    //人脸注册--- 创建上传人脸连数据
    NSDictionary* param = @{@"user_id":[self availableId:userId],
                            @"user_info":userInfo?userInfo:@"",
                            @"group_id":[self availableId:self.groupId],
                            @"image_type":@"BASE64",
                            @"liveness_control":@"NORMAL",
                            @"quality_control":@"NORMAL",
                            @"image":imageStr};
    [self faceRequestWithUrl:kBFAddFaceUrl param:param completion:^(NSDictionary *resultObject,NSError *error) {
        NSInteger errorCode = [resultObject[@"error_code"] integerValue];
        if (errorCode == 0) {
            NSDictionary* result = @{@"success":[NSNumber numberWithBool:YES]};
            completionBlock(result,nil);
        }
        else {
            NSString *errorMsg = resultObject[@"error_msg"];
            errorMsg = errorMsg ? errorMsg: @"网络请求错误";
            NSError *err = [NSError errorWithDomain:errorMsg code:errorCode userInfo:nil];
            completionBlock(nil,err);
        }
        /*
         {"error_code":0,"error_msg":"SUCCESS","log_id":305486850152173171,"timestamp":1545015217,"cached":0,"result":{"face_token":"9eb35e49ad952343a2875db71dcaa3ec","location":{"left":34.62,"top":45.42,"width":137,"height":140,"rotation":-2}}}
         */
    }];
}

- (void)updateFace:(NSString *)imageStr
            userId:(NSString *)userId
          userInfo:(NSString *)userInfo
        completion:(void (^)(NSDictionary *result , NSError *error))completionBlock {
    //人脸更新--- 更新人脸数据，会覆盖对应人员的数据
    NSDictionary* param = @{@"user_id":[self availableId:userId],
                            @"user_info":userInfo?userInfo:@"",
                            @"group_id":[self availableId:self.groupId],
                            @"image_type":@"BASE64",
                            @"liveness_control":@"NORMAL",
                            @"quality_control":@"NORMAL",
                            @"image":imageStr};
    [self faceRequestWithUrl:kBFUpdateFaceUrl param:param completion:^(NSDictionary *resultObject,NSError *error) {
        NSInteger errorCode = [resultObject[@"error_code"] integerValue];
        if (errorCode == 0) {
            NSDictionary* result = @{@"success":[NSNumber numberWithBool:YES]};
            completionBlock(result,nil);
        }
        else {
            NSString *errorMsg = resultObject[@"error_msg"];
            errorMsg = errorMsg ? errorMsg: @"网络请求错误";
            NSError *err = [NSError errorWithDomain:errorMsg code:errorCode userInfo:nil];
            completionBlock(nil,err);
        }
        /*
         {"error_code":0,"error_msg":"SUCCESS","log_id":305486850152649191,"timestamp":1545015264,"cached":0,"result":{"face_token":"253bed095d3f772a6abc3d9a03df42ee","location":{"left":29.95,"top":29.14,"width":147,"height":152,"rotation":2}}}
         {"error_code":223103,"error_msg":"user is not exist","log_id":304592850154020231,"timestamp":1545015402,"cached":0,"result":null}
         */
    }];
}

- (void)removeFace:(NSString *)userId
        completion:(void (^)(NSDictionary *result , NSError *error))completionBlock {
    NSDictionary* param = @{@"user_id":[self availableId:userId],
                            @"group_id":[self availableId:self.groupId]};
    [self faceRequestWithUrl:kBFDeleteFaceUrl param:param completion:^(NSDictionary *resultObject,NSError *error) {
        NSInteger errorCode = [resultObject[@"error_code"] integerValue];
        BOOL result = (errorCode== 0 || errorCode == 223103) ? YES : NO;//223103 user is not exist
        if (result) {
            NSDictionary* result = @{@"success":[NSNumber numberWithBool:YES]};
            completionBlock(result,nil);
        }
        else {
            NSString *errorMsg = resultObject[@"error_msg"];
            errorMsg = errorMsg ? errorMsg: @"网络请求错误";
            NSError *err = [NSError errorWithDomain:errorMsg code:errorCode userInfo:nil];
            completionBlock(nil,err);
        }
        /*
         {"error_code":0,"error_msg":"SUCCESS","log_id":304592850152375341,"timestamp":1545015237,"cached":0,"result":null}
         
         {"error_code":223103,"error_msg":"user is not exist","log_id":305486850154326171,"timestamp":1545015432,"cached":0,"result":null}
         */
    }];
}

- (void)removeFaceWithUserId:(NSString *)userId
                  completion:(void (^)(NSDictionary *result , NSError *error))completionBlock{
    //人脸删除(删除用户)--- 删除人脸连数据
    
    if (!self.accessToken) {
        //先判断 accessToken
        __weak typeof(self) weakSelf = self;
        [self obtainAccessToken:^(NSString *token) {
            weakSelf.accessToken = token;
            [weakSelf removeFace:userId completion:completionBlock];
        }];
    }
    else {
        [self removeFace:userId completion:completionBlock];
    }
}


- (void)checkFace:(NSString *)imageStr
           userId:(NSString *)userId
       completion:(void (^)(NSDictionary *result , NSError *error))completionBlock {
    //--- 判断识别人员是否是某个人员（通过userId返回bool）
    NSDictionary* param = @{@"image":imageStr,
                            @"image_type":@"BASE64",
                            @"liveness_control":@"NORMAL",
                            @"quality_control":@"NORMAL",
                            @"user_id":[self availableId:userId],
                            @"group_id_list":[self availableId:self.groupId]};
    [self faceRequestWithUrl:kBFSearchFaceUrl param:param completion:^(NSDictionary *resultObject,NSError *error) {
        NSInteger errorCode = [resultObject[@"error_code"] integerValue];
        NSString *errorMsg = resultObject[@"error_msg"];
        errorMsg = errorMsg ? @"不是本人": @"网络请求错误";
        if (errorCode == 0) {
            NSDictionary *result = resultObject[@"result"];
            NSArray *userList = result[@"user_list"];
            NSDictionary *user = [userList firstObject];
            CGFloat score = [user[@"score"] floatValue];
            if (score > kBFSimilarityScore) {
                 NSDictionary* result = @{@"success":[NSNumber numberWithBool:YES]};
                completionBlock(result,nil);
                return ;
            }
            errorMsg = @"不是本人";
        }
        NSError *err = [NSError errorWithDomain:errorMsg code:errorCode userInfo:nil];
        completionBlock(nil,err);
        
        /*
         {"error_code":0,"error_msg":"SUCCESS","log_id":304592850152877661,"timestamp":1545015287,"cached":0,"result":{"face_token":"f11205c89504b832e6aaecbfe6d5ab53","user_list":[{"group_id":"13541005601","user_id":"1223222","user_info":"1223222","score":99.116584777832}]}}
         
         {"error_code":222207,"error_msg":"match user is not found","log_id":304569250154810121,"timestamp":1545015481,"cached":0,"result":null}
         */
    }];
}

- (void)obtainFace:(NSString *)imageStr
        completion:(void (^)(NSDictionary *result , NSError *error))completionBlock{
    //--- 判断识别人员是谁（返回userid）
    NSDictionary* param = @{@"image":imageStr,
                            @"image_type":@"BASE64",
                            @"liveness_control":@"NORMAL",
                            @"quality_control":@"NORMAL",
                            @"group_id_list":[self availableId:self.groupId]};
    [self faceRequestWithUrl:kBFSearchFaceUrl param:param completion:^(NSDictionary *resultObject,NSError *error) {
        NSInteger errorCode = [resultObject[@"error_code"] integerValue];
        NSString *errorMsg = resultObject[@"error_msg"];
        errorMsg = errorMsg ? errorMsg: @"网络请求错误";
        if (errorCode == 0) {
            NSDictionary *result = resultObject[@"result"];
            NSArray *userList = result[@"user_list"];
            NSDictionary *user = [userList firstObject];
            CGFloat score = [user[@"score"] floatValue];
            if (score > kBFSimilarityScore) {
                NSDictionary *result = @{@"userId":[self userAvailableId:user[@"user_id"]]};
                completionBlock(result,nil);
                return ;
            }
            errorMsg = @"没有找到人员";
        }
        NSError *err = [NSError errorWithDomain:errorMsg code:errorCode userInfo:nil];
        completionBlock(nil,err);
        
        /*
         {"error_code":0,"error_msg":"SUCCESS","log_id":304592850152877661,"timestamp":1545015287,"cached":0,"result":{"face_token":"f11205c89504b832e6aaecbfe6d5ab53","user_list":[{"group_id":"13541005601","user_id":"1223222","user_info":"1223222","score":99.116584777832}]}}
         
         {"error_code":222207,"error_msg":"match user is not found","log_id":304569250154961971,"timestamp":1545015496,"cached":0,"result":null}
         */
    }];
}
//是否注册过人脸
- (void)isRegisteredFace:(NSString *)userId
              completion:(void (^)(NSDictionary *result , NSError *error))completionBlock {
    
    if (!self.accessToken) {
        //先判断 accessToken
        __weak typeof(self) weakSelf = self;
        [self obtainAccessToken:^(NSString *token) {
            weakSelf.accessToken = token;
            [weakSelf isRegisteredFaceInner:userId completion:completionBlock];
        }];
    }
    else {
        [self isRegisteredFaceInner:userId completion:completionBlock];
    }
}
- (void)isRegisteredFaceInner:(NSString *)userId
                   completion:(void (^)(NSDictionary *result , NSError *error))completionBlock {
    NSDictionary* param = @{@"user_id":[self availableId:userId],
                            @"group_id":[self availableId:self.groupId]};
    [self faceRequestWithUrl:kBFIsRegisteredFaceUrl param:param completion:^(NSDictionary *resultObject,NSError *error) {
        NSInteger errorCode = [resultObject[@"error_code"] integerValue];
//        NSString *errorMsg = resultObject[@"error_msg"];
//        errorMsg = errorMsg ? errorMsg: @"网络请求错误";
        BOOL resultBool = NO;

        if (errorCode == 0) {
            NSDictionary *result = resultObject[@"result"];
            NSArray *userList = result[@"user_list"];
            if (userList.count > 0) {
//                NSDictionary* result = @{@"success":[NSNumber numberWithBool:YES]};
//                completionBlock(nil,result);
//                return ;
                resultBool = YES;
            }
//            errorMsg = @"还没注册";
        }
//        NSError *err = [NSError errorWithDomain:errorMsg code:errorCode userInfo:nil];
//        completionBlock(err,nil);
        NSDictionary* result = @{@"success":[NSNumber numberWithBool:resultBool]};
        completionBlock(result,nil);
    }];
}

@end


