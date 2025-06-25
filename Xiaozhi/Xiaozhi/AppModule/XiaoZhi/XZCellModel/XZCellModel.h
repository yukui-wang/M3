//
//  XZCellModel.h
//  M3
//
//  Created by wujiansheng on 2017/11/8.
//


//#define kCellWidth [UIScreen mainScreen].bounds.size.width
#define kXZCellSpace 10
#import <CMPLib/CMPObject.h>

typedef NS_ENUM(NSInteger, ChatCellType) {
    ChatCellTypeHeader = 0,//发起协同，查看今日安排。。
    ChatCellTypeRobotMessage,//机器人文本消息
    ChatCellTypeRobotWithClickMessage,//包含点击类型的机器人
    ChatCellTypeUserMessage,//用户
};

@interface XZCellModel : CMPObject {
    CGFloat  _cellHeight;
}
/**
 *  缓存cell高度
 */
- (CGFloat)cellHeight;

/**
 *  model 所对应的cell class
 */
@property (nonatomic, copy) NSString *cellClass;
/**
 *  同一个cell class 可能会有多个xib文件  或对应不同的identifier, 默认为类名
 */
@property (nonatomic, copy) NSString *ideltifier;
/**
 *  xibIndex 默认为0
 */
@property (nonatomic, assign) NSInteger xibIndex;


//model id 防止cell 重复加载，
@property (nonatomic, copy) NSString *modelId;

@property (nonatomic, assign) CGFloat cellWidth;


//取消 操作
- (void)disableOperate;

- (CGFloat)scellWidth;
@end
