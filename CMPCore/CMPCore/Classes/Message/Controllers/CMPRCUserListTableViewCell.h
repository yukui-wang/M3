//
//  RCUserListTableViewCell.h
//  RongExtensionKit
//
//  Created by 杜立召 on 16/7/14.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CMPLib/KSCheckBox.h>
#import <RongIMKit/RongIMKit.h>

@interface CMPRCUserListTableViewCell : UITableViewCell
@property (nonatomic,strong) UIImageView* headImageView;//头像
@property (nonatomic,strong) UILabel *nameLabel;//姓名
@property (nonatomic,strong) KSCheckBox *checkBox;
@property (nonatomic,assign) NSInteger state;

-(void)setUser:(RCUserInfo *)user;

@end
