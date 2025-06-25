//
//  SPQuestion.h
//  MSCDemo
//
//  Created by CRMO on 2017/2/11.
//
//

#import <Foundation/Foundation.h>
#import "SPConstant.h"

@interface SPQuestion : NSObject

@property (nonatomic) SPAnswerType type;

// 提问的内容，自定义数据格式
// 控制层根据该项绘制UI，控制语音合成内容
@property (strong, nonatomic) id content;

/**
 是否朗读及显示
 */
@property (nonatomic) BOOL isRead;

/**
 是否是结束节点
 */
@property (nonatomic) BOOL isEnd;

/**
 前置时间
 */
@property (nonatomic, strong) NSString *bos;

/**
 后置时间
 */
@property (nonatomic, strong) NSString *eos;

/**
 指定语法ID
 */
@property (nonatomic, strong) NSString *grammarID;

/**
 供选择的人员，仅用于 选人员重名
 */
@property(nonatomic ,strong) NSArray *optionMembers;

@end
