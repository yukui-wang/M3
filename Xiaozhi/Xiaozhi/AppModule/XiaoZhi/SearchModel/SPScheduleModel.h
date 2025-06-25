//
//  SPScheduleModel.h
//  CMPCore
//
//  Created by zeb on 2017/2/19.
//
//  安排 .上午8：30-9：00日程人员沟通  >

#import <Foundation/Foundation.h>

@interface SPScheduleModel : NSObject

//内容
@property (nonatomic, strong) NSString *content;
//读的内容
@property (nonatomic, strong) NSString *readCotent;
//页面id
@property (nonatomic, strong) NSString *pageId;
// 协同专用
@property (nonatomic, strong) NSString *summaryId;
// 类型
@property (nonatomic, strong) NSString *type;
// 创建人
@property (nonatomic, strong) NSString *createUserName;
//是否显示小点 default：NO
@property (nonatomic, assign) BOOL showDot;

//以下新版本使用，老版本使用的是content，由 tilte 与time 拼接的
@property(nonatomic, strong)NSString *tilte;
@property(nonatomic, strong)NSString *time;


@end
