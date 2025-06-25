//
//  CMPOcrInvoiceSelectBottomView.m
//  CMPOcr
//
//  Created by 张艳 on 2021/11/24.
//

#import "CMPOcrInvoiceSelectBottomView.h"
#import <CMPLib/Masonry.h>
#import "CustomDefine.h"
#import "UIView+Layer.h"
#import <CMPLib/CMPThemeManager.h>

@interface CMPOcrInvoiceSelectBottomView ()

@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *reimburseButton;

@property (nonatomic, strong) UILabel *selectInfoLabel;

@end

@implementation CMPOcrInvoiceSelectBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.selectInfoLabel];
    [self addSubview:self.reimburseButton];
    [self addSubview:self.moreButton];
    
    [self.selectInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.leading.mas_equalTo(14);
        make.height.mas_equalTo(50);
    }];
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(6);
        make.height.mas_equalTo(36);
        make.width.mas_equalTo(102);
        make.right.mas_equalTo(self.reimburseButton.mas_left).offset(-14);
    }];
    [self.reimburseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(6);
        make.height.mas_equalTo(36);
        make.width.mas_equalTo(102);
        make.right.mas_equalTo(-14);
    }];
        
    [self setInvoiceNumber:0 money:0];
}

- (void)setInvoiceNumber:(NSInteger)number money:(double)money {
    
    UIFont *font = ESFontPingFangRegular(13);
    
    NSDictionary *defaultDict = @{NSFontAttributeName : font,
                                  NSForegroundColorAttributeName : [UIColor cmp_specColorWithName:@"cont-fc"]};
    NSDictionary *highlightDict = @{NSFontAttributeName : font,
                                    NSForegroundColorAttributeName : [UIColor cmp_specColorWithName:@"hl-fc1"]};
    
    NSAttributedString *att1 = [[NSAttributedString alloc] initWithString:@"已选择" attributes:defaultDict];
    NSAttributedString *att2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %zd张 ",number] attributes:highlightDict];
    NSAttributedString *att3 = [[NSAttributedString alloc] initWithString:@"发票" attributes:defaultDict];
    
    NSTextAttachment * image = [[NSTextAttachment alloc] init];
    image.image = [UIImage imageNamed:@"giftWallBottomArrow"];
    image.bounds = CGRectMake(3, -5, 20, 20);
    NSAttributedString *imageAtt = [NSAttributedString attributedStringWithAttachment:image];
    
    NSAttributedString *att4 = [[NSAttributedString alloc] initWithString:@"\n共" attributes:defaultDict];
    NSAttributedString *att5 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %.2f ",money] attributes:highlightDict];
    NSAttributedString *att6 = [[NSAttributedString alloc] initWithString:@"元" attributes:defaultDict];

    NSMutableAttributedString *allAtt = [[NSMutableAttributedString alloc] init];
    [allAtt appendAttributedString:att1];
    [allAtt appendAttributedString:att2];
    [allAtt appendAttributedString:att3];
    [allAtt appendAttributedString:imageAtt];
    [allAtt appendAttributedString:att4];
    [allAtt appendAttributedString:att5];
    [allAtt appendAttributedString:att6];
    self.selectInfoLabel.attributedText = allAtt;
    
    //置灰按钮
    _moreButton.enabled = number > 0;
    _reimburseButton.enabled = number >0;
    
    if (_moreButton.enabled) {
        UIColor *themeColor = [UIColor cmp_specColorWithName:@"theme-fc"];
        _moreButton.layer.borderColor = themeColor.CGColor;
        _moreButton.layer.borderWidth = 1.f;
        _moreButton.backgroundColor = UIColor.whiteColor;
        [_moreButton setTitleColor:themeColor forState:UIControlStateNormal];
        
        _reimburseButton.backgroundColor = themeColor;
        [_reimburseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        UIColor *themeColor = [UIColor cmp_specColorWithName:@"sup-fc1"];
        _moreButton.layer.borderColor = themeColor.CGColor;
        _moreButton.layer.borderWidth = 1.f;
        _moreButton.backgroundColor = UIColor.whiteColor;
        [_moreButton setTitleColor:themeColor forState:UIControlStateNormal];
        
        _reimburseButton.backgroundColor = themeColor;
        [_reimburseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    
}

- (void)setExtStatus:(NSInteger)ext{
    if (ext == 3) {
        self.moreButton.hidden = YES;
        [self.reimburseButton setTitle:@"完成" forState:(UIControlStateNormal)];
    }else {
        self.moreButton.hidden = NO;
        [_reimburseButton setTitle:@"一键报销" forState:(UIControlStateNormal)];
    }
}

- (void)reimburseButtonAction {
    if (RES_OK(@selector(invoiceSelectBottomViewReimburse))) {
        [self.delegate invoiceSelectBottomViewReimburse];
    }
}

- (void)moreButtonAction {
    if (RES_OK(@selector(invoiceSelectBottomViewMore))) {
        [self.delegate invoiceSelectBottomViewMore];
    }
}

- (void)infoAction {
    if (RES_OK(@selector(invoiceSelectBottomViewShowInfo))) {
        [self.delegate invoiceSelectBottomViewShowInfo];
    }
}

- (UIButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreButton.frame = CGRectMake(0, 0, 156, 36);
        _moreButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _moreButton.titleLabel.numberOfLines = 0;
                
        _moreButton.layer.cornerRadius = 18.f;
        _moreButton.layer.masksToBounds = YES;
        UIColor *themeColor = [UIColor cmp_specColorWithName:@"theme-fc"];
        _moreButton.layer.borderColor = themeColor.CGColor;
        _moreButton.layer.borderWidth = 1.f;
        _moreButton.backgroundColor = UIColor.whiteColor;
        [_moreButton setTitleColor:themeColor forState:UIControlStateNormal];

        [_moreButton setTitle:@"更多" forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(moreButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}
- (UIButton *)reimburseButton {
    if (!_reimburseButton) {
        _reimburseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _reimburseButton.frame = CGRectMake(0, 0, 102, 36);
        _reimburseButton.titleLabel.font = [UIFont systemFontOfSize:16];
        
        _reimburseButton.layer.cornerRadius = 18.f;
        _reimburseButton.layer.masksToBounds = YES;
        _reimburseButton.backgroundColor = [UIColor cmp_specColorWithName:@"theme-fc"];
        [_reimburseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        [_reimburseButton setTitle:@"一键报销" forState:UIControlStateNormal];

        [_reimburseButton addTarget:self action:@selector(reimburseButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reimburseButton;
}
- (UILabel *)selectInfoLabel {
    if (!_selectInfoLabel) {
        _selectInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _selectInfoLabel.font = [UIFont systemFontOfSize:13];
        _selectInfoLabel.textAlignment = NSTextAlignmentLeft;
        _selectInfoLabel.text = @"已选择2张发票\n共计0元";
        _selectInfoLabel.numberOfLines = 2;
        _selectInfoLabel.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(infoAction)];
        [_selectInfoLabel addGestureRecognizer:tap];
    }
    return _selectInfoLabel;
}
@end
