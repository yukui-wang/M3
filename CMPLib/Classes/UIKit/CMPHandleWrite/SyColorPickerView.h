//
//  SyColorPickerView.h
//  SyCanvasViewTest
//
//  Created by admin on 12-4-16.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SyColorPickerViewDelegate;  

@interface SyColorPickerView : UIView {
    id<SyColorPickerViewDelegate>  delegate_;
@private
    UIImageView *backgroundImg_;
    NSArray *colors_;
    CGFloat width_;
    CGFloat height_;
    UIColor *currentColor_;
    NSString *currentColorImgName_;
    NSMutableArray  *colorViews_;
}

@property (nonatomic, assign) id<SyColorPickerViewDelegate>  delegate;
@property (nonatomic, retain) NSArray *colors;
@property (nonatomic, retain) NSMutableArray  *colorViews;
@property (nonatomic, retain) NSString *currentColorImgName;

- (void)createColorViews;

- (void)refreshColorViews;

- (NSString *)setCurrentColor:(UIColor *)currentColor;

- (NSString *)getColorString:(UIColor *)color;

@end

@interface SyColorView : UIView {
    id delegate_;
    UIImageView *colorImgView_; // 颜色显示图片
    UIImageView *bgImgView_;
    UIColor *color_;
    BOOL    isCurrentColor_;
    NSString *colorImgName_;
}

@property (nonatomic, assign)id delegate;
@property (nonatomic, retain)UIColor *color;
@property (nonatomic, assign)BOOL    isCurrentColor;
@property (nonatomic, copy)NSString  *colorImgName;

- (void)setBackgroundImage:(NSString *)aImgName;

@end

@protocol SyColorPickerViewDelegate <NSObject>

- (void)colorPickerView:(SyColorPickerView *)aaColorPickerView didSelectedColor:(UIColor *)aColor colorImgName:(NSString *)imgName;

@end