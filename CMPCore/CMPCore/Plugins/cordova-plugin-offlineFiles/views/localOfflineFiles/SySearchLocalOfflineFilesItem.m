//
//  SySearchLocalOfflineFilesItem.m
//  M1Core
//
//  Created by chenquanwei on 14-3-16.
//
//

#import "SySearchLocalOfflineFilesItem.h"
#import <CMPLib/UIImage+CMPImage.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPGlobleManager.h>
#import <CMPLib/RTL.h>

@implementation SySearchLocalOfflineFilesItem

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
        [_searchButton setFrame:CGRectMake(275, 2, 35, 35)];
        [_searchButton setImage:[UIImage imageNamed:@"offlineFilesImage.bundle/ic_search.png"] forState:UIControlStateNormal];
        [_searchButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    [self addSubview:_typeLabel];
    [self addSubview:_keyBackground];
    [self addSubview:_keyTextField];
    [self addSubview:_searchButton];
    self.backgroundColor = UIColorFromRGB(0xD6D6D6);
}

- (void)layoutSubviews
{
    [_typeLabel setFrame:CGRectMake(35, 0, 44, 40)];
    [_keyBackground setFrame:CGRectMake(103, 2, self.width-153, 35)];
    [_keyTextField setFrame:CGRectMake(108, 9, self.width-160, 24)];
    [_searchButton setFrame:CGRectMake(self.width-45, 2, 35, 35)];
    
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
