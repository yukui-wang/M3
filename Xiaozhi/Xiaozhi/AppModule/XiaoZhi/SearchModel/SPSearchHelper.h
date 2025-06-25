//
//  SPSearchHelper.h
//  CMPCore
//
//  Created by CRMO on 2017/2/25.
//
//

#import <Foundation/Foundation.h>
#import "XZCellModel.h"
#import "XZTextModel.h"
#import "XZSearchResultModel.h"
@interface SPSearchHelper : NSObject

/** 总条数 **/
@property (nonatomic) NSInteger total;
/** 是否是需要选择 **/
@property (nonatomic) BOOL isOption;
/** 数据模型 **/
@property (nonatomic, strong) NSArray *data;
/** 查文档、查公告的标题 **/
@property (nonatomic, strong) NSString *searchTitle;
@property (nonatomic, copy) void (^stopSpeakBlock)(void);

/**
 从服务器中返回的json字符串构造一个类
 */
- (instancetype)initWithJson:(NSString *)str;

/**
 获取显示的数据模型
 */
- (XZTextModel *)getShowModel;
- (XZSearchResultModel *)getShowResultModel;

/**
 获取需要读的内容
 */
- (NSString *)getSpeakStr;
@end
