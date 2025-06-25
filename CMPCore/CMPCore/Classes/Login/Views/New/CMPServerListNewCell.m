//
//  CMPServerListNewCell.m
//  M3
//
//  Created by CRMO on 2017/10/31.
//

#import "CMPServerListNewCell.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/UIImage+CMPImage.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/RTL.h>

static CGFloat const kViewCornerRadius = 6.f;
static CGFloat const kViewMargin = 0;
static CGFloat const kCellMargin = 30.f;

@interface CMPServerListNewCell()

@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *noteLabel;
@property (nonatomic, strong) UIView *underline;
/* bgCornerLayer */
@property (strong, nonatomic) CAShapeLayer *topBgCornerLayer;
/* bgCornerLayer */
@property (strong, nonatomic) CAShapeLayer *bottomBgCornerLayer;

@end

@implementation CMPServerListNewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
    }
    return self;
}

- (void)setupWithModel:(CMPServerModel *)model {
    [self.contentLabel setText:[model fullUrl]];
    
    NSString *note = model.note;
    _noteLabel.text = note;
    if ([NSString isNull:note]) {
        _noteLabel.hidden = YES;
    } else {
        _noteLabel.hidden = NO;
        NSDictionary *attribute = @{NSFontAttributeName : [UIFont systemFontOfSize:12],
                                    NSForegroundColorAttributeName : [UIColor cmp_colorWithName:@"sup-fc1"]
                                    };
        note = [NSString stringWithFormat:@"%@：%@", SY_STRING(@"login_server_note_prefix"), note];
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:note attributes:attribute];
        [_noteLabel setAttributedText:attributedString];
    }
    
    self.isSelected = model.inUsed;
    
    if (model.extend1 && ([model.extend1 isEqualToString:@"1"])) {
        self.editButton.hidden = YES;
    } else {
        self.editButton.hidden = NO;
    }
    
    self.underline.hidden = NO;
    
    [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.height.equalTo(@18);
        make.top.equalTo(self.contentView).inset(13);
        if (self.noteLabel.isHidden) {
            make.centerY.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView).inset(13);
        } else {
//            make.top.equalTo(self.contentView).inset(13);
        }
        make.leading.equalTo(self.selectButton.mas_trailing).inset(10);
        make.trailing.equalTo(self.editButton.mas_leading).inset(17);
    }];
    
    [self.noteLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.noteLabel.isHidden) {
            make.edges.equalTo(self.contentLabel);
        }else{
            make.leading.trailing.equalTo(self.contentLabel);
            make.top.equalTo(self.contentLabel.mas_bottom).inset(6);
            make.bottom.equalTo(self.contentView).inset(13);
        }
    }];
}

- (void)hideBottomLine {
    self.underline.hidden = YES;
}


#pragma mark - UI布局

- (void)initView {
    [self setBackgroundColor:[UIColor cmp_colorWithName:@"white-bg"]];
    [self.contentView addSubview:self.selectButton];
    [self.contentView addSubview:self.editButton];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.noteLabel];
    [self.contentView addSubview:self.underline];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self init_updateConstraints];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)init_updateConstraints {
    _noteLabel.hidden = YES;
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).inset(10.f);
        make.width.height.equalTo(@24);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.trailing.equalTo(self.contentView).inset(kViewMargin);
        make.width.height.equalTo(@34);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.equalTo(@18);
        make.top.equalTo(self.contentView).inset(13);
        if (self.noteLabel.isHidden) {
            make.centerY.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView).inset(13);
        } else {
//            make.top.equalTo(self.contentView).inset(13);
        }
        make.leading.equalTo(self.selectButton.mas_trailing).inset(10);
        make.trailing.equalTo(self.editButton.mas_leading).inset(17);
    }];
    
    [self.noteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.noteLabel.isHidden) {
            make.edges.equalTo(self.contentLabel);
        }else{
            make.leading.trailing.equalTo(self.contentLabel);
            make.top.equalTo(self.contentLabel.mas_bottom).inset(6);
            make.bottom.equalTo(self.contentView).inset(13);
        }
    }];
    
//    [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
////        make.height.equalTo(@18);
//        make.top.equalTo(self.contentView).inset(13);
//        if (self.noteLabel.isHidden) {
//            make.centerY.equalTo(self.contentView);
//            make.bottom.equalTo(self.contentView).inset(13);
//        } else {
////            make.top.equalTo(self.contentView).inset(13);
//        }
//        make.leading.equalTo(self.selectButton.mas_trailing).inset(10);
//        make.trailing.equalTo(self.editButton.mas_leading).inset(17);
//    }];
    
//    [self.noteLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.leading.trailing.equalTo(self.contentLabel);
//        make.top.equalTo(self.contentLabel.mas_bottom).inset(6);
//        make.bottom.equalTo(self.contentView).inset(13);
//    }];
    
    [self.underline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentLabel);
        make.trailing.equalTo(self).inset(kViewMargin);
        make.height.equalTo(@0.5);
        make.bottom.equalTo(self.contentView);
    }];
    
//    [super updateConstraints];
    
    [self flipImage];
}



#pragma mark - 按钮点击事件

- (void)tapEditButton {
    if (self.tapEditAction) {
        self.tapEditAction();
    }
}

#pragma mark - Getter & Setter

- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = _isSelected ? [CMPServerListNewCell selectedBg] : [CMPServerListNewCell notSelectBg];
        [_selectButton setImage:image forState:UIControlStateNormal];
        _selectButton.enabled = NO;
        _selectButton.adjustsImageWhenDisabled = NO;
    }
    return _selectButton;
}

- (UIButton *)editButton {
    if (!_editButton) {
        UIImage *img = [UIImage imageNamed:@"table_cell_right_arrow_icon"];
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editButton setImage:img forState:UIControlStateNormal];
        [_editButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        [_editButton addTarget:self action:@selector(tapEditButton) forControlEvents:UIControlEventTouchUpInside];
        [_editButton cmp_expandClickArea:UIOffsetMake(10, 0)];
    }
    return _editButton;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _contentLabel.font = [UIFont systemFontOfSize:16];
        _contentLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
        [_contentLabel sizeToFit];
    }
    return _contentLabel;
}

- (UILabel *)noteLabel {
    if (!_noteLabel) {
        _noteLabel = [[UILabel alloc] init];
        [_noteLabel sizeToFit];
    }
    return _noteLabel;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    UIImage *image = _isSelected ? [CMPServerListNewCell selectedBg] : [CMPServerListNewCell notSelectBg];
    [_selectButton setImage:image forState:UIControlStateNormal];
}

- (UIView *)underline {
    if (!_underline) {
        _underline = [[UIView alloc] init];
        _underline.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
    }
    return _underline;
}


#pragma mark - Tools

/**
 未选中背景图片
 */
+ (UIImage *)notSelectBg {
    return [UIImage imageWithName:@"login_server_not_select" inBundle:@"CMPLogin"];
}

/**
 选中背景图片
 */
+ (UIImage *)selectedBg {
    return [[UIImage imageWithName:@"login_server_selected" inBundle:@"CMPLogin"] cmp_imageWithTintColor:[CMPThemeManager sharedManager].themeColor];
}

- (void)flipImage
{
    if (![UIView isRTL] || !_editButton) {
        return;
    }
    
    CGAffineTransform trans = _editButton.transform;
    _editButton.transform = CGAffineTransformRotate(trans, M_PI);
}



- (void)layoutSubviews {
    [self.topBgCornerLayer removeFromSuperlayer];
    self.topBgCornerLayer = nil;
    [self.bottomBgCornerLayer removeFromSuperlayer];
    self.bottomBgCornerLayer = nil;
    
    if (self.showTopCorner && self.showBottomCorner) {
       
        [self cmp_setRoundCornerWithRadius:6.f bgColor:[UIColor cmp_colorWithName:@"input-bg"]];
        
    }else {
        
        if (self.showBottomCorner) {
            self.backgroundColor = UIColor.clearColor;
            self.bottomBgCornerLayer = [self cmp_setBottomCornerWithRadius:kViewCornerRadius bgColor:[UIColor cmp_colorWithName:@"input-bg"]];
        }
        
        if (self.showTopCorner) {
            self.backgroundColor = UIColor.clearColor;
            self.topBgCornerLayer = [self cmp_setTopCornerWithRadius:kViewCornerRadius bgColor:[UIColor cmp_colorWithName:@"input-bg"]];
        }
        
        if (!self.bottomBgCornerLayer && !self.topBgCornerLayer) {
            self.backgroundColor = [UIColor cmp_colorWithName:@"input-bg"];
        }
    }
    
    
    [super layoutSubviews];
}

@end
