//
//  GLCursorView.m
//  SyCanvasViewTest
//
//  Created by admin on 12-4-11.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#import "GLCursorView.h"

#define kCursorViewWidth    1.5f;

@implementation GLCursorView

- (id)initWithFrame:(CGRect)frame
{
    frame.size.width = kCursorViewWidth;
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        subView_ = [[UIView alloc] initWithFrame:CGRectZero];
        subView_.backgroundColor = [UIColor blackColor];
        subView_.frame = CGRectMake(0, frame.size.height*0.33, frame.size.width, frame.size.height*0.66);
        [self addSubview:subView_];
    }
    return self;
}

- (void)dealloc {
    [subView_ removeFromSuperview];
    [subView_ release];
    [super dealloc];
}

- (void)setFrame:(CGRect)frame {
    frame.size.width = kCursorViewWidth;
    [super setFrame:frame];
}

@end
