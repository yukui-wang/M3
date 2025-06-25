//
//  SySearchNewsItem.m
//  M1IPhone
//
//  Created by chenquanwei on 13-7-9.
//  Copyright (c) 2013年 北京致远协创软件有限公司. All rights reserved.
//

#import "SySearchOfflineFilesItem.h"
#import <CMPLib/UIImage+CMPImage.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPGlobleManager.h>
#import <CMPLib/RTL.h>

@implementation SySearchOfflineFilesItem
@synthesize searchButton = _searchButton;
@synthesize keyTextField = _keyTextField;
- (void)setup
{
    //搜索方式显示
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, 44, 40)];
        _typeLabel.text = SY_STRING(@"common_search_subject");
        _typeLabel.textAlignment = NSTextAlignmentLeft;
        _typeLabel.textColor = [UIColor blackColor];
        _typeLabel.font = [UIFont systemFontOfSize:16];
        _typeLabel.backgroundColor = [UIColor clearColor];
        _typeLabel.adjustsFontSizeToFitWidth = YES;
        _typeLabel.textAlignment = NSTextAlignmentCenter;
    }
    //条件背景（时间除外）
    if (!_keyBackground) {
        _keyBackground = [[UIImageView alloc] initWithFrame:CGRectMake(103, 2.5, 167, 35)];
        _keyBackground.image = [UIImage textFieldBackgorundWithSize:_keyBackground.frame.size];
    }
    //条件（时间除外）
    if (!_keyTextField) {
        _keyTextField = [[UITextField alloc] initWithFrame:CGRectMake(108, 8, 160, 24)];
        _keyTextField.textAlignment = NSTextAlignmentLeft;
        _keyTextField.textColor = [UIColor blackColor];
        _keyTextField.font = [UIFont systemFontOfSize:16];
        _keyTextField.placeholder = SY_STRING(@"common_search_pleaseEnterKeywords");
        _keyTextField.borderStyle = UITextBorderStyleNone;
        _keyTextField.keyboardType = UIKeyboardTypeDefault;
        _keyTextField.hidden = NO;
        _keyTextField.userInteractionEnabled = YES;
        _keyTextField.enablesReturnKeyAutomatically = YES;
        _keyTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    
    //搜索按钮
    if (!_searchButton) {
        _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_searchButton setFrame:CGRectMake(275, 2.5, 35, 35)];
        [_searchButton setImage:[UIImage imageNamed:@"offlineFilesImage.bundle/ic_search.png"] forState:UIControlStateNormal];
        [_searchButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    [self addSubview:_typeLabel];
    [self addSubview:_keyBackground];
    [self addSubview:_keyTextField];
    
    
    [self addSubview:_searchButton];
    self.backgroundColor = UIColorFromRGB(0xD6D6D6);
    _typeLabel.font = FONTSYS(16);
    _keyTextField.font = FONTSYS(16);
    
}

- (void)layoutSubviews
{
    [_typeLabel setFrame:CGRectMake(15, 0, 52, 44)];
    CGFloat x = 80+5;
    CGFloat fieldw =  (self.width-154)/2;
    CGFloat keyW = fieldw+15+8+8+fieldw;
    [_keyBackground setFrame:CGRectMake(x, 6, keyW, 31)];
    [_keyTextField setFrame:CGRectMake(x+5, 9, keyW-10, 24)];
    
    [_searchButton setFrame:CGRectMake(self.width- 36, 4, 36, 36)];
    
    [_typeLabel resetFrameToFitRTL];
    [_keyBackground resetFrameToFitRTL];
    [_keyTextField resetFrameToFitRTL];
    [_searchButton resetFrameToFitRTL];
    
}
- (void)hiddenKeyBorder
{
    [_keyTextField resignFirstResponder];
}
- (NSString *)keywords
{
    [self hiddenKeyBorder];
    return _keyTextField.text;
    
}


- (NSString *)titleKeyWords{
    return _keyTextField.text;
}

- (void)setKeyWords:(NSString *)key
{
    [_keyTextField setText:key];
}

- (void)setType:(NSString *)aType
{
    _typeLabel.text = aType;
}

- (void)dealloc
{
    SY_RELEASE_SAFELY(_keyTextField);
    SY_RELEASE_SAFELY(_keyBackground);
    SY_RELEASE_SAFELY(_typeLabel);
    
    _searchButton = nil;
    [super dealloc];
}
@end
