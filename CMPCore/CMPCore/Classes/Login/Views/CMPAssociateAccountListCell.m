//
//  CMPAssociateAccountListCell.m
//  M3
//
//  Created by CRMO on 2018/6/11.
//

#import "CMPAssociateAccountListCell.h"
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/UIImage+RTL.h>
#import <CMPLib/CMPThemeManager.h>

@interface CMPAssociateAccountListCell()

@property (strong, nonatomic) UIView *mainView;
@property (strong, nonatomic) UILabel *shortNameLabel;
@property (strong, nonatomic) UILabel *serverTitleLabel;
@property (strong, nonatomic) UILabel *serverContentLabel;
@property (strong, nonatomic) UILabel *usernameTitleLabel;
@property (strong, nonatomic) UILabel *usernameContentLabel;
@property (strong, nonatomic) UILabel *noteTitleLabel;
@property (strong, nonatomic) UILabel *noteContentLabel;
@property (strong, nonatomic) UIButton *editButton;

@end

@implementation CMPAssociateAccountListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
    }
    return self;
}

#pragma mark-
#pragma mark-UI布局

- (void)initView {
    [self setBackgroundColor:[UIColor cmp_colorWithName:@"p-bg"]];
    [self addSubview:self.mainView];
    [self.mainView addSubview:self.shortNameLabel];
    [self.mainView addSubview:self.serverTitleLabel];
    [self.mainView addSubview:self.serverContentLabel];
    [self.mainView addSubview:self.usernameTitleLabel];
    [self.mainView addSubview:self.usernameContentLabel];
    [self.mainView addSubview:self.noteTitleLabel];
    [self.mainView addSubview:self.noteContentLabel];
    [self.mainView addSubview:self.editButton];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self).inset(10);
        make.top.equalTo(self).inset(12);
        make.height.equalTo(@124);
    }];
    
    [self.shortNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainView).inset(14);
        make.leading.equalTo(self.mainView).inset(15);
        make.trailing.equalTo(self.editButton).inset(5);
        make.height.equalTo(@20);
    }];
    
    [self.serverTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mainView).inset(15);
        make.width.equalTo(@80);
        make.height.equalTo(@20);
        make.top.equalTo(self.shortNameLabel.mas_bottom).inset(11);
    }];
    
    [self.serverContentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.serverTitleLabel.mas_trailing).inset(14);
        make.centerY.equalTo(self.serverTitleLabel);
        make.height.equalTo(@20);
        make.trailing.equalTo(self.shortNameLabel);
    }];
    
    [self.usernameTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mainView).inset(15);
        make.width.equalTo(@80);
        make.height.equalTo(@20);
        make.top.equalTo(self.serverTitleLabel.mas_bottom).inset(8);
    }];
    
    [self.usernameContentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.usernameTitleLabel.mas_trailing).inset(14);
        make.centerY.equalTo(self.usernameTitleLabel);
        make.height.equalTo(@20);
        make.trailing.equalTo(self.shortNameLabel);
    }];

    [self.noteTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mainView).inset(15);
        make.width.equalTo(@80);
        make.height.equalTo(@20);
        make.top.equalTo(self.usernameTitleLabel.mas_bottom).inset(8);
    }];
    
    [self.noteContentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.noteTitleLabel.mas_trailing).inset(14);
        make.centerY.equalTo(self.noteTitleLabel);
        make.height.equalTo(@20);
        make.trailing.equalTo(self.shortNameLabel);
    }];

    [self.editButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainView).inset(16);
        make.trailing.equalTo(self.mainView).inset(14);
        make.width.equalTo(@10);
        make.height.equalTo(@16);
    }];
    
    [super updateConstraints];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark-
#pragma mark-Getter & Setter

- (UIView *)mainView {
    if (!_mainView) {
        _mainView = [[UIView alloc] init];
        [_mainView setBackgroundColor:[UIColor cmp_colorWithName:@"white-bg"]];
    }
    return _mainView;
}

- (UILabel *)shortNameLabel {
    if (!_shortNameLabel) {
        _shortNameLabel = [[UILabel alloc] init];
        _shortNameLabel.font = [UIFont systemFontOfSize:16];
        _shortNameLabel.textAlignment = NSTextAlignmentLeft;
        _shortNameLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
    }
    return _shortNameLabel;
}

- (UILabel *)serverTitleLabel {
    if (!_serverTitleLabel) {
        _serverTitleLabel = [self commonTitleLabel];
        _serverTitleLabel.text = SY_STRING(@"ass_server_host");
    }
    return _serverTitleLabel;
}

- (UILabel *)serverContentLabel {
    if (!_serverContentLabel) {
        _serverContentLabel = [self commonContentLabel];
    }
    return _serverContentLabel;
}

- (UILabel *)usernameTitleLabel {
    if (!_usernameTitleLabel) {
        _usernameTitleLabel = [self commonTitleLabel];
        _usernameTitleLabel.text = SY_STRING(@"ass_username");
    }
    return _usernameTitleLabel;
}

- (UILabel *)usernameContentLabel {
    if (!_usernameContentLabel) {
        _usernameContentLabel = [self commonContentLabel];
    }
    return _usernameContentLabel;
}

- (UILabel *)noteTitleLabel {
    if (!_noteTitleLabel) {
        _noteTitleLabel = [self commonTitleLabel];
        _noteTitleLabel.text = SY_STRING(@"ass_server_note");
    }
    return _noteTitleLabel;
}

- (UILabel *)noteContentLabel {
    if (!_noteContentLabel) {
        _noteContentLabel = [self commonContentLabel];
    }
    return _noteContentLabel;
}

- (UIButton *)editButton {
    if (!_editButton) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_editButton setImage:[UIImage imageWithName:@"login_server_arrow" inBundle:@"CMPLogin"].rtl_imageFlippedForRightToLeftLayoutDirection forState:UIControlStateNormal];
        _editButton.userInteractionEnabled = NO;
    }
    return _editButton;
}

- (UILabel *)commonTitleLabel {
    UILabel *label = [self commonContentLabel];
    label.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
    return label;
}

- (UILabel *)commonContentLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor cmp_colorWithName:@"desc-fc"];
    return label;
}

- (void)setShortName:(NSString *)shortName {
    _shortName = shortName;
    self.shortNameLabel.text = shortName;
}

- (void)setFullUrl:(NSString *)fullUrl {
    _fullUrl = fullUrl;
    self.serverContentLabel.text = fullUrl;
}

- (void)setUsername:(NSString *)username {
    _username = username;
    self.usernameContentLabel.text = username;
}

- (void)setNote:(NSString *)note {
    _note = note;
    self.noteContentLabel.text = note;
}

- (void)setShowEdit:(BOOL)showEdit {
    _showEdit = showEdit;
    self.editButton.hidden = !showEdit;
}

@end
