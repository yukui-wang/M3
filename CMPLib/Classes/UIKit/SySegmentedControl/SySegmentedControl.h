//
//  SySegmentedControl.h
//  M1Core
//
//  Created by guoyl on 12-11-20.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPBaseView.h"
#import "UIImage+CMPImage.h"
#import "SySegmentedItem.h"

@interface SySegmentedControl : CMPBaseView
{
    NSMutableArray *_segments; // 分段选择item
    id _delegate;
    SEL valueChangedSelector; // value回调方法
    NSInteger _selectedSegmentIndex; // 选择的
    CGSize _itemSize; // 
    CGFloat _retainW;
    NSInteger _sIndex;
    
    SySegmentedItem *_selectedSegmentItem; // 选中Item
    
    UIImageView *_backgroundImageView; // 背景view
    
    // dividers
    NSMutableArray *_dividers;
}

@property(nonatomic, retain) UIImage *backgroundImage; // 如果设置背景图片，那么segmentItem就没有backgroundImage
@property(nonatomic, assign) NSInteger selectedSegmentIndex;
@property(nonatomic, assign) BOOL disableTouchState; // 不可被选择
@property(nonatomic, assign) BOOL disableSelectedSate; // 不可用选中状态
@property(nonatomic, assign) UIEdgeInsets backgroundImageEdgeInsets;
@property(nonatomic, assign) CGFloat segmentedItemHeight;
@property(nonatomic, retain) UIImage *dividerImage; // 分隔线图片
@property(nonatomic, assign) CGSize dividerSize;
@property(nonatomic,assign) NSInteger viewType;//1 iphone  2 iphone底部  3 ipad详情 4 pad协同列表

- (id)initWithItems:(NSArray *)items; // titles
- (id)initWithItemAttributes:(NSArray *)aItemAttributes; // SySegmentedItemAttribute
- (id)initForNewCustomWithItems:(NSArray *)array;

- (void)addSegmentWithAttribute:(SySegmentedItemAttribute  *)aAttribute animated:(BOOL)animated;

- (SySegmentedItem *)segmentedItemAtIndex:(NSUInteger)segment;
- (SySegmentedItem *)segmentedItemWithTag:(NSInteger)aTag;

- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated; // insert before segment number. 0..#segments. value pinned
- (void)insertSegmentWithAttribute:(SySegmentedItemAttribute  *)aAttribute atIndex:(NSUInteger)segment animated:(BOOL)animated;
- (void)insertSegmentWithImage:(UIImage *)image  atIndex:(NSUInteger)segment animated:(BOOL)animated;
- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated;
- (void)removeAllSegments;
- (void)removeSegmentedItem:(SySegmentedItem *)aSegmentItem animated:(BOOL)animated;

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment;      // can only have image or title, not both. must be 0..#segments - 1 (or ignored). default is nil
- (void)setTitleColor:(UIColor *)aColor forSegmentAtIndex:(NSUInteger)segment;
- (void)setTitleFont:(UIFont *)font selectedFont:(UIFont *)selectedFont;

- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment;

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment;       // can only have image or title, not both. must be 0..#segments - 1 (or ignored). default is nil

- (void)setRightImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment;
- (void)setSelectedRightImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment;
- (void)setBottomViewHeight:(CGFloat )h forSegmentAtIndex:(NSUInteger)segment;
- (void)setBackgroundColor:(UIColor *)backgroundColor forSegmentAtIndex:(NSUInteger)segment;
- (void)hideTopView:(BOOL)hideT hideBottomView:(BOOL)bideB;
- (void)setItemBottomViewColor:(UIColor *)bottomColor titleSelectedColor:(UIColor *)titleColor;

- (UIImage *)imageForSegmentAtIndex:(NSUInteger)segment;

- (void)setWidth:(CGFloat)width forSegmentAtIndex:(NSUInteger)segment;         // set to 0.0 width to autosize. default is 0.0
- (void)setSegmentEnable:(BOOL)enable forSegmentAtIndex:(NSUInteger)segment; 

- (CGFloat)widthForSegmentAtIndex:(NSUInteger)segment;

- (void)setContentOffset:(CGSize)offset forSegmentAtIndex:(NSUInteger)segment; // adjust offset of image or text inside the segment. default is (0,0)
- (CGSize)contentOffsetForSegmentAtIndex:(NSUInteger)segment;

- (void)setEnabled:(BOOL)enabled forSegmentAtIndex:(NSUInteger)segment;        // default is YES
- (BOOL)enabledForSegmentAtIndex:(NSUInteger)segment;
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (SySegmentedItem *)segmentedItemWithAttribute:(SySegmentedItemAttribute *)aAttribute;

- (void)addItems:(NSArray *)array;

// override point
- (UIView *)dividerView;
- (NSInteger)segmentsCount;
- (void)setSelectedBackgroundImage:(UIImage *)aImage;
@end
