//
//  CMPMessageForwardView.m
//  M3
//
//  Created by youlin guo on 2018/2/7.
//

#import "CMPMessageForwardView.h"
#import "CMPShareImageView.h"
#import "CMPCheckBoxView.h"

#import <CMPLib/CMPGlobleManager.h>
#import <CMPLib/CMPFileTypeHandler.h>
#import <CMPLib/CMPThemeManager.h>
#import "CMPMessageFilterManager.h"
#import <CMPLib/NSObject+CMPHUDView.h>

static CGFloat const kViewW = 315.f;
static CGFloat const kViewSmallH = 250.f;
static CGFloat const kViewBigH = 400.f;
static CGFloat const kImageViewH = 157.f;

@implementation CMPMessageForwardView {
	
	UIView *_bgView;
	CMPFaceView *_faceView;
	UIView *_lineView;
	UILabel *_titleLab;
	UILabel *_nameLab;
    UILabel *_contentLab;
	UITextField *_contentField;
    UIView *_lineView1;
    UIView *_lineView2;
	UIButton *_cancelBtn;
	UIButton *_okBtn;
    UILabel *_fileNameLab;
    UILabel *_fileSizeLab;
    
    UIImageView *_showingImgView;
    CMPCheckBoxView *_checkBtn;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	self.cancelBlock = nil;
	self.selectedBlock = nil;
}

- (id)initWithFrame:(CGRect)frame {
	
	self = [super initWithFrame:frame];
	if (self) {
        self.backgroundColor = [[UIColor cmp_colorWithName:@"mask-bgc"] colorWithAlphaComponent:0.5f];
	}
	return self;
}

- (void)createSubViewIsShowImgView:(BOOL)isShowImgView {
	
	if (!_bgView) {
		_bgView = [[UIView alloc] initWithFrame:CGRectMake((self.width - 310)/2, self.height/2-140, kViewW, kViewSmallH)];
        if (isShowImgView) {
            _bgView.cmp_height = kViewBigH;
            _bgView.cmp_centerY = self.height/2.f;
        }
		_bgView.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
        _bgView.layer.cornerRadius = 10;
        _bgView.clipsToBounds = YES;
		[self addSubview:_bgView];
	}
    
    if (isShowImgView) {
        _bgView.cmp_height = kViewBigH;
        _bgView.cmp_centerY = self.height/2.f;
    }
    CGFloat x = 17;
    CGFloat y = 12;
    UIFont *font = [UIFont systemFontOfSize:16.0f];
    NSInteger height = font.lineHeight+1;
	if (!_titleLab) {
		_titleLab = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 100, height)];
		_titleLab.text = SY_STRING(@"forward_send_to");
		_titleLab.textColor = [UIColor cmp_colorWithName:@"main-fc"];
		_titleLab.font = font;
        _titleLab.backgroundColor = [UIColor clearColor];
        _titleLab.numberOfLines = 1;
        _titleLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
		[_bgView addSubview:_titleLab];
	}
	
	y = 44;
    x =  20;
	if (!_faceView) {
		_faceView = [[CMPFaceView alloc] init];
		_faceView.frame = CGRectMake(x, y, 35, 35);
		_faceView.layer.cornerRadius = 17.5;
		_faceView.layer.masksToBounds = YES;
		[_bgView addSubview:_faceView];
	}
    x += _faceView.width +12;
	if (!_nameLab) {
		_nameLab = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 290-x, 35)];
		_nameLab.textColor = [UIColor cmp_colorWithName:@"main-fc"];
		_nameLab.font = font;
        _nameLab.backgroundColor = [UIColor clearColor];
		[_bgView addSubview:_nameLab];
	}
	
	y = 90;
    x = 20;
	if (!_lineView) {
		_lineView = [[UIView alloc] initWithFrame:CGRectMake(x, y, _bgView.width - 2*x, 0.5)];
		_lineView.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
		[_bgView addSubview:_lineView];
	}
	
    if (isShowImgView) {
        if (!_showingImgView) {
            _showingImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, CGRectGetMaxY(_lineView.frame) + 14.f, _bgView.width - 2*x, kImageViewH)];
            _showingImgView.contentMode = UIViewContentModeScaleAspectFit;
            _showingImgView.layer.masksToBounds = YES;
        }
        [_bgView addSubview:_showingImgView];
    }
    else {
        y = 98;
        if (!_contentLab) {
            _contentLab = [[UILabel alloc] initWithFrame:CGRectMake(x, y, _bgView.width - 2*x, 20)];
            _contentLab.font = font;
            _contentLab.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
            _contentLab.backgroundColor = [UIColor clearColor];
            _contentLab.numberOfLines = 1;
            _contentLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
            [_bgView addSubview:_contentLab];
        }
    }
	
	
    x = 22;
    y = _bgView.height - 100;
	if (!_contentField) {
		_contentField = [[UITextField alloc] initWithFrame:CGRectMake(x, y, _bgView.width - x-17, 36)];
		_contentField.textAlignment = NSTextAlignmentLeft;
		_contentField.textColor = [UIColor cmp_colorWithName:@"main-fc"];
		_contentField.font = font;
		_contentField.placeholder = SY_STRING(@"forward_leave_message");
		_contentField.borderStyle = UITextBorderStyleNone;
        _contentField.returnKeyType = UIReturnKeyDone;
        _contentField.delegate = self;
        _contentField.leftViewMode = UITextFieldViewModeAlways;
        _contentField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, 20)];
        [_contentField cmp_setCornerRadius:4.f];
        [_contentField cmp_setBorderWithColor: [UIColor cmp_colorWithName:@"cmp-bdc"]];
        _contentField.backgroundColor = [UIColor cmp_colorWithName:@"input-bg"];
        
		[_bgView addSubview:_contentField];
        //设置placeholder颜色，最新的通过kvc没法设置了
        NSMutableAttributedString *arrStr = [[NSMutableAttributedString alloc] initWithString:_contentField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor cmp_colorWithName:@"sup-fc1"],NSFontAttributeName:font}];
        _contentField.attributedPlaceholder = arrStr;
	}
    y = _bgView.height - 54;
	
    _lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, y, _bgView.width, 0.5)];
    _lineView1.backgroundColor = [UIColor cmp_colorWithName:@"sup-fc1"];
    [_bgView addSubview:_lineView1];

    CGFloat lineView2H = 16.f;
    _lineView2 = [[UIView alloc] initWithFrame:CGRectMake(_bgView.width/2.f - 0.2f, y, 0.5, lineView2H)];
    _lineView2.cmp_centerY = self.height - lineView2H/2.f;
    _lineView2.cmp_centerX = _bgView.width/2.f;
    _lineView2.backgroundColor = [UIColor cmp_colorWithName:@"sup-fc1"];
    [_bgView addSubview:_lineView2];

    y += 1;
    
    CGFloat marg = 3;
    CGFloat width = (_bgView.width- marg *3)/2;
    
    UIColor *themeColor = [CMPThemeManager sharedManager].themeColor;
    
	if (!_cancelBtn) {
		_cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelBtn.frame = CGRectMake(marg, y, width, _bgView.height-y);
		[_cancelBtn setTitle:SY_STRING(@"common_cancel") forState:UIControlStateNormal];
		[_cancelBtn setTitleColor:[UIColor cmp_colorWithName:@"desc-fc"] forState:UIControlStateNormal];
		[_cancelBtn addTarget:self action:@selector(clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
        [_bgView addSubview:_cancelBtn];
	}
	
	if (!_okBtn) {
		_okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		_okBtn.frame = CGRectMake(_bgView.width-marg-width, y, width, _bgView.height-y);
		[_okBtn setTitle:SY_STRING(@"common_ok") forState:UIControlStateNormal];
		[_okBtn setTitleColor:themeColor forState:UIControlStateNormal];
		[_okBtn addTarget:self action:@selector(clickOkBtn) forControlEvents:UIControlEventTouchUpInside];
        [_bgView addSubview:_okBtn];
	}
    _okBtn.userInteractionEnabled = YES;
    
    _lineView2.cmp_centerY = _okBtn.cmp_centerY;

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)customLayoutSubviews {
    _bgView.cmp_width = kViewW;
    _bgView.cmp_height = kViewSmallH;
    if (self.allowCheckedOutside) {
        _bgView.cmp_height = _okBtn.cmp_bottom;
    }
    _bgView.cmp_centerX = self.cmp_centerX;
    _bgView.cmp_centerY = self.cmp_centerY;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_contentField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSInteger max = 100;
    if (textField.text.length + string.length -range.length >max && string.length >0) {
        NSInteger h = max - (textField.text.length - range.length);
        _contentField.text = [textField.text stringByReplacingCharactersInRange:range withString:[string substringToIndex:h]];
        [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:SY_STRING(@"forward_leaveMsgLimit")];
        return NO;
    }
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notif {
    CGRect keyboardRect = [[[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    CGRect bgRect = _bgView.frame;
    bgRect.origin.y = self.height-_bgView.height-keyboardHeight-5;
    CGFloat aCurve = [[[notif userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGFloat aDuration = [[[notif userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:aCurve];
    [UIView setAnimationDuration:aDuration];
    [UIView setAnimationDelegate:self];
    _bgView.frame = bgRect;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notif {
    CGFloat aCurve = [[[notif userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGFloat aDuration = [[[notif userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:aCurve];
    [UIView setAnimationDuration:aDuration];
    [UIView setAnimationDelegate:self];
    _bgView.cmp_centerX = self.cmp_centerX;
    _bgView.cmp_centerY = self.cmp_centerY;
    [UIView commitAnimations];
}



- (void)clickCancelBtn {
	[self endEditing:YES];
    [self removeFromSuperview];
	if (self.cancelBlock) {
		self.cancelBlock();
	}
    _checkBtn.selected = NO;
}

- (void)clickOkBtn {
    CMPMsgFilterResult *filterRslt = [CMPMessageFilterManager filterStr:_contentField.text];
    if (filterRslt.filter.level == CMPMsgFilterLevelIntercept) {
        [self cmp_showHUDWithText:SY_STRING(@"msg_content_sensitive_notsend")];
        return;
    }
    _contentField.text = filterRslt.rslt;
    [self endEditing:YES];
    [self removeFromSuperview];
	if (self.selectedBlock) {
        _okBtn.userInteractionEnabled = NO;
		self.selectedBlock(_contentField.text,_checkBtn.selected);
	}
    _checkBtn.selected = NO;
}

- (void)setContent:(NSString*)str {
    if ([str isKindOfClass:NSNull.class] || !str.length ) {
        NSLog(@"content不能为空");
        return;
    }
    CMPMsgFilterResult *filterRslt = [CMPMessageFilterManager filterStr:str];
    if (filterRslt.filter.level == CMPMsgFilterLevelIntercept) {
        [self cmp_showHUDWithText:SY_STRING(@"msg_content_sensitive_hascleared")];
        return;
    }
    _contentLab.text = filterRslt.rslt;
    if ([filterRslt.rslt length] == 0) {
        _contentLab.hidden = YES;
    }
    else {
        _contentLab.hidden = NO;
    }
}

- (void)setThumbnailImage:(UIImage*)thumbnailImage fileSize:(NSString *)size {
    if (thumbnailImage && [NSString isNull:size]) {
        [self createSubViewIsShowImgView:YES];
        [self setupFile];
        _fileSizeLab.frame = CGRectMake(_showingImgView.cmp_x, CGRectGetMaxY(_showingImgView.frame) + 10.f, _showingImgView.width, 18.f);
        _fileSizeLab.textAlignment = NSTextAlignmentCenter;
        _showingImgView.image = thumbnailImage;
    } else {
        [self createSubViewIsShowImgView:NO];
        [self setupFile];
    }
}

- (void)setFileCount:(NSInteger)fileCount {
    _fileCount = fileCount;
//    if (fileCount > 1) {
    _fileSizeLab.text = [NSString stringWithFormat:SY_STRING(@"share_component_file_share_count_tips"),(long)fileCount];
//    }
}

- (void)setupFile{
    _contentLab.hidden = YES;
    UIFont *font = [UIFont systemFontOfSize:16.f];
    if (!_fileNameLab) {
        _fileNameLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 115, _bgView.width-20-17, font.lineHeight)];
        _fileNameLab.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
        _fileNameLab.font = font;
        _fileNameLab.backgroundColor = [UIColor clearColor];
        _fileNameLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _fileNameLab.numberOfLines = 1;
        [_bgView addSubview:_fileNameLab];
    }
    font = [UIFont systemFontOfSize:14.f];
    if (!_fileSizeLab) {
        _fileSizeLab = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_contentLab.frame) + 3,  _bgView.width-20-22, font.lineHeight)];
        _fileSizeLab.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
        _fileSizeLab.font = font;
        _fileSizeLab.backgroundColor = [UIColor clearColor];
        [_bgView addSubview:_fileSizeLab];
    }
    
    _fileSizeLab.hidden = NO;
    
    if (!self.allowCheckedOutside) return;
    
    _fileSizeLab.hidden = YES;
    if (!_checkBtn) {
        _checkBtn = [[CMPCheckBoxView alloc] initWithFrame:CGRectMake(20, _contentLab.cmp_bottom + 20,  _bgView.width-20-22, 18)];
        _checkBtn.titleLabel.font = font;
        [_checkBtn setTitle:SY_STRING(@"share_auth_tips_string") forState:UIControlStateNormal];
        [_checkBtn setTitleColor:[UIColor cmp_colorWithName:@"main-fc"] forState:UIControlStateNormal];
        [_checkBtn addTarget:self action:@selector(checkBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_bgView addSubview:_checkBtn];
    }
    
    _contentField.cmp_y = _checkBtn.cmp_bottom + 20;
    _lineView1.cmp_y = _contentField.cmp_bottom + 14;
    _lineView2.cmp_y =  _lineView1.cmp_bottom + 18;
    _cancelBtn.cmp_y = _lineView1.cmp_bottom;
    _okBtn.cmp_y = _cancelBtn.cmp_y;
    _bgView.cmp_height = _okBtn.cmp_bottom;
    
}


- (void)setName:(NSString*)name{
	_nameLab.text = name;
}

- (void)setHeadIcon:(SyFaceDownloadObj*)loadObj {
	
	_faceView.memberIcon = loadObj;
}

- (void)setLocalIcon:(UIImage *)localIcon {
    _faceView.placeholdImage = localIcon;
    _faceView.memberIcon = nil;
}

- (NSString*)getContentFieldText {
	return _contentField.text;
}

#pragma mark - 按钮点击

- (void)checkBtnTapped:(CMPCheckBoxView *)btn {
    btn.selected = !btn.selected;
}

@end
