//
//  CMPActionSheetView.m
//  BeeBee
//
//  Created by quwan on 2017/6/15.
//  Copyright © 2017年 quwan. All rights reserved.
//

// 默认设置
#define SHOWTIME 0.3 //显示时间
#define DISSMISSTIME 0.3 //消失时间
#define CORNER 15 //圆角大小
#define SHEETHEIGHT 50
#define CANCLEHEIGHT 50
#define TITLEHEIGHT 60
#define SECTIONHEIGHT 14
#define ScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define ScreenHeight ([UIScreen mainScreen].bounds.size.height)

#import "CMPActionSheet.h"
#import <CMPLib/CMPThemeManager.h>


@interface CMPActionSheetViewItem()
{
    NSString *_title;
    NSUInteger _key;
    NSString *_identifier;
}
@end

@implementation CMPActionSheetViewItem


-(NSString *)title
{
    return _title;
}

-(NSUInteger)key
{
    return _key;
}

-(NSString *)identifier
{
    return _identifier;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(CMPActionSheetViewItem *)setTitle:(NSString *)title
{
    _title = title;
    return self;
}

-(CMPActionSheetViewItem *)setKey:(NSUInteger)key
{
    _key = key;
    return self;
}

-(CMPActionSheetViewItem *)setIdentifier:(NSString *)identifier
{
    _identifier = identifier;
    return self;
}

-(BOOL)isCancelItem{
    return (_key == -1 && (_identifier && [_identifier isEqualToString:@"cmp_sheet_cancel"]));
}

@end


@interface CMPActionSheet()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *sheetTable;
@property (nonatomic,assign) CMPActionSheetStyle actionsheetStyle;
@property (nonatomic,copy) CMPActionSheetClickedButtonBlock clickedButtonBlock;
@end

@implementation CMPActionSheet
{
    NSString *_sheetTitle;
    NSString *_cancleTitle;
    NSArray *_sheetTitleArr;
    UIView *_headerView;
    UILabel *_titleLabel;
    UIButton *_cancleBtn;
    
    CGFloat _tableHeight;
    CGFloat _cellHeight;
    CGFloat _titleHeight;
    CGFloat _cancleHeight;
    NSInteger _cellCount;
    
    CGFloat _bottomHeight;//iphoneX安全区域
    
}

- (instancetype)initWithTitle:(NSString *)title
                  sheetTitles:(NSArray *)sheetTitles
               cancleBtnTitle:(NSString *)cancleBtnTitle
                   sheetStyle:(CMPActionSheetStyle)sheetStyle
                     delegate:(id<CMPActionSheetDelegate>)delegate{
    
    if (self = [super init]) {
     
        self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        
        _actionsheetStyle = sheetStyle;
        _sheetTitle = title;
        _cancleTitle = cancleBtnTitle;
        _sheetTitleArr = sheetTitles;
        _cellCount = _sheetTitleArr.count;
        if (delegate) {
            self.delegate = delegate;
        }
    }
    return self;
}

+ (instancetype)actionSheetWithTitle:(NSString *)title
                  sheetItems:(NSArray<CMPActionSheetViewItem *> *)sheetItems
               cancleBtnTitle:(NSString *)cancleBtnTitle
                   sheetStyle:(CMPActionSheetStyle)sheetStyle
                            callback:(CMPActionSheetViewItemSelectedBlock)callback{
    NSMutableArray *titles = [NSMutableArray array];
    for (CMPActionSheetViewItem *item in sheetItems) {
        [titles addObject:item.title];
    }
    CMPActionSheet *sheet = [CMPActionSheet actionSheetWithTitle:title sheetTitles:titles cancleBtnTitle:cancleBtnTitle sheetStyle:sheetStyle callback:^(NSInteger buttonIndex) {
        if (callback) {
            if (buttonIndex == 0) {
                CMPActionSheetViewItem *cancelItem = [[CMPActionSheetViewItem alloc] init];
                cancelItem.key = -1;
                cancelItem.title = cancleBtnTitle;
                cancelItem.identifier = @"cmp_sheet_cancel";
                callback(cancelItem,nil);
            }else{
                callback(sheetItems[buttonIndex-1],nil);
            }
        }
    }];
    return sheet;
}

+ (instancetype)actionSheetWithTitle:(NSString *)title
                         sheetTitles:(NSArray *)sheetTitles
                      cancleBtnTitle:(NSString *)cancleBtnTitle
                          sheetStyle:(CMPActionSheetStyle)sheetStyle
                            callback:(CMPActionSheetClickedButtonBlock)callback{
    CMPActionSheet *actionSheet = [[CMPActionSheet alloc] initWithTitle:title sheetTitles:sheetTitles cancleBtnTitle:cancleBtnTitle sheetStyle:sheetStyle delegate:nil];
    actionSheet.clickedButtonBlock = callback;
    
    /*
     * 设置Sheet样式
     */
    actionSheet.isCorner = YES;
    actionSheet.lineColor = [UIColor clearColor];
   
    actionSheet.titlebgColor = [UIColor cmp_colorWithName:@"white-bg"];
    actionSheet.subtitlebgColor = [UIColor cmp_colorWithName:@"white-bg"];
    actionSheet.canclebgColor = [UIColor cmp_colorWithName:@"white-bg"];
    
    actionSheet.titleFont = [UIFont systemFontOfSize:12];
    actionSheet.subtitleFont = [UIFont systemFontOfSize:16];
    actionSheet.cancleTitleFont = [UIFont systemFontOfSize:16];
    
    actionSheet.titleColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    actionSheet.subtitleColor = [UIColor cmp_colorWithName:@"main-fc"];
    actionSheet.cancleTitleColor = [UIColor cmp_colorWithName:@"desc-fc"];
   
    actionSheet.titleHeight = 50;
    actionSheet.sheetHeight = 50;
    actionSheet.cancleHeight = 50;
    
    return actionSheet;
}

- (void)setupView{
  
    
    if (_cellCount == 0) {
        _cellCount = _iconArr.count;
    }
    [UIView animateWithDuration:SHOWTIME animations:^{
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }];
    
    CGFloat sheetTitleHight = [_sheetTitle getHeightWithWidth:ScreenWidth - 40 font:self.titleFont] + 28;
    if (sheetTitleHight > 128) {
        sheetTitleHight = 128;
    }
    _bottomHeight = 0;
    if (@available(iOS 11.0, *)) {
        if (INTERFACE_IS_PHONE) {
            _bottomHeight = [[[UIApplication sharedApplication] delegate] window].safeAreaInsets.bottom;
        }
    }
    _cellHeight = (_sheetHeight)?_sheetHeight:SHEETHEIGHT;
    _titleHeight = sheetTitleHight;
    _cancleHeight = (_cancleHeight)?_cancleHeight:CANCLEHEIGHT;
//    _tableHeight = (_sheetTitle.length == 0)?(_cellCount*_cellHeight + _cancleHeight + SECTIONHEIGHT):((_cellCount)*_cellHeight + _titleHeight + _cancleHeight + SECTIONHEIGHT);
    _tableHeight = _cellCount*_cellHeight + _cancleHeight + SECTIONHEIGHT +(_sheetTitle.length == 0 ? 0:_titleHeight)+_bottomHeight;

    if (_sheetTitle.length != 0) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, _titleHeight)];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 14, ScreenWidth - 40, ceilf(_titleHeight-28))];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.text = _sheetTitle;
        [_headerView addSubview:_titleLabel];
    }
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, _cancleHeight+_bottomHeight)];
    if (self.canclebgColor) {
        [footerView setBackgroundColor:self.canclebgColor];
    }
    _cancleBtn = [[UIButton alloc] init];
    _cancleBtn.frame = CGRectMake(0, 0, ScreenWidth, _cancleHeight);
    [_cancleBtn setTitle:_cancleTitle forState:(UIControlStateNormal)];
    [_cancleBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    _cancleBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_cancleBtn setBackgroundColor:[UIColor whiteColor]];
    [_cancleBtn addTarget:self action:@selector(actionSheetCancle:) forControlEvents:(UIControlEventTouchUpInside)];
    [footerView addSubview:_cancleBtn];

    self.sheetTable = [[UITableView alloc] init];
    _sheetTable.frame = CGRectMake(0, ScreenHeight, ScreenWidth, _tableHeight);
    _sheetTable.backgroundColor = [UIColor clearColor];
    _sheetTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _sheetTable.delegate = self;
    _sheetTable.dataSource = self;
    _sheetTable.scrollEnabled = NO;
    _sheetTable.tableHeaderView = _headerView;
    _sheetTable.tableFooterView = footerView;
    [self addSubview:_sheetTable];
}

- (void)show{

    [self setupView]; //创建视图
    [self setSheetProperty]; //设置自定义属性
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    [UIView animateWithDuration:SHOWTIME animations:^{
        self.sheetTable.frame = CGRectMake(0, ScreenHeight - self->_tableHeight, ScreenWidth, self->_tableHeight);
    }];
}

- (void)setSheetProperty{

    if (self.titleColor) {
        _titleLabel.textColor = self.titleColor;
    }
    if (self.titleFont) {
        _titleLabel.font = self.titleFont;
    }
    if (self.titlebgColor) {
        _titleLabel.backgroundColor = self.titlebgColor;
        _headerView.backgroundColor = self.titlebgColor;
    }
    if (self.cancleTitleColor) {
        [_cancleBtn setTitleColor:self.cancleTitleColor forState:(UIControlStateNormal)];
    }
    if (self.cancleTitleFont) {
        _cancleBtn.titleLabel.font = self.cancleTitleFont;
    }
    if (self.canclebgColor) {
        [_cancleBtn setBackgroundColor:self.canclebgColor];
    }
    if (self.isCorner) {
//        _titleLabel.layer.cornerRadius = CORNER;
//        _titleLabel.layer.masksToBounds = YES;
        //_cancleBtn.layer.cornerRadius = CORNER;
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_headerView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(CORNER, CORNER)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = _headerView.bounds;
        maskLayer.path = maskPath.CGPath;
        _headerView.layer.mask = maskLayer;
            
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return _cellCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *identifier = @"sheetCell";
    CMPActionSheetCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[CMPActionSheetCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:identifier];
    }
    
    if (_actionsheetStyle == CMPActionSheetDefault) {
        [cell setupCMPActionSheetDefaultCellWithTitle:_sheetTitleArr[indexPath.row] CellHeight:_cellHeight];
    }else if (_actionsheetStyle == CMPActionSheetIconAndTitle){
        UIFont *font = _subtitleFont?_subtitleFont:[UIFont systemFontOfSize:17];
        [cell setupCMPActionSheetIconAndTitleWithTitle:_sheetTitleArr[indexPath.row] titleFont:font icon:_iconArr[indexPath.row] cellHeight:_cellHeight];
    }else if (_actionsheetStyle == CMPActionSheetIcon){
        [cell setupCMPActionSheetIconAndTitleWithIcon:_iconArr[indexPath.row] cellHeight:_cellHeight];
    }
    
    if (self.subtitleColor) {
        cell.titleLab.textColor = self.subtitleColor;
    }
    if (self.subtitleFont) {
        cell.titleLab.font = self.subtitleFont;
    }
    if (self.subtitlebgColor) {
        cell.coverView.backgroundColor = self.subtitlebgColor;
    }
    if (self.lineColor) {
        cell.bottomLine.backgroundColor = self.lineColor;
    }
    if (self.isCorner) {
        UIBezierPath *maskPath;
        if (indexPath.row == 0 && (_sheetTitle.length == 0 || !_sheetTitle)) {
            maskPath = [UIBezierPath bezierPathWithRoundedRect:cell.coverView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(CORNER, CORNER)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = cell.bounds;
            maskLayer.path = maskPath.CGPath;
            cell.layer.mask = maskLayer;
        }
//        else if (indexPath.row == _cellCount-1){
//            maskPath = [UIBezierPath bezierPathWithRoundedRect:cell.coverView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(CORNER, CORNER)];
//            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//            maskLayer.frame = cell.bounds;
//            maskLayer.path = maskPath.CGPath;
//            cell.layer.mask = maskLayer;
//        }
        
    }
    if (indexPath.row == _cellCount-1) {
        cell.bottomLine.hidden = YES;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return _cellHeight;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
////    if (_sheetTitle.length != 0) {
////        return SECTIONHEIGHT;
////    }else{
////        return 0;
////    }
//    return 0;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, SECTIONHEIGHT)];
//    headerView.backgroundColor = [UIColor clearColor];
//    return headerView;
//}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, SECTIONHEIGHT)];
    footerView.backgroundColor = [UIColor cmp_colorWithName:@"p-bg"];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
   return SECTIONHEIGHT;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [self actionSheet:self clickButtonAtIndex:indexPath.row];
}

#pragma mark CMPActionSheetDelegate
- (void)actionSheet:(CMPActionSheet *)actionSheet clickButtonAtIndex:(NSInteger)buttonIndex{
    
    if ([self.delegate respondsToSelector:@selector(actionSheet:clickButtonAtIndex:)]) {
        [self.delegate actionSheet:self clickButtonAtIndex:buttonIndex];
    }
    
    if (self.clickedButtonBlock) {
        self.clickedButtonBlock(buttonIndex + 1);
    }
    
    [self dissmiss];
    
  
    
}

- (void)actionSheetCancle:(CMPActionSheet *)actionSheet{

    if ([self.delegate respondsToSelector:@selector(actionSheetCancle:)]) {
        [self.delegate actionSheetCancle:self];
    }
    
    if (self.clickedButtonBlock) {
        self.clickedButtonBlock(0);
    }
    
    [self dissmiss];
}

#pragma mark dissmiss
- (void)dissmiss{

    [UIView animateWithDuration:DISSMISSTIME animations:^{
        self.alpha = 0;
        self.sheetTable.frame = CGRectMake(0, ScreenHeight, ScreenWidth, self->_tableHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

// 点击阴影部分是让视图消失
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([touch view] != _sheetTable) {
        [self dissmiss];
    }
}


@end
