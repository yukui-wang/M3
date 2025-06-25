#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Layer)

extern CGFloat gNavAreaHeight(void);
extern CGFloat gTabBarHeight(void);
extern CGFloat const IKNavBarHeight; //44
extern CGFloat const IKTabNormalHeight; //49

#define IKNavAreaHeight gNavAreaHeight() //88
#define IKTabBarHeight gTabBarHeight() //83
#define IKNavStartY (IKNavAreaHeight - IKNavBarHeight) // 44
#define IKBottomSafeEdge (IKTabBarHeight - IKTabNormalHeight) // 34


/** Shortcut for frame.origin.x */
@property (nonatomic, assign) CGFloat frameX;
/** Shortcut for frame.origin.y */
@property (nonatomic, assign) CGFloat frameY;
/** Shortcut for frame.size.width */
@property (nonatomic, assign) CGFloat frameW;
/** Shortcut for frame.size.height */
@property (nonatomic, assign) CGFloat frameH;
/** Shortcut for frame.origin */
@property (nonatomic, assign) CGPoint frameOrigin;
/** Shortcut for frame.size */
@property (nonatomic, assign) CGSize frameSize;

/******************************************************
 * Shortcut for bounds
 */

/** Shortcut for bounds.origin.x */
@property (nonatomic, assign) CGFloat boundsX;
/** Shortcut for bounds.origin.y */
@property (nonatomic, assign) CGFloat boundsY;
/** Shortcut for bounds.size.width */
@property (nonatomic, assign) CGFloat boundsW;
/** Shortcut for bounds.size.height */
@property (nonatomic, assign) CGFloat boundsH;
/** Shortcut for bounds.origin */
@property (nonatomic, assign) CGPoint boundsOrigin;
/** Shortcut for bounds.size */
@property (nonatomic, assign) CGSize boundsSize;

/******************************************************
 * Shortcut for center
 */

/** Shortcut for center.x */
@property (nonatomic, assign) CGFloat centerX;
/** Shortcut for center.y */
@property (nonatomic, assign) CGFloat centerY;

/******************************************************
 * Shortcut like CSS
 */

/** Shortcut for frame.origin.x */
@property (nonatomic, assign) CGFloat left;
/** Shortcut for frame.origin.y */
@property (nonatomic, assign) CGFloat top;
/** Shortcut for frame.origin.x + frame.size.width */
@property (nonatomic, assign) CGFloat right;
/** Shortcut for frame.origin.y + frame.size.height */
@property (nonatomic, assign) CGFloat bottom;
/** Shortcut for frame.size.width */
@property (nonatomic, assign) CGFloat width;
/** Shortcut for frame.size.width */
@property (nonatomic, assign) CGFloat height;

- (void)setLayerShadowRadius:(CGFloat)radius
                       color:(UIColor *)color
                      offset:(CGSize)size
                     opacity:(CGFloat)opacity;

/**
 *  设置部分圆角
 *
 *  @param corners 需要设置为圆角的角
            UIRectCornerTopLeft | UIRectCornerTopRight |
            UIRectCornerBottomLeft | UIRectCornerBottomRight |
            UIRectCornerAllCorners
 *  @param radii 需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 *  @param rect  需要设置的圆角view的rect
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                    radii:(CGSize)radii
                     rect:(CGRect)rect;

@end

NS_ASSUME_NONNULL_END
