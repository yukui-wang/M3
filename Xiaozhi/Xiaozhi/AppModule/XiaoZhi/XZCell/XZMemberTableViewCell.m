//
//  XZMemberTableViewCell.m
//  M3
//
//  Created by wujiansheng on 2018/1/3.
//

#import "XZMemberTableViewCell.h"
#import "XZMemberModel.h"
#import "XZCore.h"
#import <CMPLib/CMPFaceView.h>

#define kFontSize 16
#define kNameFontSize 15
#define kVauleColor [UIColor blackColor]
#define kTitleColor UIColorFromRGB(0x4a4a4a)
@interface XZMemberTableViewCell () {
    UIView *_bkView;
    UIImageView *_bkImgView;
    CMPFaceView *_faceView;
}
@property(nonatomic, retain)UILabel *nameLabel;
@property(nonatomic, retain)UILabel *departmentLable;
@property(nonatomic, retain)UILabel *departmentValueLable;
@property(nonatomic, retain)UILabel *postLabel;
@property(nonatomic, retain)UILabel *postValueLabel;
@property(nonatomic, retain)UILabel *levelLabel;
@property(nonatomic, retain)UILabel *levelValueLabel;
@property(nonatomic, retain)UILabel *phoneLabel;
@property(nonatomic, retain)UILabel *phoneValueLabel;

@property(nonatomic, retain)UIButton *telButton;
@property(nonatomic, retain)UIButton *mailButton;
@property(nonatomic, retain)UIButton *collButton;
@property(nonatomic, retain)UIButton *imButton;


@end

@implementation XZMemberTableViewCell

- (void)dealloc {
    self.telButton = nil;
    self.mailButton = nil;
    self.collButton = nil;
    self.imButton = nil;

    SY_RELEASE_SAFELY(_bkView);
    SY_RELEASE_SAFELY(_bkImgView)
    SY_RELEASE_SAFELY(_faceView);
    SY_RELEASE_SAFELY(_nameLabel);
    SY_RELEASE_SAFELY(_departmentLable);
    SY_RELEASE_SAFELY(_departmentValueLable);
    SY_RELEASE_SAFELY(_postLabel);
    SY_RELEASE_SAFELY(_postValueLabel);
    SY_RELEASE_SAFELY(_levelLabel);
    SY_RELEASE_SAFELY(_levelValueLabel);
    SY_RELEASE_SAFELY(_phoneLabel);
    SY_RELEASE_SAFELY(_phoneValueLabel);

    [super dealloc];
}

- (UILabel *)lableWithFontSize:(CGFloat)fontSize text:(NSString *)text  color:(UIColor *)color{
    UILabel *label = [[UILabel alloc] init];
    label.font = FONTSYS(fontSize);
    label.text = text;
    label.textColor = color;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    return [label autorelease];
}

- (UIButton *)buttonWithTitle:(NSString *)Title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:Title forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0x006ff1) forState:UIControlStateNormal];
    button.titleLabel.font = FONTSYS(14);
    button.layer.cornerRadius = 12;
    button.layer.masksToBounds = YES;
    button.layer.borderWidth = 1;
    button.layer.borderColor = UIColorFromRGB(0xbedafb).CGColor;
    [button setBackgroundColor:[UIColor whiteColor]];
    return button;
}

- (void)setup {
    [super setup];
    if (!_bkView) {
        _bkView = [[UIImageView alloc] init];
        _bkView.layer.cornerRadius = 12;
        _bkView.layer.masksToBounds = YES;
        _bkView.backgroundColor = [UIColor whiteColor];
        _bkView.layer.borderWidth = 1;
        _bkView.layer.borderColor = UIColorFromRGB(0x9ecafb).CGColor;
        [self addSubview:_bkView];
    }
    if (!_bkImgView) {
        _bkImgView = [[UIImageView alloc] init];
        _bkImgView.image =  XZ_IMAGE(@"xz_memberbk.png");
        [_bkView addSubview:_bkImgView];
    }
    if (!_faceView) {
        _faceView = [[CMPFaceView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _faceView.layer.cornerRadius = 30;
        _faceView.layer.masksToBounds = YES;
        [_bkView addSubview:_faceView];
    }
    if (!self.nameLabel) {
        self.nameLabel = [self lableWithFontSize:kNameFontSize text:@"" color:kVauleColor];
        [_bkView addSubview:self.nameLabel];
    }
    if (!self.departmentLable) {
        self.departmentLable = [self lableWithFontSize:kFontSize text:@"部门" color:kTitleColor];
        [_bkView addSubview:self.departmentLable];
    }
    if (!self.departmentValueLable) {
        self.departmentValueLable = [self lableWithFontSize:kFontSize text:@"" color:kVauleColor];
        [_bkView addSubview:self.departmentValueLable];
    }
    if (!self.postLabel) {
        self.postLabel = [self lableWithFontSize:kFontSize text:@"主岗" color:kTitleColor];
        [_bkView addSubview:self.postLabel];
    }
    if (!self.postValueLabel) {
        self.postValueLabel = [self lableWithFontSize:kFontSize text:@"" color:kVauleColor];
        [_bkView addSubview:self.postValueLabel];
    }
    if (!self.levelLabel) {
        self.levelLabel = [self lableWithFontSize:kFontSize text:@"职务" color:kTitleColor];
        [_bkView addSubview:self.levelLabel];
    }
    if (!self.levelValueLabel) {
        self.levelValueLabel = [self lableWithFontSize:kFontSize text:@"" color:kVauleColor];
        [_bkView addSubview:self.levelValueLabel];
    }
    
    if (!self.phoneLabel) {
        self.phoneLabel = [self lableWithFontSize:kFontSize text:@"手机号" color:kTitleColor];
        [_bkView addSubview:self.phoneLabel];
    }
    if (!self.phoneValueLabel) {
        self.phoneValueLabel = [self lableWithFontSize:kFontSize text:@"" color:kVauleColor];
        [_bkView addSubview:self.phoneValueLabel];
    }
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    XZMemberModel *model = (XZMemberModel *)self.model;
    [_bkView setFrame:CGRectMake(12, 0, model.scellWidth-24, model.canOperate ? self.height-kXZCellSpace-40: self.height-kXZCellSpace)];
//    [_bkView setFrame:CGRectMake(12, 0, self.width-24, self.height-kXZCellSpace-40)];
    
    [_bkImgView setFrame:CGRectMake(0, _bkView.height-28, _bkView.width, 28)];
    
    CGFloat x = 15, y = 20;
    [_faceView setFrame:CGRectMake(x, y, 60, 60)];
  
    x = 12;
    y += _faceView.height+6;
    

    NSInteger height = 0;
    CGSize size = [_nameLabel.text sizeWithFontSize:_nameLabel.font defaultSize:CGSizeMake(66, 100)];
    if (size.height > _nameLabel.font.lineHeight) {
        height = _nameLabel.font.lineHeight*2+1;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    else {
        height = _nameLabel.font.lineHeight+1;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    [_nameLabel setFrame:CGRectMake(x, y, 66, height)];
   
    NSInteger valueHeight = 0;
    CGFloat valueWidth = _bkView.width-175;
    x = 94;
    y = 19;
    height = _departmentLable.font.lineHeight;
    size = [_departmentValueLable.text sizeWithFontSize:_departmentValueLable.font defaultSize:CGSizeMake(valueWidth, CGFLOAT_MAX)];
    
    valueHeight = size.height > _departmentValueLable.font.lineHeight *2?  _departmentValueLable.font.lineHeight *2+1: size.height+1;
    [_departmentLable setFrame:CGRectMake(x, y, 60, height)];
    x = 158;
    [_departmentValueLable setFrame:CGRectMake(x, y, valueWidth, valueHeight)];
   
    x = 94;
    y += _departmentValueLable.height +6;
//    size = [_postValueLabel.text sizeWithFontSize:_postValueLabel.font defaultSize:CGSizeMake(valueWidth, CGFLOAT_MAX)];
//    valueHeight = size.height+1;
    valueHeight = _postValueLabel.font.lineHeight+1;
    [_postLabel setFrame:CGRectMake(x, y, 60, height)];
    x = 158;
    [_postValueLabel setFrame:CGRectMake(x, y,valueWidth, valueHeight)];
   
    x = 94;
    y += _postValueLabel.height +6;
//    size = [_levelValueLabel.text sizeWithFontSize:_levelValueLabel.font defaultSize:CGSizeMake(valueWidth, CGFLOAT_MAX)];
//    valueHeight = size.height+1;
    valueHeight = _levelValueLabel.font.lineHeight+1;
    
    [_levelLabel setFrame:CGRectMake(x, y, 60, height)];
    x = 158;
    [_levelValueLabel setFrame:CGRectMake(x, y, valueWidth, valueHeight)];
   
    x = 94;
    y += _levelValueLabel.height +6;
    [_phoneLabel setFrame:CGRectMake(x, y, 60, height)];
    x = 158;
    [_phoneValueLabel setFrame:CGRectMake(x, y, valueWidth, height)];
    
    x = 12;
    if (self.collButton) {
        [self.collButton setFrame:CGRectMake(x, self.height-40, 62, 30)];
        x += 72;
    }
    if (self.imButton) {
        [self.imButton setFrame:CGRectMake(x, self.height-40, 62, 30)];
        x += 72;
    }
    if (self.telButton) {
        [self.telButton setFrame:CGRectMake(x, self.height-40, 62, 30)];
        x += 72;
    }
    if (self.mailButton) {
        [self.mailButton setFrame:CGRectMake(x, self.height-40, 62, 30)];
    }
}


- (void)setModel:(XZMemberModel *)model {
    [super setModel:model];
    
    CMPOfflineContactMember *member = model.member;
    SyFaceDownloadObj *memberIcon = [[SyFaceDownloadObj alloc] init];
    memberIcon.memberId = member.orgID;
    memberIcon.serverId = [XZCore serverID];
    memberIcon.downloadUrl = [CMPCore memberIconUrlWithId:memberIcon.memberId];
    _faceView.memberIcon = memberIcon;
    SY_RELEASE_SAFELY(memberIcon);
    
    _nameLabel.text = member.name;
    _departmentValueLable.text = member.department;
    _postValueLabel.text = member.postName;
    _levelValueLabel.text = member.level;
    _phoneValueLabel.text = member.mobilePhone;
    if (model.canOperate) {
        if (!self.collButton && model.canColl) {
            self.collButton = [self buttonWithTitle:@"发协同"];
            [self.collButton addTarget:self action:@selector(collButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.collButton];
        }
        if (!self.imButton && model.canIM) {
            self.imButton = [self buttonWithTitle:@"发消息"];
            [self.imButton addTarget:self action:@selector(imButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.imButton];
        }
        if (model.hasPhone) {
            if (!self.telButton) {
                self.telButton = [self buttonWithTitle:@"打电话"];
                [self.telButton addTarget:self action:@selector(telPhone:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:self.telButton];
            }
            if (!self.mailButton) {
                self.mailButton = [self buttonWithTitle:@"发短信"];
                [self.mailButton addTarget:self action:@selector(mailPhone:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:self.mailButton];
            }
        }
    }
    else {
        [self removeButtons];
    }
    [self customLayoutSubviewsFrame:self.frame];
}

- (void)removeButtons {
    [self.telButton removeFromSuperview];
    self.telButton = nil;
    [self.mailButton removeFromSuperview];
    self.mailButton = nil;
    [self.collButton removeFromSuperview];
    self.collButton = nil;
    [self.imButton removeFromSuperview];
    self.imButton = nil;

}
- (void)telPhone:(UIButton *)sender {
    XZMemberModel *model = (XZMemberModel *)self.model;
    if(model.clickButtonBlock) {
        model.clickButtonBlock(@"打电话");
    }
    [model call];
    [self removeButtons];
}

- (void)mailPhone:(UIButton *)sender{
    XZMemberModel *model = (XZMemberModel *)self.model;
    if(model.clickButtonBlock) {
        model.clickButtonBlock(@"发短信");
    }
    [model sendMessage];
    [self removeButtons];
}

- (void)collButtonClick:(id)sender {
    XZMemberModel *model = (XZMemberModel *)self.model;
    if(model.clickButtonBlock) {
        model.clickButtonBlock(@"发协同");
    }
    [model sendColl];
    [self removeButtons];
}
- (void)imButtonClick:(id)sender {
    XZMemberModel *model = (XZMemberModel *)self.model;
    if(model.clickButtonBlock) {
        model.clickButtonBlock(@"发消息");
    }
    [model sendIMMessage];
    [self removeButtons];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
