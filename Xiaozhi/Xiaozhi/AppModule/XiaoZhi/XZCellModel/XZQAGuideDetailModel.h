//
//  XZQAGuideDetailModel.h
//  M3
//
//  Created by wujiansheng on 2018/11/19.
//

#import "XZCellModel.h"
#import "XZQAGuideTips.h"


@interface XZQAGuideDetailModel : XZCellModel
@property(nonatomic ,retain)XZQAGuideTips *tips;//显示tips 中的几条
@property (nonatomic, assign) ChatCellType chatCellType;
@property (nonatomic, assign) CGFloat lableWidth;
@property (nonatomic, copy) void (^clickTextBlock)(NSString *text);
@property(nonatomic ,retain)NSArray *HeightArray;//QA问题列表
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) CGFloat titleHeight;

@end
