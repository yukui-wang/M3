//
//  RCUserListTableViewCell.m
//  RongExtensionKit
//
//  Created by 杜立召 on 16/7/14.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "CMPRCUserListTableViewCell.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/SyFaceDownloadRecordObj.h>
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPFaceView.h>

@interface CMPRCUserListTableViewCell()
{
    CMPFaceView *_faceView;
}
@end

@implementation CMPRCUserListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //布局View
        [self setUpView];
    }
    return self;
}

#pragma mark - setUpView
- (void)setUpView{
    
    [self.contentView addSubview:self.checkBox];
    [_checkBox mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.left.offset(10);
    }];
    
    _faceView = [[CMPFaceView alloc] init];
    _faceView.frame = CGRectMake(0, 0, 26, 26);
    _faceView.layer.cornerRadius = 13;
    _faceView.layer.masksToBounds = YES;
    [self.contentView addSubview:_faceView];
    [_faceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.size.mas_equalTo(CGSizeMake(26, 26));
        make.left.offset(10);
    }];
    
    //头像
//    [self.contentView addSubview:self.headImageView];
    //姓名
    [self.contentView addSubview:self.nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.equalTo(_faceView.mas_right).offset(10);
    }];
    
    _checkBox.hidden = YES;
}

- (void)setHeadImageView:(UIImageView *)headImageView {
//  [_headImageView removeFromSuperview];
//  _headImageView = headImageView;
//   [self.contentView addSubview:_headImageView];
    
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(60.0, 5.0, self.bounds.size.width-60.0, 40.0)];
        [_nameLabel setFont:[UIFont systemFontOfSize:16.0]];
        [_nameLabel sizeToFit];
    }
    return _nameLabel;
}

-(KSCheckBox *)checkBox
{
    if (!_checkBox) {
        _checkBox = [[KSCheckBox alloc] init];
        _checkBox.userInteractionEnabled = NO;
    }
    return _checkBox;
}

- (void)awakeFromNib {
  [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


-(void)setState:(NSInteger)state
{
    _state = state;
    switch (state) {
        case 1://dan xuan
        {
            _checkBox.hidden = YES;
            [_faceView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.offset(10);
            }];
        }
            break;
            
        case 2://duo xuan
        {
            _checkBox.hidden = NO;
            [_faceView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.offset(10+20+10);
            }];
        }
            break;
            
        default:
            break;
    }
}

-(void)setUser:(RCUserInfo *)user
{
    if (user) {
        
        if ([user.userId isEqualToString:kRCUserId_AtAll]) {
            _faceView.imageView.image = [[CMPThemeManager sharedManager] skinColorImageWithName:@"membericon_all"];
        }else{
            SyFaceDownloadObj *obj = [[SyFaceDownloadObj alloc] init];
            obj.serverId = [CMPCore sharedInstance].serverID;
            obj.memberId = user.userId;
            obj.downloadUrl = [CMPCore memberIconUrlWithId:user.userId];
            _faceView.memberIcon = obj;
        }
        
        _nameLabel.text = user.name;
    }
}

@end

