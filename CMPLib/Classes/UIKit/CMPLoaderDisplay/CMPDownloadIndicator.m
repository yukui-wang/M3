//
//  CMPDownloadIndicator.m
//  BezierLoaders
//
//  Created by Mahesh on 1/30/14.
//  Copyright (c) 2014 Mahesh. All rights reserved.
//

#import "CMPDownloadIndicator.h"
#import "CMPDisplayLabel.h"

@interface CMPDownloadIndicator()

// this contains list of paths to be animated through
@property(nonatomic, strong)NSMutableArray *paths;

// the shaper layers used for display
@property(nonatomic, strong)CAShapeLayer *indicateShapeLayer;
@property(nonatomic, strong)CAShapeLayer *coverLayer;

// this is the layer used for animation
@property(nonatomic, strong)CAShapeLayer *animatingLayer;

// the type of indicator
@property(nonatomic, assign)CMPIndicatorType type;

// this applies to the covering stroke (default: 2)
@property(nonatomic, assign)CGFloat coverWidth;

// the last updatedPath
@property(nonatomic, strong)UIBezierPath *lastUpdatedPath;
@property(nonatomic, assign)CGFloat lastSourceAngle;

// this the animation duration (default: 0.5)
@property(nonatomic, assign)CGFloat animationDuration;


// this is display label that displays % downloaded
@property(nonatomic, strong)CMPDisplayLabel *displayLabel;

@end

@implementation CMPDownloadIndicator

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _type = kCMPFilledIndicator;
        [self initAttributes];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame type:(CMPIndicatorType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _type = type;
        [self initAttributes];
    }
    return self;
}

- (void)initAttributes
{
    // first set the radius percent attribute
    if(_type == kCMPClosedIndicator)
    {
        self.radiusPercent = 0.5;
        _coverLayer = [CAShapeLayer layer];
        _animatingLayer = _coverLayer;
        
        // set the fill color
        _fillColor = [UIColor clearColor];
        _strokeColor = [UIColor whiteColor];
        _closedIndicatorBackgroundStrokeColor = [UIColor grayColor];
        _coverWidth = 2.0;
        
        //[self addDisplayLabel];
    }
    else
    {
        if(_type == kCMPFilledIndicator)
        {
            // only indicateShapeLayer
            _indicateShapeLayer = [CAShapeLayer layer];
            _animatingLayer = _indicateShapeLayer;
            self.radiusPercent = 0.5;
            _coverWidth = 2.0;
            _closedIndicatorBackgroundStrokeColor = [UIColor clearColor];
        }
        else
        {
            // indicateShapeLayer and coverLayer
            _indicateShapeLayer = [CAShapeLayer layer];
            _coverLayer = [CAShapeLayer layer];
            _animatingLayer = _indicateShapeLayer;
            _coverWidth = 2.0;
            self.radiusPercent = 0.4;
            _closedIndicatorBackgroundStrokeColor = [UIColor whiteColor];
        }
        
        // set the fill color
        _fillColor = [UIColor whiteColor];
        _strokeColor = [UIColor whiteColor];
    }
    
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2].CGColor;
    CGFloat lineWidth = 1;
    layer.frame = CGRectMake(-lineWidth, -lineWidth, self.bounds.size.width + 2,  self.bounds.size.width + 2);
    layer.masksToBounds = YES;
    layer.cornerRadius = layer.frame.size.width * 0.5;
    [self.layer addSublayer:layer];
    
    _animatingLayer.frame = self.bounds;
    [self.layer addSublayer:_animatingLayer];
    
    // path array
    _paths = [NSMutableArray array];
    
    // animation duration
    _animationDuration = 0.5;
}

- (void)addDisplayLabel
{
    self.displayLabel = [[CMPDisplayLabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds)/2 - 30/2), (CGRectGetHeight(self.bounds)/2 - 30/2), 30, 30)];
    self.displayLabel.backgroundColor = [UIColor clearColor];
    self.displayLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11.5];
    self.displayLabel.text = @"0";
    self.displayLabel.textColor = [UIColor grayColor];
    self.displayLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.displayLabel];
}

- (void)loadIndicator
{
    // set the initial Path
    CGPoint center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
    UIBezierPath *initialPath = [UIBezierPath bezierPath]; //empty path
    
    if(_type == kCMPClosedIndicator)
    {
        [initialPath addArcWithCenter:center radius:(MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))) startAngle:degreeToRadian(-90) endAngle:degreeToRadian(-90) clockwise:YES]; //add the arc
    }
    else
    {
        if(_type == kCMPMixedIndicator)
        {
            [self setNeedsDisplay];
        }
        CGFloat radius = (MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))/2) * self.radiusPercent;
        [initialPath addArcWithCenter:center radius:radius startAngle:degreeToRadian(-90) endAngle:degreeToRadian(-90) clockwise:YES]; //add the arc
    }
    
    _animatingLayer.path = initialPath.CGPath;
    _animatingLayer.strokeColor = _strokeColor.CGColor;
    _animatingLayer.fillColor = _fillColor.CGColor;
    _animatingLayer.lineWidth = _coverWidth;
    self.lastSourceAngle = degreeToRadian(-90);
}

#pragma mark -
#pragma mark Helper Methods
- (NSArray *)keyframePathsWithDuration:(CGFloat)duration lastUpdatedAngle:(CGFloat)lastUpdatedAngle newAngle:(CGFloat)newAngle radius:(CGFloat)radius type:(CMPIndicatorType)type
{
    NSUInteger frameCount = ceil(duration * 60);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:frameCount + 1];
    for (int frame = 0; frame <= frameCount; frame++)
    {
        CGFloat startAngle = degreeToRadian(-90);
        CGFloat endAngle = lastUpdatedAngle + (((newAngle - lastUpdatedAngle) * frame) / frameCount);
        
        [array addObject:(id)([self pathWithStartAngle:startAngle endAngle:endAngle radius:radius type:type].CGPath)];
    }
    
    return [NSArray arrayWithArray:array];
}

- (UIBezierPath *)pathWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle radius:(CGFloat)radius type:(CMPIndicatorType)type
{
    BOOL clockwise = startAngle < endAngle;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
    
    if(type == kCMPClosedIndicator)
    {
        [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:clockwise];
    }
    else
    {
        [path moveToPoint:center];
        [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:clockwise];
        [path closePath];
    }
    return path;
}

- (void)drawRect:(CGRect)rect
{
    if(_type == kCMPMixedIndicator || _type == kCMPClosedIndicator)
    {
        CGFloat radius = (MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) / 2) - self.coverWidth;
        CGPoint center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
        
        UIBezierPath *coverPath = [UIBezierPath bezierPath]; //empty path
        [coverPath setLineWidth:_coverWidth];
        [coverPath addArcWithCenter:center radius:radius startAngle:0 endAngle:2 * M_PI clockwise:YES]; //add the arc
        [_closedIndicatorBackgroundStrokeColor set];
        [coverPath stroke];
    }
}

#pragma mark - update indicator
- (void)updateWithTotalBytes:(CGFloat)bytes downloadedBytes:(CGFloat)downloadedBytes
{
    _lastUpdatedPath = [UIBezierPath bezierPathWithCGPath:_animatingLayer.path];
    
    [_paths removeAllObjects];
    
    CGFloat destinationAngle = [self destinationAngleForRatio:(downloadedBytes/bytes)];
    CGFloat radius = (MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) * _radiusPercent) - self.coverWidth;
    [_paths addObjectsFromArray:[self keyframePathsWithDuration:self.animationDuration lastUpdatedAngle:self.lastSourceAngle newAngle:destinationAngle  radius:radius type:_type]];
    
    _animatingLayer.path = (__bridge CGPathRef)((id)_paths[(_paths.count -1)]);
    self.lastSourceAngle = destinationAngle;
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    [pathAnimation setValues:_paths];
    [pathAnimation setDuration:self.animationDuration];
    [pathAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [pathAnimation setRemovedOnCompletion:YES];
    [_animatingLayer addAnimation:pathAnimation forKey:@"path"];
    
    //[self.displayLabel updateValue:downloadedBytes/bytes];
}

- (CGFloat)destinationAngleForRatio:(CGFloat)ratio
{
    return (degreeToRadian((360*ratio) - 90));
}

float degreeToRadian(float degree)
{
    return ((degree * M_PI)/180.0f);
}

#pragma mark -
#pragma mark Setter Methods
- (void)setFillColor:(UIColor *)fillColor
{
    if(_type == kCMPClosedIndicator)
        _fillColor = [UIColor clearColor];
    else
        _fillColor = fillColor;
}

- (void)setRadiusPercent:(CGFloat)radiusPercent
{
    if(_type == kCMPClosedIndicator)
    {
        _radiusPercent = 0.5;
        return;
    }
    
    if(radiusPercent > 0.5 || radiusPercent < 0)
        return;
    else
        _radiusPercent = radiusPercent;
        
}

- (void)setIndicatorAnimationDuration:(CGFloat)duration
{
    self.animationDuration = duration;
}

@end
