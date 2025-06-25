//
//  SPScheduleHelper.h
//  CMPCore
//
//  Created by CRMO on 2017/2/24.
//
//

#import <Foundation/Foundation.h>
#import "XZCellModel.h"
#import "XZTextModel.h"
#import "SPWillDoneModel.h"
#import "XZScheduleModel.h"

@interface SPScheduleHelper : NSObject


/**
 条数过多，用户说“不需要”就不读了
 */
@property (nonatomic) BOOL noReadPlan;

/**
 今日待办事项
 */
@property (nonatomic, strong) NSArray *plans;


/**
 待办协同、公文
 */
@property (nonatomic, strong) NSArray *willDones;


/**
 从服务器中返回的json字符串构造一个类

 @param str json字符串
 */
- (instancetype)initWithJson:(NSString *)str;


/**
 获取机器应该读的内容
 */
- (NSString *)getPlanSpeakStr;

/**
 获取显示用的Model
  */
- (XZTextModel *)getPlanShowModel;

- (XZScheduleModel *)getPlanShowModel1;

/**
 获取待办事项机器应该读的内容
*/
- (NSString *)getTodoSpeakStr;

/**
 获取待办事项显示用的Model
*/
- (XZTextModel *)getTodoShowModel;

@end
