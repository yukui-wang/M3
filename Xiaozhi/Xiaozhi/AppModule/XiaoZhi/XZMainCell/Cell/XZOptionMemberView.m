//
//  XZOptionMemberView.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/31.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#define kContentFont  FONTSYS(20)
#define kDeleteHeight 20
#define kCellHeight 66

#import "XZOptionMemberView.h"
#import "XZCore.h"
#import <CMPLib/CMPFaceView.h>
#import <CMPLib/CMPBaseTableViewCell.h>

@interface XZOptionMemberItemCell : CMPBaseTableViewCell {
    UIImageView *_selectView;
    CMPFaceView *_faceView;
    UILabel *_nameLabel;
    UILabel *_postLabel;
    UIView *_line;
}

@property(nonatomic, assign)BOOL isLast;
@end

@implementation XZOptionMemberItemCell

- (void)setup {

    if (!_selectView) {
        _selectView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [self addSubview:_selectView];
    }
    if (!_faceView) {
        _faceView = [[CMPFaceView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _faceView.layer.cornerRadius = 20;
        _faceView.layer.masksToBounds = YES;
        [self addSubview:_faceView];
    }
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        [_nameLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [_nameLabel setFont:FONTSYS(16)];
        [_nameLabel setTextColor:UIColorFromRGB(0x333333)];
        [self addSubview:_nameLabel];
    }
    if (!_postLabel) {
        _postLabel = [[UILabel alloc] init];
        [_postLabel setBackgroundColor:[UIColor clearColor]];
        [_postLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [_postLabel setFont:FONTSYS(12)];
        [_postLabel setTextColor:UIColorFromRGB(0x999999)];
        [self addSubview:_postLabel];
    }
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = UIColorFromRGB(0xe4e4e4);
        [self addSubview:_line];
    }
    self.separatorHide = YES;
    [self setupSelected:NO];
    [self setSelectBkViewColor:[UIColor clearColor]];
}

- (void)setIsLast:(BOOL)isLast {
    _isLast = isLast;
    _line.hidden = isLast;
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    [_selectView setFrame:CGRectMake(14, self.height/2-10, 20, 20)];
    [_faceView setFrame:CGRectMake(44, self.height/2-20, 40, 40)];
    [_nameLabel setFrame:CGRectMake(98, 11, self.width-100, _nameLabel.font.lineHeight)];
    [_postLabel setFrame:CGRectMake(98, 39, self.width-100, _postLabel.font.lineHeight)];
    [_line setFrame:CGRectMake(98, self.height-1, self.width-98, 1)];
}

- (void)setupMember:(CMPOfflineContactMember *)member {
    SyFaceDownloadObj *memberIcon = [[SyFaceDownloadObj alloc] init];
    memberIcon.memberId = member.orgID;
    memberIcon.serverId = [XZCore serverID];
    memberIcon.downloadUrl = [CMPCore memberIconUrlWithId:memberIcon.memberId];
    _faceView.memberIcon = memberIcon;
    _nameLabel.text = member.name;
    _postLabel.text = member.postName;
}
- (void)setupSelected:(BOOL)selected {
    _selectView.image = XZ_IMAGE(selected?@"xz_member_select.png":@"xz_member_org.png");
}

@end

@interface XZOptionMemberView () <UITableViewDelegate,UITableViewDataSource> {
    UILabel *_contentLabel;
    UIView *_cardView;
    UITableView *_tableView;
    UIButton *_cancelButton;
    UIButton *_moreButton;
    UIButton *_okButton;
}
@property(nonatomic, strong)XZOptionMemberModel *model;
@property(nonatomic, strong)NSMutableArray *selectMembers;
@end


@implementation XZOptionMemberView

- (void)setup {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        [_contentLabel setBackgroundColor:[UIColor clearColor]];
        [_contentLabel setFont:kContentFont];
        [_contentLabel setTextColor:[UIColor whiteColor]];
        [self addSubview:_contentLabel];
    }
    if (!_cardView) {
        _cardView = [[UIView alloc] init];
        [_cardView setBackgroundColor:[UIColor whiteColor]];
        _cardView.layer.cornerRadius = 8;
        _cardView.layer.masksToBounds = YES;
        [self addSubview:_cardView];
    }
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        [_cardView addSubview:_tableView];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
}

- (void)customLayoutSubviews {
    NSInteger height = _contentLabel.font.lineHeight+1;
    [_contentLabel setFrame:CGRectMake(16, 0, self.width-16, height)];
    NSInteger memberCount = [[self memberArray] count];
    if (memberCount > 5) {
        [_cardView setFrame:CGRectMake(0, height+10, self.width, 5 *kCellHeight-kDeleteHeight)];
    }
    else {
        [_cardView setFrame:CGRectMake(0, height+10, self.width, memberCount *kCellHeight)];
    }
    [_tableView setFrame:_cardView.bounds];
    if (_cancelButton) {
        [_cancelButton setFrame:CGRectMake(0, CGRectGetMaxY(_cardView.frame)+10, 60, 30)];
    }
    if (_moreButton) {
        [_moreButton setFrame:CGRectMake(CGRectGetMaxX(_cancelButton.frame)+6, _cancelButton.originY, 60, 30)];
    }
    if (_okButton) {
        [_okButton setFrame:CGRectMake(CGRectGetMaxX(_moreButton.frame)+6, _cancelButton.originY, 60, 30)];
    }
}

- (NSMutableArray *)selectMembers {
    if (!_selectMembers) {
        _selectMembers = [[NSMutableArray alloc] init];
    }
    return _selectMembers;
}
- (NSArray *)memberArray {
    return self.model.param.members;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section  {
    return self.memberArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"XZOptionMemberItemCell";
    XZOptionMemberItemCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[XZOptionMemberItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSArray *memberArray = [self memberArray];
    NSInteger row = indexPath.row;
    if (row < memberArray.count) {
        CMPOfflineContactMember *member = memberArray[row];
        [cell setupMember:member];
        [cell setupSelected:[self.selectMembers containsObject:member]];
    }
    cell.isLast = indexPath.row < memberArray.count-1 ? NO :YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *memberArray = [self memberArray];
    NSInteger row = indexPath.row;
    if (row < memberArray.count) {
        CMPOfflineContactMember *member = memberArray[row];
        if (self.model.param.isMultipleSelection) {
            if ([self.selectMembers containsObject:member]) {
                [self.selectMembers removeObject:member];
            }
            else {
                [self.selectMembers addObject:member];
            }
            [self showOkBtn:self.selectMembers.count > 0 ?YES:NO];
            XZOptionMemberItemCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell setupSelected:[self.selectMembers containsObject:member]];
        }
        else {
            if (self.model.didChoosedMembersBlock) {
                self.model.didChoosedMembersBlock(@[member],YES);
            }
        }
    }
}

- (void)setupWithModel:(XZOptionMemberModel *)model {
    self.model = model;
    __weak typeof(self) weakSelf = self;
    self.model.clickOKButtonBlock = ^{
        [weakSelf okButtonAction:nil];
    };
    _contentLabel.text = model.param.showContent;
    if (model.param.isMultipleSelection) {
        if (!_moreButton) {
            _moreButton = [self btnWithTitle:@"更多"];
            [self addSubview:_moreButton];
            [_moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        if (!_cancelButton) {
            _cancelButton = [self btnWithTitle:@"取消"];
            [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_cancelButton];
        }
        [self.selectMembers addObjectsFromArray:model.param.defaultSelectArray];
        [self showOkBtn:self.selectMembers.count > 0 ?YES:NO];
    }
    [self customLayoutSubviews];
    [_tableView reloadData];
}

- (void)showOkBtn:(BOOL)show {
    if (show) {
        if (!_okButton) {
            _okButton = [self btnWithTitle:@"确认"];
            _okButton.backgroundColor = UIColorFromRGB(0x297FFB);
            _okButton.layer.borderWidth = 0;
            [_okButton addTarget:self action:@selector(okButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_okButton];
        }
        [_okButton setFrame:CGRectMake(CGRectGetMaxX(_moreButton.frame)+6, _cancelButton.originY, 60, 30)];
        _okButton.hidden = NO;
    }
    else {
        _okButton.hidden = YES;
    }
    
}

- (UIButton *)btnWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = FONTSYS(14);
    button.layer.cornerRadius = 15;
    button.layer.masksToBounds = YES;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
    return button;
}

- (void)cancelButtonAction:(id)sender {
    if (self.model.clickTextBlock) {
        self.model.clickTextBlock(@"取消");
    }
}

- (void)moreButtonAction:(id)sender {
    if (self.model.showMoreBlock) {
        self.model.showMoreBlock(self.selectMembers,self.model.param.isMultipleSelection);
    }
}

- (void)okButtonAction:(id)sender {
    if (self.model.didChoosedMembersBlock) {
        self.model.didChoosedMembersBlock(self.selectMembers,YES);
    }
}

+ (CGFloat)viewHeightForModel:(XZOptionMemberModel *)model {
    NSInteger height = kContentFont.lineHeight+1;
    NSInteger memberCount = model.param.members.count;
    if (memberCount > 5) {
        height += 10 + 5 *kCellHeight -kDeleteHeight; //-20   OA-193691
    }
    else {
        height += 10 + memberCount *kCellHeight;
    }
    if (model.param.isMultipleSelection) {
        //确定按钮
        height += 10+30;
    }
    height += 20;//多余空间
    return height;
}

@end
