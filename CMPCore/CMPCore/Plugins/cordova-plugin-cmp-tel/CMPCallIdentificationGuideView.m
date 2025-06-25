//
//  CMPCallIdentificationGuideView.m
//  M3
//
//  Created by CRMO on 2018/4/12.
//

#import "CMPCallIdentificationGuideView.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/UIImage+CMPImage.h>
#import <CMPLib/CMPObject.h>

@interface CMPCallIdentificationGuideView()
@end

@implementation CMPCallIdentificationGuideView


- (void)setup {
    [self setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:self.titleLabel];
    [self addSubview:self.firstStepLabel];
    [self addSubview:self.firstStepImage];
    [self addSubview:self.secondStepLabel];
    [self addSubview:self.secondStepImage];
    [self addSubview:self.closeButton];
    [self addSubview:self.kownButton];
}

#pragma mark-
#pragma mark 布局

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [self.closeButton mas_updateConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0,*)) {
            make.top.equalTo(self.mas_safeAreaLayoutGuideTop).inset(10);
            make.trailing.equalTo(self.mas_safeAreaLayoutGuideTrailing).inset(20);
        } else {
            make.top.equalTo(self).inset(CMP_STATUSBAR_HEIGHT);
            make.trailing.equalTo(self).inset(20);
        }
        make.height.width.equalTo(@20);
    }];
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.lessThanOrEqualTo(self.closeButton.mas_bottom).inset(40);
        make.leading.trailing.equalTo(self).inset(20);
    }];
    
    [self.firstStepLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.lessThanOrEqualTo(self.titleLabel.mas_bottom).inset(40);
        make.leading.trailing.equalTo(self).inset(20);
    }];
    
    [self.firstStepImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.firstStepLabel.mas_bottom).inset(20);
        make.width.equalTo(@275);
        make.height.equalTo(@130);
    }];
    
    [self.secondStepLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.lessThanOrEqualTo(self.firstStepImage.mas_bottom).inset(40);
        make.leading.trailing.equalTo(self).inset(20);
    }];
    
    [self.secondStepImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.secondStepLabel.mas_bottom).inset(20);
        make.width.equalTo(@275);
        make.height.equalTo(@130);
    }];
    
    [self.kownButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.equalTo(@280);
        make.height.equalTo(@40);
        make.top.greaterThanOrEqualTo(self.secondStepImage.mas_bottom);
        if (@available(iOS 11.0,*)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).inset(10);
        } else {
            make.bottom.equalTo(self).inset(10);
        }
    }];
    
    [super updateConstraints];
}

#pragma mark-
#pragma mark Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        NSDictionary *dic;
        if (iPhone5) {
            dic = @{NSFontAttributeName : [UIFont systemFontOfSize:20]};
        } else {
            dic = @{NSFontAttributeName : [UIFont systemFontOfSize:30]};
        }
        
        NSAttributedString *text = [[NSAttributedString alloc] initWithString:SY_STRING(@"call_identification_guide_title") attributes:dic];
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.attributedText = text;
        _titleLabel.numberOfLines = 2;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

- (UILabel *)firstStepLabel {
    if (!_firstStepLabel) {
        NSDictionary *dic = @{NSFontAttributeName : [UIFont systemFontOfSize:16]};
        NSAttributedString *text = [[NSAttributedString alloc] initWithString:SY_STRING(@"call_identification_guide_1") attributes:dic];
        _firstStepLabel = [[UILabel alloc] init];
        _firstStepLabel.attributedText = text;
        _firstStepLabel.textAlignment = NSTextAlignmentLeft;
        _firstStepLabel.numberOfLines = 2;
        [_firstStepLabel sizeToFit];
    }
    return _firstStepLabel;
}

- (UIImageView *)firstStepImage {
    if (!_firstStepImage) {
        _firstStepImage = [[UIImageView alloc] init];
        NSString *imageName = [NSString stringWithFormat:@"call_guide_1%@", SY_STRING(@"common_language")];
        _firstStepImage.image = [UIImage imageNamed:imageName];
        _firstStepImage.contentMode = UIViewContentModeScaleToFill;
    }
    return _firstStepImage;
}

- (UILabel *)secondStepLabel {
    if (!_secondStepLabel) {
        NSDictionary *dic = @{NSFontAttributeName : [UIFont systemFontOfSize:16]};
        NSAttributedString *text = [[NSAttributedString alloc] initWithString:SY_STRING(@"call_identification_guide_2") attributes:dic];
        _secondStepLabel = [[UILabel alloc] init];
        _secondStepLabel.attributedText = text;
        _secondStepLabel.textAlignment = NSTextAlignmentLeft;
        [_secondStepLabel sizeToFit];
    }
    return _secondStepLabel;
}

- (UIImageView *)secondStepImage {
    if (!_secondStepImage) {
        _secondStepImage = [[UIImageView alloc] init];
        NSString *imageName = [NSString stringWithFormat:@"call_guide_2%@", SY_STRING(@"common_language")];
        _secondStepImage.image = [UIImage imageNamed:imageName];
        _secondStepImage.contentMode = UIViewContentModeScaleToFill;
    }
    return _secondStepImage;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setImage:[UIImage imageNamed:@"call_guide_close"] forState:UIControlStateNormal];
    }
    return _closeButton;
}

- (UIButton *)kownButton {
    if (!_kownButton) {
        _kownButton = [[UIButton alloc] init];
        [_kownButton setTitle:SY_STRING(@"common_isee") forState:UIControlStateNormal];
        _kownButton.backgroundColor = [UIColor cmp_colorWithName:@"theme-fc"];// [UIColor colorWithRed:58/255.0 green:173/255.0 blue:251/255.0 alpha:1.0];
        _kownButton.layer.cornerRadius = 5;
        _kownButton.layer.masksToBounds = YES;
    }
    return _kownButton;
}


@end
