//
//  CMPOcrPackageDetailHeaderView.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/20.
//

#import "CMPOcrPackageDetailHeaderView.h"

@interface CMPOcrPackageDetailHeaderView()

@property (nonatomic, assign) BOOL canControl;

@end

@implementation CMPOcrPackageDetailHeaderView

- (instancetype)initByControl:(BOOL)canControl{
    if (self = [super init]) {
        _canControl = canControl;
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    //搜索栏
    _searchBar = [[CustomCircleSearchBar alloc]initWithPlaceholder:@"输入发票类型或金额" size:CGSizeMake(UIScreen.mainScreen.bounds.size.width, 44)];
    [self addSubview:_searchBar];
    _searchBar.textfield.keyboardType = UIKeyboardTypeDefault;
    
    [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];

    if (_canControl) {
        //按钮视图
        UIView *addView = [self getAddBtnView];
        UIView *invoiceView = [self getSubmitInvoiceBtnView];
        
        UIStackView *horizontalStackView = [[UIStackView alloc]init];
        horizontalStackView.axis = UILayoutConstraintAxisHorizontal;
        [self addSubview:horizontalStackView];
        [horizontalStackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_searchBar.mas_bottom).offset(10);
            make.centerX.equalTo(self).offset(0);
            make.left.mas_equalTo(4);
            make.right.mas_equalTo(-4);
            make.height.mas_equalTo(80);
        }];
        [horizontalStackView addArrangedSubview:addView];
        [horizontalStackView addArrangedSubview:invoiceView];
        horizontalStackView.distribution = UIStackViewDistributionFillEqually;
        horizontalStackView.spacing = -10;
    }
    
}

- (void)addInvoiceBtnAction:(id)sender{
    if(_AddInvoiceBtnAction){
        _AddInvoiceBtnAction();
    }
}

- (void)submitInvoiceBtnAction:(id)sender{
    if (_SubmitInvoiceBtnAction) {
        _SubmitInvoiceBtnAction();
    }
}

#pragma mark - 按钮视图
- (UIView *)getAddBtnView{
    UIView *containerView = UIView.new;
    //背景图
    UIImageView *bgImageView = [[UIImageView alloc]init];
    bgImageView.image = [UIImage imageNamed:@"ocr_card_package_btn_blue"];
    [containerView addSubview:bgImageView];
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    //icon
    UIImageView *iconImageView = [[UIImageView alloc]init];
    iconImageView.image = [UIImage imageNamed:@"ocr_card_btn_icon_camera"];
    [containerView addSubview:iconImageView];
    //文字
    UILabel *label = UILabel.new;
    label.text = @"添加发票";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = UIColor.whiteColor;
    
    UIStackView *stackViewLabel = UIStackView.new;
    stackViewLabel.axis = UILayoutConstraintAxisVertical;
    stackViewLabel.distribution =UIStackViewDistributionEqualSpacing;
    UIView *whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 5)];
    [stackViewLabel addArrangedSubview:whiteView];
    [stackViewLabel addArrangedSubview:label];
    
    UIStackView *stackView = UIStackView.new;
    stackView.spacing = 10;
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    [containerView addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(containerView).offset(-7);
        make.centerX.equalTo(containerView).offset(0);
    }];
    
    [stackView addArrangedSubview:iconImageView];
    [stackView addArrangedSubview:stackViewLabel];
    
    //UIbutton
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"" forState:(UIControlStateNormal)];
    [btn addTarget:self action:@selector(addInvoiceBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [containerView addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    return containerView;
}
- (UIView *)getSubmitInvoiceBtnView{
    UIView *containerView = UIView.new;
    //背景图
    UIImageView *bgImageView = [[UIImageView alloc]init];
    bgImageView.image = [UIImage imageNamed:@"ocr_card_package_btn_green"];
    [containerView addSubview:bgImageView];
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    //icon
    UIImageView *iconImageView = [[UIImageView alloc]init];
    iconImageView.image = [UIImage imageNamed:@"ocr_card_btn_icon_invoice"];
    [containerView addSubview:iconImageView];
    //文字
    UILabel *label = UILabel.new;
    label.text = @"一键报销";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = UIColor.whiteColor;
    
    UIStackView *stackViewLabel = UIStackView.new;
    stackViewLabel.axis = UILayoutConstraintAxisVertical;
    stackViewLabel.distribution =UIStackViewDistributionEqualSpacing;
    UIView *whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 5)];
    [stackViewLabel addArrangedSubview:whiteView];
    [stackViewLabel addArrangedSubview:label];
    
    UIStackView *stackView = UIStackView.new;
    stackView.spacing = 10;
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    [containerView addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(containerView).offset(-7);
        make.centerX.equalTo(containerView).offset(0);
    }];
    
    [stackView addArrangedSubview:iconImageView];
    [stackView addArrangedSubview:stackViewLabel];
    
    //UIbutton
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"" forState:(UIControlStateNormal)];
    [btn addTarget:self action:@selector(submitInvoiceBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [containerView addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    return containerView;
}

@end
