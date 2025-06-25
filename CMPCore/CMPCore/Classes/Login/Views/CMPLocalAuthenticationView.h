//
//  CMPLocalAuthenticationView.h
//  M3
//
//  Created by CRMO on 2019/1/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPLocalAuthenticationView : UIView

@property (strong, nonatomic) UIImageView *avatarView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIButton *startButton;
@property (strong, nonatomic) UILabel *infoLabel;

/**
 添加底部按钮
 */
- (void)addButtomButtons:(NSArray *)buttons;

+ (UIButton *)bottomButton;

@end

NS_ASSUME_NONNULL_END
