//
//  CMPCloudLoginResponse.h
//  M3
//
//  Created by CRMO on 2018/9/11.
//

#import <CMPLib/CMPObject.h>

@interface CMPCloudLoginResponseData : CMPObject
@property (nonatomic , copy) NSString *addr_m3;
@property (nonatomic , copy) NSString *addr_oa;
@property (nonatomic , copy) NSString *corpid;
@property (nonatomic , copy) NSString *corp;
@property (nonatomic , assign) NSInteger time;
@end

@interface CMPCloudLoginResponse : CMPObject
@property (nonatomic , copy) NSString *msg;
@property (nonatomic , copy) NSArray<CMPCloudLoginResponseData *> *data;
@property (nonatomic , assign) NSInteger code;
/** 根据错误码解析的错误提示，已国际化 **/
@property (nonatomic , copy) NSString *errorDetail;
@property (assign, nonatomic) BOOL success;

@end
