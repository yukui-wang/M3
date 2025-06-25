//
//  SPAnswer.h
//  MSCDemo
//
//  Created by CRMO on 2017/2/11.
//
//

#import <Foundation/Foundation.h>
#import "SPConstant.h"
//#import "SPSmartEngine.h"

@interface SPAnswer : NSObject

@property (nonatomic) SPAnswerType type;

// 用户响应的内容，自定义数据格式
// 通过解析该数据，决定下一步行为
@property (strong, nonatomic) id content;

@property (nonatomic, strong) NSDictionary *currentResult;

@end
