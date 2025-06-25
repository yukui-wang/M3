//
//  UIView+SyView.m
//  M1Core
//
//  Created by admin on 12-10-30.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

//#define IS_IPHONE_X              ([[UIApplication sharedApplication] statusBarFrame].size.height == 44.f ? YES:NO)

#define CMP_SCREEN_WIDTH        [UIScreen mainScreen].bounds.size.width
#define CMP_SCREEN_HEIGHT       [UIScreen mainScreen].bounds.size.height

#import "UIView+CMPView.h"
#import <QuartzCore/QuartzCore.h>
#import "SOSwizzle.h"

static void *expandOffsetKey = &expandOffsetKey;

@interface UIView ()
@property (assign, nonatomic) UIOffset expandOffset;
@end

@implementation UIView (CMPView)

+ (void)load {
    SOSwizzleInstanceMethod(self, @selector(layoutSubviews),@selector(cmp_view_layoutSubviews));
    SOSwizzleInstanceMethod(self, @selector(addSubview:),@selector(cmp_addSubview:));
}

- (UIInterfaceOrientation)interfaceOrientation {
    return [UIApplication sharedApplication].statusBarOrientation;
}

- (UIUserInterfaceIdiom)userInterfaceIdiom
{
    return [[UIDevice currentDevice] userInterfaceIdiom];
}

- (CGFloat)originX {
    return self.frame.origin.x;
}

- (CGFloat)originY {
    return self.frame.origin.y;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (CGFloat)height {
    return self.frame.size.height;
}

+ (CGSize)mainScreenSize {
    return [[UIScreen mainScreen] bounds].size;
}

+ (CGFloat)staticStatusBarHeight
{
    CGFloat height = [[UIApplication sharedApplication] statusBarFrame].size.height;
    if (height == 0) {
        height = IS_IPHONE_X_Portrait ? 44 : 20;
    }
    return height;//  20;
}

- (UIImage*) imageWithUIView:(UIView*) view
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContextWithOptions(view.bounds.size,0,[UIScreen mainScreen].scale);
    CGContextRef currnetContext = UIGraphicsGetCurrentContext();
    //[view.layer drawInContext:currnetContext];
    [view.layer renderInContext:currnetContext];
    // 从当前context中创建一个改变大小后的图片
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    return image;
}

-(void)removeAllSubviews
{
    if (self && self.subviews.count>0) {
        NSArray *subviews = [self.subviews copy];
        for (UIView *aview in subviews) {
            if (aview && [aview isKindOfClass:[UIView class]]) {
                [aview removeFromSuperview];
            }
        }
    }
}

#pragma mark-
#pragma mark 快捷获取、设置Frame

- (CGFloat)cmp_right{
    return self.cmp_x+self.cmp_width;
}

- (CGFloat)cmp_bottom{
    return self.cmp_y+self.cmp_height;
}

- (CGFloat)cmp_left{
    return self.cmp_x;
}

- (CGFloat)cmp_top{
    return self.cmp_y;
}

- (CGFloat)cmp_x {
    return self.frame.origin.x;
}

- (void)setCmp_bottom:(CGFloat)cmp_bottom {
    self.cmp_y = cmp_bottom - self.cmp_height;
}

- (void)setCmp_x:(CGFloat)cmp_x {
    CGRect frame = self.frame;
    frame.origin.x = cmp_x;
    self.frame = frame;
}

- (CGFloat)cmp_y {
    return self.frame.origin.y;
}

- (void)setCmp_y:(CGFloat)cmp_y {
    CGRect frame = self.frame;
    frame.origin.y = cmp_y;
    self.frame = frame;
}

- (CGFloat)cmp_width {
    return self.frame.size.width;
}

- (void)setCmp_width:(CGFloat)cmp_width {
    CGRect frame = self.frame;
    frame.size.width = cmp_width;
    self.frame = frame;
}

- (CGFloat)cmp_height {
    return self.frame.size.height;
}

- (void)setCmp_height:(CGFloat)cmp_height {
    CGRect frame = self.frame;
    frame.size.height = cmp_height;
    self.frame = frame;
}

- (CGSize)cmp_size {
    return self.frame.size;
}

- (void)setCmp_size:(CGSize)cmp_size {
    CGRect frame = self.frame;
    frame.size = cmp_size;
    self.frame = frame;
}

- (CGPoint)cmp_origin {
    return self.frame.origin;
}

- (void)setCmp_origin:(CGPoint)cmp_origin {
    CGRect frame = self.frame;
    frame.origin = cmp_origin;
    self.frame = frame;
}

- (CGFloat)cmp_centerX {
    return self.center.x;
}

- (void)setCmp_centerX:(CGFloat)cmp_centerX {
    CGPoint center = self.center;
    center.x = cmp_centerX;
    self.center = center;
}

- (CGFloat)cmp_centerY {
    return self.center.y;
}

- (void)setCmp_centerY:(CGFloat)cmp_centerY {
    CGPoint center = self.center;
    center.y = cmp_centerY;
    self.center = center;
}

#pragma mark-
#pragma mark 扩大点击区域

- (void)cmp_expandClickArea:(UIOffset)offset {
    self.expandOffset = offset;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -self.expandOffset.horizontal, -self.expandOffset.vertical);
    return CGRectContainsPoint(bounds, point);
}

- (void)setExpandOffset:(UIOffset)expandOffset {
    NSValue *value = [NSValue valueWithUIOffset:expandOffset];
    objc_setAssociatedObject(self, &expandOffsetKey, value, OBJC_ASSOCIATION_COPY);
}

- (UIOffset)expandOffset {
    NSValue *value = objc_getAssociatedObject(self, &expandOffsetKey);
    return [value UIOffsetValue];
}

- (UIImage *)grabScreenshot {
    return [self grabScreenshotWithSize:self.bounds.size];
}

- (UIImage *)grabScreenshotWithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0f);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark- 自动布局

- (void)cmp_view_layoutSubviews {
    [self cmp_view_layoutSubviews];
    
    if (self.layoutSubviewsCallback) {
        self.layoutSubviewsCallback(self);
    }
}


- (void)setLayoutSubviewsCallback:(void (^)(UIView *))layoutSubviewsCallback {
    objc_setAssociatedObject(self, @selector(layoutSubviewsCallback), layoutSubviewsCallback, OBJC_ASSOCIATION_RETAIN);
}

- (void (^)(UIView *))layoutSubviewsCallback {
    return objc_getAssociatedObject(self, @selector(layoutSubviewsCallback));
}

/**
 *  @判断view是否显示
 */
- (BOOL)isShowingOnKeyWindow
{
    // 主窗口
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    // 以主窗口左上角为坐标原点, 计算self的矩形框
    CGRect newFrame = [keyWindow convertRect:self.frame fromView:self.superview];
    CGRect winBounds = keyWindow.bounds;
    
    // 主窗口的bounds 和 self的矩形框 是否有重叠
    BOOL intersects = CGRectIntersectsRect(newFrame, winBounds);
    
    return !self.isHidden && self.alpha > 0.01 && self.window == keyWindow && intersects;
}

/// 设置四角都一样圆角的view
/// @param radius radius
- (void)cmp_setCornerRadius:(CGFloat)radius {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = radius;
}

/// 设置成圆形
- (void)cmp_setRoundView {
    [self cmp_setCornerRadius:self.height/2.f];
}

/// 设置顶部两角为圆角的view
/// @param cornerRadius radius
/// @param bgColor 背景颜色
- (CAShapeLayer *)cmp_setTopCornerWithRadius:(CGFloat)cornerRadius bgColor:(UIColor *)bgColor {
    CAShapeLayer *layer = CAShapeLayer.layer;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    layer.path = path.CGPath;
    layer.fillColor = bgColor.CGColor;
    [self.layer insertSublayer:layer atIndex:0];
    return layer;
}

/// 设置底部两角为圆角的view
/// @param cornerRadius radius
/// @param bgColor 背景颜色
- (CAShapeLayer *)cmp_setBottomCornerWithRadius:(CGFloat)cornerRadius bgColor:(UIColor *)bgColor {
    CAShapeLayer *layer = CAShapeLayer.layer;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    layer.path = path.CGPath;
    layer.fillColor = bgColor.CGColor;
    [self.layer insertSublayer:layer atIndex:0];
    return layer;
}

/// 设置底部四角为圆角的view
/// @param cornerRadius radius
/// @param bgColor 背景颜色
- (CAShapeLayer *)cmp_setRoundCornerWithRadius:(CGFloat)cornerRadius bgColor:(UIColor *)bgColor {
    CAShapeLayer *layer = CAShapeLayer.layer;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:cornerRadius];
    layer.path = path.CGPath;
    layer.fillColor = bgColor.CGColor;
    [self.layer insertSublayer:layer atIndex:0];
    return layer;
}

- (void)cmp_setBorderWithColor:(UIColor *)color {
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = 0.5f;
    self.layer.masksToBounds = YES;
}


-(void)cmp_addSubview:(UIView *)view
{
    //ks fix 为了处理Xcode12后 cell直接添加subview无法点击的问题
    if ([self isKindOfClass:[UITableViewCell class]]) {
        if (view && ![view isEqual:((UITableViewCell *)self).contentView]) {
            [((UITableViewCell *)self).contentView cmp_addSubview:view];
            return;
        }
    }
    [self cmp_addSubview:view];
}

@end
