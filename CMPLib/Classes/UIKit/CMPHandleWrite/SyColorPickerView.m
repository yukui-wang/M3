//
//  SyColorPickerView.m
//  SyCanvasViewTest
//
//  Created by admin on 12-4-16.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//


#import "SyColorPickerView.h"

@interface SyColorPickerView () {
    CGSize _visableSize;
    CGSize _colorViewSize; 
    CGFloat _space;
}
@end

@implementation SyColorPickerView
@synthesize colors = colors_;
@synthesize delegate = delegate_;
@synthesize colorViews = colorViews_;
@synthesize currentColorImgName = currentColorImgName_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *aImage = [UIImage imageNamed:@"CMPHandleWrite.bundle/bg_pen_color.png"];
        _visableSize = CGSizeMake(214, 104);
        if (aImage) {
            _visableSize = aImage.size;
        }
        _colorViewSize = CGSizeMake(60, 60);
        CGRect bgFrame = CGRectZero;
        bgFrame.size = _visableSize;
        backgroundImg_ = [[UIImageView alloc] initWithFrame:bgFrame];
        backgroundImg_.image = aImage;
        [self insertSubview:backgroundImg_ atIndex:0];
        [self createColorViews];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    frame.size = _visableSize;
    [super setFrame:frame];
}

- (NSString *)setCurrentColor:(UIColor *)currentColor
{
    NSString *cColorStr =[self getColorString:currentColor];
    if ([cColorStr isEqualToString:[self getColorString:[UIColor blueColor]]]) {
        self.currentColorImgName = @"CMPHandleWrite.bundle/ic_pen_color_blue.png";
    }
    else if ([cColorStr isEqualToString:[self getColorString:[UIColor redColor]]]) {
        self.currentColorImgName = @"CMPHandleWrite.bundle/ic_pen_color_red.png";
    }
    else {
        self.currentColorImgName = @"CMPHandleWrite.bundle/ic_pen_color_black.png";
    }
    [currentColor_ release];
    currentColor_ = [currentColor retain];
    [self refreshColorViews];
    return self.currentColorImgName;
}

- (void)dealloc 
{
    [backgroundImg_ release];
    backgroundImg_ = nil;
    
    [colors_ release];
    colors_ = nil;
    
    [currentColor_ release];
    currentColor_ = nil;
    
    self.colorViews = nil;
    self.currentColorImgName = nil;
    
    [super dealloc];
}

- (void)createColorViews
{
    self.colors = [NSArray arrayWithObjects:\
                   [UIColor redColor],\
                   [UIColor blackColor],\
                   [UIColor blueColor], nil];
    NSArray *imgs = [NSArray arrayWithObjects:@"CMPHandleWrite.bundle/ic_color_red.png", @"CMPHandleWrite.bundle/ic_color_black.png", @"CMPHandleWrite.bundle/ic_color_blue.png", nil];
    CGFloat aStartY = _visableSize.height/2 - _colorViewSize.height/2 - 10;
    _space = (_visableSize.width - _colorViewSize.width*3)/4;
    CGFloat aStartX = _space;
    int i = 0;
    for (UIView *aView in self.colorViews) {
        [aView removeFromSuperview];
    }
    self.colorViews = [NSMutableArray arrayWithCapacity:0];
    
    for (UIColor *aColor in self.colors) 
    {
        CGRect aFrame = CGRectZero;
        aFrame.origin.x = aStartX;
        aFrame.origin.y = aStartY;
        aFrame.size = _colorViewSize;
        SyColorView *aView = [[SyColorView alloc] initWithFrame:aFrame];
        aView.delegate = self;
        aView.color = aColor;
        [aView setBackgroundImage:[imgs objectAtIndex:i]];
        [self addSubview:aView];
        [self.colorViews addObject:aView];
        [aView release];
        
        aStartX += _colorViewSize.width;
        aStartX += _space;
        i ++;
    }
}

- (void)refreshColorViews
{
    for (SyColorView *colorView in self.colorViews) {
        colorView.isCurrentColor = [self.currentColorImgName isEqualToString:colorView.colorImgName];
    }
}

- (void)didSelectedColor:(UIColor *)aColor colorImgName:(NSString *)imgName
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(colorPickerView:didSelectedColor:colorImgName:)] ) {
        self.currentColor = aColor;
        [self refreshColorViews];
        [self.delegate colorPickerView:self didSelectedColor:aColor colorImgName:self.currentColorImgName];
    }
}

- (NSString *)getColorString:(UIColor *)aColor 
{
    const CGFloat *components = CGColorGetComponents(aColor.CGColor);
    NSString *colorAsString = [NSString stringWithFormat:@"%f,%f,%f,%f", components[0], \
                               components[1], components[2], components[3]];
    return colorAsString;
}

@end

@implementation SyColorView
@synthesize delegate = delegate_;
@synthesize color = color_;
@synthesize isCurrentColor = isCurrentColor_;
@synthesize colorImgName = colorImgName_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect imgFrame = CGRectZero;
        CGSize aSize = CGSizeMake(35, 35);
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            aSize = CGSizeMake(50, 50);
        }
        imgFrame.size = aSize;
        colorImgView_  = [[UIImageView alloc] initWithFrame:imgFrame];
        [self addSubview:colorImgView_];
    }
    return self;
}

- (void)layoutSubviews
{
    CGRect f = colorImgView_.frame;
    f.origin.x = self.frame.size.width/2 - f.size.width/2;
    f.origin.y = self.frame.size.height/2 - f.size.height/2;
    colorImgView_.frame = f;
}

- (void)setBackgroundImage:(NSString *)aImgName
{
    self.colorImgName = aImgName;
    colorImgView_.image = [UIImage imageNamed:aImgName];
}

- (void)setIsCurrentColor:(BOOL)isCurrentColor
{
    isCurrentColor_ = isCurrentColor;
    if (self.isCurrentColor) {
        if (!bgImgView_) {
//            CGRect imgFrame = CGRectMake(0, 0, 54, 54);
//            bgImgView_ = [[UIImageView alloc] initWithFrame:imgFrame];
        }
//        [self insertSubview:bgImgView_ atIndex:0];
//        bgImgView_.image = [UIImage imageNamed:@"colorBK.png"];
    }
    else {
        [bgImgView_ removeFromSuperview];
        [bgImgView_ release];
        bgImgView_ = nil;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedColor:colorImgName:)] )  
    {
        [self.delegate didSelectedColor:self.color colorImgName:self.colorImgName];
    }
}

- (void)dealloc
{
    [color_ release];
    [colorImgView_ release];
    [bgImgView_ release];
    
    color_ = nil;
    colorImgView_ = nil;
    bgImgView_ = nil;
    
    [colorImgName_ release];
    colorImgName_ = nil;
    
    [super dealloc];
}

@end
