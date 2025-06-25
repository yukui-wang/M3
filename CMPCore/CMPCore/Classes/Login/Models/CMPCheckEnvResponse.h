//
//  CMPCheckEnvResponse.h
//  M3
//
//  Created by CRMO on 2017/12/6.
//

#import "CMPBaseResponse.h"
#import <CMPLib/CMPV5ProductEditionModel.h>

@interface CMPCheckEnvResponseUpdateServer : CMPObject

@property (nonatomic , copy) NSString              * url;
@property (nonatomic , copy) NSString              * transkey;
@property (nonatomic , copy) NSString              * key;
@property (nonatomic , copy) NSString              * i18n;//7.1sp1版本之前支持国际化标志
@property (nonatomic , copy) NSString              * trustdo;//手机盾插件增加

@end

@interface CMPCheckEnvResponseData : CMPObject

@property (nonatomic , copy) NSString              * version;
@property (nonatomic , strong) CMPCheckEnvResponseUpdateServer              * updateServer;
@property (nonatomic , copy) NSString              * identifier;
@property (nonatomic , strong) CMPV5ProductEditionModel              * productEdition;

@end

@interface CMPCheckEnvResponse : CMPBaseResponse

@property (nonatomic , strong) CMPCheckEnvResponseData              * data;

@end
