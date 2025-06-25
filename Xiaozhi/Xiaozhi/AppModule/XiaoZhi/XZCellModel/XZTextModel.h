//
//  XZTextModel.h
//  M3
//
//  Created by wujiansheng on 2017/12/2.
//

#import "XZCellModel.h"
#import "XZTextTapModel.h"
#import "XZTextInfoModel.h"
@interface XZTextModel : XZCellModel {
    BOOL _defalutTapEnable;
}

@property (nonatomic, assign) ChatCellType chatCellType;
@property (nonatomic, assign) CGFloat lableWidth;
//单元格主要内容 ##橙色##  $$加粗$$
@property (nonatomic, copy) NSString *contentInfo;
//机器人点击 [[],[]..]
@property (nonatomic, retain) NSArray *clickItems;
@property (nonatomic, retain) NSMutableArray *showItems;

//显示查看更多按钮
@property (nonatomic, assign) BOOL showMoreBtn;
//点击查看更多按钮
@property (nonatomic, copy) void (^moreBtnClickAction)(XZTextModel *model);
@property (nonatomic, copy) void (^clickBlock)(NSObject *clickedObj);
@property (nonatomic, copy) void (^clickTextBlock)(NSString *text);
@property (nonatomic, copy) void (^clickLinkBlock)(NSString *linkUrl);

@property (nonatomic, assign) NSInteger itemTag;
@property (nonatomic, assign) BOOL resetCellHeight;//重新设置cell 高度
@property (nonatomic, assign) BOOL tapEnable;//点击事件是否可用

+ (XZTextModel*)modelWithMessageType:(ChatCellType)type
                             itemTag:(NSInteger)itemTag
                         contentInfo:(NSString *)contentInfo;
- (void)disableTapText;
- (BOOL)canClickAtIndex:(NSInteger)index;
- (void)clickAtIndex:(NSInteger)index;

//小致说话解析：去掉“##xxx##”中的“##”，去掉"[XXX](yyy)"中的“[](yyy)”
+ (NSString *)handleGuideWord:(NSString *)guideWord;
@end
