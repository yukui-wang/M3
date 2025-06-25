//
//  CMPLocalAuthenticationView.m
//  M3
//
//  Created by CRMO on 2019/1/17.
//

#import "CMPLocalAuthenticationView.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/CMPThemeManager.h>

@interface CMPLocalAuthenticationView()

@end

@implementation CMPLocalAuthenticationView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
    [self addSubview:self.avatarView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.startButton];
    [self addSubview:self.infoLabel];
    
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.height.equalTo(87);
        make.topMargin.equalTo(69);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.avatarView.mas_bottom).offset(10);
        make.width.equalTo(self.cmp_width - 16);
    }];
    
    [self.startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
        make.width.height.equalTo(60);
    }];
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.startButton.mas_bottom).offset(20);
        make.centerX.equalTo(self.startButton);
    }];
}

#pragma mark-
#pragma mark- API

- (void)addButtomButtons:(NSArray *)buttons {
    for (UIButton *button in buttons) {
        [self addSubview:button];
    }
    if (buttons.count == 1) {
        UIButton *centerButton = [buttons firstObject];
        centerButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [centerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottomMargin.equalTo(-40);
            make.width.equalTo(150);
            make.height.equalTo(20);
        }];
    } else if (buttons.count == 2) {
        UIButton *leftButton = [buttons objectAtIndex:0];
        UIButton *rightButton = [buttons objectAtIndex:1];
        leftButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        rightButton.titleLabel.textAlignment = NSTextAlignmentRight;
        [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leadingMargin.equalTo(30);
            make.bottomMargin.equalTo(-40);
//            make.width.equalTo(150);
            make.height.equalTo(20);
        }];
        [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailingMargin.equalTo(-30);
            make.bottomMargin.equalTo(-40);
//            make.width.equalTo(150);
            make.height.equalTo(20);
        }];
    }
}

+ (UIButton *)bottomButton {
    UIButton *button = [[UIButton alloc] init];
    [button setTitleColor:[UIColor cmp_colorWithName:@"sup-fc1"] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
    [button cmp_expandClickArea:UIOffsetMake(10, 20)];
    return button;
}

#pragma mark-
#pragma mark- Getter

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.cornerRadius = 87 / 2;
        _avatarView.layer.masksToBounds = YES;
    }
    return _avatarView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (UIButton *)startButton {
    if (!_startButton) {
        _startButton = [[UIButton alloc] init];
        [_startButton cmp_expandClickArea:UIOffsetMake(50, 50)];
    }
    return _startButton;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont systemFontOfSize:16];
        _infoLabel.textColor = [UIColor cmp_colorWithName:@"theme-fc"];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _infoLabel;
}

#pragma mark-
#pragma mark- Private



@end
