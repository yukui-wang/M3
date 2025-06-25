//
//  Target_FaceDetection.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/4.
//  Copyright © 2019 wujiansheng. All rights reserved.
//



#import "Target_FaceDetection.h"
#import "BaiduFaceIdApp.h"
#import "BFLibraryManager.h"
#import "BFBaseViewController.h"
#import "BFLivenessViewController.h"
#import "BFDetectionViewController.h"
#import "XZCore.h"
#import <CMPLib/NSString+CMPString.h>

typedef void(^FaceDetectionEndBlock)(NSDictionary *result,NSError *error);
typedef void(^FaceDetectionCancelBlock)(void);

@implementation Target_FaceDetection

- (void)Action_showFaceDetectionView:(NSDictionary *)params {
    NSString *groupId = params[@"groupId"];
    NSString *useId = params[@"useId"];
    UIViewController *presentVC = params[@"viewController"];
    FaceDetectionEndBlock endBlock = params[@"completion"];
    FaceDetectionCancelBlock cancelBlock = params[@"cancelBlock"];
    BFaceHandleType handleType = [params[@"handleType"] integerValue];
   
    NSDictionary *faceParams = params[@"faceParams"];
    BFBaseViewController *viewController = nil;
    BOOL live = [faceParams[@"live"] boolValue];
    if (live) {
        viewController = [[BFLivenessViewController alloc]init];
        ((BFLivenessViewController *)viewController).liveEnum = faceParams[@"liveEnum"];
    }
    else {
        viewController = [[BFDetectionViewController alloc]init];
    }
    viewController.userInfo = faceParams[@"userInfo"];//or token
    viewController.userId = useId;
    viewController.groupId = groupId;
    viewController.handleType = handleType;
    viewController.finishBlock = endBlock;
    viewController.cancelBlock = cancelBlock;
    [presentVC presentViewController:viewController animated:YES completion:nil];
}

- (void)Action_removeFace:(NSDictionary *)params {
    NSString *groupId = params[@"groupId"];
    NSString *useId = params[@"useId"];
    FaceDetectionEndBlock block = params[@"completion"];
    [BFLibraryManager sharedInstance].groupId = groupId;
    [[BFLibraryManager sharedInstance]removeFaceWithUserId:useId completion:block];
}

- (void)Action_isRegisteredFace:(NSDictionary *)params {
    NSString *groupId = params[@"groupId"];
    NSString *useId = params[@"useId"];
    FaceDetectionEndBlock block = params[@"completion"];
    [BFLibraryManager sharedInstance].groupId = groupId;
    [[BFLibraryManager sharedInstance]isRegisteredFace:useId completion:block];
}

- (BOOL)Action_hasFacePermission:(NSDictionary *)params {
    BaiduFaceIdApp *baiduFaceInfo = [[XZCore sharedInstance] baiduFaceInfo];
    BOOL result = YES;
    if (!baiduFaceInfo || [NSString isNull:baiduFaceInfo.faceDetectAPIKey] || [NSString isNull:baiduFaceInfo.faceDetectSecretKey]) {
        result = NO;
    }
    return result;
}

- (void)Action_cleanFaceData {
    [[BFLibraryManager sharedInstance] cleanData];
}

@end
