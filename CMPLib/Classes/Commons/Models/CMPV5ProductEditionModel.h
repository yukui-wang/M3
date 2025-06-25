//
//  CMPV5ProductEditionModel.h
//  CMPLib
//
//  Created by youlin on 2019/2/23.
//  Copyright © 2019年 CMPCore. All rights reserved.
//

#import "CMPObject.h"

@interface CMPV5ProductEditionModel : CMPObject

@property (strong, nonatomic) NSString *value; // 具体产品信息 A6V5-1
@property (strong, nonatomic) NSString *suffix; // 产品后缀，用户国际化、资源文件修改 -gov,a8默认为""
@property (strong, nonatomic) NSString *productLine; // 产品线a8、gov、nc、u8

@property (nonatomic , copy) NSString              * screenshotEnable;
@property (nonatomic , copy) NSString              * canUseSMS;
@property (nonatomic , copy) NSString              * canUseVPN;
@property (nonatomic , copy) NSString              * checkSSL;

@end
