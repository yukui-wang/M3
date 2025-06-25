//
//  KSActionSheetView.m
//  XGiant
//
//  Created by Songu Kaku on 2018/6/13.
//  Copyright © 2018年 com.xinjucn. All rights reserved.
//

#import "KSActionSheetView.h"
//#import "UIFont+XGFont.h"
#import <CMPLib/CMPConstant.h>

#define kRowHeight 50.0f
#define kRowLineHeight 0.5f
#define kSeparatorHeight 10.0f

#define kTitleFontSize 14.0f
#define kButtonTitleFontSize 17.0f
#define kDetailContentHeightMax (kRowHeight + kRowLineHeight)*6

@interface KSActionSheetViewItem()
{
    NSString *_title;
    NSUInteger _key;
    NSString *_identifier;
}
@end

@implementation KSActionSheetViewItem


-(NSString *)title
{
    return _title;
}

-(NSUInteger)key
{
    return _key;
}

-(NSString *)identifier
{
    return _identifier;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(KSActionSheetViewItem *)setTitle:(NSString *)title
{
    _title = title;
    return self;
}

-(KSActionSheetViewItem *)setKey:(NSUInteger)key
{
    _key = key;
    return self;
}

-(KSActionSheetViewItem *)setIdentifier:(NSString *)identifier
{
    _identifier = identifier;
    return self;
}

@end

@interface KSActionSheetView()<UIScrollViewDelegate> {
    UIView      *_backView;
    UIView *_actionSheetView;
    CGFloat _actionSheetHeight;
    BOOL        _isShow;
    NSArray *_titles;
    NSInteger _selectIndex;
    UIScrollView *detailContentBgScrollView;
}
@property (nonatomic, copy)  NSString *title;
@property (nonatomic, copy)  NSString *cancelButtonTitle;
@property (nonatomic, copy)  NSString *destructiveButtonTitle;
@property (nonatomic, copy)  NSArray *otherButtonTitles;
@property (nonatomic, copy)  NSArray<KSActionSheetViewItem *> *otherButtonTitleItems;
@property (nonatomic, copy)  KSActionSheetViewItemSelectedBlock itemSelectedBlk;
@end

@implementation KSActionSheetView

- (void)dealloc {
    _title= nil;
    _cancelButtonTitle = nil;
    _destructiveButtonTitle = nil;
    _otherButtonTitles = nil;
    _otherButtonTitleItems = nil;
    _itemSelectedBlk = nil;
    
    _actionSheetView = nil;
    _backView = nil;
    detailContentBgScrollView = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        CGRect frame = [UIScreen mainScreen].bounds;
        self.frame = frame;
    }
    return self;
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:_backView];
    if (!CGRectContainsPoint([_actionSheetView frame], point)) {
        [self dismiss];
    }
}

- (void)didSelectAction:(UIButton *)button {
    if (_itemSelectedBlk) {
        if (button.tag == -1) {
            KSActionSheetViewItem *cancelItem = [[KSActionSheetViewItem alloc] init];
            cancelItem.key = -1;
            cancelItem.title = button.titleLabel.text;
            cancelItem.identifier = @"ks_sheet_cancel";
            _itemSelectedBlk(self, cancelItem,nil);
        }else if (button.tag == ([_otherButtonTitles count] ? [_otherButtonTitles count]+1: 0)) {
            KSActionSheetViewItem *desItem = [[KSActionSheetViewItem alloc] init];
            desItem.key = -2;
            desItem.title = button.titleLabel.text;
            desItem.identifier = @"ks_sheet_des";
            _itemSelectedBlk(self, desItem,nil);
        }else{
            _itemSelectedBlk(self, _otherButtonTitleItems[button.tag-1],nil);
        }
        
    }

    [self dismiss];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - public
- (void)show {
    if(_isShow) return;
    _isShow = YES;
    [UIView animateWithDuration:0.35f delay:0 usingSpringWithDamping:0.9f initialSpringVelocity:0.7f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionLayoutSubviews animations:^{
        
        [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
        self->_backView.alpha = 1.0;
        
        self->_actionSheetView.frame = CGRectMake(0, CGRectGetHeight(self.frame)-self->_actionSheetHeight-[self _safeAreaEdge].bottom, CGRectGetWidth(self.frame), self->_actionSheetHeight);
    } completion:NULL];
}

- (void)dismiss {
    _isShow = NO;
    [UIView animateWithDuration:0.35f delay:0 usingSpringWithDamping:0.9f initialSpringVelocity:0.7f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionLayoutSubviews animations:^{
        
        self->_backView.alpha = 0.0;
        
        self->_actionSheetView.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), self->_actionSheetHeight);
        
    } completion:^(BOOL finished) {
        
        if (self->_willDismissBlk) {//nimeide
            self->_willDismissBlk();
        }
        [self removeFromSuperview];
    }];
}


-(UIEdgeInsets)_safeAreaEdge
{
    if (@available(iOS 11.0, *)) {
        return self.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}



-(void)updateEnableState:(BOOL)enable
               byIndexes:(NSArray<NSNumber *> *)indexes
{
    if (!detailContentBgScrollView) {
        return;
    }
    for (NSNumber *val in indexes) {
        UIButton *_v = [detailContentBgScrollView viewWithTag:val.integerValue+1];
        if (_v && [_v isKindOfClass:[UIButton class]]) {
            if (!enable) {
                [_v setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                _v.enabled = NO;
            }else{
                [_v setTitleColor:UIColorFromRGB(0x191919) forState:UIControlStateNormal];
                _v.enabled = YES;
            }
            
        }
    }
    
}





- (instancetype)initWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
        otherButtonTitleItems:(NSArray<KSActionSheetViewItem *> *)otherButtonTitleItems
         actionSheetViewColor:(UIColor *)actionSheetViewColor
             normalImageColor:(UIColor *)normalImageColor
        highlightedImageColor:(UIColor *)highlightedImageColor
                      handler:(KSActionSheetViewItemSelectedBlock)block
{
    self = [self init];
    if (self) {
        
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        
        _title = title;
        _cancelButtonTitle = cancelButtonTitle;
        _destructiveButtonTitle = destructiveButtonTitle;
        _otherButtonTitleItems = [NSArray arrayWithArray:otherButtonTitleItems];
        _itemSelectedBlk = block;
        
        _backView = [[UIView alloc] initWithFrame:self.frame];
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35];
        _backView.alpha = 0.0f;
        [self addSubview:_backView];
        
        _actionSheetView = [[UIView alloc] init];
        if (actionSheetViewColor) {
            _actionSheetView.backgroundColor = actionSheetViewColor;
        }else {
            //            _actionSheetView.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f];
            _actionSheetView.backgroundColor = UIColorFromRGB(0xf5f6f7);
        }
        [self addSubview:_actionSheetView];
        
        CGFloat offy = 0;
        CGFloat width = self.frame.size.width;
        
        UIImage *normalImg = [[UIImage alloc] init];
        UIImage *highlightedImg = [[UIImage alloc] init];
        
        if (normalImageColor) {
            normalImg = [self imageWithColor:normalImageColor];
        }else {
            normalImg = [self imageWithColor:[UIColor whiteColor]];
        }
        
        if (highlightedImageColor) {
            highlightedImg = [self imageWithColor:highlightedImageColor];
        }else {
            highlightedImg = [self imageWithColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f]];
        }
        
        if (_title && _title.length>0) {
            CGFloat spacing = 15.0f;
            CGFloat titleHeight = ceil([_title boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Regular" size:kTitleFontSize]} context:nil].size.height) + spacing*2;
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, titleHeight)];
            titleLabel.alpha = 0.95;
            titleLabel.backgroundColor = [UIColor whiteColor];
            titleLabel.textColor = UIColorFromRGB(0x999999);
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:kTitleFontSize];
            titleLabel.numberOfLines = 0;
            titleLabel.text = _title;
            [_actionSheetView addSubview:titleLabel];
            
            offy += titleHeight+kRowLineHeight;
        }
        
        if ([_otherButtonTitleItems count] > 0) {
            CGFloat contentHeight = _otherButtonTitleItems.count*(kRowHeight+kRowLineHeight);
            CGFloat h = MIN(contentHeight, kDetailContentHeightMax);
            detailContentBgScrollView = nil;
            detailContentBgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, offy, width, h)];
            detailContentBgScrollView.contentSize = CGSizeMake(width, MAX(contentHeight, kDetailContentHeightMax));
            if (contentHeight > h) {
                detailContentBgScrollView.scrollEnabled = YES;
            }else{
                detailContentBgScrollView.scrollEnabled = NO;
            }
            [_actionSheetView addSubview:detailContentBgScrollView];
            for (int i = 0; i < _otherButtonTitleItems.count; i++) {
                KSActionSheetViewItem *item = _otherButtonTitleItems[i];
                UIButton *btn = [[UIButton alloc] init];
                btn.alpha = 0.95;
                btn.frame = CGRectMake(0, i*(kRowHeight+kRowLineHeight), width, kRowHeight);
                btn.tag = i+1;
                btn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:kButtonTitleFontSize];
                [btn setTitleColor:UIColorFromRGB(0x191919) forState:UIControlStateNormal];
                [btn setTitle:item.title forState:UIControlStateNormal];
                [btn setBackgroundImage:normalImg forState:UIControlStateNormal];
                [btn setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
                [btn addTarget:self action:@selector(didSelectAction:) forControlEvents:UIControlEventTouchUpInside];
                [detailContentBgScrollView addSubview:btn];
            }
            offy += h;
            offy -= kRowLineHeight;
        }
        
        if (_destructiveButtonTitle && _destructiveButtonTitle.length>0) {
            offy += kRowLineHeight;
            UIButton *destructiveButton = [[UIButton alloc] init];
            destructiveButton.alpha = 0.95;
            destructiveButton.frame = CGRectMake(0, offy, width, kRowHeight);
            destructiveButton.tag = [_otherButtonTitleItems count] ?[_otherButtonTitleItems count]+1 : 0;
            destructiveButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:kButtonTitleFontSize];
            [destructiveButton setTitleColor:UIColorFromRGB(0xf24848) forState:UIControlStateNormal];
            [destructiveButton setTitle:_destructiveButtonTitle forState:UIControlStateNormal];
            [destructiveButton setBackgroundImage:normalImg forState:UIControlStateNormal];
            [destructiveButton setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
            [destructiveButton addTarget:self action:@selector(didSelectAction:) forControlEvents:UIControlEventTouchUpInside];
            [_actionSheetView addSubview:destructiveButton];
            offy += kRowHeight;
        }
        
        if (_cancelButtonTitle && _cancelButtonTitle.length>0) {
            offy += kSeparatorHeight;
            
            UIButton *cancelBtn = [[UIButton alloc] init];
            cancelBtn.alpha = 0.95;
            cancelBtn.frame = CGRectMake(0, offy, width, kRowHeight);
            cancelBtn.tag = -1;
            cancelBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:kButtonTitleFontSize];
            [cancelBtn setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
            [cancelBtn setTitle:_cancelButtonTitle ?: @"取消" forState:UIControlStateNormal];
            [cancelBtn setBackgroundImage:normalImg forState:UIControlStateNormal];
            [cancelBtn setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
            [cancelBtn addTarget:self action:@selector(didSelectAction:) forControlEvents:UIControlEventTouchUpInside];
            [_actionSheetView addSubview:cancelBtn];
            
            offy += kRowHeight;
        }
        //        offy += 10;
        _actionSheetHeight = offy;
        _actionSheetView.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), _actionSheetHeight);
    }
    return self;
}


+ (KSActionSheetView *)showActionSheetWithTitle:(NSString *)title
                              cancelButtonTitle:(NSString *)cancelButtonTitle
                         destructiveButtonTitle:(NSString *)destructiveButtonTitle
                          otherButtonTitleItems:(NSArray<KSActionSheetViewItem *> *)otherButtonTitleItems
                                        handler:(KSActionSheetViewItemSelectedBlock)block
{
    KSActionSheetView *actionSheetView = [[KSActionSheetView alloc] initWithTitle:title cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitleItems:otherButtonTitleItems actionSheetViewColor:nil normalImageColor:nil highlightedImageColor:nil handler:block];
    return actionSheetView;
}



@end

