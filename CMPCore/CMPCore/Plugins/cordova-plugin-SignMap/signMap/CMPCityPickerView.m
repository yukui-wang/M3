//
//  CMPCityPickerView.m
//  CMPCore
//
//  Created by wujiansheng on 16/8/1.
//
//

#import "CMPCityPickerView.h"

@interface CMPCityPickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSArray *_provinceList;
    NSInteger _provinceIndex;
    UIButton *_cancelButton;
    UIButton *_finishButton;
    UIView *_toolView;
    BOOL _language_ZhCN;
}
@end

@implementation CMPCityPickerView

- (void)dealloc
{
    SY_RELEASE_SAFELY(_provinceList);
    SY_RELEASE_SAFELY(_toolView);
    SY_RELEASE_SAFELY(_cityPickerView);
    [super dealloc];
}

- (void)setup
{
    _language_ZhCN = [CMPCore language_ZhCN];
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:.5f];
    if (!_toolView) {
        _toolView = [[UIView alloc] init];
        [self addSubview:_toolView];
        _toolView.backgroundColor = [UIColor whiteColor];
        
    }
    if (!_cityPickerView) {
        _cityPickerView = [[UIPickerView alloc] init];
        _cityPickerView.backgroundColor = [UIColor whiteColor];
        _cityPickerView.delegate = self;
        _cityPickerView.dataSource = self;
        [self addSubview:_cityPickerView];
    }
    _provinceIndex = 0;
    if (!_provinceList) {
        _provinceList = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CMPSignLbs.bundle/ProvincesAndCities.plist" ofType:nil]];
    }
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:SY_STRING(@"common_cancel") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:UIColorFromRGB(0x459bff) forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_toolView addSubview:_cancelButton];
    }
    
    if (!_finishButton) {
        _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_finishButton setTitle:SY_STRING(@"common_ok") forState:UIControlStateNormal];
        [_finishButton setTitleColor:UIColorFromRGB(0x459bff) forState:UIControlStateNormal];
        [_finishButton addTarget:self action:@selector(finishButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_toolView addSubview:_finishButton];
    }
}

- (void)customLayoutSubviews
{
    [_cancelButton setFrame:CGRectMake(15, 0, 60, 40)];
    [_finishButton setFrame:CGRectMake(self.width-75, 0, 60, 40)];
    [_toolView setFrame:CGRectMake(0, self.height-40-216, self.width, 40)];
    [_cityPickerView setFrame:CGRectMake(0, self.height-216, self.width, 216)];
}

#pragma mark  UIPickerViewDelegate,UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger count = 0;
    switch (component) {
        case 0:
            count = _provinceList.count;
            break;
        case 1: {
            NSDictionary *dic = [_provinceList objectAtIndex:_provinceIndex];
            NSArray *array = [dic objectForKey:@"Cities"];
            count = array.count;
        }
            break;
        default:
            break;
    }
    return count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.width/2;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = @"";
    switch (component) {
        case 0: {
            NSDictionary *dic = [_provinceList objectAtIndex:row];
            title = _language_ZhCN ? [dic objectForKey:@"State"]:[dic objectForKey:@"en"];
        }
            break;
        case 1: {
            NSDictionary *dic = [_provinceList objectAtIndex:_provinceIndex];
            NSArray *array = [dic objectForKey:@"Cities"];
            NSDictionary *city = [array objectAtIndex:row];
            title = _language_ZhCN ? [city objectForKey:@"city"]:[city objectForKey:@"en"];
        }
            break;
        default:
            break;
    }
    return title;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0: {
            _provinceIndex = row;
            [pickerView reloadComponent:1];
        }
            break;
        case 1: {
            
        }
            break;
        default:
            break;
    }
}

- (void)cancelButtonAction:(id)sender
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(cityPickerViewDidCancel)]) {
        [self.delegate cityPickerViewDidCancel];
    }
    [self dismiss];
}

- (void)finishButtonAction:(id)sender
{
    _provinceIndex = [_cityPickerView selectedRowInComponent:0];
    NSInteger cityRow = [_cityPickerView selectedRowInComponent:1];
    NSDictionary *dic = [_provinceList objectAtIndex:_provinceIndex];
    NSString *provinceName = [dic objectForKey:@"State"];
    NSArray *cityArray = [dic objectForKey:@"Cities"];
    NSMutableDictionary  *reslut = [NSMutableDictionary dictionary];
    if (cityRow <cityArray.count) {
        NSDictionary *city = [cityArray objectAtIndex:cityRow];
        reslut = [NSMutableDictionary  dictionaryWithDictionary:city];
    }
    NSArray *array = [NSArray arrayWithObjects:@"北京市",@"天津市",@"重庆市",@"上海市",@"香港",@"澳门", nil];
    if ([array containsObject:provinceName]) {
        provinceName = @"";
    }
    else {
        provinceName = _language_ZhCN ?[dic objectForKey:@"State"]:[dic objectForKey:@"en"];
    }
    [reslut setObject:provinceName forKey:@"province"];
    if (self.delegate &&[self.delegate respondsToSelector:@selector(cityPickerViewDidSelectCityWithInfo:)]) {
        [self.delegate cityPickerViewDidSelectCityWithInfo:reslut];
    }
    [self dismiss];
}

- (void)show
{
    CGRect f = self.frame;
    f.origin.y = 0;
    self.frame = f;
    
    [_toolView setFrame:CGRectMake(0, self.height, self.width, 40)];
    [_cityPickerView setFrame:CGRectMake(0, self.height+40, self.width, 216)];
    [UIView animateWithDuration:0.3 animations:^{
        [_toolView setFrame:CGRectMake(0, self.height-40-216, self.width, 40)];
        [_cityPickerView setFrame:CGRectMake(0, self.height-216, self.width, 216)];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss {
    
    [UIView animateWithDuration:0.3 animations:^{
        [_toolView setFrame:CGRectMake(0, self.height, self.width, 40)];
        [_cityPickerView setFrame:CGRectMake(0, self.height+40, self.width, 216)];
    } completion:^(BOOL finished) {
        CGRect f = self.frame;
        f.origin.y = self.height;
        self.frame = f;
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    if (p.y <_toolView.originY) {
        [self dismiss];
    }
}

@end
