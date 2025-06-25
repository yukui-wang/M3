//
//  CMPNewVersionTipView.m
//  M3
//
//  Created by 程昆 on 2019/3/29.
//

#import "CMPNewVersionTipView.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPConstant.h>


@interface CMPNewVersionTipView ()

@property (nonatomic,strong)UIImageView *tipImageView;
@property (nonatomic,strong)UIImageView *closeImageView;
@property (nonatomic,copy)CMPNewVersionTipViewDissmissBlock dissmissBlock;

@property (nonatomic,strong)UITapGestureRecognizer *dismissGesture;

@end

@implementation CMPNewVersionTipView

- (instancetype)init {
    if (self = [super init]) {
        [self setupSubviews];
        [self setupSubviewsConstraints];
        [self addGesture];
    }
    return self;
}

- (void)setupSubviews {
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    self.tipImageView = [[UIImageView alloc]init];
    self.tipImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"CMPNewVersionTip.bundle/common_app_tip%@.png",SY_STRING(@"common_language")]];
    [self addSubview:self.tipImageView];
    self.closeImageView = [[UIImageView alloc]init];
    self.closeImageView.image = [UIImage imageNamed:@"CMPNewVersionTip.bundle/close_tip.png"];
    [self addSubview:self.closeImageView];
}


- (void)setupSubviewsConstraints {
    [self.tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(320);
        make.height.equalTo(291);
    }];
    
    [self.closeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipImageView.mas_bottom).offset(20);
        make.size.equalTo(50);
        make.centerX.equalTo(self);
    }];
}

- (void)addGesture {
    self.dismissGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissGestureAction:)];
    [self addGestureRecognizer:self.dismissGesture];
}

- (void)dismissGestureAction:(UITapGestureRecognizer *)gesture{
   
   CGPoint location = [gesture locationInView:self];
   CGPoint convertLocation = [self convertPoint:location toView:self.tipImageView];
   if ([self.tipImageView pointInside:convertLocation withEvent:nil]) {
       return;
   }
   [self removeFromSuperview];
   self.dissmissBlock();
}

- (void)showInView:(UIView *)view dissmiss:(CMPNewVersionTipViewDissmissBlock)dismissBlock{
    self.dissmissBlock = dismissBlock;
    [self removeFromSuperview];
    [view addSubview:self];
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
}

@end
