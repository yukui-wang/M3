//
//  CMPDeviceBindResponse.h
//  M3
//
//  Created by CRMO on 2017/12/6.
//

#import "CMPBaseResponse.h"

@interface CMPDeviceBindResponseData :CMPObject
@property (nonatomic , assign) BOOL              successFlag;
@property (nonatomic , copy) NSString              * resultCode;
@property (nonatomic , copy) NSString              * classType;
@property (nonatomic , copy) NSString              * resultMessage;
@end

@interface CMPDeviceBindResponse :CMPBaseResponse
@property (nonatomic , strong) CMPDeviceBindResponseData              * data;
@end

