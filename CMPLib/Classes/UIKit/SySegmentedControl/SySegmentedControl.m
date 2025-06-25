//
//  SySegmentedControl.m
//  M1Core
//
//  Created by guoyl on 12-11-20.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#import "SySegmentedControl.h"
@interface SySegmentedControl () {
    BOOL _isNewCustom;
    UIView *_bottomView;
    UIView *_topLineView;
}
- (void)addItems:(NSArray *)array;
- (void)layoutItems;
- (void)layoutItemsWithIndex:(NSInteger)index;
- (SySegmentedItem *)segmentedItemWithAttribute:(SySegmentedItemAttribute *)aAttribute;
- (void)setActionForSegment:(SySegmentedItem *)aItem; 
@end

@implementation SySegmentedControl
@synthesize selectedSegmentIndex = _selectedSegmentIndex;
@synthesize disableSelectedSate = _disableSelectedSate;
@synthesize disableTouchState = _disableTouchState;
@synthesize backgroundImage = _backgroundImage;
@synthesize backgroundImageEdgeInsets = _backgroundImageEdgeInsets;
@synthesize segmentedItemHeight = _segmentedItemHeight;
@synthesize dividerImage = _dividerImage;
@synthesize dividerSize = _dividerSize;
@synthesize viewType = _viewType;
- (void)dealloc
{
    [_segments release];
    _segments = nil;
    
    _selectedSegmentItem = nil;
    
    [_dividers removeAllObjects];
    [_dividers release];
    _dividers = nil;
    
    [_backgroundImage release];
    _backgroundImage = nil;
    
    [_backgroundImageView release];
    _backgroundImageView = nil;
    
    [_dividerImage release];
    _dividerImage = nil;
    if (_bottomView) {
        [_bottomView release];
        _bottomView = nil;
    }
    SY_RELEASE_SAFELY(_topLineView);
       [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        _selectedSegmentIndex = -1;
        _selectedSegmentItem = nil;
        self.autoresizesSubviews = NO;
        self.backgroundColor =UIColorFromRGB(0xe7ecf2);
        self.segmentedItemHeight = 0;//40;
        self.dividerImage = [UIImage imageWithColor:UIColorFromRGB(0xbcbcbc)];
        self.dividerSize = CGSizeMake(1, 29);
         _viewType =2;
        
        _topLineView = [[UIView alloc] init];
        _topLineView.backgroundColor = UIColorFromRGB(0xbec8cf);
        
        [self addSubview:_topLineView];
        
    }
    return self;
}

- (id)initWithItems:(NSArray *)array
{
    self = [self init];
    if (self) {
        _selectedSegmentItem = nil;
        NSMutableArray *segArray = [[NSMutableArray alloc] init];
        NSInteger vTag = 0;
        for (NSString *aTitle in array) {
            
            SySegmentedItemAttribute *aAttribute = [[SySegmentedItemAttribute alloc] init];
            aAttribute.viewType = _viewType;
            aAttribute.title = aTitle;
            if(_isNewCustom){
                aAttribute.selectedBackgroundImage = nil;
                self.dividerImage = nil;
                self.dividerSize = CGSizeZero;
            }
            aAttribute.segmentedItemTag = vTag;
            SySegmentedItem *aItem = [self segmentedItemWithAttribute:aAttribute];
            aItem.viewType = _viewType;
            aItem.isNewCustom = _isNewCustom;
            
            
            [aAttribute release];
            [segArray addObject:aItem];
            vTag++;
        }
        
        [self addItems:segArray];
        [segArray release];
    }
    return self;
}
- (id)initForNewCustomWithItems:(NSArray *)array;
{
    if (_viewType == 1 ||_viewType == 2) {
    }
    else {
        _isNewCustom = YES;
 
    }
    return [self initWithItems:array];
}
- (id)initWithItemAttributes:(NSArray *)aItemAttributes 
{
    self = [self init];
    if (self) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (SySegmentedItemAttribute *aAttribute in aItemAttributes) {
            aAttribute.viewType = _viewType;
            SySegmentedItem *aItem = [self segmentedItemWithAttribute:aAttribute];
            aItem.viewType = _viewType;

            [array addObject:aItem];
        }
        [self addItems:array];
        [array release];
    }
    return self;
}

- (CGSize)dividerSize
{
    if (_viewType != 1 && _viewType != 2) {
        return CGSizeZero;
    }
    if (_dividerSize.width == 0 || _dividerSize.height == 0) {
        return self.dividerImage.size;
    }
    return _dividerSize;
}

- (void)setDividerImage:(UIImage *)dividerImage
{
    [_dividerImage release];
    _dividerImage = [dividerImage retain];
    [self layoutItems];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    [_backgroundImage release];
    _backgroundImage = [backgroundImage retain];
    if (_backgroundImage) {
        if (!_backgroundImageView) {
            _backgroundImageView = [[UIImageView alloc] init];
            CGFloat l = _backgroundImageEdgeInsets.left;
            CGFloat t = _backgroundImageEdgeInsets.top;
            _backgroundImageView.frame = CGRectMake(l, t, self.contentSize.width, self.contentSize.height);
            [self insertSubview:_backgroundImageView atIndex:0];
        }
        _backgroundImageView.image = backgroundImage;
        for (SySegmentedItem *aItem in _segments) {
            [aItem setBackgroundImage:nil];
        }
    }
    else {
        _backgroundImageView.image = nil;
        [_backgroundImageView removeFromSuperview];
        [_backgroundImageView release];
        _backgroundImageView = nil;
    }
}

- (void)setBackgroundImageEdgeInsets:(UIEdgeInsets)backgroundImageEdgeInsets
{
    _backgroundImageEdgeInsets = backgroundImageEdgeInsets;
    CGFloat l = _backgroundImageEdgeInsets.left;
    CGFloat t = _backgroundImageEdgeInsets.top;
    _backgroundImageView.frame = CGRectMake(l, t, self.contentSize.width, self.contentSize.height);
}

- (void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    CGFloat l = _backgroundImageEdgeInsets.left;
    CGFloat t = _backgroundImageEdgeInsets.top;
    _backgroundImageView.frame = CGRectMake(l, t, self.contentSize.width, self.contentSize.height);
//    _segmentedItemHeight = contentSize.height;
}

- (SySegmentedItem *)segmentedItemAtIndex:(NSUInteger)segment
{
    SySegmentedItem *item = [_segments objectAtIndex:segment];
    return item;
}

- (SySegmentedItem *)segmentedItemWithTag:(NSInteger)aTag
{
    SySegmentedItem *result = nil;
    for (SySegmentedItem *aSegmentedItem in _segments) {
        if (aSegmentedItem.tag == aTag) {
            result = aSegmentedItem;
            break;
        }
    }
    return result;
}

- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated {
    
}

- (void)insertSegmentWithImage:(UIImage *)image  atIndex:(NSUInteger)segment animated:(BOOL)animated
{
    
}

- (void)insertSegmentWithAttribute:(SySegmentedItemAttribute  *)aAttribute atIndex:(NSUInteger)segment animated:(BOOL)animated
{
    SySegmentedItem *aItem = [self segmentedItemWithAttribute:aAttribute];
    aItem.viewType  = _viewType;
    [_segments insertObject:aItem atIndex:segment];
    [self addSubview:aItem];
    UIView *divider = [self dividerView];
    if (divider && divider.width > 0 && divider.height > 0) {
        [self addSubview:divider];
        [_dividers addObject:divider];
    }
    [self layoutItems];
}

- (void)addSegmentWithAttribute:(SySegmentedItemAttribute  *)aAttribute animated:(BOOL)animated
{
    SySegmentedItem *aItem = [self segmentedItemWithAttribute:aAttribute];
    aItem.viewType = _viewType;
    [_segments addObject:aItem];
    [self addSubview:aItem];
    UIView *divider = [self dividerView];
    if (divider && divider.width > 0 && divider.height > 0) {
        [self addSubview:divider];
        [_dividers addObject:divider];
    }
    [self layoutItems];
}

- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated
{
    SySegmentedItem *aItem = [_segments objectAtIndex:segment];
    if (segment != 0 && segment - 1 < _dividers.count) {
        UIView *v = [_dividers objectAtIndex:segment-1];
        [v removeFromSuperview];
        [_dividers removeObject:v];
    }
    [aItem removeFromSuperview];
    [_segments removeObjectAtIndex:segment];
    [self layoutItems];
}

- (void)removeSegmentedItem:(SySegmentedItem *)aSegmentItem animated:(BOOL)animated
{
    NSInteger aIndex = [_segments indexOfObject:aSegmentItem];
    [self removeSegmentAtIndex:aIndex animated:animated];
}

- (void)removeAllSegments
{
    
}

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment {
    if (segment > _segments.count) {
        return;
    }
    SySegmentedItem *item = [_segments objectAtIndex:segment];
    item.title = title;
}

- (void)setTitleColor:(UIColor *)aColor forSegmentAtIndex:(NSUInteger)segment
{
    SySegmentedItem *item = [_segments objectAtIndex:segment];
    [item setTitleColor:aColor];
}

- (void)setTitleFont:(UIFont *)font selectedFont:(UIFont *)selectedFont {
    for (SySegmentedItem *aItem in _segments) {
        aItem.titleFont = font;
        aItem.selectedTitleFont = selectedFont;
    }
}

- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment {
    SySegmentedItem *item = [_segments objectAtIndex:segment];
    return item.attribute.title;
}

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment 
{
    SySegmentedItem *item = [_segments objectAtIndex:segment];
    [item setImage:image];
}



- (void)setRightImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment 
{
    SySegmentedItem *item = [_segments objectAtIndex:segment];
    [item setRightImage:image];
    
}

- (void)setSelectedRightImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment 
{
    SySegmentedItem *item = [_segments objectAtIndex:segment];
    [item setRightSelectedImage:image];
}
- (void)setBottomViewHeight:(CGFloat )h forSegmentAtIndex:(NSUInteger)segment
{
    SySegmentedItem *item = [_segments objectAtIndex:segment];
    item.bottomImageViewHeight = h;
    [item layoutSubviews];
}
- (void)setBackgroundColor:(UIColor *)backgroundColor forSegmentAtIndex:(NSUInteger)segment
{
    SySegmentedItem *item = [_segments objectAtIndex:segment];
    [item setBackgroundColor:backgroundColor];
}

- (void)hideTopView:(BOOL)hideT hideBottomView:(BOOL)bideB
{
    _topLineView.hidden = hideT;
    _bottomView.hidden = bideB;
}
- (void)setItemBottomViewColor:(UIColor *)bottomColor titleSelectedColor:(UIColor *)titleColor
{
    for (SySegmentedItem *aItem in _segments) {
        aItem.bottomViewColor = bottomColor;
        aItem.titleSeletedColor = titleColor;
    }
}
- (UIImage *)imageForSegmentAtIndex:(NSUInteger)segment {
    return nil;
}

- (void)setWidth:(CGFloat)width forSegmentAtIndex:(NSUInteger)segment 
{
    SySegmentedItem *item = [_segments objectAtIndex:segment];
    CGRect frame = item.frame;
    frame.size.width = width;
    item.frame = frame;
    // should layout subItems
    [self layoutItemsWithIndex:segment];
}

- (void)setSegmentEnable:(BOOL)enable forSegmentAtIndex:(NSUInteger)segment 
{
    SySegmentedItem *item = [_segments objectAtIndex:segment];
    item.enabled = enable;
}

- (CGFloat)widthForSegmentAtIndex:(NSUInteger)segment {
    return 0.0f;
}

- (CGFloat)segmentedItemHeight
{
    if (_segmentedItemHeight == 0) {
        return self.height;
    }
    return _segmentedItemHeight;
}

- (void)setContentOffset:(CGSize)offset forSegmentAtIndex:(NSUInteger)segment {
    
}

- (CGSize)contentOffsetForSegmentAtIndex:(NSUInteger)segment {
    SySegmentedItem *item = [_segments objectAtIndex:segment];
    return item.frame.size;
}

- (void)setEnabled:(BOOL)enabled forSegmentAtIndex:(NSUInteger)segment {
    SySegmentedItem *aItem = [_segments objectAtIndex:segment];
    aItem.enabled = enabled;
}

- (BOOL)enabledForSegmentAtIndex:(NSUInteger)segment {
    return YES;
}

- (void)customLayoutSubviews 
{
    CGFloat l = _backgroundImageEdgeInsets.left;
    CGFloat t = _backgroundImageEdgeInsets.top;
    _backgroundImageView.frame = CGRectMake(l, t, self.contentSize.width, self.contentSize.height);
    [self layoutItems];
}

#pragma -mark  segmentedItemWithAttribute
- (SySegmentedItem *)segmentedItemWithAttribute:(SySegmentedItemAttribute *)aAttribute
{
    SySegmentedItem *aItem = [[[SySegmentedItem alloc] initWithAttribute:aAttribute] autorelease];  
    [self setActionForSegment:aItem];
    return aItem;
}

- (void)addItems:(NSArray *)array 
{
    if (!_segments) {
        _segments = [[NSMutableArray alloc] init];
    }
    
    if (!_dividers) {
        _dividers = [[NSMutableArray alloc] init];
    }
    
    for (NSInteger i = 0; i < array.count; i ++) {
        SySegmentedItem *aItem = [array objectAtIndex:i];
        [_segments addObject:aItem];
        [self addSubview:aItem];
        // add divider
        if (i != array.count -1) {
            UIView *divider = [self dividerView];
            if (divider && divider.width > 0 && divider.height > 0) {
                [self addSubview:divider];
                [_dividers addObject:divider];
            }
        }
        // add end
    }
} 

- (void)layoutItems
{
    CGSize dividerSize = self.dividerSize;
    for (UIView *aView in _dividers) {
        [aView removeFromSuperview];
    }
    _bottomView.frame = CGRectMake(0, self.height-2, self.width, 2);

    [_dividers removeAllObjects];
    [_dividers release];
    _dividers = [[NSMutableArray alloc] init];
    
    CGFloat f = self.width - (_segments.count-1)*dividerSize.width;
    NSInteger w = f/_segments.count;
    _retainW = f - w*_segments.count;
    _itemSize = CGSizeMake(w, self.segmentedItemHeight);
    _sIndex = _segments.count - _retainW;

    CGFloat x = 0.0;
    for (int i = 0; i < _segments.count; i++) {
        SySegmentedItem *item = [_segments objectAtIndex:i];
        item.viewType = _viewType;
        
        CGRect frame = item.frame;
        frame.origin.x = x;
        frame.origin.y = 0;
        frame.size.width = _itemSize.width;
        frame.size.height = _itemSize.height;
        if (i>=_sIndex && _retainW>0) {
            frame.size.width += 1;
        }
        if (IS_IPHONE_X_UNIVERSAL) {
            frame.size.height -= 34;
        }
        item.frame = frame;
        x+= frame.size.width;
        // add divider
        if (i < _segments.count - 1 &&[self dividerView]) {
            UIView *divider = [self dividerView];//[_dividers objectAtIndex:i];
            
            CGFloat y =0;
            divider.frame = CGRectMake(x, y+5.5, dividerSize.width, divider.height);
            x += dividerSize.width;
            [self addSubview:divider];
            [_dividers addObject:divider];
        }
        // add end
    }
}

- (void)layoutItemsWithIndex:(NSInteger)index
{
    SySegmentedItem *aSegmentedItem = [_segments objectAtIndex:index];
    // 把后边的重现平等分
    CGSize dividerSize = self.dividerSize;
    CGFloat x = aSegmentedItem.frame.origin.x + aSegmentedItem.width;
    CGFloat rW = self.width - x - dividerSize.width * (_dividers.count - index);
    CGFloat sW = rW/(_segments.count - index - 1); // 平均宽度
    _retainW = rW - sW*(_segments.count - index - 1);
    _sIndex = _segments.count - _retainW;
    for (NSInteger i = index + 1; i < _segments.count; i ++) {
        if (i - 1 < _dividers.count) {
            UIView *divider = [_dividers objectAtIndex:i -1];
            CGRect rect = divider.frame;
            rect.origin.x = x;
            rect.size.height = divider.height;
            divider.frame = rect;
            x += rect.size.width;
        }
        SySegmentedItem *item = [_segments objectAtIndex:i];
        CGRect frame = item.frame;
        frame.origin.x = x;
        frame.size.width = sW;
        if ((i >= _segments.count - _sIndex) && _retainW > 0) {
            frame.size.width += 1;
        }
        item.frame = frame;
        x += item.frame.size.width;
    }
}
- (void)layoutSubviews
{
    [self bringSubviewToFront:_topLineView];
    _topLineView.frame = CGRectMake(0, 0, self.width, 0.5);
}
- (void)dimAllButtonsExcept:(SySegmentedItem*)selectedButton
{
    if (selectedButton == _selectedSegmentItem || _disableSelectedSate) {
        return;
    }
    _selectedSegmentItem.selected = NO;
    _selectedSegmentItem.highlighted = NO;
    
    selectedButton.selected = YES;
    selectedButton.highlighted = YES;
    if(_isNewCustom){
        for (SySegmentedItem *item in _segments) {
            [item setBottomImage:nil];
            [item setTitleColor:[UIColor blackColor]];
            if ([selectedButton isEqual:item]) {
                [item setBottomImage:[UIImage imageNamed:@"SySegmentedControl.bundle/According_to_the.png"]];
                [item setTitleColor:[UIColor colorWithRed:57.0/255 green:148.0/255 blue:18.0/255 alpha:1]];
            }
        }
    }
    _selectedSegmentItem = selectedButton;
    [self bringSubviewToFront:_selectedSegmentItem];
}

- (void)touchDownAction:(SySegmentedItem*)button
{
    if (!self.disableTouchState) {
        button.selected = YES;
    }
}

- (void)touchUpInsideAction:(SySegmentedItem *)button
{
    if (self.disableSelectedSate) {
        [self performSelector:@selector(setSelectButton:) withObject:button afterDelay:0.15];
    }
    _selectedSegmentIndex = [_segments indexOfObject:button];
    [self dimAllButtonsExcept:button];
    if ([_delegate respondsToSelector:valueChangedSelector]) {
        [_delegate performSelector:valueChangedSelector withObject:self];
    }
}

- (void)otherTouchesAction:(SySegmentedItem *)button
{
    if (self.disableSelectedSate || button != _selectedSegmentItem) {
        [self performSelector:@selector(setSelectButton:) withObject:button afterDelay:0.15];
    }
}

- (void)touchDragInsideAction:(SySegmentedItem *)button {
    
}

- (void)setSelectedSegmentIndex:(NSInteger)segment
{
    BOOL valueChange = NO;
    if (segment != _selectedSegmentIndex) {
        valueChange = YES;
    }
    _selectedSegmentIndex = segment;
    SySegmentedItem *item = nil;
    if (_selectedSegmentIndex >= 0 && _selectedSegmentIndex < _segments.count) {
        item = [_segments objectAtIndex:segment];
    }
    [self dimAllButtonsExcept:item];
    if (valueChange && _selectedSegmentIndex >= 0) {
        if ([_delegate respondsToSelector:valueChangedSelector]) {
            [_delegate performSelector:valueChangedSelector withObject:self];
        }
    }
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    _delegate = target;
    valueChangedSelector = action;
}

- (UIView *)dividerView
{
    if (_viewType== 1) {
       UIView *aView = [[[UIView alloc] init] autorelease];
        aView.backgroundColor = UIColorFromRGB(0x58a8b3);
        aView.frame = CGRectMake(0, 0, 1, 40);
        return aView;
    }
    else if (_viewType== 2)
    {
        UIImage *img = [UIImage imageWithCGImage:self.dividerImage.CGImage];
        UIView *aView = [[[UIImageView alloc] initWithImage:img] autorelease];
        aView.backgroundColor = UIColorFromRGB(0xe7ecf2);
        aView.frame = CGRectMake(0, 5.5, self.dividerSize.width, self.dividerSize.height);
        return aView;
    }
    else if (_viewType == 4)
    {
        return nil;
        UIView *aView = [[[UIImageView alloc] initWithImage:self.dividerImage] autorelease];
        aView.frame = CGRectMake(0, (self.height-self.dividerSize.height)/2, self.dividerSize.width, self.dividerSize.height);
        return aView;
    }
    return nil;
}

- (void)setActionForSegment:(SySegmentedItem *)aItem 
{
    [aItem addTarget:self action:@selector(touchDownAction:) forControlEvents:UIControlEventTouchDown];
    [aItem addTarget:self action:@selector(touchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
    [aItem addTarget:self action:@selector(otherTouchesAction:) forControlEvents:UIControlEventTouchUpOutside];
    [aItem addTarget:self action:@selector(otherTouchesAction:) forControlEvents:UIControlEventTouchDragOutside];
    [aItem addTarget:self action:@selector(touchDragInsideAction:) forControlEvents:UIControlEventTouchDragInside];
    [aItem addTarget:self action:@selector(otherTouchesAction:) forControlEvents:UIControlEventTouchDragOutside];
    [aItem addTarget:self action:@selector(otherTouchesAction:) forControlEvents:UIControlEventTouchCancel];
} 

- (void)setDisableSelectedSate:(BOOL)disableSelectedSate
{
    _selectedSegmentItem.selected = !disableSelectedSate;
    _disableSelectedSate = disableSelectedSate;
}

//设置按下弹起时的加载背景图片
- (void)setSelectButton:(SySegmentedItem *)aButton {
    aButton.selected = NO;
}

- (NSInteger)segmentsCount
{
    return _segments.count;
}

- (void)setSelectedBackgroundImage:(UIImage *)aImage
{
    for (SySegmentedItem *aItem in _segments) {
        [aItem setSelectedBackgroundImage:aImage];
    }
}
- (void)setViewType:(NSInteger)viewType
{
    _viewType = viewType;
    if (_viewType == 1) {
        self.dividerSize = CGSizeMake(1, 40);

    } else  if (_viewType == 3) {
        if (!_bottomView) {
            _bottomView = [[UIView alloc] init];
            _bottomView.frame = CGRectMake(0, self.height-2, self.width, 2);
            _bottomView.backgroundColor =  UIColorFromRGB(0xcee1f2);
            [self addSubview:_bottomView];
        }
        self.backgroundColor = UIColorFromRGB(0xf1f1f1);

        
    }else if (_viewType == 4) {
        self.dividerSize = CGSizeMake(1, 23);
//        self.dividerImage = [UIImage imageNamed:@"self.dividerImage"];

    }else if(_viewType == 5){
        
        for (int i = 0; i < _segments.count; i++)
        {
            SySegmentedItem *aItem = _segments[i];
            
            if(i  != 0 && i != _segments.count -1){
                aItem.position = SySegmentedItemAttribute_Position_Middle;
            }else if(i  == 0){
                aItem.position = SySegmentedItemAttribute_Position_First;
            }else if(i == _segments.count - 1){
                aItem.position = SySegmentedItemAttribute_Position_Last;

            }

        }
        
    }
    [self layoutItems];

}
@end
