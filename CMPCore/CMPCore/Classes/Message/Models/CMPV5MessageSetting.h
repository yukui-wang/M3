//
//  CMPV5MessageSetting.h
//  M3
//
//  Created by CRMO on 2018/1/10.
//

#import <CMPLib/CMPObject.h>

@interface CMPV5MessageSetting : CMPObject
@property (strong, nonatomic) NSString *appId;
@property (strong, nonatomic) NSString *top;
@property (strong, nonatomic) NSString *parent;
@property (strong, nonatomic) NSString *topTime;
@property (strong, nonatomic) NSString *remind;
@end
