//
//  CMPSignFloatView.m
//  CMPCore
//
//  Created by wujiansheng on 16/7/28.
//
//

#import "CMPSignFloatView.h"

@interface CMPSignFloatView()
{
    UIImageView *_cityIamgeView;
    UIImageView *_adressIamgeView;
    UIView *_lineView;
    UILabel *_cityLabel;
    
}

@end

@implementation CMPSignFloatView

- (void)dealloc
{
    SY_RELEASE_SAFELY(_cityIamgeView);
    SY_RELEASE_SAFELY(_adressIamgeView);
    SY_RELEASE_SAFELY(_lineView);
    SY_RELEASE_SAFELY(_cityLabel);
    SY_RELEASE_SAFELY(_adressField);
    [super dealloc];
}

- (void)setup
{
    self.backgroundColor = [UIColor whiteColor];
//    self.layer.cornerRadius = 5;
//    self.layer.shadowOffset = CGSizeMake(0, 1);
//    self.layer.shadowOpacity = 0.50;
//    
    if (!_cityIamgeView) {
        _cityIamgeView = [[UIImageView alloc] init];
        _cityIamgeView.image = [UIImage imageNamed:@"CMPSignLbs.bundle/img_city.png"];
        [self addSubview:_cityIamgeView];
    }
    
    if (!_cityLabel) {
        _cityLabel = [[UILabel alloc] init];
        _cityLabel.backgroundColor = [UIColor clearColor];
        _cityLabel.font =  FONTSYS(16);
        _cityLabel.textColor = UIColorFromRGB(0x333333);
        _cityLabel.text = SY_STRING(@"common_pleaseSelectLocation");
        [self addSubview:_cityLabel];
    }
    
    if (!_cityButton) {
        _cityButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_cityButton];
    }
    
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorFromRGB(0xc7c7c7);
        [self addSubview:_lineView];
    }
    
    if (!_adressIamgeView) {
        _adressIamgeView = [[UIImageView alloc] init];
        _adressIamgeView.image = [UIImage imageNamed:@"CMPSignLbs.bundle/img_adress.png"];
        [self addSubview:_adressIamgeView];
    }
    
    if (!_adressField) {
        _adressField = [[UITextField alloc] init];
        _adressField.font = FONTSYS(16);
        _adressField.textColor = UIColorFromRGB(0x333333);
        _adressField.placeholder = SY_STRING(@"common_pleaseSelectLocation");
        _adressField.returnKeyType = UIReturnKeySearch;
        [self addSubview:_adressField];
    }
}

- (void)customLayoutSubviews
{
    CGFloat y = 0;
    CGFloat x = 19;
    CGFloat hafH = 48;
    [_cityIamgeView setFrame:CGRectMake(x, y+19, 10, 10)];
    x += _cityIamgeView.width+ 10;
    [_cityLabel setFrame:CGRectMake(x, 0, self.width-9-x, hafH)];
    y += hafH;

    [_cityButton setFrame:CGRectMake(x, 0, self.width-x, hafH)];
    
    [_lineView setFrame:CGRectMake(0, y, self.width, 1)];
    y += 1;
    x = 19;
    [_adressIamgeView setFrame:CGRectMake(x, y +19, 10, 10)];
    x += _cityIamgeView.width+ 10;
    [_adressField setFrame:CGRectMake(x, y, self.width-9-x, hafH)];

}

- (void)layoutProvince:(NSString *)province  city:(NSString *)city address:(NSString *)address
{
    if (!province) {
        province = @"";
    }
    if (!city) {
        city = @"";
    }
    
    [_cityLabel setText:[NSString stringWithFormat:@"%@ %@",province,city]];
    [_adressField setText:address];
}
@end
