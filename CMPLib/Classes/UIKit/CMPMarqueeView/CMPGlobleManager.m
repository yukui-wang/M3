//
//  SyGlobleManager.m
//  WeiboUI
//
//  Created by weitong on 12-7-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CMPGlobleManager.h"
#import "CMPMarqueeView.h"
#import "CMPModalView.h"

@implementation CMPGlobleManager

@synthesize globeMarqueeView = _globeMarqueeView;
static CMPGlobleManager *instance = nil;

- (void)initGlobleManager {
    
}

+ (CMPGlobleManager*)sharedSyGlobleManager
{
    if (instance == nil) {
        instance = [[super allocWithZone:NULL] init];
        [instance initGlobleManager];
    }
    return instance;
}
+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedSyGlobleManager] retain];
}
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}
- (id)retain
{
    return self;
}
- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}
- (oneway void)release
{
    
}
- (id)autorelease
{
    return self;
}
- (void)dealloc {
    SY_RELEASE_SAFELY(_globeMarqueeView);
    [super dealloc];
}

#pragma mark 更新提示
- (void)pushMarqueeView:(NSString *)text autoHide:(BOOL)aAutoHide animated:(BOOL)aAnimated immediately:(BOOL)aImmediately
{
    if (!text || ![text isKindOfClass:[NSString class]]  || text.length == 0) {
        return;
    }
    if (!_globeMarqueeView) {
        _globeMarqueeView = [[CMPMarqueeView alloc] initWithFrame:CGRectZero];
        [[CMPGlobleManager mainWindow] addSubview:_globeMarqueeView];
        _globeMarqueeView.alpha = 1.0;
    }
    if (_globeMarqueeView) {
        [_globeMarqueeView removeFromSuperview];
        [[CMPGlobleManager mainWindow] addSubview:_globeMarqueeView];
        [[CMPGlobleManager mainWindow] bringSubviewToFront:_globeMarqueeView];
        [_globeMarqueeView pop:text autoHide:aAutoHide animated:aAnimated immediately:aImmediately];
    }
}

- (void)pushMarqueeView:(NSString *)text
{
    [self pushMarqueeView:text autoHide:YES animated:YES immediately:YES];
}

- (void)pushMarqueeViewDelay:(NSString *)text
{
    [self pushMarqueeView:text autoHide:YES animated:YES immediately:NO];
}

- (void)pushMarqueeView:(NSString *)text autoHide:(BOOL)aAutoHide animated:(BOOL)aAnimated
{
    [self pushMarqueeView:text autoHide:aAutoHide animated:aAnimated immediately:YES];
}

- (void)setPopMarqueeViewEnable:(BOOL)enable
{
    if (!_globeMarqueeView) {
        _globeMarqueeView = [[CMPMarqueeView alloc] initWithFrame:CGRectZero];
        //        [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:_globeMarqueeView];
        _globeMarqueeView.alpha = 1.0;
    }
    _globeMarqueeView.disablePop = !enable;
}

- (void)dismissMarqueeView:(BOOL)animated
{
    [_globeMarqueeView dismiss:animated];
}

//  显示模态窗体
- (void)popModalViewWithContentView:(UIView *)aContentView autoHide:(BOOL)autoHide
{
    if (!_modalView) {
        _modalView = [[CMPModalView alloc] initWithFrame:CGRectMake(0, 0, [UIView mainScreenSize].width, [UIView mainScreenSize].height )];
        [[CMPGlobleManager mainWindow] addSubview:_modalView];
        NSLog(@"_modalView.frame:%@",NSStringFromCGRect(_modalView.frame));
    }
    if (_modalView) {
        [[CMPGlobleManager mainWindow] bringSubviewToFront:_modalView];
        [_modalView popWithContentView:aContentView autoHide:autoHide];
    }
}

- (void)presentView:(UIView *)aView fromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated
{
    if (!_modalView) {
        _modalView = [[CMPModalView alloc] initWithFrame:CGRectMake(0, 0, [UIView mainScreenSize].width, [UIView mainScreenSize].height )];
        [[CMPGlobleManager mainWindow] addSubview:_modalView];
    }
    if (_modalView) {
        [[CMPGlobleManager mainWindow] bringSubviewToFront:_modalView];
        [_modalView presentView:aView fromRect:rect inView:view animated:animated autoHide:YES];
    }
}


- (void)dismissModalView:(BOOL)animated {
    [_modalView.contentView removeFromSuperview];
    [_modalView removeFromSuperview];
    SY_RELEASE_SAFELY(_modalView);
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_DismissModalView object:nil];
}

+ (UIWindow *)mainWindow {
    return [[[UIApplication sharedApplication] delegate] window];
}

@end
