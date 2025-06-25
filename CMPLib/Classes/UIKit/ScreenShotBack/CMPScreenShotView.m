

//
//  CMPScreenShotView.m
//  CMPScreenShotView
//
//  Created by 郑文明 on 16/5/10.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import "CMPScreenShotView.h"

@implementation CMPScreenShotView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        _imgView = [[UIImageView alloc] initWithFrame:self.bounds];
        
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
//        _maskView.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.4];
        _maskView.backgroundColor = [UIColor clearColor];
        [self addSubview:_imgView];
        [self addSubview:_maskView];
    }
    return self;
}

- (void)showEffectChange:(CGPoint)pt
{
//    NSLog(@"x=%f,y=%f", pt.x, pt.y);
    if (pt.x > 0) {
        _maskView.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:-pt.x / 320.0 * 0.4 + 0.4];
        _imgView.transform = CGAffineTransformMakeScale(0.95 + (pt.x / 320.0 * 0.05), 0.95 + (pt.x / 320.0 * 0.05));
    }
}

- (void)restore
{
    if (_maskView && _imgView) {
        //_maskView.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.4];
         _maskView.backgroundColor = [UIColor clearColor];
        _imgView.transform = CGAffineTransformMakeScale(0.95, 0.95);
    }
}

- (void)setNoneEffect
{
    //_maskView.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0];
    _maskView.backgroundColor = [UIColor clearColor];
    _imgView.transform = CGAffineTransformIdentity;
}

- (void)dealloc
{
    [_imgView removeFromSuperview];
    [_imgView release];
    _imgView = nil;
    
    [_maskView removeFromSuperview];
    [_maskView release];
    _maskView = nil;
    
    [super dealloc];
}

@end
