//
//  SyBaseTableViewCellSelectView.h
//  M1Core
//
//  Created by wujiansheng on 15/3/9.
//
//

#import "CMPBaseView.h"

@interface SyBaseTableViewCellSelectView : CMPBaseView
@property (nonatomic, assign)CGFloat  lineLeftMargin;//分割线左边距
@property (nonatomic, assign)CGFloat  lineRightMargin;//分割线右边距
@property (nonatomic, assign)CGFloat  lineHeight;
- (void)setupLineColor:(UIColor *)lineColor;
- (void)hideSeparatorLineView:(BOOL)hide;
@end
