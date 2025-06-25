//
//  CMPOcrDetailListCell.m
//  CMPOcr
//
//  Created by 张艳 on 2021/11/24.
//

#import "CMPOcrDetailListCell.h"
#import "CustomDefine.h"
#import "UIView+Layer.h"
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/NSDate+CMP.h>
#import "NSArray+MutableCopyCatetory.h"
@interface CMPOcrDetailListCell ()<UITextFieldDelegate>
{
    UILabel         *titleLab;
    UITextField     *inputField;
    UILabel         *contentLab;
    UIImageView     *actionImage;
    UIView          *lineLab;
    UILabel *_tipLb;
}
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, assign) BOOL canEdit;
@property(nonatomic, strong) MASConstraint * offsetYConstraint;
@end

@implementation CMPOcrDetailListCell

- (NSDateFormatter *)formatter{
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc]init];
    }
    return _formatter;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _canEdit = YES;
        [self makeUI];
    }
    return self;
}

- (void)makeUI{
    //title
    titleLab = [[UILabel alloc] init];
    titleLab.textAlignment = NSTextAlignmentLeft;
    titleLab.numberOfLines = 0;
    titleLab.font = [UIFont systemFontOfSize:16];
    titleLab.textColor = UIColor.blackColor;
    [titleLab sizeToFit];
    [self.contentView addSubview:titleLab];
    
    //>indicator
    actionImage = [[UIImageView alloc] init];
    actionImage.image = [UIImage imageNamed:@"ocr_card_default_arrow_right"];
    [self.contentView addSubview:actionImage];
    
    //input
    inputField = [[UITextField alloc] init];
    inputField.delegate = self;
    inputField.textColor = [UIColor cmp_specColorWithName:@"desc-fc"];
    inputField.textAlignment = NSTextAlignmentRight;
    inputField.returnKeyType = UIReturnKeyDone;
    inputField.font = [UIFont systemFontOfSize:16];
    inputField.placeholder = @"请输入";
    [self.contentView addSubview:inputField];
    
    //content
    contentLab = [[UILabel alloc] init];
    contentLab.textAlignment = NSTextAlignmentRight;
    contentLab.font = [UIFont systemFontOfSize:CMPShiPei(16)];
    contentLab.hidden = YES;
    [self.contentView addSubview:contentLab];
    
    //分割线
    lineLab = [[UILabel alloc] init];
    lineLab.backgroundColor = [UIColor cmp_specColorWithName:@"cmp-bdc"];
    [self.contentView addSubview:lineLab];
    
    _tipLb = [[UILabel alloc] init];
    _tipLb.textAlignment = NSTextAlignmentRight;
    _tipLb.font = [UIFont systemFontOfSize:CMPShiPei(14)];
    _tipLb.textColor = UIColorFromRGB(0xFB191F);
    _tipLb.hidden = YES;
    [_tipLb sizeToFit];
    _tipLb.numberOfLines = 0;
    [self.contentView addSubview:_tipLb];
    
    [self remakeConstraint:0];
}

- (void)updateOffsetYConstraint:(CGFloat)offsetY{
//    NSLayoutConstraint *layoutConstraint = [self.offsetYConstraint valueForKey:@"layoutConstraint"];
//    layoutConstraint.constant = offsetY;
}

- (void)remakeConstraint:(CGFloat)offsetY{
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
//        self.offsetYConstraint = make.centerY.mas_equalTo(self.contentView.mas_centerY).offset(offsetY);
        make.width.mas_equalTo(100);
        make.top.offset(15);
//        make.bottom.offset(-15);
    }];
    [actionImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(15);
        make.height.mas_equalTo(16);
        make.right.mas_equalTo(-14);
        make.centerY.mas_equalTo(titleLab.mas_centerY);
    }];
    [inputField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(titleLab.mas_centerY);
        make.right.mas_equalTo(-(15+14+2));
        make.left.mas_equalTo(titleLab.mas_right).offset(5);
    }];
    [contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(titleLab.mas_centerY);
        make.right.mas_equalTo(-(15+14+2));
        make.left.mas_equalTo(titleLab.mas_right).offset(5);
    }];
    [lineLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.right.mas_equalTo(-12);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(0);
        make.top.equalTo(titleLab.mas_bottom).offset(15);
    }];
}

- (void)hideLine{
    lineLab.hidden = YES;
}

- (void)setParam:(NSDictionary *)param canEdit:(BOOL)canEdit{
    _canEdit = canEdit;
    self.param = param;
}

- (void)setParam:(NSDictionary *)param{
    _param = param;
    NSString *key = param.allKeys.firstObject;
    NSDictionary *value = [param objectForKey:key];
    NSString *desc = [value objectForKey:@"desc"];
    NSString *content = [value objectForKey:@"value"];
    if ([@"kind" isEqualToString:key] && value[@"localName"]) {
        content = value[@"localName"];
    }
    
//    BOOL canEdit;
//    id outsideTag_canEdit = param[@"canEdit"];
//    if (outsideTag_canEdit && [outsideTag_canEdit isKindOfClass:NSString.class]) {
//        canEdit = [outsideTag_canEdit isEqualToString:@"1"];
//    }else{
//        if (_canEdit) {
//            NSString *validUsedFlag = [NSString stringWithFormat:@"%@",param[@"validUsedFlag"]];
//            if ([NSString isNotNull:validUsedFlag]) {
//                canEdit = ![validUsedFlag boolValue];
//            }
//        }
//    }

    NSInteger type = [[value objectForKey:@"type"] integerValue];
    BOOL canEdit = [[value objectForKey:@"canEdit"] boolValue];
    BOOL showNext = [[value objectForKey:@"showNext"] boolValue];
    
//    BOOL showNext;
//    id outsideTag_showNext = param[@"showNext"];
//    if (outsideTag_showNext && [outsideTag_showNext isKindOfClass:NSString.class]) {
//        showNext = [outsideTag_showNext isEqualToString:@"1"];
//    }

    NSString *tipMsg = [value objectForKey:@"tipMsg"];
        
    if (type == 6) {
        NSString *dateValue = [value objectForKey:@"value"];
        if (dateValue.length > 0 && ![dateValue isEqualToString:@"0"]) {
            NSTimeInterval time = [dateValue longLongValue]/1000;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
            [self.formatter setDateFormat:@"yyyy年MM月dd日"];
            content = [self.formatter stringFromDate:date];
        }else{
            content = @"";
        }
    }else if (type == 7){
        NSString *dateValue = [value objectForKey:@"value"];
        if (dateValue.length > 0 && ![dateValue isEqualToString:@"0"]) {
            NSTimeInterval time = [dateValue longLongValue]/1000;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
            [self.formatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
            content = [self.formatter stringFromDate:date];
        }else{
            content = @"";
        }
    }
    
    lineLab.hidden = NO;
    titleLab.text = desc;
    
    inputField.text = content;
    contentLab.text = content;
    
    UIColor *canEditContentDefaultTextColor = [UIColor cmp_specColorWithName:@"desc-fc"];
    UIColor *cannotEditContentDefaultTextColor = UIColorFromRGB(0xC5C5C5);
    
    inputField.textColor = cannotEditContentDefaultTextColor;
    contentLab.textColor = cannotEditContentDefaultTextColor;
    
    if (_canEdit) {
        if (canEdit) {
            contentLab.hidden = YES;
            inputField.hidden = NO;
            inputField.textColor = canEditContentDefaultTextColor;
        }else{
            contentLab.hidden = NO;
            inputField.hidden = YES;
        }
        if (type == 6
            || type == 7
            || [key isEqualToString:@"ocr_local_key_invoice_kind"]
            || [key isEqualToString:@"kind"]) {//6为日期7为时间
            contentLab.textColor = [UIColor cmp_specColorWithName:@"theme-fc"];            
            contentLab.hidden = NO;
            inputField.hidden = YES;
            
            if (canEdit) {
                showNext = YES;
            }
        }

    }else{
        
        contentLab.hidden = NO;
        inputField.hidden = YES;
        if ([content isEqualToString:@"0"] && [key isEqualToString:@"ocr_local_key_associate_invoice"]) {
            contentLab.text = @"";
        }
    }
    actionImage.hidden = !showNext;
    if (inputField.hidden == NO) {
        switch (type) {
            case 1:
                inputField.keyboardType = UIKeyboardTypeNumberPad;
                break;
            case 2:
            case 3:
                inputField.keyboardType = UIKeyboardTypeDecimalPad;
                break;
            default:
                inputField.keyboardType = UIKeyboardTypeDefault;
                break;
        }
    }
    
    [inputField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(titleLab.mas_centerY);
        make.right.mas_equalTo(actionImage.hidden?-14:-(15+14+2));
        make.left.mas_equalTo(titleLab.mas_right).offset(5);
    }];
    [contentLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(titleLab.mas_centerY);
        make.right.mas_equalTo(actionImage.hidden?-14:-(15+14+2));
        make.left.mas_equalTo(titleLab.mas_right).offset(5);
    }];
    
    if ([NSString isNotNull:tipMsg]) {
        _tipLb.text = tipMsg;
        _tipLb.hidden = NO;
        [titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(16);
            make.width.mas_equalTo(100);
            make.top.offset(15);
        }];
        [_tipLb mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(contentLab.mas_bottom).offset(15);
            make.right.mas_equalTo(actionImage.hidden?-14:-(15+14+2));
            make.left.mas_equalTo(titleLab.mas_left).offset(5);
        }];
        [lineLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12);
            make.right.mas_equalTo(-12);
            make.height.mas_equalTo(1);
            make.bottom.mas_equalTo(0);
            make.top.mas_equalTo(_tipLb.mas_bottom).offset(15);
        }];
    }else{
        _tipLb.text = @"";
        _tipLb.hidden = YES;
        [titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(16);
//            self.offsetYConstraint = make.centerY.offset(0);
            make.width.mas_equalTo(100);
            make.top.offset(15);
//            make.bottom.offset(-15);
        }];
        [lineLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12);
            make.right.mas_equalTo(-12);
            make.height.mas_equalTo(1);
            make.bottom.mas_equalTo(0);
            make.top.equalTo(titleLab.mas_bottom).offset(15);
        }];
    }
    
    self.backgroundColor = [UIColor whiteColor];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (BOOL)deptNumInputShouldNumber:(NSString *)str
{
   if (str.length == 0) {
        return NO;
    }
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}


+ (BOOL)isNumber:(NSString *)strValue
{
    if (strValue == nil || [strValue length] <= 0)
    {
        return NO;
    }
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    NSString *filtered = [[strValue componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    if (![strValue isEqualToString:filtered])
    {
        return NO;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!string || string.length==0) {
        return YES;
    }
    NSString *key = _param.allKeys.firstObject;
    NSDictionary *value = [_param objectForKey:key];
    NSInteger type = [[value objectForKey:@"type"] integerValue];
    if (type < 4) {
        BOOL isValid = [CMPOcrDetailListCell isNumber:string];
        return isValid;
    }
    NSInteger curLen = textField.text.length;
    if (curLen + string.length > 50) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSString *key = _param.allKeys.firstObject;
    NSDictionary *value = [_param objectForKey:key];
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:[value mutableDicDeepCopy]];
    mDict[@"value"] = textField.text?:@"";
    if (_DidEditBlock && mDict) {
        _param = @{
            key : mDict
        };
        _DidEditBlock(_param);
    }
    [textField resignFirstResponder];
}

@end
