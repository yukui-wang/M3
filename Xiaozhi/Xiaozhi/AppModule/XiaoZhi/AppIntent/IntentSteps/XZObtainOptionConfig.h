//
//  XZObtainOptionConfig.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/10/24.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import <CMPLib/CMPObject.h>


@interface XZObtainOptionConfigParam : CMPObject
@property(nonatomic,strong)NSString *key;
@property(nonatomic,assign)BOOL required;
@end

@interface XZObtainOptionConfig : CMPObject
@property(nonatomic,strong)NSString *obtainUrl;
@property(nonatomic,strong)NSString *obtainUrlType;
@property(nonatomic,strong)NSArray  *obtainParams;
@property(nonatomic,strong)NSString *obtainLoadUrl;
@property(nonatomic,strong)NSString *obtainRenderType;
@property(nonatomic,strong)NSDictionary *obtainExtData;
- (id)initWithDic:(NSDictionary *)dic;
- (NSString *)requestUrl;
- (NSString *)loadUrl;
@end


