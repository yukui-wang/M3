//
//  CMPShareToInnerCell.m
//  M3
//
//  Created by MacBook on 2019/10/29.
//

#import "CMPShareToInnerCell.h"
#import "CMPShareCellModel.h"
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/Masonry.h>

NSString * const CMPShareToInnerCellId = @"CMPShareToInnerCellId";

@interface CMPShareToInnerCell()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorLine;

@property (nonatomic,strong) UIImageView *aImgView;
@property (nonatomic,strong) UILabel *aTitleLb;
@property (nonatomic,strong) UIView *aSeparatorLine;
@property (nonatomic,strong) UIImageView *aArrowView;

@end

@implementation CMPShareToInnerCell

- (void)awakeFromNib {//ios12无法显示，不知道原因，所以用原始方法重写了
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
    self.titleLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
    self.separatorLine.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
    
    [self.imgView cmp_setCornerRadius:4.f];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
        
        _aImgView = [[UIImageView alloc] init];
        _aImgView.backgroundColor = [UIColor clearColor];
        [_aImgView cmp_setCornerRadius:4.f];
        [self.contentView addSubview:_aImgView];
        [_aImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.offset(0);
            make.left.offset(14);
            make.size.mas_equalTo(CGSizeMake(26, 26));
        }];
        
        _aArrowView = [[UIImageView alloc] init];
        _aArrowView.backgroundColor = [UIColor clearColor];
        _aArrowView.image = [UIImage imageNamed:@"tableViewArrow"];
        [self.contentView addSubview:_aArrowView];
        [_aArrowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.offset(0);
            make.right.offset(-10);
            make.size.mas_equalTo(CGSizeMake(16, 16));
        }];
        
        _aSeparatorLine = [[UIView alloc] init];
        _aSeparatorLine.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
        [self.contentView addSubview:_aSeparatorLine];
        [_aSeparatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.offset(0);
            make.left.offset(14);
            make.height.equalTo(0.5);
        }];
        
        _aTitleLb = [[UILabel alloc] init];
        _aTitleLb.numberOfLines = 1;
        _aTitleLb.textAlignment = NSTextAlignmentLeft;
        _aTitleLb.font = [UIFont systemFontOfSize:16];
        _aTitleLb.textColor = [UIColor cmp_colorWithName:@"main-fc"];
        [_aTitleLb sizeToFit];
        [self.contentView addSubview:_aTitleLb];
        [_aTitleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.offset(0);
            make.left.equalTo(_aImgView.mas_right).offset(10);
            make.right.equalTo(_aArrowView.mas_left).offset(-10);
        }];
        
    }
    return self;
}

- (void)setModel:(CMPShareCellModel *)model {
    _model = model;
    
    self.aImgView.image = [UIImage imageNamed:model.icon];
    self.aTitleLb.text = SY_STRING(model.title);
}

@end
