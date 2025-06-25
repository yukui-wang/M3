//
//  SySearchNewsItem.h
//  M1IPhone
//
//  Created by chenquanwei on 13-7-9.
//  Copyright (c) 2013年 北京致远协创软件有限公司. All rights reserved.
//

#import <CMPLib/CMPBaseView.h>

@interface SySearchOfflineFilesItem : CMPBaseView
{
    
    UITextField *_keyTextField; //条件 －标题、发起人
    UIImageView *_keyBackground;//条件背景 －标题、发起人
    
    UILabel *_typeLabel;//搜索类型
    UIButton *_searchButton;//搜索
}

@property(nonatomic, readonly) UIButton *searchButton;
@property(nonatomic, retain)UITextField *keyTextField;

- (NSString *)keywords;//返回 选择关键字
- (void)setKeyWords:(NSString *)key;//设置 选择关键字
- (void)setType:(NSString *)aType;//设置 搜索类型
- (void)hiddenKeyBorder;
- (NSString *)titleKeyWords;
@end
