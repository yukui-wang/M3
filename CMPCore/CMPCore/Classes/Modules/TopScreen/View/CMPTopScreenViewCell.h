//
//  CMPTopScreenViewCell.h
//  M3
//
//  Created by Shoujian Rao on 2023/12/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPTopScreenViewCell : UITableViewCell
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, copy) void(^closeBtnClickBlock)(void);
@end

NS_ASSUME_NONNULL_END
