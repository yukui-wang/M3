//
//  SyMarqueeView.m
//  WeiboUI
//
//  Created by weitong on 12-7-9. edit by guoyl for ipad and iphone
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CMPMarqueeView.h"
#import "CMPConstant.h"
#import "NSString+CMPString.h"

#define kSyMarqueePaddingTopStart 0
#define kSyMarqueePaddingLeft 0
#define kSyMarqueePaddingRight 0

#define kSyMarqueePaddingTopStart 0
#define kSyMarqueePaddingLeft 0
#define kSyMarqueePaddingRight 0

@interface CMPMarqueeView ()<UIAlertViewDelegate> {
    NSMutableArray *_popStack;
    BOOL _animated;
    BOOL _hadShowAlertView;
}

- (CGSize)marqueeSize;
- (void)setStartFrameWithInterfaceOrientation:(UIInterfaceOrientation)orientation;
- (void)setEndFrameWithInterfaceOrientation:(UIInterfaceOrientation)orientation;
- (void)onAnimationStop;
- (void)dismissAnimationStop;
- (void)popFromStack;
- (void)pop:(NSString *)text autoHide:(BOOL)autoHide animated:(BOOL)aAnimated;
- (void)setTextLableText:(NSString*)text;

@end

@implementation CMPMarqueeView
@synthesize backgroundImageView = _backgroundImageView;
@synthesize textLable = _textLable;
@synthesize disablePop = _disablePop;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CGSize)marqueeSize
{
    return INTERFACE_IS_PAD ? CGSizeMake(700, 65) : CGSizeMake(320, 65);
}

- (id)initWithFrame:(CGRect)frame
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willChangeStatusBarOrientation:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizesSubviews = NO;
        _popStack = [[NSMutableArray alloc] init];
        _showing = NO;
        if (!_backgroundImageView) {
            CGFloat h = [self marqueeSize].height;
            _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kSyMarqueePaddingLeft, 0, frame.size.width, h)];
            //            UIImage *aImg = [[UIImage imageNamed:@"marquee.png"] stretchableImageWithCapInsets:UIEdgeInsetsMake(10, 2, 15, 2)];
            //            [_backgroundImageView setImage:aImg];
            _backgroundImageView.backgroundColor = [UIColor blackColor];
            _backgroundImageView.alpha = .7;
            [self addSubview:_backgroundImageView];
            _backgroundImageView.clipsToBounds = YES;
        }
        
        if (!_textLable) {
            CGFloat height = [FONT_CONTENT lineHeight];
            _textLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, height, 0)];
            _textLable.backgroundColor = [UIColor clearColor];
            _textLable.textAlignment = NSTextAlignmentCenter;
            _textLable.font = FONT_CONTENT;
            _textLable.textColor = [UIColor whiteColor];
            [self addSubview:_textLable];
        }
        if (!_closeButton) {
            _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            if (INTERFACE_IS_PAD) {
                [_closeButton setFrame:CGRectMake(self.frame.size.width -42,(self.frame.size.height-22)/2 + 20 ,22,22)];
                [_closeButton setBackgroundImage:[UIImage imageNamed:@"marquee_close.png"] forState:UIControlStateNormal];
            }
            else {
                [_closeButton setFrame:CGRectMake(self.frame.size.width -21,(self.frame.size.height-11)/2 + 20 ,11,11)];
                [_closeButton setBackgroundImage:[UIImage imageNamed:@"marquee_close.png"] forState:UIControlStateNormal];
            }
            
            [_closeButton addTarget:self
                             action:@selector(dismiss:)
                   forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_closeButton];
        }
        self.hidden = YES;
        _hadShowAlertView = NO;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)setStartFrameWithInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    CGFloat angle = 0.0;
    CGRect newFrame = CGRectZero;
    CGFloat statusHeight = 0.0f;//[UIView statusBarHeight];
    CGSize mainSize = [UIView mainScreenSize];
    CGSize marqueeSize = self.marqueeSize;
    CGFloat marqueeWidth = mainSize.width;
    CGFloat t = mainSize.height;
    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            angle = M_PI;
            newFrame = CGRectMake(mainSize.width/2 - marqueeWidth/2, mainSize.height + marqueeSize.height - statusHeight, marqueeWidth, marqueeSize.height);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            if(IOS8_Later){
                newFrame = CGRectMake(mainSize.width/2 - marqueeWidth/2, -marqueeSize.height + statusHeight, marqueeWidth, marqueeSize.height);
            }else{
                mainSize.height = mainSize.width;
                mainSize.width = t;
                marqueeWidth = mainSize.width;
                angle = - M_PI / 2.0f;
                newFrame = CGRectMake(-marqueeSize.height + statusHeight, mainSize.width/2 - marqueeWidth/2, marqueeSize.height, marqueeWidth);
            }
            break;
        case UIInterfaceOrientationLandscapeRight:
            if (IOS8_Later) {
                newFrame = CGRectMake(mainSize.width/2 - marqueeWidth/2, -marqueeSize.height + statusHeight, marqueeWidth, marqueeSize.height);
            }else{
                mainSize.height = mainSize.width;
                mainSize.width = t;
                marqueeWidth = mainSize.width;
                angle = M_PI / 2.0f;
                newFrame = CGRectMake(mainSize.height + marqueeSize.height - statusHeight, mainSize.width/2 - marqueeWidth/2, marqueeSize.height, marqueeWidth);
            }
            
            break;
        default:
            angle = 0.0;
            newFrame = CGRectMake(mainSize.width/2 - marqueeWidth/2, -marqueeSize.height + statusHeight, marqueeWidth, marqueeSize.height);
            break;
    }
    
    self.transform = CGAffineTransformMakeRotation(angle);
    self.frame = newFrame;
}

- (void)layoutSubviews
{
    CGFloat marqueeHeight = self.marqueeSize.height;
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    CGFloat width = MAX(w, h);
    UIFont *aFont = nil;
    CGFloat height = 0.0f;
    NSInteger intY ;
    CGFloat statusBarHeight = 0;
    if (IOS7_Later) {
        statusBarHeight = 20;
    }
    if (INTERFACE_IS_PAD) {
        aFont = FONT_PROFILE;
        intY = (marqueeHeight-statusBarHeight)/2;
        [_closeButton setFrame:CGRectMake(width -42, intY - 11+statusBarHeight, 22, 22)];
    }
    else {
        aFont = FONT_CONTENT;
        intY = (marqueeHeight-statusBarHeight)/2;
        [_closeButton setFrame:CGRectMake(width -30, intY -11+statusBarHeight, 22, 22)];
    }
    height = [aFont lineHeight];
    _textLable.font = aFont;
    intY = (marqueeHeight+statusBarHeight - height)/2;
    //根据字符串长度设置label宽度
    CGSize vTextSize = [_textLable.text sizeWithFontSize:_textLable.font defaultSize:CGSizeMake(width-60, height+1)];

    [_textLable setFrame:CGRectMake(30,intY, vTextSize.width + 20, height)];
    //设置居中
    CGPoint vCenterPoint = _textLable.center;
    vCenterPoint.x = width/2.0;
    _textLable.center = vCenterPoint;
    //重新设置closeButton位置
    if (INTERFACE_IS_PAD) {
        //        aFont = FONT_PROFILE;
        intY = (marqueeHeight-statusBarHeight)/2;
        [_closeButton setFrame:CGRectMake(CGRectGetMaxX(_textLable.frame)+ 15, intY - 11+statusBarHeight, 22, 22)];
    }
    
    [_backgroundImageView setFrame:CGRectMake(0, 0, width, _backgroundImageView.height)];
}

- (void)setEndFrameWithInterfaceOrientation:(UIInterfaceOrientation)orientation;
{
    CGFloat angle = 0.0;
    CGRect newFrame = CGRectZero;
    CGFloat statusHeight = 0.0f;//[UIView staticStatusBarHeight];
    CGSize mainSize = [UIView mainScreenSize];
    CGSize marqueeSize = self.marqueeSize;
    CGFloat marqueeWidth = mainSize.width;
    CGFloat t = mainSize.height;
    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            angle = M_PI;
            newFrame = CGRectMake(mainSize.width/2 - marqueeWidth/2, mainSize.height - statusHeight - marqueeSize.height, marqueeWidth, marqueeSize.height);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            if (IOS8_Later) {
                newFrame = CGRectMake(mainSize.width/2 - marqueeWidth/2,statusHeight , marqueeWidth, marqueeSize.height);
            }else{
                mainSize.height = mainSize.width;
                mainSize.width = t;
                marqueeWidth = mainSize.width;
                angle = - M_PI / 2.0f;
                newFrame = CGRectMake(statusHeight, mainSize.width/2 - marqueeWidth/2, marqueeSize.height, marqueeWidth);
            }
            break;
        case UIInterfaceOrientationLandscapeRight:
            if (IOS8_Later) {
                newFrame = CGRectMake(mainSize.width/2 - marqueeWidth/2,statusHeight ,marqueeWidth, marqueeSize.height);
            }else{
                mainSize.height = mainSize.width;
                mainSize.width = t;
                marqueeWidth = mainSize.width;
                angle = M_PI / 2.0f;
                newFrame = CGRectMake(mainSize.height - statusHeight - marqueeSize.height, mainSize.width/2 - marqueeWidth/2, marqueeSize.height, marqueeWidth);
            }
            break;
        default:
            angle = 0.0;
            newFrame = CGRectMake(mainSize.width/2 - marqueeWidth/2, statusHeight, marqueeWidth, marqueeSize.height);
            break;
    }
    self.transform = CGAffineTransformMakeRotation(angle);
    self.frame = newFrame;
}

- (void)setTextLableText:(NSString*)text
{
    _textLable.text = text;
    [self layoutSubviews];
}

- (void)pop:(NSString *)text autoHide:(BOOL)autoHide animated:(BOOL)aAnimated immediately:(BOOL)aImmediate
{
    if (aImmediate) {
        [self pop:text autoHide:autoHide animated:aAnimated];
        return;
    }
    NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:text, @"text", [NSNumber numberWithBool:autoHide], @"autoHide", [NSNumber numberWithBool:aAnimated], @"animated", nil];
    [_popStack addObject:aDict];
    [self popFromStack];
}

- (void)pop:(NSString *)text autoHide:(BOOL)autoHide animated:(BOOL)aAnimated
{
   /* if ([NSString textLength:text] > 19) {
        if (_hadShowAlertView) {
            return;
        }
        _hadShowAlertView = YES;
        UIAlertView *vAlertView = [[UIAlertView alloc] initWithTitle:SY_STRING(@"common_prompt") message:text delegate:self cancelButtonTitle:SY_STRING(@"common_ok") otherButtonTitles:nil, nil];
        [vAlertView show];
        [vAlertView release];
        return;
    }*/
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    self.hidden = NO;
    _autoHide = autoHide;
    _showing = YES;
    _animated = aAnimated;
    self.alpha = 1.0;
    [self setStartFrameWithInterfaceOrientation:orientation];
    [self setTextLableText:text];
    if (aAnimated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
        if (autoHide) {
            [UIView setAnimationDidStopSelector:@selector(onAnimationStop)];
        }
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [self setEndFrameWithInterfaceOrientation:orientation];
        [UIView commitAnimations];
    }
    else {
        [self setEndFrameWithInterfaceOrientation:orientation];
        [self onAnimationStop];
    }
}

- (void)popFromStack
{
    if (_popStack.count == 0 || self.disablePop || _showing) {
        return;
    }
    NSDictionary *aDict = [_popStack objectAtIndex:0];
    NSString *text = [aDict objectForKey:@"text"];
    BOOL autoHide = [[aDict objectForKey:@"autoHide"] boolValue];
    BOOL aAnimated = [[aDict objectForKey:@"animated"] boolValue];
    [self pop:text autoHide:autoHide animated:aAnimated];
}

- (void)popInternalWithInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    [self setStartFrameWithInterfaceOrientation:orientation];
    
    self.hidden = NO;
    self.alpha = 1.0;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    if (_autoHide) {
        [UIView setAnimationDidStopSelector:@selector(onAnimationStop)];
    }
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [self setEndFrameWithInterfaceOrientation:orientation];
    self.alpha = 1.0;
    [UIView commitAnimations];
}

- (void)dismiss:(BOOL)animated
{
    _animated = animated;
    if (_animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(dismissAnimationStop)];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [self setStartFrameWithInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        [UIView commitAnimations];
    }
    else {
        [self setStartFrameWithInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        [self dismissAnimationStop];
    }
}

- (void)dismissInternal
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.hidden = YES;
}

- (void)onAnimationStop
{
    [self performSelector:@selector(dismiss:) withObject:nil afterDelay:3];
}

- (void)dismissAnimationStop
{
    _showing = NO;
    if (!_disablePop) {
        if (_popStack.count > 0) {
            [_popStack removeObjectAtIndex:0];
        }
        if (_popStack.count > 0) {
            [self popFromStack];
            return;
        }
    }
    _textLable.text = nil;
    self.hidden = YES;
    [self removeFromSuperview];
}

- (void)willChangeStatusBarOrientation:(NSNotification *)notification
{
    if (_showing) {
        [self dismissInternal];
    }
}

- (void)didChangeStatusBarOrientation:(NSNotification *)notification
{
    if (_showing) {
        UIInterfaceOrientation aOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        [self popInternalWithInterfaceOrientation:aOrientation];
    }
}

- (void)setDisablePop:(BOOL)disablePop
{
    _disablePop = disablePop;
    if (!disablePop) {
        [self popFromStack];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _hadShowAlertView = NO;
}

@end
