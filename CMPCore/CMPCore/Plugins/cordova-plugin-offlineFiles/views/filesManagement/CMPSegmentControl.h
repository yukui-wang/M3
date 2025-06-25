//
//  CMPSegmentControl.h
//  M3
//
//  Created by MacBook on 2019/10/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPSegmentedControl : UIView

+ (instancetype)segmentedWithFrame:(CGRect)frame titles:(NSArray<NSString *>*)titles;
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray<NSString *>*)titles;
- (void)addValueChangedEventWithTarget:(id)target action:(SEL)action;
- (void)selectIndex:(NSInteger)index;
/* 选中的title颜色 */
@property (strong, nonatomic) UIColor *selectedTitleColor;
/* 未选中的title颜色 */
@property (strong, nonatomic) UIColor *unselectedTitleColor;
/* 选中的字体 */
@property (strong, nonatomic) UIFont *selectedFont;
/* 未选中的字体 */
@property (strong, nonatomic) UIFont *unselectedFont;
/* 选中的背景颜色 */
@property (strong, nonatomic) UIColor *selectedBgColor;
/* 未选中的背景颜色 */
@property (strong, nonatomic) UIColor *unselectedBgColor;
/* 是否显示border，默认显示，即YES */
@property (assign, nonatomic,getter=isShowBorder) BOOL showBorder;
/* border宽度，默认0.5 */
@property (assign, nonatomic) CGFloat borderWidth;
/* border颜色，默认蓝色 */
@property (strong, nonatomic) UIColor *borderColor;

- (void)disableBtnWithIndex:(int)index disable:(BOOL)disable;

@end

NS_ASSUME_NONNULL_END
