//
//  LGUIView.m
//  LGIndexView
//
//  Created by 雨逍 on 2016/12/5.
//  Copyright © 2016年 刘干. All rights reserved.
//

#import "CMPSpellBar.h"
#import "CMPIconFont.h"
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface CMPSpellBar () {
    NSMutableArray *_labelList;
    CGFloat _labelY;
}

@end


@implementation CMPSpellBar

- (void)initLabels
{
    if (!_labelList) {
        _labelList = [[NSMutableArray alloc] init];
    }
    
    CGFloat maxh = 24;
    _labelY = 0;
    CGFloat hh = self.frame.size.height/self.indexArray.count;
    if (hh > maxh) {
        hh = maxh;
        _labelY = self.frame.size.height/2- self.indexArray.count *maxh/2;
    }
    for (int i = 0; i < self.indexArray.count; i ++) {
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, i * hh+_labelY, self.width, hh)];
        label.tag = TAG + i;
        label.textAlignment = NSTextAlignmentCenter;
        if (i == 0) {
            UIFont *iconfont = [CMPIconFont fontWithSize:14];
            label.font = iconfont;
            label.text = @"\U0000e625";
        }
        else {
            label.text = self.indexArray[i];
            label.font = FONT_SIZE;
        }
        label.textColor = STR_COLOR;
        [self addSubview:label];
        [_labelList addObject:label];
        [label release];
        label = nil;
        _number = label.font.pointSize;
    }
    
//    if (!_animationLabel) {
//        _animationLabel = [[UILabel alloc]initWithFrame:CGRectMake(-WIDTH/2 + self.frame.size.width/2, 100, 60, 60)];
//        _animationLabel.layer.masksToBounds = YES;
//        _animationLabel.layer.cornerRadius = 5.0f;
//        _animationLabel.backgroundColor = [UIColor orangeColor];
//        _animationLabel.textColor = [UIColor whiteColor];
//        _animationLabel.alpha = 0;
//        _animationLabel.textAlignment = NSTextAlignmentCenter;
//        _animationLabel.font = [UIFont systemFontOfSize:18];
//        [self addSubview:_animationLabel];
//    }
}


-(void)animationWithSection:(NSInteger)section
{
    if (self.selectedBlock) {
        self.selectedBlock(section);
    }
//    _animationLabel.text = self.indexArray[section];
//    _animationLabel.alpha = 1.0;
}


-(void)panAnimationFinish
{
    CGFloat maxh = 24;
    CGFloat hh = self.frame.size.height/self.indexArray.count;
    if (hh > maxh) {
        hh = maxh;
    }
    for (int i = 0; i < self.indexArray.count; i ++)
    {
        UILabel * label = (UILabel *)[self viewWithTag:TAG + i];
        [UIView animateWithDuration:0.2 animations:^{
            label.center = CGPointMake(self.frame.size.width/2, i * hh + hh/2+_labelY);
            if (i == 0) {
                UIFont *iconfont = [UIFont fontWithName:@"iconfont" size: 14];
                label.font = iconfont;
            }
            else {
                label.font = FONT_SIZE;
            }
            label.alpha = 1.0;
            label.textColor = STR_COLOR;
        }];
    }
    [UIView animateWithDuration:1 animations:^{
        self.animationLabel.alpha = 0;
    }];
}


-(void)panAnimationBeginWithToucher:(NSSet<UITouch *> *)touches
{
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (point.y < 0) {
        point.y  = 0;
    }
    CGFloat maxh = 24;
    CGFloat hh = self.frame.size.height/self.indexArray.count;
    if (hh > maxh) {
        hh = maxh;
    }
    NSInteger index = (point.y-_labelY) / hh;
    
    if (index >= self.indexArray.count) {
        index = self.indexArray.count-1;
    }
    else if (index < 0) {
        index = 0;
    }
     [self animationWithSection:index];
    for (int i = 0; i < self.indexArray.count; i ++)
    {
        UILabel * label = (UILabel *)[self viewWithTag:TAG + i];
        CGRect f = CGRectMake(0, 0, self.width*3, hh*3);

        [UIView animateWithDuration:0.2 animations:^{
            CGFloat x = self.frame.size.width/2;
            CGFloat alpha = 1.0;
            CGFloat fontSize = 12;
            BOOL bold= NO;
            if (i == index) {
                x -= 90;
                fontSize = 38;
                bold = YES;
            }
            else if (labs(i-index) ==1) {
                x -= 80;
                fontSize = 32;
                alpha = 0.3;
            }
            else if (labs(i-index) ==2) {
                x -= 75;
                fontSize = 28;
                alpha = 0.5;
            }
            else if (labs(i-index) ==3) {
                x -= 58;
                fontSize = 24;
                alpha = 0.6;
            }
            else if (labs(i-index) ==4) {
                x -= 40;
                fontSize = 18;
                alpha = 0.8;
            }
            else if (labs(i-index) ==5) {
                x -= 19;
                fontSize = 14;
            }
            label.frame = f;
            label.center = CGPointMake(x, i * hh + hh/2 +_labelY);
            if (i == 0) {
                label.font = [UIFont fontWithName:@"iconfont" size: fontSize+2];
            }
            else {
                label.font = bold ?FONTBOLDSYS(fontSize):FONTSYS(fontSize);
            }
            label.alpha = alpha;
            label.textColor = STR_COLOR;

        }];
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self panAnimationBeginWithToucher:touches];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self panAnimationBeginWithToucher:touches];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self panAnimationFinish];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self panAnimationFinish];
}


-(void)selectIndexBlock:(MyBlock)block {
    self.selectedBlock = block;
}


- (void)setIndexArray:(NSArray *)indexArray {
    
    for (UIView *view in _labelList) {
        [view removeFromSuperview];
    }
    [_labelList removeAllObjects];
    
    [_indexArray release];
    _indexArray = nil;
    _indexArray = [indexArray retain];
    [self initLabels];
    [self customLayoutSubviews];
}

- (void)customLayoutSubviews {
    CGFloat maxh = 24;
    _labelY = 0;
    CGFloat hh = self.frame.size.height/self.indexArray.count;
    if (hh > maxh) {
        hh = maxh;
        _labelY = self.frame.size.height/2- self.indexArray.count *maxh/2;
    }
    for (int i = 0; i < _labelList.count; i ++) {
        UILabel * label = [_labelList objectAtIndex:i];
        label.frame = CGRectMake(0, i * hh+_labelY, self.frame.size.width, hh);
    }
//    CGFloat ox = self.superview.width;
//    _animationLabel.frame = CGRectMake(-ox/2 + self.frame.size.width/2, self.height/2-30, 60, 60);
}

-(void)dealloc {
    self.animationLabel = nil;
    self.indexArray = nil;
    self.selectedBlock = nil;
    [_labelList removeAllObjects];
    [_labelList release];
    _labelList = nil;
    [super dealloc];
}

@end
