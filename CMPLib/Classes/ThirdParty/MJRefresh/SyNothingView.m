//
//  SyNothingView.m
//  M1IPad
//
//  Created by wujs on 12-12-30.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#import "SyNothingView.h"
#import "Masonry.h"
#import "UIColor+Hex.h"

@interface SyNothingView()
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *infoLabel;
@end

@implementation SyNothingView

- (void)setup {
    if (!_imageView) {
        UIImage *image = [CMPThemeManager sharedManager].isDisplayDrak? [UIImage imageNamed:@"localFile.bundle/nothing_dark.png"]:[UIImage imageNamed:@"localFile.bundle/nothing.png"];
        
        float scale = self.cmp_width / image.size.width;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width * scale, image.size.height * scale)];
        _imageView.image = image;
        [self addSubview:_imageView];
    }
    
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.backgroundColor = [UIColor clearColor];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        NSAttributedString *str = [[NSAttributedString alloc]
                                   initWithString:SY_STRING(@"common_Nothing_sorry")
                                   attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                                NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#B7B7B7"]}];
        _infoLabel.attributedText = str;
        [self addSubview:_infoLabel];
    }
    
    self.backgroundColor = [UIColor cmp_colorWithName:@"p-bg"];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
    }];
    
    [self.infoLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_bottom);
        make.centerX.equalTo(self);
        make.width.equalTo(self.imageView);
        make.height.equalTo(30);
    }];
    
    [super updateConstraints];
}

@end
