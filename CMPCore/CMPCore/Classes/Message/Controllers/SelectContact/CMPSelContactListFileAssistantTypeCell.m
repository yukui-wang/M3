//
//  CMPSelContactListFileAssistantTypeCell.m
//  M3
//
//  Created by 程昆 on 2020/5/20.
//

#import "CMPSelContactListFileAssistantTypeCell.h"
#import "CMPModuleIconView.h"
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/Masonry.h>
#import "CMPMessageObject.h"
#import <CMPLib/CMPThemeManager.h>

@interface CMPSelContactListFileAssistantTypeCell ()

@property (nonatomic, strong) CMPModuleIconView *iconView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) UIImageView *selectImageView;

@end

@implementation CMPSelContactListFileAssistantTypeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpSubviews];
        [self setUpSubviewsConstraints];
    }
    return self;
}

#pragma mark - layout Subviews

- (void)setUpSubviews {
    self.selectionStyle  = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
    
    [self addSubview:self.iconView];
    [self addSubview:self.userNameLabel];
    [self addSubview:self.separatorView];
}

- (void)setUpSubviewsConstraints {
    if(_selectImageView){
        [_selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(14);
            make.width.height.mas_equalTo(20);
            make.centerY.equalTo(self);
        }];
    }
    CGFloat x = _selectImageView?14+20+10:14;
    [self.iconView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(x);
        make.centerY.equalTo(self);
        make.size.equalTo(CGSizeMake(26, 26));
    }];
    
    [self.userNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.iconView.mas_trailing).offset(10);
        make.trailing.equalTo(self).offset(-10);
        make.centerY.equalTo(self);
    }];
    
    [self.separatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(14);
        make.bottom.trailing.equalTo(self);
        make.height.equalTo(0.5);
    }];
        
    self.iconView.layoutSubviewsCallback = ^(UIView *superview) {
        CMPModuleIconView *iconView = (CMPModuleIconView *)superview;
        [iconView setIconSize:CGSizeMake(13, 13)];
    };
}
- (void)setSelectImageConfig{
    if(!_selectImageView){
        _selectImageView = [UIImageView new];
        _selectImageView.image = [UIImage imageNamed:@"share_btn_unselected_circle"];
        [self addSubview:_selectImageView];
    }
    [self setUpSubviewsConstraints];
}
- (void)setSelectCell:(BOOL)selectCell{
    _selectCell = selectCell;
    _selectImageView.image = _selectCell?[[CMPThemeManager sharedManager] skinColorImageWithName:@"share_btn_selected_circle"]:[UIImage imageNamed:@"share_btn_unselected_circle"];
}

#pragma mark - lazy view

- (CMPModuleIconView *)iconView {
    if (!_iconView) {
        _iconView = [[CMPModuleIconView alloc] init];
        _iconView.layer.cornerRadius = 13;
    }
    return _iconView;
}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc]init];
        _userNameLabel.textAlignment = NSTextAlignmentLeft;
        _userNameLabel.font = FONTSYS(16);
        _userNameLabel.backgroundColor = [UIColor clearColor];
        _userNameLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
        _userNameLabel.numberOfLines = 2;
    }
    return _userNameLabel;
}

- (UIView *)separatorView {
    if (!_separatorView) {
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
    }
    return _separatorView;
}

#pragma mark - 业务方法

- (void)setDataModel:(CMPMessageObject *)dataModel {
    [self.iconView setImageWithIconUrl:@"image:msg_file_assistant:2719739"];
    self.userNameLabel.text = dataModel.appName;
}

@end
