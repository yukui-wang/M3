//
//  CMPSegmentView.m
//  CMPSegmentView <https://github.com/wangruofeng/CMPSegmentView>
//
//  Created by 王若风 on 1/15/15.
//  Copyright (c) 2015 王若风. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "CMPSegmentView.h"
#import "CMPThemeManager.h"
#import <CMPLib/CMPConstant.h>

#define kDefaultTintColor       [UIColor cmp_colorWithName:@"theme-bgc"]
#define kDefaultNormalColor     [[UIColor cmp_colorWithName:@"white-bg"] colorWithAlphaComponent:0.8]
#define KDefaultCornerRadius    13.f
#define kLeftRightMargin        30
#define kItemHeight             26
#define kItemTitleFont          14
#define kItemLineHeight         10
#define kBorderLineWidth        0.5

@class CMPSegmentItemView;

@protocol CMPSegmentItemViewDelegate

- (void)itemStateChanged:(CMPSegmentItemView *)item
				   index:(NSUInteger)index
			  isSelected:(BOOL)isSelected;
@end

#pragma mark - CMPSegmentItemView

@interface CMPSegmentItemView : UIView

@property (nonatomic, strong) UILabel   *titleLabel;

@property (nonatomic, strong) UIColor   *norColor;
@property (nonatomic, strong) UIColor   *selColor;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL      isSelected;
@property (nonatomic, weak	) id<CMPSegmentItemViewDelegate> delegate;

@end

@implementation CMPSegmentItemView

- (instancetype)initWithFrame:(CGRect)frame
						index:(NSInteger)index
						title:(NSString *)title
					 norColor:(UIColor *)norColor
					 selColor:(UIColor *)selColor
				   isSelected:(BOOL)isSelected;
{
	self = [super initWithFrame:frame];
	if (self) {
		 
		_titleLabel                 = [UILabel new];
		_titleLabel.textAlignment   = NSTextAlignmentCenter;
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.font            = [UIFont systemFontOfSize:kItemTitleFont weight:UIFontWeightRegular];
		
		[self addSubview:_titleLabel];
		
		_norColor        = norColor;
		_selColor        = selColor;
		_titleLabel.text = title;
		_index           = index;
		_isSelected      = isSelected;
	}
	
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	_titleLabel.frame = self.bounds;
}

#pragma mark - Setter

- (void)setSelColor:(UIColor *)selColor
{
	if (_selColor != selColor) {
		_selColor = selColor;
		
		if (_isSelected) {
			self.titleLabel.textColor = self.norColor;
			self.backgroundColor      = self.selColor;
		} else {
			self.titleLabel.textColor = self.selColor;
			self.backgroundColor      = self.norColor;
		}
		
	}
}

- (void)setIsSelected:(BOOL)isSelected
{
	_isSelected = isSelected;
	if (_isSelected) {
        self.titleLabel.textColor = [UIColor cmp_colorWithName:@"reverse-fc"];
		self.backgroundColor      = self.selColor;
        self.layer.cornerRadius = KDefaultCornerRadius;
        //self.layer.masksToBounds = YES;
	} else {
        self.titleLabel.textColor = [UIColor cmp_colorWithName:@"cont-fc"];
		self.backgroundColor      = self.norColor;
        self.layer.cornerRadius = 0;
        //self.layer.masksToBounds = NO;
	}
	
}

#pragma mark - Event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.isSelected = !_isSelected;

	if (_delegate) {
		[_delegate itemStateChanged:self
							  index:self.index
						 isSelected:self.isSelected];
	}
}

@end

#pragma mark - CMPSegmentView

@interface CMPSegmentView()<CMPSegmentItemViewDelegate>

@property (nonatomic, strong) UIView         *bgView;
@property (nonatomic, strong) NSArray        *titles;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *lines;

@end

@implementation CMPSegmentView

- (instancetype)initWithFrame:(CGRect)frame
					   titles:(NSArray<NSString *> * _Nonnull)titles
{
	self = [super initWithFrame:frame];
	if (self) {
		
		NSAssert(titles.count >= 2, @"titles's cout at least 2!please check!");
		
		self.backgroundColor = [UIColor whiteColor];

		_titles = titles;
		
		// bgView
		_bgView = [[UIView alloc] init];
		_bgView.backgroundColor    = kDefaultNormalColor;
		_bgView.clipsToBounds      = YES;
		_bgView.layer.cornerRadius = KDefaultCornerRadius;
		
		[self addSubview:_bgView];
		
		[self addSubItemView];
		[self addSubLineView];
	}
	
	return self;
}

- (void)addSubItemView
{
	NSInteger count = _titles.count;
	for (NSInteger i = 0; i < count; i++) {
		CMPSegmentItemView *item = [[CMPSegmentItemView alloc] initWithFrame:CGRectZero
															 index:i
															 title:_titles[i]
														  norColor:kDefaultNormalColor
														  selColor:kDefaultTintColor
														isSelected:(i == 0)? YES: NO];
		[_bgView addSubview:item];
		item.delegate = self;
		
		//save all items
		if (!self.items) {
			self.items = [[NSMutableArray alloc] initWithCapacity:count];
		}
		[_items addObject:item];
	}
}

- (void)addSubLineView
{
	NSInteger count = _titles.count;

	//add Ver lines
	for (NSInteger i = 0; i < count - 1; i++) {
		UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
        lineView.backgroundColor = [UIColor colorWithRed:212/255.0 green:212/255.0 blue:212/255.0 alpha:1];
		[_bgView addSubview:lineView];
		
		//save all lines
		if (!self.lines) {
			self.lines = [[NSMutableArray alloc] initWithCapacity:count];
		}
		[_lines addObject:lineView];
	}
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutUI];
}

- (void)layoutUI
{
	CGFloat viewWidth     = CGRectGetWidth(self.frame);
	CGFloat viewHeight    = CGRectGetHeight(self.frame);
	__block CGFloat initX = 0;
	CGFloat initY         = 0;
	
	NSInteger count         = self.titles.count;
	CGFloat leftRightMargin = self.leftRightMargin ?: kLeftRightMargin;
    if (self.items.count == 2) {
        leftRightMargin = (viewWidth - 170) * 0.5;
    }
	CGFloat itemWidth       = (viewWidth - 2 * leftRightMargin)/count;
	CGFloat itemHeight      = self.itemHeight ?: kItemHeight;

	
	//configure bgView
	self.bgView.frame = CGRectMake(leftRightMargin, (viewHeight - itemHeight) / 2, viewWidth - 2 * leftRightMargin, itemHeight);
	
	//configure items
	[self.items enumerateObjectsUsingBlock:^(CMPSegmentItemView * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
		item.frame = CGRectMake(initX, initY, itemWidth, itemHeight);
		initX += itemWidth;
	}];
	
	initX = 0;
	//configure lines
	[self.lines enumerateObjectsUsingBlock:^(UIView *  _Nonnull lineView, NSUInteger idx, BOOL * _Nonnull stop) {
		initX += itemWidth;
		lineView.frame = CGRectMake(initX-1,(kItemHeight - kItemLineHeight) * 0.5, 1, kItemLineHeight);
	}];
	
}

#pragma mark - Setter

- (void)setCornerRadius:(CGFloat)cornerRadius{
	
	NSAssert(cornerRadius > 0, @"cornerRadius must be above 0");
	
	_cornerRadius = cornerRadius;
	_bgView.layer.cornerRadius  = cornerRadius;
	
	[self layoutUI];
}

- (void)setTintColor:(UIColor *)tintColor{
	
	if (_tintColor != tintColor) {
		_tintColor = tintColor;
		
		//self.bgView.layer.borderColor  = tintColor.CGColor;
		
		for (NSInteger i = 0; i < self.items.count; i++) {
			CMPSegmentItemView *item = self.items[i];
			item.selColor = tintColor;
		}
		
		for (NSInteger i = 0; i < self.lines.count; i++) {
			UIView *lineView = self.lines[i];
			lineView.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
		}
		
		[self layoutUI];
	}
}

- (void)setSelectedIndex:(NSUInteger)index
{
	_selectedIndex = index;
    
    [self hiddenLinesWithIndex:index];
	
	if (index < self.items.count) {
		for (int i = 0; i < self.items.count; i++) {
			CMPSegmentItemView *item = self.items[i];
			
			if (i == index) {
				[item setIsSelected:YES];
			} else {
				[item setIsSelected:NO];
			}
		}
	}
}

#pragma mark - CMPSegmentItemViewDelegate

- (void)itemStateChanged:(CMPSegmentItemView *)currentItem index:(NSUInteger)index isSelected:(BOOL)isSelected
{
	// diselect all items
	for (int i = 0; i < self.items.count; i++) {
		CMPSegmentItemView *item = self.items[i];
		item.isSelected = NO;
	}
	currentItem.isSelected = YES;
    
    [self hiddenLinesWithIndex:index];
	
	// notify delegate
	if ([_delegate respondsToSelector:@selector(segmentView:didSelectedIndex:)]) {
		[_delegate segmentView:self didSelectedIndex:index];
	}
	
	// notify block handler
	if (_handlder) {
		_handlder(self, index);
	}
}

- (void)hiddenLinesWithIndex:(NSUInteger)index {
    for (NSInteger i = 0; i < self.lines.count; i++) {
        UIView *lineView = self.lines[i];
        lineView.hidden = NO;
    }
    
    NSInteger aIndex = index;
    
    NSInteger leftIndex = ((aIndex - 1) >= 0 ) ? (aIndex - 1) : 0;
    UIView *leftLineView = self.lines[leftIndex];
    leftLineView.hidden = YES;
    
    NSUInteger rightIndex = (aIndex > (self.lines.count - 1)) ? (self.lines.count - 1) : aIndex;
    UIView *rightLineView = self.lines[rightIndex];
    rightLineView.hidden = YES;
}

@end
