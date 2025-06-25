//
//  CMPOcrDetailTableViewController.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/29.
//

#import "CMPOcrDetailTableViewController.h"
#import <CMPLib/JJStockView.h>
#import "CMPOcrInvoiceDetailDataProvider.h"
#import "CustomDefine.h"
#import "UILabel+Attribute.h"
#import "NSArray+MutableCopyCatetory.h"
#import <CMPLib/CMPAlertView.h>
#import "CMPOcrScheduleViewModel.h"
@interface CMPOcrDetailTableViewController ()<StockViewDataSource,StockViewDelegate,UITextFieldDelegate>

@property(nonatomic,readwrite,strong)JJStockView* stockView;
@property (nonatomic, strong) CMPOcrInvoiceDetailDataProvider   *dataProvider;
@property (nonatomic, strong) NSDictionary *originDataDict;
@property (nonatomic, strong) NSDictionary *originCopyDataDict;//备份的原始数据
@property (nonatomic, strong) NSMutableArray *topHeadArr;
@property (nonatomic, strong) NSDictionary *topLeftDict;
@property (nonatomic, strong) NSMutableArray *rows;
@property (nonatomic, strong) NSMutableArray *firstColumnArr;

@property (nonatomic, strong) UITextField *currentTextField;
@property (nonatomic, strong) UILabel *currentLabel;

@property (nonatomic, strong) CMPOcrScheduleViewModel *scheduleViewModel;
@property (nonatomic, assign) BOOL changed;
@property (nonatomic, weak) UIButton *saveButton;

@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation CMPOcrDetailTableViewController
- (void)dealloc{
    NSLog(@"%@-dealloc",self.class);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"明细表";
    
    [self.view addSubview:self.stockView];
    
    CGFloat top = CGRectGetMaxY(self.bannerNavigationBar.frame);
    [self.stockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(top);
    }];
    
    [self fetchScheduleInvoice];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

//我的页面进入不允许编辑
- (BOOL)canEdit{
    return self.rdv_tabBarController.selectedIndex != 2;
}

- (void)closeKeyboard{
    [self.view endEditing:YES];
}

- (void)fetchScheduleInvoice {
    weakify(self);
    [self.dataProvider fetchScheduleInvoiceList:self.invoiceId success:^(NSDictionary * _Nonnull data) {
        strongify(self);
        NSDictionary *dataDict = data[@"data"];
        self.originDataDict = [dataDict copy];
        self.originCopyDataDict = [self.originDataDict mutableDicDeepCopy];
        //首行
        self.topHeadArr = [NSMutableArray arrayWithArray:dataDict[@"columns"]];
        //左上标题
        self.topLeftDict = self.topHeadArr.firstObject;
        [self.topHeadArr removeObject:self.topHeadArr.firstObject];
        //row
        self.rows = [NSMutableArray arrayWithArray:dataDict[@"rows"]];
        //首列
        self.firstColumnArr = [NSMutableArray new];
        NSMutableArray *tmpRows = [NSMutableArray new];
        for (NSArray *originRow in self.rows) {
            NSMutableArray *changedRow = [NSMutableArray arrayWithArray:originRow];
            [self.firstColumnArr addObject:changedRow.firstObject];
            [changedRow removeObject:changedRow.firstObject];
            [tmpRows addObject:changedRow];
        }
        self.rows = tmpRows;
        [self.stockView reloadStockView];
        
    } fail:^(NSError * _Nonnull error) {
        strongify(self)
        [self cmp_showHUDError:error];
    }];
}

//自定义返回btn
- (void)setupBannerButtons{
    self.bannerNavigationBar.leftMargin = 0;
    self.backBarButtonItemHidden = YES;
    UIButton *backButton = [UIButton buttonWithImageName:@"navBackButton" frame:kBannerImageButtonFrame buttonImageAlignment:kButtonImageAlignment_Center modifyImage:NO];
    self.bannerNavigationBar.leftBarButtonItems = [NSArray arrayWithObject:backButton];
    [backButton addTarget:self action:@selector(backBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //保存
    self.bannerNavigationBar.rightMargin = 10;
    self.saveButton = [UIButton buttonWithTitle:@"保存" textColor:UIColor.blackColor textSize:16];
    self.bannerNavigationBar.rightBarButtonItems = [NSArray arrayWithObject:self.saveButton];
    [self.saveButton addTarget:self action:@selector(saveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.saveButton.hidden = YES;
}
//返回btn事件
- (void)backBarButtonAction:(id)sender{
    [self.view endEditing:YES];
    if (_changed) {
        [[[CMPAlertView alloc]initWithTitle:@"" message:@"当前发票信息已修改，确认是否保存？" cancelButtonTitle:@"不保存" otherButtonTitles:@[@"确认保存"] callback:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self saveUpdate];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }] show];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)saveButtonAction:(id)sender{
    [self saveUpdate];
}

- (void)saveUpdate{
    //遍历添加userOverrideFlag
    NSArray *rowsChangeArr = _originDataDict[@"rows"];
    NSArray *rows = _originCopyDataDict[@"rows"];
    BOOL changed = NO;
    for (int i=0; i<rows.count; i++) {
        NSArray *rowChange = rowsChangeArr[i];
        NSArray *row = rows[i];
        for (int j=0; j<row.count; j++) {
            NSDictionary *rowDict = row[j];
            NSDictionary *rowChangeDict = rowChange[j];
            changed = ![rowDict isEqualToDictionary:rowChangeDict];
            if (changed) {
                [rowChangeDict setValue:@"true" forKey:@"userOverrideFlag"];
            }
        }
    }
    
    __weak typeof(self) wSelf = self;
    [self.scheduleViewModel updateScheduleByInvoiceId:self.invoiceId param:self.originDataDict completion:^(NSError *err) {
        if (err) {
            [wSelf cmp_showHUDError:err];
        }else{
            wSelf.changed = NO;
            [wSelf cmp_showHUDWithText:@"保存成功"];
            wSelf.saveButton.hidden = YES;
            wSelf.originCopyDataDict = [wSelf.originDataDict mutableDicDeepCopy];
        }
    }];
}

//比较变更
- (BOOL)compareIfChanged{
    NSArray *rowsChangeArr = _originDataDict[@"rows"];
    NSArray *rows = _originCopyDataDict[@"rows"];
    BOOL changed = NO;
    for (int i=0; i<rows.count; i++) {
        NSArray *rowChange = rowsChangeArr[i];
        NSArray *row = rows[i];
        for (int j=0; j<row.count; j++) {
            NSDictionary *rowDict = row[j];
            NSDictionary *rowChangeDict = rowChange[j];
            changed = ![rowDict isEqualToDictionary:rowChangeDict];
            if (changed) {
                break;
            }
        }
        if (changed) {
            break;
        }
    }
    return changed;
}
#pragma mark - Stock DataSource
//首列内容数量
- (NSUInteger)countForStockView:(JJStockView*)stockView{
    return self.firstColumnArr.count;
}

//首列内容
- (UIView*)titleCellForStockView:(JJStockView*)stockView atRowPath:(NSUInteger)row{
    NSDictionary *dict = self.firstColumnArr[row];
    UILabel *label = [self createLabelWithFrame:CGRectMake(0, 0, 100, 30)];
    label.param = dict;
    label.text = [self timeStrFrom:dict];
    return label;
}

//内容 row
- (UIView*)contentCellForStockView:(JJStockView*)stockView atRowPath:(NSUInteger)row{
    NSMutableArray *rowArr = self.rows[row];
    CGFloat w = 100;
    CGFloat h = 30;
    UIView* bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rowArr.count * w, h)];
    
    bg.backgroundColor = UIColor.whiteColor;
    
    for (int i = 0; i < rowArr.count; i++) {
        UILabel* label = [self createLabelWithFrame:CGRectMake(i * w, 0, w, h)];
        [bg addSubview:label];
        NSDictionary *dict = rowArr[i];
        label.param = dict;
        label.rowNum = row;//第几行
        label.text = [self timeStrFrom:dict];
    }
    return bg;
}

- (NSString *)timeStrFrom:(NSDictionary *)dict{
    NSInteger type = [dict[@"type"] integerValue];
    NSString *value = dict[@"value"];
    if (value.length) {
        if (type == 6) {
            NSTimeInterval time = [value longLongValue]/1000;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
            [self.formatter setDateFormat:@"yyyy年MM月dd日"];
            value = [self.formatter stringFromDate:date];
        }else if (type == 7){
            NSTimeInterval time = [value longLongValue]/1000;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
            [self.formatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
            value = [self.formatter stringFromDate:date];
        }
    }
    return value;
}

#pragma mark - Stock Delegate
//row height
- (CGFloat)heightForCell:(JJStockView*)stockView atRowPath:(NSUInteger)row{
    return 30.0f;
}

//首行高度
- (CGFloat)heightForHeadTitle:(JJStockView*)stockView{
    return 40.0f;
}

//左上角标题
- (UIView*)headRegularTitle:(JJStockView*)stockView{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    label.layer.borderColor = [UIColor cmp_specColorWithName:@"cmp-bdc"].CGColor;
    label.layer.borderWidth = .5f;
    
    label.text = self.topLeftDict[@"name"];//@"标题";
    label.backgroundColor = [UIColor cmp_specColorWithName:@"gray-bgc"];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

//首行title
- (UIView*)headTitle:(JJStockView*)stockView{
    CGFloat w = 100;
    CGFloat h = 40;
    
    UIView* bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.topHeadArr.count*w, h)];
    bg.backgroundColor = [UIColor cmp_specColorWithName:@"gray-bgc"];
    
    for (int i = 0; i < self.topHeadArr.count; i++) {
        UILabel* label = [self createLabelWithFrame:CGRectMake(i * w, 0, w, h)];
        label.userInteractionEnabled = NO;
        [bg addSubview:label];
        
        NSDictionary *dict = self.topHeadArr[i];
        label.text = dict[@"name"];//[NSString stringWithFormat:@"标题:%d",i];
    }
    return bg;
}

- (UILabel *)createLabelWithFrame:(CGRect)frame{
    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    label.layer.borderColor = [UIColor cmp_specColorWithName:@"cmp-bdc"].CGColor;
    label.layer.borderWidth = .5f;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.textColor = [UIColor blackColor];
    if ([self canEdit]) {
        label.userInteractionEnabled = YES; // 一定要设置
        [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelClick:)]];
    }
    return label;
}

- (void)labelClick:(UITapGestureRecognizer *)tap{
    [self.view endEditing:YES];
    UILabel *label = (UILabel *)tap.view;
    _currentLabel = nil;
    
    NSDictionary *param = label.param;
    NSInteger type = [param[@"type"] integerValue];
    if (type == 6) {//日期
        UIDatePicker *datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(10, 20, UIScreen.mainScreen.bounds.size.width - 20, 160)];
        datePicker.datePickerMode = UIDatePickerModeDate;
        NSTimeInterval time = [param[@"value"] doubleValue];
        datePicker.date = [NSDate dateWithTimeIntervalSince1970:time/1000];
        if (@available(iOS 13.4, *)) {
            datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        }
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n" message:@"" preferredStyle:(UIAlertControllerStyleActionSheet)];
        alertVC.modalPresentationStyle = UIModalPresentationPopover;
        [alertVC.view addSubview:datePicker];
        [datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(alertVC.view);
        }];
        
        __weak typeof(self) weakSelf = self;
        UIAlertAction *sureAtion = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            NSDate *lastDate = datePicker.date;
            NSTimeInterval timestamp = [lastDate timeIntervalSince1970] * 1000;
            NSString *timeStr = [NSString stringWithFormat:@"%.0f",timestamp];
            
            NSTimeInterval time = [timeStr longLongValue]/1000;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
            [weakSelf.formatter setDateFormat:@"yyyy年MM月dd日"];
            NSString * value = [weakSelf.formatter stringFromDate:date];
            label.text = value;
            
            [label.param setValue:timeStr forKey:@"value"];
            weakSelf.changed = [weakSelf compareIfChanged];
            weakSelf.saveButton.hidden = !weakSelf.changed;
        }];
        [alertVC addAction:sureAtion];
        UIAlertAction *cancelAtion = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertVC addAction:cancelAtion];
        [self presentViewController:alertVC animated:YES completion:^{}];
    }else if (type == 7) {
        UIDatePicker *datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(10, 20, UIScreen.mainScreen.bounds.size.width - 20, 160)];//date216
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        NSTimeInterval time = [param[@"value"] doubleValue];
        datePicker.date = [NSDate dateWithTimeIntervalSince1970:time/1000];
        if (@available(iOS 13.4, *)) {
            datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        }
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n" message:@"" preferredStyle:(UIAlertControllerStyleActionSheet)];
        alertVC.modalPresentationStyle = UIModalPresentationPopover;
        [alertVC.view addSubview:datePicker];
        [datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(alertVC.view);
        }];
        __weak typeof(self) weakSelf = self;
        UIAlertAction *sureAtion = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            NSDate *lastDate = datePicker.date;
            NSTimeInterval timestamp = [lastDate timeIntervalSince1970] * 1000;
            NSString *timeStr = [NSString stringWithFormat:@"%.0f",timestamp];
            
            NSTimeInterval time = [timeStr longLongValue]/1000;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
            [weakSelf.formatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
            NSString *value = [weakSelf.formatter stringFromDate:date];
            label.text = value;
            
            [label.param setValue:timeStr forKey:@"value"];
            weakSelf.changed = [weakSelf compareIfChanged];
            weakSelf.saveButton.hidden = !weakSelf.changed;
            
        }];
        [alertVC addAction:sureAtion];
        UIAlertAction *cancelAtion = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertVC addAction:cancelAtion];
        [self presentViewController:alertVC animated:YES completion:^{}];
    }else{
        UITextField *tf = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, label.frame.size.width, label.frame.size.height)];
        tf.textAlignment = NSTextAlignmentCenter;
        tf.delegate = self;
        tf.text = label.text;
        tf.backgroundColor = UIColor.whiteColor;
        tf.returnKeyType = UIReturnKeyDone;
        [tf becomeFirstResponder];
        [label addSubview:tf];
        _currentLabel = label;
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    _currentLabel.text = textField.text;
    [textField removeFromSuperview];
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    _currentLabel.text = textField.text;
    if (textField.text) {
        [_currentLabel.param setValue:textField.text forKey:@"value"];
    }
    _changed = [self compareIfChanged];
        //显示保存按钮
    self.saveButton.hidden = !_changed;
}

#pragma mark - Get

- (JJStockView*)stockView{
    if(_stockView != nil){
        return _stockView;
    }
    _stockView = [JJStockView new];
    _stockView.dataSource = self;
    _stockView.delegate = self;
    return _stockView;
}
- (CMPOcrInvoiceDetailDataProvider *)dataProvider {
    if (!_dataProvider) {
        _dataProvider = [[CMPOcrInvoiceDetailDataProvider alloc] init];
    }
    return _dataProvider;
}

- (CMPOcrScheduleViewModel *)scheduleViewModel{
    if (!_scheduleViewModel) {
        _scheduleViewModel = [CMPOcrScheduleViewModel new];
    }
    return _scheduleViewModel;
}

- (NSDateFormatter *)formatter{
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc]init];
    }
    return _formatter;
}
@end
