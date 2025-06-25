//
//  CMPOcrInvoiceItemCell.m
//  CMPOcr
//
//  Created by 张艳 on 2021/11/24.
//

#import "CMPOcrInvoiceItemCell.h"
#import "CustomDefine.h"
#import "UIView+Layer.h"
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/KSLabel.h>

@interface CMPOcrInvoiceNewItemCell ()
{
    UIView          *separatorView;//主发票分隔线
//    UIView          *backView;
    UILabel         *titleLab;
    UILabel         *dateLab;
    UILabel         *mainLab;
    UILabel         *confirmLab;
    KSLabel         *statusLab;
    UIImageView     *iconImage;
    UIImageView     *badImage;
    UILabel         *moneyLab;
    UIStackView     *detailsStackView;
}
@property (nonatomic, assign) NSInteger fromPage;
@end

@implementation CMPOcrInvoiceNewItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self makeUI];
    }
    return self;
}

- (void)makeUI{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    separatorView = [[UIView alloc]init];
    separatorView.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
    [self.contentView addSubview:separatorView];
    
    _backView = [[UIView alloc] init];
    _backView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_backView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backViewAction)];
    [_backView addGestureRecognizer:tap];

    self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.selectButton setImage:[UIImage imageNamed:@"ocr_card_batch_manage_uncheck"] forState:UIControlStateNormal];
    [self.selectButton setImage:[UIImage imageNamed:@"ocr_card_batch_manage_checked"] forState:UIControlStateSelected];
//    self.selectButton.adjustsImageWhenDisabled = NO;
    [self.selectButton addTarget:self action:@selector(selectButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.selectButton];

    titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 22)];
    titleLab.text = @"发票名称";
    titleLab.numberOfLines = 2;
    titleLab.textColor = [UIColor blackColor];
    titleLab.font = [UIFont systemFontOfSize:16];
    titleLab.textAlignment = NSTextAlignmentLeft;
    [_backView addSubview:titleLab];

    dateLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 17)];
    dateLab.text = @"2021年11月29日15:0";
    dateLab.textColor = [UIColor grayColor];
    dateLab.font = [UIFont systemFontOfSize:12];
    dateLab.textAlignment = NSTextAlignmentLeft;
    [_backView addSubview:dateLab];
    dateLab.hidden = YES;
    
    mainLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
    mainLab.text = @"主";
    mainLab.textColor = [UIColor whiteColor];
    mainLab.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    mainLab.font = [UIFont systemFontOfSize:10];
    mainLab.layer.cornerRadius = 2.f;
    mainLab.layer.masksToBounds = YES;
    mainLab.textAlignment = NSTextAlignmentCenter;
    [_backView addSubview:mainLab];

    confirmLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 18)];
    confirmLab.text = @"未确认";
    confirmLab.textColor = [UIColor cmp_specColorWithName:@"app-bgc5"];//kRGBColor(251, 146, 25);
    confirmLab.backgroundColor = [[UIColor cmp_specColorWithName:@"warnmark-bgc"] colorWithAlphaComponent:0.1];//  kRGBColor(241, 243, 215);
    confirmLab.font = [UIFont systemFontOfSize:10];
    confirmLab.textAlignment = NSTextAlignmentCenter;
    [_backView addSubview:confirmLab];
    
    statusLab = [[KSLabel alloc] initWithFrame:CGRectMake(0, 0, 52, 18)];
    statusLab.text = @"已报销";
    statusLab.textColor = [UIColor cmp_specColorWithName:@"app-bgc3"];
    statusLab.font = [UIFont systemFontOfSize:10];
    statusLab.textAlignment = NSTextAlignmentCenter;
    statusLab.hidden = YES;
//    [statusLab sizeToFit];
//    statusLab.numberOfLines = 1;
    [_backView addSubview:statusLab];
    
    iconImage = [[UIImageView alloc] init];
    iconImage.contentMode = UIViewContentModeScaleAspectFill;
    iconImage.clipsToBounds = YES;
    iconImage.layer.cornerRadius = 2.f;
    [_backView addSubview:iconImage];
    
    badImage = [[UIImageView alloc] init];
    badImage.contentMode = UIViewContentModeScaleAspectFill;
    badImage.clipsToBounds = YES;
    badImage.image = [UIImage imageNamed:@"ocr_card_alert_red"];
    [_backView addSubview:badImage];
    
    moneyLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 18)];
    moneyLab.text = @"$12100";
    moneyLab.textColor = [UIColor cmp_specColorWithName:@"theme-bdc"];
    moneyLab.textAlignment = NSTextAlignmentRight;
    moneyLab.font = [UIFont boldSystemFontOfSize:16];
    [_backView addSubview:moneyLab];
    
    detailsStackView = [[UIStackView alloc]init];
    detailsStackView.distribution = UIStackViewDistributionEqualSpacing;
    detailsStackView.spacing = 0;
    detailsStackView.axis = UILayoutConstraintAxisVertical;
    [_backView addSubview:detailsStackView];
}

- (void)remakeConstraintForMainDeputy:(BOOL)mainDeputy canSelect:(BOOL)canSelect position:(NSInteger)position ext:(NSInteger)ext{
    CGFloat btnWidth = canSelect?45:0;//按钮宽度
    CGFloat backViewLeft = canSelect?45:14;
    backViewLeft += _item.mainDeputyTag == 2?2:0;
    
    if (ext==2 && _item.relationInvoiceId.length > 0) {
        backViewLeft -= 2;//关联发票
    }
    
    CGFloat backViewRight = -14;
    CGFloat separatorHeight = mainDeputy?10:0;//顶部分隔线高度
    CGFloat backViewBot = position >= 3?-10:0;//3和4 底部10px白色底
    CGFloat leftMargin = _item.mainDeputyTag == 2?7:0;//副发票backView内左边
    if (ext==2 && _item.relationInvoiceId.length > 0) {
        leftMargin = 0;//关联发票
    }
    //莫名奇妙需要-3，margin才不会出问题
    CGFloat rightMargin = -3;// mainDeputy?-3:-10;//副发票backView内右边
    
    //主发票分隔线
    [separatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(separatorHeight);//主发票顶部有10高的分隔线
    }];
        
    //背景view
    [_backView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backViewLeft);
        make.right.mas_equalTo(backViewRight);//副发票右边多14
        make.top.equalTo(separatorView.mas_bottom).offset(0);
        make.bottom.mas_equalTo(backViewBot);
    }];
    
    //发票图
    [iconImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leftMargin);
        make.top.mas_equalTo(14);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
    }];
    //
    [badImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(16);
        make.right.mas_equalTo(iconImage.mas_right).offset(-2);
        make.bottom.mas_equalTo(iconImage.mas_bottom).offset(-2);
    }];
    
    //选择框
    [self.selectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(btnWidth);
        make.centerY.mas_equalTo(iconImage.mas_centerY).offset(0);
        make.left.mas_equalTo(0);
    }];
    
    //发票名
    [titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(iconImage.mas_top).offset(0);
        make.left.mas_equalTo(iconImage.mas_right).offset(10);
        make.right.mas_lessThanOrEqualTo(moneyLab.mas_left).offset(-16);;
    }];
    //主发票标记
    [mainLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLab.mas_right).offset(2);
        make.width.height.mas_equalTo(14);
        make.centerY.equalTo(titleLab).offset(0);
    }];
    
    //金额
    [moneyLab setContentCompressionResistancePriority:751 forAxis:UILayoutConstraintAxisHorizontal];
    [moneyLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(rightMargin);
        make.centerY.equalTo(titleLab).offset(0);
        make.height.mas_equalTo(20);
    }];
    
    //确认状态
    [confirmLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(rightMargin);
        make.top.mas_equalTo(titleLab.mas_bottom).offset(5);
        make.height.mas_equalTo(18);
        make.width.mas_equalTo(52);
    }];
    
    //报销状态
    [statusLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(rightMargin);
        make.top.mas_equalTo(moneyLab.mas_bottom).offset(5);
        make.height.mas_equalTo(18);
        make.width.mas_equalTo(52);
    }];

    //日期
    [dateLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLab.mas_bottom).offset(7);
        make.left.mas_equalTo(titleLab.mas_left).offset(0);
        make.right.mas_equalTo(confirmLab.mas_left).offset(0);
        make.height.mas_equalTo(17);
    }];
    
    //更多信息
    CGFloat moreH =_item.displayFields?(_item.displayFields.count - 1)*17:0;
    [detailsStackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLab.mas_bottom).offset(7);
        make.left.mas_equalTo(titleLab.mas_left).offset(0);
        make.right.mas_equalTo(confirmLab.mas_left).offset(-2);
        make.height.mas_equalTo(17 + moreH);
    }];
    
    UIView *vv = [statusLab.superview viewWithTag:11];
    if (vv) {
        [vv mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(statusLab);
            make.height.mas_equalTo(18);
            make.width.mas_equalTo(52);
        }];
    }
}

+ (CGFloat)getTitleLabelHeight:(CMPOcrInvoiceItemModel *)item canSelect:(BOOL)canSelect{
    CGFloat selectWidth = canSelect?45:0;
    CGFloat iconWidth = 50;
    CGFloat marginToIcon = 10;
    CGFloat mainWidth = 14;
    CGFloat titleMargin = 16;
    BOOL isMain = item.mainDeputyTag == 1;
    CGFloat rightMargin = isMain?3:10;
    
    UILabel *moneyLabel = [UILabel new];
    moneyLabel.font = [UIFont boldSystemFontOfSize:16];
    moneyLabel.text = [NSString stringWithFormat:@"¥%@",item.total.length>0?item.total:@"0"];
    [moneyLabel sizeToFit];
    CGFloat moneyWidth = moneyLabel.frame.size.width;
    
    CGFloat maxW = UIScreen.mainScreen.bounds.size.width - selectWidth - iconWidth - marginToIcon - mainWidth - titleMargin - rightMargin - moneyWidth;
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.numberOfLines = 2;
//    titleLabel.text = @"啥叫等了好久撒旦撒的撒旦哈师大的撒好的撒的撒旦撒旦的撒";
    titleLabel.text = item.modelName;
    CGSize size = [titleLabel sizeThatFits:CGSizeMake(maxW, CGFLOAT_MAX)];
    CGFloat h = size.height;
    return h;
}

- (void)backViewAction {
    if (RES_OK(@selector(invoiceNewItemCellBack:))) {
        [self.delegate invoiceNewItemCellBack:self];
    }
}

- (void)selectButtonAction {
    if (RES_OK(@selector(invoiceNewItemCellSelect:))) {
        [self.delegate invoiceNewItemCellSelect:self];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [confirmLab addRoundedCorners:UIRectCornerTopRight|UIRectCornerBottomLeft radii:CGSizeMake(9, 9) rect:CGRectMake(0, 0, 52, 18)];
}

- (void)setItem:(CMPOcrInvoiceItemModel *)item from:(NSInteger)fromPage{
    _fromPage = fromPage;
    if (_fromPage==1) {
        statusLab.borderLayer = [CAShapeLayer layer];
    }else{
        statusLab.layer.cornerRadius = 4.f;
        statusLab.layer.borderColor = [UIColor cmp_specColorWithName:@"app-bgc3"].CGColor;
        statusLab.layer.borderWidth = 1.f;
    }
    self.item = item;
}

- (void)setItem:(CMPOcrInvoiceItemModel *)item{
    _item = item;
        
    self.selectButton.hidden = YES;
    _backView.backgroundColor = UIColor.whiteColor;
    self.selectButton.selected = item.isSelected;
    mainLab.hidden = !(item.mainDeputyTag == 1);
    
    if (_fromPage == 1) {//默认票夹
        self.selectButton.hidden = item.mainDeputyTag == 2;
        _backView.backgroundColor = item.mainDeputyTag==2 ? [UIColor cmp_specColorWithName:@"gray-bgc"]: [UIColor whiteColor];
    }else if(_fromPage == 2){//包详情
        _backView.backgroundColor = item.mainDeputyTag==2 ? [UIColor cmp_specColorWithName:@"gray-bgc"]: [UIColor whiteColor];
    }else if(_fromPage == 3){//关联发票
        self.selectButton.hidden = NO;
    }else if (_fromPage == 4){//我的
        _backView.backgroundColor = item.mainDeputyTag==2 ? [UIColor cmp_specColorWithName:@"gray-bgc"]: [UIColor whiteColor];
    }
    
    if ([item.fileType containsString:@"pdf"]) {
        iconImage.image = [UIImage imageNamed:@"ocr_card_pdf_placeholder"];
    }else{
        //原图
//        NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/commonImage/showImage?size=source&id=%@", item.fileId];
//        [iconImage sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"ocr_card_image_placeholder"]];
        
        //缩略图
        NSString *url = [CMPCore fullUrlForPathFormat:@"/commonimage.do?method=showImage&id=%@&createDate=%@&size=custom&w=56&h=50&igonregif=1&option.n_a_s=1",item.fileId,item.createDate];
        [iconImage sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"ocr_card_image_placeholder"]];
    }
    
    confirmLab.text = item.confirmStatusDisplay;
    if ([item.confirmStatusDisplay containsString:@"已确认"]) {
        confirmLab.textColor = [UIColor cmp_specColorWithName:@"theme-bdc"];
        confirmLab.backgroundColor = [[UIColor cmp_specColorWithName:@"theme-bdc"] colorWithAlphaComponent:0.1];
    }else{
        confirmLab.textColor = [UIColor cmp_specColorWithName:@"app-bgc5"];
        confirmLab.backgroundColor = [[UIColor cmp_specColorWithName:@"app-bgc5"] colorWithAlphaComponent:0.1];
    }
    
    statusLab.hidden = YES;
    if (_fromPage == 1) {
        confirmLab.hidden = YES;
        statusLab.hidden = NO;
        UIColor *textColor = [UIColor cmp_specColorWithName:@"app-bgc5"];
        NSString *titleStr = item.verifyStatusDisplay;
        switch (item.verifyStatus) {
            case InvoiceVerifyResult_Valid:
            {
                if ([NSString isNull:titleStr]) {
                    titleStr = @"已验真";
                }
                textColor = UIColorFromRGB(0x61B109);
            }
                break;
            case InvoiceVerifyResult_Invalid:
            {
                if ([NSString isNull:titleStr]) {
                    titleStr = @"已作废";
                }
                textColor = UIColorFromRGB(0x666666);
            }
                break;
            case InvoiceVerifyResult_HasNotVerify:
            {
                if ([NSString isNull:titleStr]) {
                    titleStr = @"未验真";
                }
                textColor = UIColorFromRGB(0xFF9900);
            }
                break;
            case InvoiceVerifyResult_NoNeedVerify:
            {
                if ([NSString isNull:titleStr]) {
                    titleStr = @"无需验真";
                }
                textColor = UIColorFromRGB(0x297FFB);
            }
                break;
            case InvoiceVerifyResult_CheckHasNoInfo:
            {
                if ([NSString isNull:titleStr]) {
                    titleStr = @"查无此票";
                }
                textColor = UIColorFromRGB(0xFF4141);
            }
                break;
                
            default:
            {
                if ([NSString isNull:titleStr]) {
                    titleStr = @"未知";
                }
            }
                break;
        }
        statusLab.text = titleStr;
        statusLab.textColor = textColor;
//        statusLab.layer.borderColor = textColor.CGColor;
        statusLab.borderLayer.strokeColor = textColor.CGColor;
    }
    else if (self.fromPage == 4) {//只能查看（我的->包->列表）
        //0：未报销 1.已删除  2.报销中 3.已报销
        confirmLab.hidden = YES;
        statusLab.hidden = NO;
        if (item.status == 2) {
            statusLab.text = item.statusDisplay?:@"报销中";
            statusLab.textColor = [UIColor cmp_specColorWithName:@"app-bgc5"];
            statusLab.layer.borderColor = [UIColor cmp_specColorWithName:@"app-bgc5"].CGColor;
        }else if(item.status == 3){
            statusLab.text = item.statusDisplay?:@"已报销";
            statusLab.textColor = [UIColor cmp_specColorWithName:@"app-bgc3"];
            statusLab.layer.borderColor = [UIColor cmp_specColorWithName:@"app-bgc3"].CGColor;
        }else{
            statusLab.hidden = YES;
        }
    }
    
    titleLab.text = item.modelName?:@"未知";
    
    dateLab.text = item.createDateDisplay;
    moneyLab.text = [NSString stringWithFormat:@"¥%@",item.total.length>0?item.total:@"0"];
    
    //加入更多信息
    [detailsStackView.arrangedSubviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];

    for (NSDictionary *fieldDict in item.displayFields) {
        UIStackView *s = [self getHorizonViewWithName:fieldDict[@"name"] value:fieldDict[@"value"]];
        [detailsStackView addArrangedSubview:s];
    }
    
    //是否信息缺失
    badImage.hidden = !item.isBad;
    if (_fromPage == 3) {
        badImage.hidden = YES;
    }
}

- (void)setCellEnable:(BOOL)enable{
//    _selectButton.enabled = enable;
    _selectButton.userInteractionEnabled = enable;
    UIImage *img = enable?[UIImage imageNamed:@"ocr_card_batch_manage_checked"]:[UIImage imageNamed:@"ocr_card_batch_manage_disable"];
    [self.selectButton setImage:img forState:UIControlStateSelected];
}

- (UIStackView *)getHorizonViewWithName:(NSString *)name value:(NSString *)value{
    UIStackView *stack = [[UIStackView alloc]init];
    stack.distribution = UIStackViewDistributionFillProportionally;
//    stack.spacing = 10;
    stack.axis = UILayoutConstraintAxisHorizontal;
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 17)];
    nameLabel.text = name;
    nameLabel.adjustsFontSizeToFitWidth = YES;
    nameLabel.minimumScaleFactor = 0.7;
    nameLabel.textColor = [UIColor cmp_specColorWithName:@"desc-fc"];
    nameLabel.font = [UIFont systemFontOfSize:12];
    [stack addArrangedSubview:nameLabel];
    
    [nameLabel sizeToFit];
    
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(nameLabel.frame.size.width > 60?80:60);
        make.height.mas_equalTo(17);
    }];
    
    UILabel *valueLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 17)];
    valueLabel.text = value;
    valueLabel.adjustsFontSizeToFitWidth = YES;
    valueLabel.minimumScaleFactor = 0.7;
    valueLabel.textColor = [UIColor blackColor];
    valueLabel.font = [UIFont systemFontOfSize:12];
    [stack addArrangedSubview:valueLabel];
    
    return stack;
}

- (void)hideStatus{
    confirmLab.hidden = YES;
}

@end
