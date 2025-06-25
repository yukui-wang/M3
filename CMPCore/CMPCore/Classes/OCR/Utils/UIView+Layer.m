#import "UIView+Layer.h"

@implementation UIView (Layer)


/**
 1.view.clipsToBounds=YES时，阴影效果不起效。将clipsToBounds设为NO即可
 2.view.backgroundColor为clearcolor透明色时，阴影会内附在view内部的控件上。或者字体上。阴影需要取色，然后计算和绘制阴影。所以最好设置view的backgroundColor，阴影就恢复正常。
 */
- (void)setLayerShadowRadius:(CGFloat)radius
                       color:(UIColor *)color
                      offset:(CGSize)size
                     opacity:(CGFloat)opacity{
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowRadius = radius;//阴影半径
    self.layer.shadowOffset = size;//width负右 height负上
    self.layer.shadowOpacity = opacity;//透明度
}
- (void)addRoundedCorners:(UIRectCorner)corners
                   radii:(CGSize)radii
                     rect:(CGRect)rect
{
    CGRect newRect = CGRectIsNull(rect) ? self.bounds : rect;
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:newRect
                                                  byRoundingCorners:corners
                                                        cornerRadii:radii];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    self.layer.mask = shape;
}


#define ik_force_inline __inline__ __attribute__((always_inline))

extern ik_force_inline BOOL gIsIphoneX(void) {
    static BOOL s_isIphoneX = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ((1. * [UIScreen mainScreen].bounds.size.height
             / [UIScreen mainScreen].bounds.size.width) > 2.16) {
            s_isIphoneX = YES;
        } else if ((1. * [UIScreen mainScreen].bounds.size.width
                    / [UIScreen mainScreen].bounds.size.height) > 2.16) {
            //横屏
            s_isIphoneX = YES;
        } else {
            s_isIphoneX = NO;
        }
    });
    return s_isIphoneX;
}

extern ik_force_inline CGFloat gNavAreaHeight(void) {
    return (gIsIphoneX() ? 88 : 64);
}



extern ik_force_inline CGFloat gTabBarHeight(void) {
    return (gIsIphoneX() ? 83 : 49);
}


CGFloat const IKNavBarHeight = 44;
CGFloat const IKTabNormalHeight = 49;


//***********************  Frame  ***********************//
-(CGFloat)frameX{
    return self.frame.origin.x;
}
-(void)setFrameX:(CGFloat)frameX{
    CGRect frame = self.frame;
    frame.origin.x = frameX;
    self.frame = frame;
}

-(CGFloat)frameY{
    return self.frame.origin.y;
}
-(void)setFrameY:(CGFloat)frameY{
    CGRect frame = self.frame;
    frame.origin.y = frameY;
    self.frame = frame;
}

-(CGFloat)frameW{
    return self.frame.size.width;
}
-(void)setFrameW:(CGFloat)frameW{
    CGRect frame = self.frame;
    frame.size.width = frameW;
    self.frame = frame;
}

-(CGFloat)frameH{
    return self.frame.size.height;
}
-(void)setFrameH:(CGFloat)frameH{
    CGRect frame = self.frame;
    frame.size.height = frameH;
    self.frame = frame;
}

- (CGPoint)frameOrigin {
    return self.frame.origin;
}
- (void)setFrameOrigin:(CGPoint)frameOrigin {
    CGRect frame = self.frame;
    frame.origin = frameOrigin;
    self.frame = frame;
}
- (CGSize)frameSize {
    return self.frame.size;
}
- (void)setFrameSize:(CGSize)frameSize {
    CGRect frame = self.frame;
    frame.size = frameSize;
    self.frame = frame;
}

//***********************  Bounds  ***********************//
-(CGFloat)boundsX{
    return self.bounds.origin.x;
}
-(void)setBoundsX:(CGFloat)boundsX{
    CGRect bounds = self.bounds;
    bounds.origin.x = boundsX;
    self.bounds = bounds;
}

-(CGFloat)boundsY{
    return self.bounds.origin.y;
}
-(void)setBoundsY:(CGFloat)boundsY{
    CGRect bounds = self.bounds;
    bounds.origin.y = boundsY;
    self.bounds = bounds;
}

-(CGFloat)boundsW{
    return self.bounds.size.width;
}
-(void)setBoundsW:(CGFloat)boundsW{
    CGRect bounds = self.bounds;
    bounds.size.width = boundsW;
    self.bounds = bounds;
}

-(CGFloat)boundsH{
    return self.bounds.size.height;
}
-(void)setBoundsH:(CGFloat)boundsH{
    CGRect bounds = self.bounds;
    bounds.size.height = boundsH;
    self.bounds = bounds;
}

- (CGPoint)boundsOrigin {
    return self.bounds.origin;
}
-(void)setBoundsOrigin:(CGPoint)boundsOrigin {
    CGRect frame = self.bounds;
    frame.origin = boundsOrigin;
    self.bounds = frame;
}

- (CGSize)boundsSize {
    return self.bounds.size;
}
-(void)setBoundsSize:(CGSize)boundsSize {
    CGRect frame = self.bounds;
    frame.size = boundsSize;
    self.bounds = frame;
}

//***********************  Center  ***********************//
-(CGFloat)centerX{
    return self.center.x;
}
-(void)setCenterX:(CGFloat)centerX{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

-(CGFloat)centerY{
    return self.center.y;
}
-(void)setCenterY:(CGFloat)centerY{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

//***********************  Left  ***********************//
- (CGFloat)left {
    return self.frameX;
}
- (void)setLeft:(CGFloat)x {
    self.frameX = x;
}

//***********************  Top  ***********************//
- (CGFloat)top {
    return self.frameY;
}
- (void)setTop:(CGFloat)y {
    self.frameY = y;
}

//***********************  Right  ***********************//
- (CGFloat)right {
    return self.frameX + self.frameW;
}
- (void)setRight:(CGFloat)right {
    self.frameX = right - self.frameW;
}

//***********************  Bottom  ***********************//
- (CGFloat)bottom {
    return self.frameY + self.frameH;
}
- (void)setBottom:(CGFloat)bottom {
    self.frameY = bottom - self.frameH;
}

//***********************  Width  ***********************//
- (CGFloat)width {
    return self.frameW;
}
- (void)setWidth:(CGFloat)width {
    self.frameW = width;
}

//***********************  Height  ***********************//
- (CGFloat)height {
    return self.frameH;
}
- (void)setHeight:(CGFloat)height {
    self.frameH = height;
}

@end
