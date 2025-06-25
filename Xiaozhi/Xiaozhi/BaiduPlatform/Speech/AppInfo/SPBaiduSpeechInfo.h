//
//  SPBaiduSpeechInfo.h
//  M3
//
//  Created by wujiansheng on 2018/4/25.
//

#import <Foundation/Foundation.h>
#import "BaiduAppError.h"

//语音识别
@interface SPBaiduSpeechInfo : NSObject
@property(nonatomic, copy) NSString *baiduSpeechAppId ;
@property(nonatomic, copy) NSString *baiduSpeechApiKey;
@property(nonatomic, copy) NSString *baiduSpeechSecretKey;
@property(nonatomic, retain) BaiduAppError *baiduAppError;

- (id)initWithResult:(NSDictionary *)result;
- (id)initWithBaiduIphoneVoiceApp:(NSDictionary *)dic;
- (BOOL)canUseXiaoZhi;
- (BOOL)isUnavailableCode;
+ (SPBaiduSpeechInfo *)defaultInfo;


@end

