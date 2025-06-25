//
//  CMPOcrInvoiceCheckListCell.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/14.
//

#import "CMPOcrInvoiceCheckListCell.h"
#import <CMPLib/UIImageView+WebCache.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPThemeManager.h>

@interface CMPOcrInvoiceCheckListCell()
//@property (weak, nonatomic) IBOutlet UIImageView *invoiceImageView;
//@property (weak, nonatomic) IBOutlet UILabel *imageNameLabel;
//@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
//@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
//@property (weak, nonatomic) IBOutlet UIButton *actionBtn;

@property (strong, nonatomic) UIImageView *invoiceImageView;
@property (strong, nonatomic) UILabel *imageNameLabel;
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UILabel *errorLabel;
@property (strong, nonatomic) UIButton *actionBtn;

@end

@implementation CMPOcrInvoiceCheckListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _invoiceImageView = [[UIImageView alloc]init];
        _invoiceImageView.contentMode = UIViewContentModeScaleAspectFill;
        _invoiceImageView.image = [UIImage imageNamed:@"ocr_card_image_placeholder"];
        _invoiceImageView.layer.cornerRadius = 4.f;
        _invoiceImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_invoiceImageView];
        [_invoiceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.left.mas_equalTo(14);
            make.width.height.mas_equalTo(72);
        }];
        
        _actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_actionBtn setTitle:@"" forState:(UIControlStateNormal)];
        [self.contentView addSubview:_actionBtn];
        [_actionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-10);
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(28);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
        }];
        [_actionBtn addTarget:self action:@selector(actionBtnClick:) forControlEvents:(UIControlEventTouchUpInside)];
        
        UIStackView *vStack = [[UIStackView alloc]init];
        vStack.axis = UILayoutConstraintAxisVertical;
        vStack.distribution = UIStackViewDistributionEqualSpacing;
        vStack.spacing = 5;
        vStack.alignment = UIStackViewAlignmentFill;
        [self.contentView addSubview:vStack];
        [vStack mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_invoiceImageView.mas_right).offset(10);
            make.right.mas_equalTo(_actionBtn.mas_left).offset(-10);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
        }];
        
        _imageNameLabel = [[UILabel alloc]init];
        _imageNameLabel.font = [UIFont systemFontOfSize:14];
        _imageNameLabel.textColor = UIColor.blackColor;
        _imageNameLabel.numberOfLines = 2;
        [vStack addArrangedSubview:_imageNameLabel];
        
        _progressView = [UIProgressView new];
        [vStack addArrangedSubview:_progressView];
        
        _errorLabel = [UILabel new];
        _errorLabel.textColor = [UIColor cmp_specColorWithName:@"hl-bgc3"];
        _errorLabel.font = [UIFont systemFontOfSize:12];
        _errorLabel.numberOfLines = 2;
        [vStack addArrangedSubview:_errorLabel];
        
    }
    return self;
}

//- (void)layoutSubviews{
//    [super layoutSubviews];
//    self.contentView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
//}
//
//- (void)awakeFromNib {
//    [super awakeFromNib];
//    [_actionBtn setTitle:@"" forState:(UIControlStateNormal)];
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)actionBtnClick:(id)sender {
    NSLog(@"actionBtnClick");
    if (_ActionBtnBlock) {
        _ActionBtnBlock(_itemModel);
    }
}

- (void)setItemModel:(CMPOcrItemModel *)itemModel{
    _itemModel = itemModel;
    _invoiceImageView.image = nil;
    if (itemModel.image) {
        _invoiceImageView.image = itemModel.image;
    }else if ([itemModel.fileType containsString:@"pdf"]) {
        _invoiceImageView.image = [UIImage imageNamed:@"ocr_card_pdf_placeholder"];
    }else if (itemModel.filePath.length>0){//优先显示本地copy后的图片
        _invoiceImageView.image = [UIImage imageWithContentsOfFile:itemModel.filePath];
    }else if (itemModel.fileId.length>0){//显示网络图片
        NSString *url = [CMPCore fullUrlForPathFormat:@"/commonimage.do?method=showImage&id=%@&createDate=&size=custom&w=60&h=60&igonregif=1&option.n_a_s=1",itemModel.fileId];
        [_invoiceImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"ocr_card_image_placeholder"]];
    }else{
        _invoiceImageView.image = [UIImage imageNamed:@"ocr_card_image_placeholder"];
    }
    
    _imageNameLabel.text = itemModel.filename?:[itemModel.fileId stringByAppendingFormat:@".%@",itemModel.fileType];
    
    UIColor *textColor = UIColor.lightGrayColor;//tip color,fail color = red
    NSString *text = @"";
    _actionBtn.hidden = YES;
    _progressView.hidden = NO;
    UIImage *btnImage = nil;
    
    switch (itemModel.taskStatus) {
        case CMPOcrItemStateUploadPause:
            _progressView.progress = 0.0;
            textColor = UIColor.lightGrayColor;
            text = @"已暂停";
            _actionBtn.hidden = NO;
            btnImage = [UIImage imageNamed:@"ocr_card_check_upload"];
            break;
        case CMPOcrItemStateUploadError:
            _progressView.progress = 0.0;
            textColor = UIColor.redColor;
            text = @"上传失败";
            _actionBtn.hidden = NO;
            btnImage = [UIImage imageNamed:@"ocr_card_check_refresh"];
            break;
        case CMPOcrItemStateNotUpload:
            _progressView.progress = 0.15;
            textColor = UIColor.lightGrayColor;
            text = @"正在上传中...";
            _actionBtn.hidden = NO;
            btnImage = [UIImage imageNamed:@"ocr_card_check_pause"];
            break;
        case CMPOcrItemStateUploadSuccess:
            _progressView.progress = 0.34;
            textColor = UIColor.lightGrayColor;
            text = @"上传成功";
            break;
//        case CMPOcrItemStateWaitSubmit:
//            _progressView.progress = 0.4;
//            textColor = UIColor.lightGrayColor;
//            text = @"等待提交";
//            break;
        case CMPOcrItemStateSubmitFail:
            _progressView.progress = 0.45;
            textColor = UIColor.redColor;
            text = @"提交识别失败";
            _actionBtn.hidden = NO;
            btnImage = [UIImage imageNamed:@"ocr_card_check_refresh"];
            break;
        case CMPOcrItemStateSubmitSuccess:
            _progressView.progress = 0.6;
            textColor = UIColor.lightGrayColor;
            text = @"等待识别...";
            break;
        case CMPOcrItemStateCheckProcessing:
            _progressView.progress = 0.75;
            textColor = UIColor.lightGrayColor;
            text = @"正在处理中...";
            break;
        case CMPOcrItemStateCheckFailed:
//        case CMPOcrItemStateCheckSuspend:
        case CMPOcrItemStateCheckWaiting:
        case CMPOcrItemStateCheckBlurring:
//        case CMPOcrItemStateCheckRepeat:
        case CMPOcrItemStateOcrServerFail:
        case CMPOcrItemStateOcrNoAuthCount:
            _progressView.hidden = YES;
            textColor = UIColor.redColor;
            text = itemModel.taskStatusDisplay;
            _actionBtn.hidden = NO;
            btnImage = [UIImage imageNamed:@"ocr_card_check_refresh"];
            break;
        case CMPOcrItemStateCheckSuspend://ks fix -- V5-38503【智能报销】ios端，上传了发票后，发票一直处于"识别中"
        case CMPOcrItemStateCheckRepeat:
        case CMPOcrItemStateMixResult://ks fix -- V5-36176【智能报销】混贴发票重新识别按钮不生效
            _progressView.hidden = YES;
            textColor = UIColor.redColor;
            text = itemModel.taskStatusDisplay;
            break;
        default:
        {
            NSInteger taskStatus = itemModel.taskStatus;
            if (taskStatus >= 12 && taskStatus < 80) {
                _progressView.hidden = YES;
                textColor = UIColor.redColor;
                text = itemModel.taskStatusDisplay;
                _actionBtn.hidden = NO;
                btnImage = [UIImage imageNamed:@"ocr_card_check_refresh"];
            }else if (taskStatus >= 80 && taskStatus < 100){
                _progressView.hidden = YES;
                textColor = UIColor.redColor;
                text = itemModel.taskStatusDisplay;
            }else{
                textColor = UIColor.lightGrayColor;
                text = @"正在处理中...";
            }
        }
            break;
    }
    
    _errorLabel.textColor = textColor;
    _errorLabel.text = text;
    [_actionBtn setImage:btnImage forState:(UIControlStateNormal)];
}
@end
