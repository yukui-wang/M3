//
//  BaiduFaceIdApp.h
//  M3
//
//  Created by wujiansheng on 2019/2/27.
//

#import <Foundation/Foundation.h>
#import "BaiduAppError.h"

//人脸识别
@interface BaiduFaceIdApp : NSObject
@property(nonatomic, copy) NSString *faceDetectAppID ;
@property(nonatomic, copy) NSString *faceDetectAPIKey;
@property(nonatomic, copy) NSString *faceDetectSecretKey;
@property(nonatomic, retain) BaiduAppError *baiduAppError;
- (id)initWithBaiduFaceIdApp:(NSDictionary *)dic;
@end

