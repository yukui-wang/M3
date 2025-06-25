//
//  CMPMultiLoginManageView.m
//  M3
//
//  Created by 程昆 on 2019/9/10.
//

#import "CMPMultiLoginManageView.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/UIImage+JCColor2Image.h>
#import "CMPMessageManager.h"
#import "CMPOnlineDevModel.h"
#import <CMPLib/CMPThemeManager.h>
#pragma mark - CMPMultiLoginButton class

@interface CMPMultiLoginButton : UIButton

@end

@implementation CMPMultiLoginButton

-(void)setHighlighted:(BOOL)highlighted {
    
}

@end

#pragma mark - CMPMultiLoginManageView class

@interface CMPMultiLoginManageView ()
{
    UIImageView *iconImageView;
}
@property (nonatomic,weak)UILabel *tipLable;
@property (nonatomic,weak)UIButton *muteButton;

@end

@implementation CMPMultiLoginManageView

- (UIImage *)createImageWithBackgroundAndOverlay:(UIImage *)overlayImage bgColor:(UIColor *)bgColor{
    CGSize size = CGSizeMake(40, 40);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    // 绘制白色圆形
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(4, 4, 32, 32)];
    [bgColor setFill];
    [path fill];
    
    // 绘制叠加图片
    [overlayImage drawInRect:CGRectMake(11, 11, 18, 18)];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // 设置圆角
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height)
                                cornerRadius:20] addClip];
    [finalImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return roundedImage;
}

- (void)setup {
    BOOL isShowFileAssistant =  CMPMessageManager.sharedManager.hasZhiXinPermissionAndServerAvailable == YES ?: NO;
    
    UIBlurEffect * blur;
    if (@available(iOS 10.0, *)) {
         blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
    } else {
         blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    [self addSubview:effectView];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"multi_login_close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton cmp_expandClickArea:UIOffsetMake(10, 15)];
    [self addSubview:closeButton];
    
    iconImageView = [[UIImageView alloc] init];
    iconImageView.image = [UIImage imageNamed:@"multi_login_equipment"];
    [self addSubview:iconImageView];
    
    UILabel *tipLable = [[UILabel alloc] init];
    tipLable.textAlignment = NSTextAlignmentCenter;
    tipLable.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    tipLable.textColor = [UIColor cmp_colorWithName:@"main-fc"];
    [self addSubview:tipLable];
    self.tipLable = tipLable;
        
    UIButton *muteButton = [CMPMultiLoginButton buttonWithType:UIButtonTypeCustom];
    
    //暗黑模式背景色
    UIColor *bgColor = [CMPThemeManager sharedManager].isDisplayDrak?UIColor.blackColor:UIColor.whiteColor;
    
    UIImage *already_mute_img = [UIImage imageNamed:@"multi_login_already_mute1"];
    //处理图片主题色
    already_mute_img = [[CMPThemeManager sharedManager] skinColorImageWithImage:already_mute_img];
    //组合背景图片
    already_mute_img = [self createImageWithBackgroundAndOverlay:already_mute_img bgColor:bgColor];
    
    UIImage *muteImg = [UIImage imageNamed:@"multi_login_mute1"];
    //处理图片主题色
    muteImg = [[CMPThemeManager sharedManager] skinColorImageWithImage:muteImg];
    //组合背景图片
    muteImg = [self createImageWithBackgroundAndOverlay:muteImg bgColor:bgColor];
    
    [muteButton setImage:already_mute_img forState:UIControlStateNormal];
    [muteButton setImage:muteImg forState:UIControlStateSelected];
    
    [muteButton setTitle:SY_STRING(@"mutil_login_already_mute") forState:UIControlStateNormal];
    [muteButton setTitle:SY_STRING(@"mutil_login_mute") forState:UIControlStateSelected];
    [muteButton setTitleColor:[UIColor cmp_colorWithName:@"cont-fc"] forState:UIControlStateNormal];
    muteButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    muteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [muteButton addTarget:self action:@selector(muteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    muteButton.selected = [CMPCore sharedInstance].multiLoginReceivesMessageState;
    [self addSubview:muteButton];
    self.muteButton = muteButton;
    
    UIButton *fileAssistantButton = nil;
    if (isShowFileAssistant == YES) {
        fileAssistantButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIImage *assistImg = [UIImage imageNamed:@"multi_login_file_assistant1"];
        assistImg = [[CMPThemeManager sharedManager] skinColorImageWithImage:assistImg];
        assistImg = [self createImageWithBackgroundAndOverlay:assistImg bgColor:bgColor];
        
        [fileAssistantButton setImage:assistImg forState:UIControlStateNormal];
        [fileAssistantButton setImage:assistImg forState:UIControlStateHighlighted];
        
//        [fileAssistantButton setImage:[UIImage imageNamed:@"multi_login_file_assistant"] forState:UIControlStateNormal];
//        [fileAssistantButton setImage:[UIImage imageNamed:@"multi_login_file_assistant"] forState:UIControlStateHighlighted];
        
        [fileAssistantButton setTitle:SY_STRING(@"msg_fileass") forState:UIControlStateNormal];
        [fileAssistantButton setTitleColor:[UIColor cmp_colorWithName:@"cont-fc"] forState:UIControlStateNormal];
        fileAssistantButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        fileAssistantButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [fileAssistantButton addTarget:self action:@selector(fileAssistantButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:fileAssistantButton];
    }
    
    UIButton * exitOtherDeviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIColor *themeColor = [UIColor cmp_colorWithName:@"white-bg"];
    UIImage *image = [UIImage cmp_createImageWithColor:themeColor addCornerWithRadius:30 andSize:CGSizeMake(215, 40)];
    UIImage *highlightedImage = [UIImage cmp_createImageWithColor:[themeColor colorWithAlphaComponent:0.7] addCornerWithRadius:30 andSize:CGSizeMake(215, 40)];
    [exitOtherDeviceButton setBackgroundImage:image forState:UIControlStateNormal];
    [exitOtherDeviceButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    [exitOtherDeviceButton setTitle:SY_STRING(@"mutil_login_exit_other_client") forState:UIControlStateNormal];
    [exitOtherDeviceButton setTitleColor:[UIColor cmp_colorWithName:@"theme-fc"] forState:UIControlStateNormal];
    exitOtherDeviceButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [exitOtherDeviceButton addTarget:self action:@selector(exitOtherDeviceButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:exitOtherDeviceButton];
    
    
    

    [effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(14);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(10);
        } else {
            make.top.equalTo(self).offset(31);
        }
        make.size.equalTo(CGSizeMake(22, 22));
    }];
    
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(closeButton.mas_bottom).offset(74);
        make.centerX.equalTo(self);
        make.size.equalTo(CGSizeMake(144, 144));
    }];
    
    [tipLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iconImageView.mas_bottom).offset(30);
        make.leading.trailing.equalTo(self);
    }];
    
    [muteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipLable.mas_bottom).offset(50);
        if (isShowFileAssistant) {
            make.trailing.equalTo(self.mas_centerX).offset(-41);
        } else {
            make.centerX.equalTo(self.mas_centerX);
        }
        make.size.equalTo(CGSizeMake(76, 76 + 18));
    }];
    
    [fileAssistantButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(muteButton);
        make.leading.equalTo(self.mas_centerX).offset(41);
        make.size.equalTo(muteButton);
    }];
    
    muteButton.layoutSubviewsCallback = ^(UIView *superview) {
        UIButton *button = (UIButton *)superview;
        CGFloat buttonHeight = 20;
        button.imageView.frame = CGRectMake(0, 0, superview.cmp_width, superview.cmp_width);
        button.titleLabel.frame = CGRectMake(-31,superview.cmp_height - buttonHeight, button.imageView.cmp_width + 62, buttonHeight);
    };
    
    if (isShowFileAssistant) {
        fileAssistantButton.layoutSubviewsCallback = ^(UIView *superview) {
            UIButton *button = (UIButton *)superview;
            CGFloat buttonHeight = 20;
            button.imageView.frame = CGRectMake(0, 0, superview.cmp_width, superview.cmp_width);
            button.titleLabel.frame = CGRectMake(-31,superview.cmp_height - buttonHeight, button.imageView.cmp_width + 62, buttonHeight);
        };
    }
    
    [exitOtherDeviceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-50);
        } else {
            make.bottom.equalTo(self.mas_bottom).offset(-50);
        }
        make.centerX.equalTo(self);
        make.size.equalTo(CGSizeMake(215, 40));
    }];
    
}

-(void)updateDataWithModel:(CMPOnlineDevModel *)model{
    if (model) {
        _tipLable.text = [model tip];
        
        if (model.isMultiOnline) {
            if ([model isOnlyPhoneOnline]) {
                iconImageView.image = [[UIImage imageNamed:@"mutillogin_phone"] cmp_imageWithTintColor:[UIColor cmp_colorWithName:@"cont-fc"]];
            }
            else if ([model isOnlyPadOnline]) {
                iconImageView.image = [[UIImage imageNamed:@"mutillogin_pad"] cmp_imageWithTintColor:[UIColor cmp_colorWithName:@"cont-fc"]];
            }
            else if ([model isOnlyPcOnline]) {
                iconImageView.image = [[UIImage imageNamed:@"mutillogin_pc"] cmp_imageWithTintColor:[UIColor cmp_colorWithName:@"cont-fc"]];
            }
            else {
                iconImageView.image = [[UIImage imageNamed:@"mutillogin_mutil"] cmp_imageWithTintColor:[UIColor cmp_colorWithName:@"cont-fc"]];
            }
        }else{
            iconImageView.image = [UIImage imageNamed:@""];
        }
    }
    [_muteButton setSelected:[CMPCore sharedInstance].multiLoginReceivesMessageState];
}

- (void)setTipText:(NSString *)text {
    self.tipLable.text = text;
}

- (void)closeButtonAction:(UIButton *)sender {
    if (self.closeButtonAction) {
        self.closeButtonAction();
    }
}

- (void)muteButtonAction:(UIButton *)sender {
    if (self.muteButtonAction) {
        self.muteButtonAction();
    }
}

- (void)fileAssistantButtonAction:(UIButton *)sender {
    if (self.fileAssistantButtonAction) {
        self.fileAssistantButtonAction();
    }
}

- (void)exitOtherDeviceButtonAction:(UIButton *)sender {
    if (self.exitOtherDeviceButtonAction) {
        self.exitOtherDeviceButtonAction();
    }
}

- (void)setMuteButtonSelectedStatus:(BOOL)status {
    self.muteButton.selected = status;
}


@end

