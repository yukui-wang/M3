//
//  SyLbsCustomTableViewCell.m
//  M1Core
//
//  Created by Aries on 14/12/16.
//
//

#import "CMPLbsCustomTableViewCell.h"
#import <CMPLib/CMPConstant.h>
@interface CMPLbsCustomTableViewCell ()
{
    UIImageView *_circleImageView;
    UIImageView *_bgImageView;
    UILabel     *_textLabel;
}
@end

@implementation CMPLbsCustomTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = /*UIColorFromRGB(0xf2f2f2)*/[UIColor clearColor];
        if(!_bgImageView){
            _bgImageView = [[UIImageView alloc] init];
            UIImage *image = [UIImage imageNamed:@"lbsShow.bundle/sign_atMe_bg.png"];
            _bgImageView.image = [image stretchableImageWithLeftCapWidth:14 topCapHeight:32];
            [self addSubview:_bgImageView];
        }
        if(!_textLabel){
            _textLabel = [[UILabel alloc] init];
            _textLabel.font = FONTSYS(15);
            _textLabel.textColor = [UIColor blackColor];
            _textLabel.numberOfLines = 0;
            [self addSubview:_textLabel];
        }
        if(!_circleImageView){
            _circleImageView = [[UIImageView alloc] init];
            [self addSubview:_circleImageView];
        }
    }
    return self;
}

- (void)setContentText:(NSString *)contentText
{
    if(!contentText)
        return;
    if(contentText == _contentText)
        return;
    _contentText = [contentText copy];
    
    if (!IOS6_Later) {
        _textLabel.text = _contentText;
        return;
    }
    NSMutableAttributedString *strA = [[NSMutableAttributedString alloc] initWithString:_contentText];
    NSRange range = [contentText rangeOfString:@"@"];
    if(range.location != NSNotFound){
        [strA addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(range.location, _contentText.length - range.location)];
    }    _textLabel.attributedText = strA;
    SY_RELEASE_SAFELY(strA);
}
- (void)setCellType:(NSInteger)cellType
{
    if(cellType == 0){
        _circleImageView.image = [UIImage imageNamed:@"lbsShow.bundle/sign_location.png"];
        
    }else if(cellType == 1){
        _circleImageView.image = [UIImage imageNamed:@"lbsShow.bundle/sign_commnet.png"];
    }
}
- (void)dealloc
{
    SY_RELEASE_SAFELY(_contentText);
    SY_RELEASE_SAFELY(_bgImageView);
    SY_RELEASE_SAFELY(_textLabel);
    SY_RELEASE_SAFELY(_circleImageView);
    [super dealloc];
}
- (void)layoutSubviews
{
    _circleImageView.frame = CGRectMake(22, 22, 28, 28);
    
    CGFloat width = self.bounds.size.width - 90;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        width = 400;
    CGSize  addressLabelSize = [_contentText sizeWithFont:FONTSYS(15) constrainedToSize:CGSizeMake(width-20,1000)];
    _textLabel.frame = CGRectMake(70, 24, width-20, addressLabelSize.height);

    _bgImageView.frame = CGRectMake(55, 13, width, self.frame.size.height - 13);
    _textLabel.center = CGPointMake(width/2+60, CGRectGetMidY(_bgImageView.frame));
    
}
@end
