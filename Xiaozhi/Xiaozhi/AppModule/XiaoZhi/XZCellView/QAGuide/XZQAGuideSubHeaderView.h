//
//  XZQAGuideSubHeaderView.h
//  M3
//
//  Created by wujiansheng on 2018/11/16.
//

#import <CMPLib/SyBaseTableViewCellHeaderView.h>
#import "XZQAGuideTips.h"

@interface XZQAGuideSubHeaderView : SyBaseTableViewCellHeaderView {
    UIView *_pointView;
    UILabel *_titleLabel;
    UIButton *_moreBtn;
}
@property(nonatomic, retain)XZQAGuideTips *tips;
@property (nonatomic, copy) void (^showTipsDetailBlock)(XZQAGuideTips *tips);

@end

