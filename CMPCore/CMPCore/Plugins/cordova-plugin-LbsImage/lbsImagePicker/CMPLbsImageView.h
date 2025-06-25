//
//  CMPLbsImageView.h
//  CMPCore
//
//  Created by wujiansheng on 16/7/27.
//
//


#import <UIKit/UIKit.h>
#import <CMPLib/CMPConstant.h>
@interface CMPLbsImageView : UIImageView

@property(nonatomic, retain)UILabel *timeLabel;//时分
@property(nonatomic, retain)UILabel *dateLabel;//时期 星期几
@property(nonatomic, retain)UILabel *nameLabel;//名字
@property(nonatomic, retain)UILabel *locationLabel;//位置

- (void)customLayoutSubviews;
- (UIImage *)result;
- (void)hideName;
- (void)showDateTimeWithTime:(NSString *)time;

@end
