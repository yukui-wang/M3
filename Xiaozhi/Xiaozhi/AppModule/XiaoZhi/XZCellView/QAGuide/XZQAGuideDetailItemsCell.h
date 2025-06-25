//
//  XZQAGuideDetailCell.h
//  M3
//
//  Created by wujiansheng on 2018/11/19.
//

#import <CMPLib/CMPBaseTableViewCell.h>

@interface XZQAGuideDetailItemsCell : CMPBaseTableViewCell
@property(nonatomic, retain)UILabel *tLabel;
@property (nonatomic, copy) void (^clickTextBlock)(NSString *text);

@end
