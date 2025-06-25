//
//  SySegmentedItem.m
//  M1Core
//
//  Created by guoyl on 12-11-20.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#import "SySegmentedItem.h"
#import "UIView+CMPView.h"
#import "UIImage+CMPImage.h"

@interface SySegmentedItem () {
    BOOL _hasSetRightImageEdgeInsets;
    BOOL _hasSetImageEdgeInsets;
    BOOL _hasSetTitleEdgeInsets;
    UIView *_bottomSelectedView;
    
}
- (void)updateWithSegmentedItemAttribute:(SySegmentedItemAttribute *)aSegItemAttribute;
@end

@implementation SySegmentedItem
@synthesize attribute = _attribute;
@synthesize viewType = _viewType;
@synthesize bottomImageViewHeight = _bottomImageViewHeight;
@synthesize bottomViewColor = _bottomViewColor;
@synthesize titleSeletedColor = _titleSeletedColor;
- (void)dealloc
{
    [_titleLabel release];
    _titleLabel = nil;
    
    [_imageView release];
    _imageView = nil;
    
    [_rightImageView release];
    _rightImageView = nil;
    
    [_backgroundImageView release];
    _backgroundImageView = nil;
    
    [_attribute release];
    _attribute = nil;
    
    [_bottomImageView release];
    _bottomImageView = nil;
    [_selectArrowImageView release];
    _selectArrowImageView = nil;
    
    if (_bottomSelectedView) {
        [_bottomSelectedView release];
        _bottomSelectedView = nil;
    }
    [_bottomViewColor release];
    _bottomViewColor = nil;
    [_titleSeletedColor release];
    _titleSeletedColor = nil;
    [super dealloc];
}

- (id)initWithAttribute:(SySegmentedItemAttribute *)aAttribute
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizesSubviews = NO;
        // background
        if (!_backgroundImageView) {
            _backgroundImageView = [[UIImageView alloc] init];
            _backgroundImageView.userInteractionEnabled = NO;
            [self addSubview:_backgroundImageView];
        }
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] init];
            _titleLabel.textColor = [UIColor blackColor];
            _titleLabel.backgroundColor = [UIColor clearColor];
            _titleLabel.textAlignment = NSTextAlignmentCenter;
            _titleLabel.numberOfLines = 0;
            [self addSubview:_titleLabel];
        }
        if (!_selectArrowImageView) {
            _selectArrowImageView = [[UIImageView alloc] init];
            _selectArrowImageView.userInteractionEnabled = NO;
            _selectArrowImageView.image = [UIImage imageNamed:@"SySegmentedControl.bundle/seg_arrow.png"];
            [self addSubview:_selectArrowImageView];
            _selectArrowImageView.hidden = YES;
        }
        self.attribute = aAttribute;
        self.bottomImageViewHeight = 2;
        self.tag = aAttribute.segmentedItemTag;
        self.bottomViewColor = UIColorFromRGB(0x64a6d8);
        self.titleSeletedColor = UIColorFromRGB(0x003d5f);
        _viewType =2;
    }
    return self;
}

- (void)setAttribute:(SySegmentedItemAttribute *)attribute
{
    [_attribute release];
    _attribute = [attribute retain];
    [self updateWithSegmentedItemAttribute:self.attribute];
}

- (void)updateWithSegmentedItemAttribute:(SySegmentedItemAttribute *)aSegItemAttribute
{
    [self setBackgroundImage:aSegItemAttribute.backgroundImage];
    [self setSelectedBackgroundImage:aSegItemAttribute.selectedBackgroundImage];
    [self setImage:aSegItemAttribute.image];
    // group
    [self setRightImage:aSegItemAttribute.rightImage];
    [self setTitle:aSegItemAttribute.title];
    [self setTitleFont:aSegItemAttribute.titleFont];
    // group
    [self setSelectedTitleFont:aSegItemAttribute.selectedTitleFont];
    [self setTitleColor:aSegItemAttribute.titleColor];
}

- (void)layoutSubviews
{
    CGSize aRightImageSize = _attribute.rightImage.size;
    if (_viewType == 3) {
        _bottomSelectedView.frame = CGRectMake(0, self.height-_bottomImageViewHeight, self.width, _bottomImageViewHeight);
        [self bringSubviewToFront:_bottomSelectedView];
        
    }
    _backgroundImageView.frame = CGRectMake(0, 0, self.width, self.height);
    // bottom view
    if (_bottomImageView) {
        CGSize aBottomImageSize = _attribute.bottomImage.size;
        _bottomImageView.frame = CGRectMake(self.width/2 - aBottomImageSize.width/2, self.height - aBottomImageSize.height - 7, aBottomImageSize.width, aBottomImageSize.height);
        if(_isNewCustom){
            _bottomImageView.frame = CGRectMake(30, self.height - 4, self.width - 2*30, 4);
        }
    }
    // 计算title所需要的宽度
    CGFloat titleFontHeight = _titleLabel.font.lineHeight*2;
    CGSize aSize = CGSizeZero;
    if ([_attribute.title length] > 0) {
        aSize = CGSizeMake(self.width, titleFontHeight);
        aSize = [_attribute.title sizeWithFont:_titleLabel.font constrainedToSize:aSize lineBreakMode:NSLineBreakByWordWrapping];
    }
    // 获取image的size
    CGSize aImageSize = _attribute.image.size;
    CGFloat aMargin = _attribute.marginTitleAndImage;
    if (aSize.width == 0 || aImageSize.width == 0) {
        aMargin = 0;
    }
    NSInteger x = self.width/2 - (aSize.width + aImageSize.width + aMargin)/2;
    if (x<=0) {
        x = 2;
    }
    if (!_hasSetImageEdgeInsets) {
        NSInteger y = self.height/2 - aImageSize.height/2;
        _imageView.frame = CGRectMake(x, y, _imageView.width, _imageView.height);
    }
    else {
        NSInteger left = _attribute.imageEdgeInsets.left;
        NSInteger top = self.height/2 - aImageSize.height/2;//_attribute.imageEdgeInsets.top;
        x = left;
        _imageView.frame = CGRectMake(left, top, _imageView.width, _imageView.height);
    }
    x += _imageView.width;
    x += aMargin;
    if (!_hasSetTitleEdgeInsets) {
        if (x + aSize.width + aRightImageSize.width > self.width) {
            aSize.width = self.width - aRightImageSize.width - x;
        }
        _titleLabel.frame = CGRectMake(x, self.height/2 - titleFontHeight/2, aSize.width, titleFontHeight);
    }
    else {
        _titleLabel.frame = CGRectMake(_attribute.titleEdgeInsets.left, self.height/2 - titleFontHeight/2, self.width - _attribute.titleEdgeInsets.left - _attribute.titleEdgeInsets.right, titleFontHeight);
    }
    
    if (self.selected && _attribute.rightSelectedImage) {
        aRightImageSize = _attribute.rightSelectedImage.size;
    }
    if (!_hasSetRightImageEdgeInsets) {
        x = self.width - 5.0f - aRightImageSize.width;
        _rightImageView.frame = CGRectMake(x, self.height/2 - aRightImageSize.height/2, aRightImageSize.width, aRightImageSize.height);
    }
    else {
        NSInteger left = _attribute.rightImageEdgeInsets.left;
        NSInteger top =  self.height/2 - aRightImageSize.height/2;
        if (left <= (_titleLabel.originX + _titleLabel.width)) left = self.width - aRightImageSize.width - 5;
        _rightImageView.frame = CGRectMake(left, top, aRightImageSize.width, aRightImageSize.height);
    }
    [_selectArrowImageView setFrame:CGRectMake(self.width/2-5, self.height-6, 10, 6)];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    _selectArrowImageView.hidden = !selected;
    if (_viewType == 3) {
        _bottomSelectedView.hidden = !selected;
        if (_titleLabel) {
            if (selected) {
                _titleLabel.textColor = _titleSeletedColor;
            }else{
                _titleLabel.textColor = [UIColor blackColor];
            }
        }
        
        return;
    }
    if (_viewType == 4) {
        self.backgroundColor = selected?RGBCOLOR(241,241,241): RGBCOLOR(221,221,221);
        
        return;
    }
    if (selected) {
        if (_attribute.selectedBackgroundImage) {
            _backgroundImageView.image = _attribute.selectedBackgroundImage;
        }
        if (_attribute.selectedTitleFont) {
            _titleLabel.font = _attribute.selectedTitleFont;
        }
        if (_attribute.rightSelectedImage) {
            _rightImageView.image = _attribute.rightSelectedImage;
        }
        // title color ?
    }
    else {
        _backgroundImageView.image = _attribute.backgroundImage;
        _titleLabel.font = _attribute.titleFont;
        _rightImageView.image = _attribute.rightImage;
    }
    [self setNeedsLayout];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _attribute.backgroundImage = backgroundImage;
    if (!self.selected) {
        _backgroundImageView.image = _attribute.backgroundImage;
    }
}

- (void)setSelectedBackgroundImage:(UIImage *)selectedBackgroundImage
{
    _attribute.selectedBackgroundImage = selectedBackgroundImage;
    if (self.selected) {
        _backgroundImageView.image = _attribute.selectedBackgroundImage;
    }
}

- (void)setImage:(UIImage *)image
{
    [self setImage:image size:image.size];
}

- (void)setImage:(UIImage *)image size:(CGSize)aSize
{
    _attribute.image = image;
    if (_attribute.image) {
        if (!_imageView) {
            _imageView = [[UIImageView alloc] init];
            [self addSubview:_imageView];
        }
        _imageView.frame = CGRectMake(0, 0, aSize.width, aSize.height);
        _imageView.image = _attribute.image;
    }
    else {
        _imageView.image = nil;
        [_imageView removeFromSuperview];
        [_imageView release];
        _imageView = nil;
    }
    [self setNeedsLayout];
}

- (void)setRightImage:(UIImage *)rightImage
{
    _attribute.rightImage = rightImage;
    if (_attribute.rightImage) {
        if (!_rightImageView) {
            _rightImageView = [[UIImageView alloc] init];
            [self addSubview:_rightImageView];
        }
        _rightImageView.image = rightImage;
    }
    else {
        _rightImageView.image = nil;
        [_rightImageView removeFromSuperview];
        [_rightImageView release];
        _rightImageView = nil;
    }
    [self setNeedsLayout];
}

- (void)setRightSelectedImage:(UIImage *)aImage
{
    _attribute.rightSelectedImage = aImage;
    if (self.selected) {
        _rightImageView.image = aImage;
    }
}

- (void)setTitle:(NSString *)aTitle
{
    _attribute.title = aTitle;
    _titleLabel.text = aTitle;
    [self setNeedsLayout];
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _attribute.titleFont = titleFont;
    if (!self.selected) {
        _titleLabel.font = _attribute.titleFont;
    }
    [self setNeedsLayout];
}

- (void)setSelectedTitleFont:(UIFont *)selectedTitleFont
{
    _attribute.selectedTitleFont = selectedTitleFont;
    if (self.selected) {
        _titleLabel.font = _attribute.selectedTitleFont;
    }
    [self setNeedsLayout];
}

- (void)setTitleColor:(UIColor *)aColor
{
    _attribute.titleColor = aColor;
    _titleLabel.textColor = aColor;
}

- (void)setRightImageEdgeInsets:(UIEdgeInsets)rightImageEdgeInsets
{
    _hasSetRightImageEdgeInsets = YES;
    _attribute.rightImageEdgeInsets = rightImageEdgeInsets;
    [self setNeedsLayout];
}

- (void)setImageEdgeInsets:(UIEdgeInsets)imageEdgeInsets
{
    _hasSetImageEdgeInsets = YES;
    _attribute.imageEdgeInsets = imageEdgeInsets;
    [self setNeedsLayout];
}

- (void)setBottomImage:(UIImage *)bottomImage
{
    _attribute.bottomImage = bottomImage;
    if (_attribute.bottomImage) {
        if (!_bottomImageView) {
            _bottomImageView = [[UIImageView alloc] init];
            [self addSubview:_bottomImageView];
        }
        _bottomImageView.image = bottomImage;
    }
    else {
        [_bottomImageView removeFromSuperview];
        [_bottomImageView release];
        _bottomImageView = nil;
    }
}

- (void)setSelectedBottomImage:(UIImage *)selectedBottomImage
{
    _attribute.selectedBottomImage = selectedBottomImage;
    if (self.selected) {
        _bottomImageView.image = selectedBottomImage;
    }
}
- (void)setPosition:(SySegmentedItemAttribute_Position)position
{
    
        NSString *pngName = nil;
        if(position == SySegmentedItemAttribute_Position_First){
            pngName = @"SySegmentedControl.bundle/seg_left_selected.png";
        }else if(position == SySegmentedItemAttribute_Position_Middle){
            pngName = @"SySegmentedControl.bundle/seg_mid_selected.png";
        }else if(position == SySegmentedItemAttribute_Position_Last){
            pngName = @"SySegmentedControl.bundle/seg_right_selected.png";
        }
        if(pngName){
            self.selectedBackgroundImage = [UIImage imageNamed:pngName] ;
        }
    
}
- (void)setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets
{
    _hasSetTitleEdgeInsets = YES;
    _attribute.titleEdgeInsets = titleEdgeInsets;
    [self setNeedsLayout];
}
- (void)setViewType:(NSInteger)viewType
{
    _viewType = viewType;
    [_selectArrowImageView removeFromSuperview];
    
    if (_viewType != 1) {
        if (_viewType == 3)
        {
            _backgroundImageView.hidden = YES;
            self.backgroundImage  = nil;
            self.selectedBackgroundImage = nil;
            if (!_bottomSelectedView) {
                _bottomSelectedView = [[UIView alloc] init];
                _bottomSelectedView.frame = CGRectMake(0, self.height-2, self.width, 2);
                _bottomSelectedView.backgroundColor = self.bottomViewColor;
                _bottomSelectedView.hidden = YES;
                [self addSubview:_bottomSelectedView];
            }
        }
        else if (_viewType ==4)
        {
            _backgroundImageView.hidden = YES;
            self.backgroundImage  = nil;
            self.selectedBackgroundImage = nil;
            self.backgroundColor = self.selected?RGBCOLOR(241,241,241): RGBCOLOR(221,221,221);
            
        }
    }
    else{
        [self addSubview:_selectArrowImageView];
        self.backgroundImage = [[UIImage imageNamed:@"SySegmentedControl.bundle/tab_normal.png"] stretchableImageWithLeftCapWidth:2
                                                                                           topCapHeight:0.0];
        self.selectedBackgroundImage = [[UIImage imageNamed:@"SySegmentedControl.bundle/tab_normal_pressdown.png"] stretchableImageWithLeftCapWidth:10
                                                                                                             topCapHeight:0];
    }
    [self setNeedsLayout];
}
- (void)setBottomViewColor:(UIColor *)bottomViewColor
{
    [_bottomViewColor release];
    _bottomViewColor = [bottomViewColor retain];
    if (_bottomSelectedView) {
        _bottomSelectedView.backgroundColor = _bottomViewColor;
    }
}
@end
