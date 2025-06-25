//
//  SPCommondNodeFactory.h
//  命令节点工厂类，命令节点通过工厂的initCommondNode方法初始化
//
//  Created by CRMO on 2017/2/12.
//
//

#import "SPBaseCommondNode.h"
#import "SPShortTextCommondNode.h"
#import "SPLongTextCommondNode.h"
#import "SPMemberCommondNode.h"
#import "SPOptionCommondNode.h"
#import "SPPromptCommondNode.h"
#import "SPSubmitCommondNode.h"
#import "SPViewCommondNode.h"

@interface SPCommondNodeFactory : SPBaseCommondNode


/**
 根据命令插件的节点信息，生成对应节点

 @param commondDic 节点信息        
 "stepIndex": "2",
 "word": "发给谁？",
 "isReadWord": "true",
 "key": "receivers",
 "type": "input",
 "fieldType": "member",
 "sucessStepIndex": "3",
 "failStepIndex": "5"
 @return 节点
 */
+ (SPBaseCommondNode *)initCommondNode:(NSDictionary *)commondDic;
/**
 将命令插件中json的type字段转换成SPAnswerType
 新增节点类型需要在SPAnswerType与该函数中增加对应
 
 @param type 命令插件中json中的type字段值
 @return SPAnswerType
 */
+ (SPAnswerType)getAnswerTypeWithType:(NSString *)type;

@end
