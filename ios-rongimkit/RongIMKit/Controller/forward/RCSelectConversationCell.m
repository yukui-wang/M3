//
//  RCSelectConversationCell.m
//  RongCallKit
//
//  Created by 岑裕 on 16/3/15.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCSelectConversationCell.h"
#import "RCKitCommonDefine.h"
#import "RCKitUtility.h"
#import "RCUserInfoCacheManager.h"
#import "RCloudImageView.h"

@interface RCSelectConversationCell ()

@property (nonatomic, strong) UIImageView *selectedImageView;

@property (nonatomic, strong) RCloudImageView *headerImageView;

@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation RCSelectConversationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor =
            [RCKitUtility generateDynamicColor:HEXCOLOR(0xffffff)
                                     darkColor:[HEXCOLOR(0x1c1c1e) colorWithAlphaComponent:0.4]];
        [self.contentView addSubview:self.selectedImageView];
        [self.contentView addSubview:self.headerImageView];
        [self.contentView addSubview:self.nameLabel];
    }
    return self;
}

- (void)setConversation:(RCConversation *)conversation ifSelected:(BOOL)ifSelected {
    if (!conversation) {
        return;
    }
    if (ifSelected) {
        [self.selectedImageView setImage:[RCKitUtility imageNamed:@"message_cell_select" ofBundle:@"RongCloud.bundle"]];
    } else {
        [self.selectedImageView
            setImage:[RCKitUtility imageNamed:@"message_cell_unselect" ofBundle:@"RongCloud.bundle"]];
    }
    if (conversation.conversationType == ConversationType_GROUP) {
        RCGroup *group = [[RCUserInfoCacheManager sharedManager] getGroupInfoFromCacheOnly:conversation.targetId];
        if (group) {
            [self.headerImageView setImageURL:[NSURL URLWithString:group.portraitUri]];
            [self.nameLabel setText:group.groupName];
        } else {
            [self.headerImageView
                setPlaceholderImage:[RCKitUtility imageNamed:@"default_group_portrait" ofBundle:@"RongCloud.bundle"]];
            [self.nameLabel setText:conversation.targetId];
        }
    } else {
        RCUserInfo *userInfo = [[RCUserInfoCacheManager sharedManager] getUserInfo:conversation.targetId];
        if (userInfo) {
            [self.headerImageView setImageURL:[NSURL URLWithString:userInfo.portraitUri]];
            [self.nameLabel setText:userInfo.name];
        } else {
            [self.headerImageView
                setPlaceholderImage:[RCKitUtility imageNamed:@"default_portrait_msg" ofBundle:@"RongCloud.bundle"]];
            [self.nameLabel setText:conversation.targetId];
        }
    }
}

- (void)resetSubviews {
    [self.selectedImageView setImage:[RCKitUtility imageNamed:@"message_cell_unselect" ofBundle:@"RongCloud.bundle"]];
    [self.headerImageView
        setPlaceholderImage:[RCKitUtility imageNamed:@"default_portrait_msg" ofBundle:@"RongCloud.bundle"]];
    self.nameLabel.text = nil;
}

- (UIImageView *)selectedImageView {
    if (!_headerImageView) {
        _selectedImageView = [[UIImageView alloc] init];
        _selectedImageView.frame = CGRectMake(10, 25, 20, 20);
        [_selectedImageView setImage:[RCKitUtility imageNamed:@"message_cell_unselect" ofBundle:@"RongCloud.bundle"]];
    }
    return _selectedImageView;
}

- (RCloudImageView *)headerImageView {
    if (!_headerImageView) {
        _headerImageView = [[RCloudImageView alloc] init];
        _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_headerImageView
            setPlaceholderImage:[RCKitUtility imageNamed:@"default_portrait_msg" ofBundle:@"RongCloud.bundle"]];
        _headerImageView.frame = CGRectMake(40, 5, 60, 60);
        _headerImageView.layer.cornerRadius = 5;
        _headerImageView.layer.masksToBounds = YES;
    }
    return _headerImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = CGRectMake(110, 5, self.bounds.size.width - 110, 60);
        _nameLabel.textColor = RCDYCOLOR(0x000000, 0x9f9f9f);
    }
    return _nameLabel;
}

@end
