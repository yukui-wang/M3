//
//  XZMemberCard.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/23.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZMemberDetailView.h"
#import <CMPLib/CMPFaceView.h>
#import "XZCore.h"
@interface XZMemberDetailView () {
    UIView *_cardView;
    UIImageView *_bkView;
    CMPFaceView *_faceView;
    UILabel *_nameLabel;
    UILabel *_infoLabel;
    UILabel *_phoneLabel;
}

@property (nonatomic, retain) XZMemberModel *model;
@property(nonatomic, retain)UIButton *telButton;
@property(nonatomic, retain)UIButton *mailButton;
@property(nonatomic, retain)UIButton *collButton;
@property(nonatomic, retain)UIButton *imButton;
@end


@implementation XZMemberDetailView

- (void)setup {
    if (!_cardView) {
        _cardView = [[UIView alloc] init];
        _cardView.backgroundColor = UIColorFromRGB(0xA6DBFF);
        _cardView.layer.cornerRadius = 10;
        _cardView.layer.masksToBounds = YES;
        
        [self addSubview:_cardView];
    }
    if (!_bkView) {
        _bkView = [[UIImageView alloc] init];
        _bkView.image = XZ_IMAGE(@"xz_member_bk.png");
        [_cardView addSubview:_bkView];
    }
    
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        [_nameLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [_nameLabel setFont:FONTSYS(22)];
        [_nameLabel setTextColor:UIColorFromRGB(0x333333)];
        [_cardView addSubview:_nameLabel];
    }
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        [_infoLabel setBackgroundColor:[UIColor clearColor]];
        [_infoLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [_infoLabel setFont:FONTSYS(12)];
        [_infoLabel setTextColor:UIColorFromRGB(0x666666)];
        [_cardView addSubview:_infoLabel];
    }
    
    if (!_phoneLabel) {
        _phoneLabel = [[UILabel alloc] init];
        [_phoneLabel setBackgroundColor:[UIColor clearColor]];
        [_phoneLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [_phoneLabel setFont:FONTSYS(12)];
        [_phoneLabel setTextColor:UIColorFromRGB(0x666666)];
        [_cardView addSubview:_phoneLabel];
    }
    if (!_faceView) {
        _faceView = [[CMPFaceView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        _faceView.layer.cornerRadius = 40;
        _faceView.layer.masksToBounds = YES;
        [_cardView addSubview:_faceView];
    }
}

- (void)customLayoutSubviews {
    [_cardView setFrame:CGRectMake(14, 0, self.width-28,160)];
    [_bkView setFrame:CGRectMake(0, _cardView.height-73, _cardView.width, 73)];
    [_faceView setFrame:CGRectMake(_cardView.width-100, 40, 80, 80)];
    
    NSInteger height = _nameLabel.font.lineHeight+1;
    [_nameLabel setFrame:CGRectMake(20, 40, _cardView.width-20-110, height)];
    height = _infoLabel.font.lineHeight+1;
    [_infoLabel setFrame:CGRectMake(20, 74, _cardView.width-20-110, height)];
    height = _phoneLabel.font.lineHeight+1;
    [_phoneLabel setFrame:CGRectMake(20, 98, _cardView.width-20-110, height)];
    CGFloat  x = 19;
    if (self.collButton) {
        [self.collButton setFrame:CGRectMake(x, self.height-32, 76, 32)];
        x += 76+4;
    }
    if (self.imButton) {
        [self.imButton setFrame:CGRectMake(x, self.height-32, 76, 32)];
        x += 76+4;
    }
    if (self.telButton) {
        [self.telButton setFrame:CGRectMake(x, self.height-32, 76, 32)];
        x += 76+4;
    }
    if (self.mailButton) {
        [self.mailButton setFrame:CGRectMake(x, self.height-32, 76, 32)];
    }
}

- (void)setupInfo:(XZMemberModel *)model {
    self.model = model;
    
    CMPOfflineContactMember *member = model.member;
    SyFaceDownloadObj *memberIcon = [[SyFaceDownloadObj alloc] init];
    memberIcon.memberId = member.orgID;
    memberIcon.serverId = [XZCore serverID];
    memberIcon.downloadUrl = [CMPCore memberIconUrlWithId:memberIcon.memberId];
    _faceView.memberIcon = memberIcon;
    _nameLabel.text = member.name;
    _infoLabel.text = [NSString stringWithFormat:@"%@-%@",member.department,member.postName];
    _phoneLabel.text = member.mobilePhone;
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
    [self customLayoutSubviews];
}

- (UIButton *)buttonWithTitle:(NSString *)Title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:Title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = FONTSYS(14);
    button.layer.cornerRadius = 16;
    button.layer.masksToBounds = YES;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
    [button setBackgroundColor:[UIColor clearColor]];
    return button;
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


+ (CGFloat)viewHeight:(BOOL)enable {
    if (enable) {
        return 160+41;
    }
    return 160;
}
@end
