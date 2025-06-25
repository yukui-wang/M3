//
//  CMPOcrAssociatedFooterView.m
//  CMPOcr
//
//  Created by 崔帅兵MA on 2021/11/25.
//

#import "CMPOcrAssociatedFooterView.h"
#import "CustomDefine.h"
#import "UIView+Layer.h"
#import <CMPLib/CMPThemeManager.h>

@interface CMPOcrAssociatedFooterView ()
{
    UIButton        * nameBtn;
    UILabel         * moreLab;
    UIImageView     * btnImage;
}
@end

@implementation CMPOcrAssociatedFooterView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self makeUI];
    }
    return self;
}
- (void)makeUI{
    self.backgroundColor = UIColor.whiteColor;
    UILabel *lineLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kCMPOcrScreenWidth, 1)];
    lineLab.backgroundColor = k16RGBColor(0xf2f2f2);
    [self addSubview:lineLab];
    
    CGFloat more_width = STRING_WIDTH(@"已选择0个关联发票", (49), 13);
    moreLab = [[UILabel alloc] initWithFrame:CGRectMake((10),1, more_width+(5), (49))];
    moreLab.text = @"已选择0个关联发票";
    moreLab.font = [UIFont systemFontOfSize:13];
    moreLab.textAlignment = NSTextAlignmentLeft;
    moreLab.userInteractionEnabled = YES;
    [self addSubview:moreLab];
    
    NSMutableAttributedString *numStr = [[NSMutableAttributedString alloc] initWithString:moreLab.text];
    [numStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,3)];
    [numStr addAttribute:NSForegroundColorAttributeName value:kBlueColor range:NSMakeRange(3,moreLab.text.length-4)];
    [numStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(moreLab.text.length-4,4)];
    moreLab.attributedText = numStr;
    
    btnImage = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(moreLab.frame), (23), (10), (5))];
    [btnImage setImage:[UIImage imageNamed:@"p_show"]];
    [self addSubview:btnImage];

    nameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nameBtn.frame = CGRectMake(0,0, CGRectGetWidth(moreLab.frame), CGRectGetHeight(moreLab.frame));
    nameBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [nameBtn addTarget:self action:@selector(showInvoiceListView:) forControlEvents:UIControlEventTouchUpInside];
    [moreLab addSubview:nameBtn];

    
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.frame = CGRectMake(kCMPOcrScreenWidth-(158+14), (6), (158), (36));
    sureBtn.backgroundColor = [UIColor cmp_specColorWithName:@"theme-bdc"];
    sureBtn.layer.cornerRadius = (18);
    sureBtn.layer.masksToBounds = YES;
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sureBtn];
}

- (void)showInvoiceListView:(UIButton*)btn{
    NSLog(@"关联");
    btn.selected = !btn.selected;
    if (self.showBlock) {
        self.showBlock(btn.selected);
    }
}

- (void)sureButtonClick{
    NSLog(@"确定");
    if (self.sureBlcok) {
        self.sureBlcok();
    }
}
- (void)refreshSelectInvoiceCount:(NSInteger)count;{
    
    CGFloat more_width = STRING_WIDTH(moreLab.text, (49), 13);

    moreLab.text = [NSString stringWithFormat:@"已选择%ld个关联发票",count];
    moreLab.frame = CGRectMake((10),1, more_width+(5), (49));
    moreLab.font = [UIFont systemFontOfSize:13];
    moreLab.textAlignment = NSTextAlignmentLeft;
    
    NSMutableAttributedString *numStr = [[NSMutableAttributedString alloc] initWithString:moreLab.text];
    [numStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,3)];
    [numStr addAttribute:NSForegroundColorAttributeName value:[UIColor cmp_specColorWithName:@"theme-fc"] range:NSMakeRange(3,moreLab.text.length-4)];
    [numStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(moreLab.text.length-4,4)];
    moreLab.attributedText = numStr;

    btnImage.frame = CGRectMake(CGRectGetMaxX(moreLab.frame), (23), (10), (5));
}
@end
