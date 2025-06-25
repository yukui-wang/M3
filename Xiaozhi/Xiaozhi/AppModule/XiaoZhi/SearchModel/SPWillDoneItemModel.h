//
//  SPWillDoneItemModel.h
//  CMPCore
//
//  Created by zeb on 2017/2/20.
//
//

#import <Foundation/Foundation.h>

@interface SPWillDoneItemModel : NSObject
//内容
@property (nonatomic, strong) NSString *content;
//发起人
@property (nonatomic, strong) NSString *initiator;
//发起时间
@property (nonatomic, strong) NSString *creatDate;
//页面id
@property (nonatomic, strong) NSString *pageId;
// 文档类型
@property (nonatomic, strong) NSString *frType;
// 文档类型
@property (nonatomic, strong) NSString *frMineType;
// 待办类型
@property (nonatomic, strong) NSString *type;
// summaryId
@property (nonatomic, strong) NSString *summaryId;
// sourchID
@property (nonatomic, strong) NSString *sourchId;
//是否显示小点 default：NO
@property (nonatomic, assign) BOOL showDot;
//显示是否左对齐
@property (nonatomic, assign) BOOL alignmentLeft;

@end
