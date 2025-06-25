//
//  BaiduImageClassifyApp.h
//  M3
//
//  Created by wujiansheng on 2019/2/27.
//

#import <Foundation/Foundation.h>
#import "BaiduAppError.h"

//图像识别

@interface BaiduImageClassifyApp : NSObject
@property(nonatomic, copy) NSString *imageClassifyAppID;
@property(nonatomic, copy) NSString *imageClassifyAPIKey;
@property(nonatomic, copy) NSString *imageClassifySecretKey;
@property(nonatomic, retain) BaiduAppError *baiduAppError;
- (id)initWithBaiduImageClassifyApp:(NSDictionary *)dic;
@end
