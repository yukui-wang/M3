//
//  CMPOfflineContactSearchCell.m
//  CMPCore
//
//  Created by wujiansheng on 2017/1/5.
//
//

#import "CMPOfflineContactTopCell.h"
#import "CMPChatManager.h"

@interface CMPOfflineContactTopCell()
{
    UIImageView *_orgImageView;//组织架构
    UILabel *_orgLabel;
    UIImageView *_teamImageView;//项目组
    UILabel *_teamLabel;
    UIImageView *_groupImageView;//我的群聊
    UILabel *_groupLabel;
    UIImageView *_contactsImageView;//常用联系人
    UILabel *_contactsLabel;
    
    UIImageView *_relatedImageView;//关联人员
    UILabel *_relatedLabel;
    
//    UIView *_sepLine;
    
}
@end

@implementation CMPOfflineContactTopCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.orgButton = nil;
    self.teamButton = nil;
    self.groupButton = nil;
    self.contactsButton = nil;
    self.relatedButton = nil;
    
    SY_RELEASE_SAFELY(_orgImageView);
    SY_RELEASE_SAFELY(_orgLabel);
    SY_RELEASE_SAFELY(_teamImageView);
    SY_RELEASE_SAFELY(_teamLabel);
    SY_RELEASE_SAFELY(_groupImageView);
    SY_RELEASE_SAFELY(_groupLabel);
    SY_RELEASE_SAFELY(_contactsImageView);
    SY_RELEASE_SAFELY(_contactsLabel);
    
    SY_RELEASE_SAFELY(_relatedImageView);
    SY_RELEASE_SAFELY(_relatedLabel);
//    SY_RELEASE_SAFELY(_sepLine);
    [super dealloc];
}

- (void)setupAZView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOrNotShowChatGroup:) name:kNotificationName_PermissionForZhixinChange object:nil];
    if (!_orgImageView) {
        _orgImageView = [[UIImageView alloc] init];
        _orgImageView.image = [UIImage imageNamed:@"offlineContact.bundle/org.png"];
        [self addSubview:_orgImageView];
    }
    if (!_orgLabel) {
        _orgLabel = [[UILabel alloc]init];
        _orgLabel.textAlignment = NSTextAlignmentLeft;
        _orgLabel.font = FONTSYS(18);
        _orgLabel.backgroundColor = [UIColor clearColor];
        _orgLabel.textColor = UIColorFromRGB(0x000000);
        _orgLabel.text = SY_STRING(@"contacts_org");
        [self addSubview:_orgLabel];
    }

    if (!_teamImageView) {
        _teamImageView = [[UIImageView alloc] init];
        _teamImageView.image =[UIImage imageNamed:@"offlineContact.bundle/team.png"];
        [self addSubview:_teamImageView];
    }
    if (!_teamLabel) {
        _teamLabel = [[UILabel alloc]init];
        _teamLabel.textAlignment = NSTextAlignmentLeft;
        _teamLabel.font = FONTSYS(18);
        _teamLabel.backgroundColor = [UIColor clearColor];
        _teamLabel.textColor = UIColorFromRGB(0x000000);
        _teamLabel.text = SY_STRING(@"contacts_team");
        [self addSubview:_teamLabel];
    }
    
    if (!_groupImageView) {
        _groupImageView = [[UIImageView alloc] init];
        _groupImageView.image = [UIImage imageNamed:@"offlineContact.bundle/group.png"];
        [self addSubview:_groupImageView];
    }
    if (!_groupLabel) {
        _groupLabel = [[UILabel alloc]init];
        _groupLabel.textAlignment = NSTextAlignmentLeft;
        _groupLabel.font = FONTSYS(18);
        _groupLabel.backgroundColor = [UIColor clearColor];
        _groupLabel.textColor = UIColorFromRGB(0x000000);
        _groupLabel.text = SY_STRING(@"contacts_groupchat");
        [self addSubview:_groupLabel];
    }
    
    if (!_contactsImageView) {
        _contactsImageView = [[UIImageView alloc] init];
        _contactsImageView.image = [UIImage imageNamed:@"offlineContact.bundle/contacts.png"];
        [self addSubview:_contactsImageView];
    }
    if (!_contactsLabel) {
        _contactsLabel = [[UILabel alloc]init];
        _contactsLabel.textAlignment = NSTextAlignmentLeft;
        _contactsLabel.font = FONTSYS(18);
        _contactsLabel.backgroundColor = [UIColor clearColor];
        _contactsLabel.textColor = UIColorFromRGB(0x000000);
        _contactsLabel.text = SY_STRING(@"contacts_frequent");
        [self addSubview:_contactsLabel];
    }
    //contacts_related
    [self initButtons];
    self.selectionStyle =  UITableViewCellSelectionStyleNone;
    [self setBkViewColor:[UIColor whiteColor]];
    [self setSelectBkViewColor:[UIColor whiteColor]];
    
    self.separatorImageView.hidden = YES;
}

- (void)setupFrequentView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOrNotShowChatGroup:) name:kNotificationName_PermissionForZhixinChange object:nil];
    if (!_orgImageView) {
        _orgImageView = [[UIImageView alloc] init];
        _orgImageView.image = [UIImage imageNamed:@"offlineContact.bundle/org_new.png"];
        [self addSubview:_orgImageView];
    }
    if (!_orgLabel) {
        _orgLabel = [[UILabel alloc]init];
        _orgLabel.textAlignment = NSTextAlignmentLeft;
        _orgLabel.font = FONTSYS(18);
        _orgLabel.backgroundColor = [UIColor clearColor];
        _orgLabel.textColor = UIColorFromRGB(0x000000);
        _orgLabel.text = SY_STRING(@"contacts_org");
        [self addSubview:_orgLabel];
    }
    
    if (!_teamImageView) {
        _teamImageView = [[UIImageView alloc] init];
        _teamImageView.image =[UIImage imageNamed:@"offlineContact.bundle/team_new.png"];
        [self addSubview:_teamImageView];
    }
    if (!_teamLabel) {
        _teamLabel = [[UILabel alloc]init];
        _teamLabel.textAlignment = NSTextAlignmentLeft;
        _teamLabel.font = FONTSYS(18);
        _teamLabel.backgroundColor = [UIColor clearColor];
        _teamLabel.textColor = UIColorFromRGB(0x000000);
        _teamLabel.text = SY_STRING(@"contacts_team");
        [self addSubview:_teamLabel];
    }
    
    if (!_groupImageView) {
        _groupImageView = [[UIImageView alloc] init];
        _groupImageView.image = [UIImage imageNamed:@"offlineContact.bundle/group_new.png"];
        [self addSubview:_groupImageView];
    }
    if (!_groupLabel) {
        _groupLabel = [[UILabel alloc]init];
        _groupLabel.textAlignment = NSTextAlignmentLeft;
        _groupLabel.font = FONTSYS(18);
        _groupLabel.backgroundColor = [UIColor clearColor];
        _groupLabel.textColor = UIColorFromRGB(0x000000);
        _groupLabel.text = SY_STRING(@"contacts_groupchat");
        [self addSubview:_groupLabel];
    }
    
    if (!_relatedImageView) {
        _relatedImageView = [[UIImageView alloc] init];
        _relatedImageView.image = [UIImage imageNamed:@"offlineContact.bundle/related.png"];
        [self addSubview:_relatedImageView];
    }
    if (!_relatedLabel) {
        _relatedLabel = [[UILabel alloc]init];
        _relatedLabel.textAlignment = NSTextAlignmentLeft;
        _relatedLabel.font = FONTSYS(18);
        _relatedLabel.backgroundColor = [UIColor clearColor];
        _relatedLabel.textColor = UIColorFromRGB(0x000000);
        _relatedLabel.text = SY_STRING(@"contacts_related");
        [self addSubview:_relatedLabel];
    }

    [self initButtons];
    self.selectionStyle =  UITableViewCellSelectionStyleNone;
    [self setBkViewColor:[UIColor whiteColor]];
    [self setSelectBkViewColor:[UIColor whiteColor]];
    
    self.separatorImageView.hidden = YES;
}

- (void) initButtons {
    if (!self.orgButton) {
        self.orgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.orgButton];
    }
    if (!self.teamButton) {
        self.teamButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.teamButton];
    }
    if (!self.groupButton) {
        self.groupButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.groupButton];
    }
    if (!self.contactsButton && _contactsLabel) {
        self.contactsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.contactsButton];
    }
    if (!self.relatedButton && _relatedLabel) {
        self.relatedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.relatedButton];
    }
}

- (void)customLayoutSubviewsFrame:(CGRect)frame
{
    if (![CMPCore sharedInstance].hasPermissionForZhixin ||
        [CMPChatManager sharedManager].chatType == CMPChatType_null) {
        _groupImageView.hidden = YES;
        _groupLabel.hidden = YES;
        _groupButton.hidden = YES;
    } else {
        _groupImageView.hidden = NO;
        _groupLabel.hidden = NO;
        _groupButton.hidden = NO;
    }
    CGFloat imageW = 23;
    CGFloat x = 14;
    CGFloat y = 16-6;//-6搜索框margin
    [_orgImageView setFrame:CGRectMake(x, y, imageW, imageW)];
    x += imageW+10;

    CGFloat labelW = self.width/2-x;
    [_orgLabel setFrame:CGRectMake(x - 5, y, labelW, imageW)];
   
    x = self.width/2+14;
    [_teamImageView setFrame:CGRectMake(x, y, imageW, imageW)];
    x += imageW+10;

    [_teamLabel setFrame:CGRectMake(x-5, y, labelW-10, imageW)];
    
//    [_sepLine setFrame:CGRectMake(14, y +40+14, self.width-14, 1)];
    
    y += imageW+ 20;
    x = 14;
    if ([CMPCore sharedInstance].hasPermissionForZhixin && [CMPChatManager sharedManager].chatType != CMPChatType_null) {
        
        [_groupImageView setFrame:CGRectMake(x, y, imageW, imageW)];
        x += imageW+10;
        
        [_groupLabel setFrame:CGRectMake(x - 5, y, labelW, imageW)];
        
        x = self.width/2+14;
    }
    if (_contactsImageView) {
        [_contactsImageView setFrame:CGRectMake(x, y, imageW, imageW)];
    }
    if (_relatedImageView) {
        [_relatedImageView setFrame:CGRectMake(x, y, imageW, imageW)];
    }
    
    x += imageW+10;

    if (_contactsLabel) {
        [_contactsLabel setFrame:CGRectMake(x-5, y,labelW-10, imageW)];
    }
    if (_relatedLabel) {
        [_relatedLabel setFrame:CGRectMake(x-5, y,labelW-10, imageW)];
    }
    CGFloat w = self.width/2-28;
    [_orgButton setFrame:CGRectMake(_orgImageView.originX, _orgImageView.originY, w, imageW)];
    [_teamButton setFrame:CGRectMake(_teamImageView.originX, _teamImageView.originY, w, imageW)];
    [_groupButton setFrame:CGRectMake(_groupImageView.originX, _groupImageView.originY, w, imageW)];
    if (_contactsButton) {
        [_contactsButton setFrame:CGRectMake(_contactsImageView.originX, _contactsImageView.originY, w, imageW)];
    }
    if (_relatedButton) {
        [_relatedButton setFrame:CGRectMake(_relatedImageView.originX, _relatedImageView.originY, w, imageW)];
    }
}

- (void)showOrNotShowChatGroup:(NSNotification *)notif
{
    [self customLayoutSubviewsFrame:self.frame];
}


+ (CGFloat)cellHeight
{
   return 16*2 +23*2 +20-6;//-6搜索框margin
}
@end
