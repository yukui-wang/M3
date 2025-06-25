//
//  CMPOcrMainListCell.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/5.
//

#import "CMPOcrMainListCell.h"
#import "CMPOcrPackageModel.h"
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/Masonry.h>
@interface CMPOcrMainListCell()
{
    CMPOcrPackageModel *_item;
}

@property (nonatomic, strong) UILabel *nameLb;
@property (nonatomic, strong) UILabel *amountLb;
@property (nonatomic, strong) UILabel *countLb;
@property (nonatomic, strong) UILabel *statusLb;
@property (nonatomic, strong) UIButton *submitBtn;
@property (nonatomic, strong) UIButton *wakeupBtn;

@end

@implementation CMPOcrMainListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIView *bgView = [UIView new];
        bgView.layer.cornerRadius = 8.f;
        bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(14);
            make.right.mas_equalTo(-14);
            make.top.mas_equalTo(5);
            make.bottom.mas_equalTo(-5);
        }];
        //名称
        _nameLb = [UILabel new];
        _nameLb.textColor = UIColor.blackColor;
        _nameLb.font = [UIFont systemFontOfSize:16];
        [bgView addSubview:_nameLb];
        [_nameLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.top.mas_equalTo(14);
            make.right.mas_equalTo(-10);
        }];
        //状态
//        _statusLb = [UILabel new];
//        _statusLb.layer.masksToBounds = YES;
//        _statusLb.layer.cornerRadius = 3.f;
//        _statusLb.font = [UIFont systemFontOfSize:10];
//        _statusLb.textAlignment = NSTextAlignmentCenter;
//        [bgView addSubview:_statusLb];
//        [_statusLb mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(_nameLb.mas_right).offset(8);
//            make.centerY.mas_equalTo(_nameLb.mas_centerY);
//            make.width.mas_equalTo(42);
//            make.height.mas_equalTo(16);
//            make.right.mas_lessThanOrEqualTo(-10);
//        }];
        //金额
        _amountLb = [UILabel new];
        _amountLb.font = [UIFont systemFontOfSize:18];
        _amountLb.textColor = [UIColor cmp_specColorWithName:@"theme-bdc"];
        [bgView addSubview:_amountLb];
        [_amountLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_nameLb.mas_bottom).offset(10);
            make.left.mas_equalTo(_nameLb.mas_left);
        }];
        //张数
        _countLb = [UILabel new];
        _countLb.font = [UIFont systemFontOfSize:12];
        _countLb.textColor = [UIColor cmp_specColorWithName:@"desc-fc"];
        [bgView addSubview:_countLb];
        [_countLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_amountLb.mas_right).offset(10);
            make.bottom.mas_equalTo(_amountLb.mas_bottom);
        }];
        
        //一键报销
        _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _submitBtn.layer.cornerRadius = 4.f;
        _submitBtn.layer.borderColor = [UIColor cmp_specColorWithName:@"theme-bdc"].CGColor;
        _submitBtn.layer.borderWidth = 1.f;
        [_submitBtn setTitle:@"一键报销" forState:(UIControlStateNormal)];
        _submitBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_submitBtn setTitleColor:[UIColor cmp_specColorWithName:@"theme-bdc"] forState:(UIControlStateNormal)];
        [_submitBtn addTarget:self action:@selector(_submitAct:) forControlEvents:(UIControlEventTouchUpInside)];
        [bgView addSubview:_submitBtn];
        [_submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-10);
            make.centerY.mas_equalTo(_amountLb.mas_centerY);
            make.width.mas_equalTo(72);
        }];
        //唤醒pc
        _wakeupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _wakeupBtn.layer.cornerRadius = 4.f;
        _wakeupBtn.layer.borderColor = [UIColor cmp_specColorWithName:@"theme-bdc"].CGColor;
        _wakeupBtn.layer.borderWidth = 1.f;
        [_wakeupBtn setTitle:@"唤醒PC" forState:(UIControlStateNormal)];
        _wakeupBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_wakeupBtn setTitleColor:[UIColor cmp_specColorWithName:@"theme-bdc"] forState:(UIControlStateNormal)];
        [_wakeupBtn addTarget:self action:@selector(_wakeupAct:) forControlEvents:(UIControlEventTouchUpInside)];
        [bgView addSubview:_wakeupBtn];
        [_wakeupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(_submitBtn.mas_left).offset(-10);
            make.centerY.mas_equalTo(_submitBtn.mas_centerY);
            make.width.mas_equalTo(72);
        }];
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        _statusLb.hidden = YES;
        _submitBtn.hidden = YES;
        [self addFourSidesShadowToView:bgView withColor:UIColor.grayColor];//阴影
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    // Initialization code
    [_statusLb sizeToFit];
    [_submitBtn addTarget:self action:@selector(_submitAct:) forControlEvents:UIControlEventTouchUpInside];
    _statusLb.hidden = YES;
    _submitBtn.hidden = YES;
    _statusLb.layer.cornerRadius = 2.f;
    
    [self addFourSidesShadowToView:self withColor:UIColor.grayColor];//阴影
}
//添加四边阴影效果
-(void)addFourSidesShadowToView:(UIView *)theView withColor:(UIColor*)theColor{
    //阴影颜色
    theView.layer.shadowColor = theColor.CGColor;
    //阴影偏移
    theView.layer.shadowOffset = CGSizeMake(0, 0 );
    //阴影透明度，默认0
    theView.layer.shadowOpacity = 0.1;
    //阴影半径，默认3
    theView.layer.shadowRadius = 3;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setItem:(CMPOcrPackageModel *)item
{
    _item = item;
    
    _nameLb.text = _item.name;
    _amountLb.text = [NSString stringWithFormat:@"￥%.2f",_item.invoiceAmount];
    _countLb.text = [NSString stringWithFormat:@"共%lu张",(unsigned long)_item.invoiceCount];
    [self judgefyItemStatus1];
}

-(void)_submitAct:(UIButton *)btn
{
    if (_item && _actBlk) {
        _actBlk(1,_item);
    }
}
-(void)_wakeupAct:(UIButton *)btn
{
    if (_item && _actBlk) {
        _actBlk(2,_item);
    }
}
-(void)judgefyItemStatus1
{
    if (_item) {
        UIColor *submitShowColor = UIColorFromRGB(0x297FFB);
        NSString *submitShowStr = @"一键报销";
                
        _submitBtn.hidden = NO;
        _statusLb.hidden = YES;

        [self setSubmitBtnText:submitShowStr color:submitShowColor];
        [self setWakeupBtnColor:submitShowColor];
        
        //如果包里没有票，则不显示按钮
        BOOL noInvoice = _item.invoiceCount <= 0;
        _submitBtn.hidden = noInvoice;
        _wakeupBtn.hidden = noInvoice;
    }
    _submitBtn.userInteractionEnabled = YES;
    if (_fromPage == 1) {//我的页面隐藏按钮
        _wakeupBtn.hidden = YES;
        _submitBtn.hidden = YES;
        
        //报销完成/正在报销
        if ([_item.statusDisplay isKindOfClass:NSString.class] && _item.statusDisplay.length > 0) {
            _submitBtn.hidden = NO;
            _submitBtn.userInteractionEnabled = NO;
            NSString *displayStr = _item.statusDisplay;
            UIColor *displayColor;
            if (_item.status == 5) {//报销完成
                displayColor = UIColorFromRGB(0x58C195);
            }else if (_item.status == 6) {//报销中
                displayColor = UIColorFromRGB(0xFF9900);
            }
            [self setSubmitBtnText:displayStr color:displayColor];
        }
        
    }
}
-(void)judgefyItemStatus
{
    if (_item) {
        UIColor *statusShowColor = UIColorFromRGB(0x999999);
        NSString *statusShowStr = _item.statusDisplay;
        BOOL statusLbShow = YES;
        UIColor *submitShowColor = UIColorFromRGB(0x999999);
        NSString *submitShowStr = @"一键报销";
        BOOL submitBtnShow = YES;
        
        switch (_item.status) {
            case 0://新建(报销包新建)
            {
                statusShowColor =  UIColorFromRGB(0xFF9900);
            }
                break;
            case 1://识别中,状态栏显示识别中，提交按钮显示一件报销灰色不可点击
            {
                statusShowColor =  UIColorFromRGB(0xFF9900);
            }
                break;
            case 2://被回退（流程被回退了）
            {
                submitShowStr = @"再次发起";
                submitShowColor = UIColorFromRGB(0x297FFB);
                statusShowColor = UIColorFromRGB(0xFF7979);
            }
                break;
            case 3://被终止（流程被终止）
            {
                statusShowColor = UIColor.redColor;
                submitShowStr = @"再次发起";
                submitShowColor = UIColorFromRGB(0x297FFB);
            }
                break;
            case 4://被撤销（流程被撤销
            {
                statusShowColor = UIColor.redColor;
                submitShowStr = @"再次发起";
                submitShowColor = UIColorFromRGB(0x297FFB);
            }
                break;
            case 5://报销成功（流程完成）
            {
                statusLbShow = NO;
                submitShowColor = UIColorFromRGB(0x58C195);
                submitShowStr = statusShowStr;
            }
                break;
            case 6://处理中；
            {
                statusLbShow = NO;
                submitShowStr = statusShowStr;
            }
                break;
            case 7://可报销
            {
                statusLbShow = NO;
                submitShowColor = UIColorFromRGB(0x297FFB);
            }
                break;
            case 8://保存待发，显示一键报销，可点击
            {

                statusShowColor = UIColorFromRGB(0x58C195);
                submitShowColor = UIColorFromRGB(0x297FFB);
            }
                break;
                
            default:
                break;
        }
        _submitBtn.hidden = !submitBtnShow;
        _statusLb.hidden = !statusLbShow;

        [self setStatusLbText:statusShowStr color:statusShowColor];
        [self setSubmitBtnText:submitShowStr color:submitShowColor];
        [self setWakeupBtnColor:submitShowColor];
        
        if (statusShowStr.length <= 0) {
            _statusLb.hidden = YES;
        }else{
            _statusLb.hidden = NO;
        }
        if (_item.isHistory) {
            _statusLb.hidden = YES;
        }
        _wakeupBtn.hidden = _item.isHistory;
    }
}

-(void)setSubmitBtnText:(NSString *)text color:(UIColor *)color
{
    if (color) {
        [_submitBtn setTitleColor:color forState:UIControlStateNormal];
        _submitBtn.layer.borderColor = color.CGColor;
    }
    if (text) {
        [_submitBtn setTitle:text forState:UIControlStateNormal];
    }
}
-(void)setWakeupBtnColor:(UIColor *)color
{
    if (color) {
        [_wakeupBtn setTitleColor:color forState:UIControlStateNormal];
        _wakeupBtn.layer.borderColor = color.CGColor;
    }
}


-(void)setStatusLbText:(NSString *)text color:(UIColor *)color
{
    if (color) {
        _statusLb.backgroundColor = [color colorWithAlphaComponent:0.1];
        _statusLb.textColor = color;
    }
    if (text) {
        _statusLb.text = text;
    }
}

@end
