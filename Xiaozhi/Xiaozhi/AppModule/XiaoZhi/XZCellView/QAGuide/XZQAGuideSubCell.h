//
//  XZQAGuideSubCell.h
//  M3
//
//  Created by wujiansheng on 2018/11/16.
//

#import <CMPLib/CMPBaseTableViewCell.h>


@interface XZQAGuideSubCell : CMPBaseTableViewCell
@property(nonatomic, retain)UILabel *tLabel;
@property (nonatomic, copy) void (^clickTextBlock)(NSString *text);

@end

