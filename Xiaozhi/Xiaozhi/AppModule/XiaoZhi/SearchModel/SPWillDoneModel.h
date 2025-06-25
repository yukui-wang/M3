//
//  SPWillDoneModel.h
//  CMPCore
//
//  Created by zeb on 2017/2/20.
//
//  代办样式

#import <Foundation/Foundation.h>

@interface SPWillDoneModel : NSObject
//代办条数
@property (nonatomic, assign) NSInteger count;
//内容
@property (nonatomic, strong) NSString *content;
//页面id
@property (nonatomic, strong) NSString *pageId;
//是否显示小点 default：NO
@property (nonatomic, assign) BOOL showDot;
@end
