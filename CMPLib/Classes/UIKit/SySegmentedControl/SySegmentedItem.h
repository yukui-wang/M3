//
//  SySegmentedItem.h
//  M1Core
//
//  Created by guoyl on 12-11-20.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SySegmentedItemAttribute.h"

@interface SySegmentedItem : UIControl
{
    UILabel *_titleLabel;    
    UIImageView *_backgroundImageView;
    UIImageView *_imageView;
    UIImageView *_rightImageView;
    UIImageView *_bottomImageView;
    UIImageView *_selectArrowImageView;

}

@property(nonatomic, retain)SySegmentedItemAttribute *attribute;
@property(nonatomic ,assign) BOOL isNewCustom;
@property(nonatomic,assign) NSInteger viewType;//1 iphone  2 iphone底部
@property (nonatomic, assign) SySegmentedItemAttribute_Position position;
@property(nonatomic,assign)CGFloat bottomImageViewHeight;
@property(nonatomic,retain)UIColor *bottomViewColor;
@property(nonatomic,retain)UIColor *titleSeletedColor;

- (id)initWithAttribute:(SySegmentedItemAttribute *)aAttribute;
// set attribute
- (void)setBackgroundImage:(UIImage *)backgroundImage;
- (void)setSelectedBackgroundImage:(UIImage *)selectedBackgroundImage;
- (void)setImage:(UIImage *)image;
- (void)setImage:(UIImage *)image size:(CGSize)aSize;
- (void)setRightImage:(UIImage *)rightImage;
- (void)setRightSelectedImage:(UIImage *)aImage;
- (void)setTitle:(NSString *)aTitle;
- (void)setTitleFont:(UIFont *)titleFont;
- (void)setSelectedTitleFont:(UIFont *)selectedTitleFont;
- (void)setTitleColor:(UIColor *)aColor;
- (void)setRightImageEdgeInsets:(UIEdgeInsets)rightImageEdgeInsets;
- (void)setImageEdgeInsets:(UIEdgeInsets)imageEdgeInsets;

- (void)setBottomImage:(UIImage *)bottomImage;
- (void)setSelectedBottomImage:(UIImage *)selectedBottomImage;
- (void)setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets;
@end
