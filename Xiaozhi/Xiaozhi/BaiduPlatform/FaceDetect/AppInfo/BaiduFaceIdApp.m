//
//  BaiduFaceIdApp.m
//  M3
//
//  Created by wujiansheng on 2019/2/27.
//

#import "BaiduFaceIdApp.h"
#import "SPTools.h"

@implementation BaiduFaceIdApp

- (id)initWithBaiduFaceIdApp:(NSDictionary *)dic {
    if (self = [super init]) {
        self.faceDetectAppID = [SPTools stringValue:dic forKey:@"faceDetectAppID"];
        self.faceDetectAPIKey = [SPTools stringValue:dic forKey:@"faceDetectAPIKey"];
        self.faceDetectSecretKey = [SPTools stringValue:dic forKey:@"faceDetectSecretKey"];
        NSDictionary *error = [SPTools dicValue:dic forKey:@"baiduAppError"];
        if (error) {
            _baiduAppError = [[BaiduAppError alloc] initWithError:error];
        }
    }
    return self;
}

@end

