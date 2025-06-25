//
//  Target_FaceDetection.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/4.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Target_FaceDetection : NSObject
//人脸识别
- (void)Action_showFaceDetectionView:(NSDictionary *)params;
//删除人脸识别数据
- (void)Action_removeFace:(NSDictionary *)params;
//是否注册过人脸识别
- (void)Action_isRegisteredFace:(NSDictionary *)params;
//是否有人脸识别权限
- (BOOL)Action_hasFacePermission:(NSDictionary *)params;
- (void)Action_cleanFaceData;

@end

NS_ASSUME_NONNULL_END
