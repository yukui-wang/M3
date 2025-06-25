//
//  XZQAGuideModel.h
//  M3
//
//  Created by wujiansheng on 2018/10/22.
//

#define kXZQAGuideCellHeight 30
#define kXZQAGuideCellHeaderHeight 23
#define kXZQAGuideCellFooterHeight 26

#import "XZCellModel.h"
#import "XZQAGuideTips.h"
@interface XZQAGuideModel : XZCellModel
- (id)initWithQuestions:(NSArray *)tips;
@property(nonatomic ,retain)NSArray *tipsSet;//QA问题列表
@property(nonatomic ,assign)BOOL tipsClickEnable;//tips 是否可点击

@property (nonatomic, assign) ChatCellType chatCellType;
@property (nonatomic, assign) CGFloat lableWidth;
@property (nonatomic, copy) void (^moreBtnClickAction)(XZQAGuideTips *tips);
@property (nonatomic, copy) void (^clickTextBlock)(NSString *text);

@end

