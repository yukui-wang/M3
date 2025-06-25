//
//  CMPBaseResponse.h
//  M3
//
//  Created by CRMO on 2017/11/20.
//

#import <CMPLib/CMPObject.h>

@interface CMPBaseResponse : CMPObject

@property (nonatomic , copy) NSString *code;
@property (nonatomic , copy) NSString *message;
@property (nonatomic , copy) NSString *time;
@property (nonatomic , copy) NSString *version;

@end
