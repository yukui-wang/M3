//
//  KSCheckBox.m
//  MPlus
//
//  Created by Kaku_Songu on 2017/5/19.
//  Copyright © 2017年 Kaku Songu. All rights reserved.
//

#import "KSCheckBox.h"
#import <CMPLib/CMPThemeManager.h>

@interface KSCheckBox()
@property (nonatomic,strong)UIImageView *checkImgView;
@end

@implementation KSCheckBox

- (void)dealloc
{
}

-(UIImageView *)checkImgView
{
    if (!_checkImgView) {
        _checkImgView = [[UIImageView alloc]init];
        _checkImgView.backgroundColor = [UIColor clearColor];
        [self addSubview:_checkImgView];
    }
    return _checkImgView;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.checkState = CHECKSTATE_UNCHECK;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tap];
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect r = self.frame;
    CGFloat w = r.size.width,h = r.size.height;
    CGFloat _x = MAX(w, h);
    
    if (w!=h) {
        
        if (_x<20) {
            _x = 20;
        }
        r.size = CGSizeMake(_x, _x);
        self.frame = r;

    }
    self.layer.cornerRadius = _x/2;
    self.checkImgView.frame = CGRectMake(0, 0, _x, _x);
}

-(void)setCheckState:(CHECKSTATE)checkState
{
    _checkState = checkState;
    if (_checkState == CHECKSTATE_CHECKED) {
        self.checkImgView.image = [[CMPThemeManager sharedManager] skinColorImageWithName:[self _getImgName]];
    }else{
        self.checkImgView.image = [UIImage imageNamed:[self _getImgName]];
    }
}

-(NSString *)_getImgName
{
    NSString *imageName;
    switch (_checkState) {
        case CHECKSTATE_CHECKED:
            imageName = @"share_btn_selected_circle";
            self.layer.borderWidth = 0;
            break;
        case CHECKSTATE_DISABLE:
            imageName = @"";
            break;
            
        default:
            imageName = @"";
            self.layer.borderWidth = 1;
            break;
    }
    return imageName;
}

-(void)tap:(UITapGestureRecognizer *)tap
{
    BOOL canCheck = YES;
    if (self.checkPreAction) {
        canCheck = self.checkPreAction(self.checkState);
    }
    if (canCheck) {
        self.checkState = !self.checkState;
        if (self.checkDoneAction) {
            self.checkDoneAction(self.checkState);
        }
    }
}
@end
