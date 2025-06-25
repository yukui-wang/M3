//
//  XZGuideMode.h
//  M3
//
//  Created by wujiansheng on 2018/1/4.
//

#import "XZCellModel.h"

typedef NS_ENUM(NSInteger, GuideCellType) {
    GuideCellTypeGuide = 0,//引导
    GuideCellTypeHelp//帮助
};


@interface XZGuideMode : XZCellModel
- (id)initWithType:(GuideCellType)type;
@property (nonatomic, assign) ChatCellType chatCellType;
@property (nonatomic, assign) CGFloat lableWidth;
@property (nonatomic, copy) NSString *contentInfo;
@property (nonatomic, copy)NSAttributedString *guideInfo;
@property (nonatomic, assign)BOOL showMore;
@property (nonatomic, copy) void (^moreBtnClickAction)(void);
- (void)moreBtnClick;
@end
