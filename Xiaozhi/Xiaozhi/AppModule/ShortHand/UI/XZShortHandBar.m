//
//  XZShortHandBar.m
//  M3
//
//  Created by wujiansheng on 2019/1/11.
//

#import "XZShortHandBar.h"

@implementation XZShortHandBar
- (void)dealloc {
    self.fontBtn = nil;
    self.boldBtn = nil;
    self.italicBtn = nil;
    self.pointBtn = nil;
    self.numberBtn = nil;
    self.replaceBtn = nil;
    self.voiceBtn = nil;

    [super dealloc];
}
- (UIButton *)buttonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor blueColor]];
    button.titleLabel.font = FONTSYS(12);
    return button;
}
- (void)setup {
    
    
    if (!self.fontBtn)  {
        self.fontBtn = [self buttonWithTitle:@"Font"];
        [self addSubview:self.fontBtn];
    }
    if (!self.boldBtn)  {
        self.boldBtn = [self buttonWithTitle:@"Bold"];
        [self addSubview:self.boldBtn];
    }
    if (!self.italicBtn)  {
        self.italicBtn = [self buttonWithTitle:@"/italic"];
        [self addSubview:self.italicBtn];
    } if (!self.numberBtn)  {
        self.numberBtn = [self buttonWithTitle:@"123"];
        [self addSubview:self.numberBtn];
    }
    if (!self.replaceBtn)  {
        self.replaceBtn = [self buttonWithTitle:@"Replace"];
        [self addSubview:self.replaceBtn];
    }
    
    if (!self.voiceBtn) {
        self.voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.voiceBtn setImage:[UIImage imageNamed:@"XZbundle.bundle/xz_speakbtn_def.png"] forState:UIControlStateNormal];
        [self.voiceBtn setImage:[UIImage imageNamed:@"XZbundle.bundle/xz_speakbtn_pre.png"] forState:UIControlStateSelected];
        [self addSubview:self.voiceBtn];
    }
    self.backgroundColor = [UIColor whiteColor];
}

- (void)customLayoutSubviews {
    CGFloat width = 45;
    CGFloat height = 30;
    CGFloat x = 10;
    
    [self.fontBtn setFrame:CGRectMake(x, self.height/2-height/2, width, height)];
    x += self.fontBtn.width+10;
    [self.boldBtn setFrame:CGRectMake(x, self.height/2-height/2, width, height)];
    x += self.boldBtn.width+10;
    [self.italicBtn setFrame:CGRectMake(x, self.height/2-height/2, width, height)];
    x += self.italicBtn.width+10;
    [self.pointBtn setFrame:CGRectMake(x, self.height/2-height/2, width, height)];
    x += self.pointBtn.width+10;
    [self.numberBtn setFrame:CGRectMake(x, self.height/2-height/2, width, height)];
    x += self.numberBtn.width+10;
    [self.replaceBtn setFrame:CGRectMake(x, self.height/2-height/2, width, height)];
    x += self.replaceBtn.width+10;
    [self.voiceBtn setFrame:CGRectMake(x, self.height/2-height/2, width, height)];
    x += self.voiceBtn.width+10;
}

@end
