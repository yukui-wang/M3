//
//  CMPBaseTableViewCellSelectView.h
//  CMPCore
//
//  Created by wujiansheng on 2017/1/5.
//
//

#import <CMPLib/CMPBaseView.h>

@interface CMPBaseTableViewCellSelectView : CMPBaseView
@property (nonatomic, assign)CGFloat  lineLeftMargin;//分割线左边距
@property (nonatomic, assign)CGFloat  lineRightMargin;//分割线右边距
@property (nonatomic, assign)CGFloat  lineHeight;
- (void)setupLineColor:(UIColor *)lineColor;
- (void)hideSeparatorLineView:(BOOL)hide;
@end
