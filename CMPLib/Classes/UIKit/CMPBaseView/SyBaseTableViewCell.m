//
//  SyBaseTableViewCell.m
//  M1IPhone
//
//  Created by  on 12-10-29.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#import "SyBaseTableViewCell.h"

@interface SyBaseTableViewCell()
{
    CGRect _preFrame;
}

@end

@implementation SyBaseTableViewCell
@synthesize separatorImageView = _separatorImageView;
@synthesize showSelectedFlag = _showSelectedFlag;
@synthesize fistImage = _fistImage;
@synthesize separatorLeftMargin = _separatorLeftMargin;
@synthesize separatorRightMargin = _separatorRightMargin;
@synthesize selectBkView = _selectBkView;

- (void)dealloc
{
    SY_RELEASE_SAFELY(_bkView);
    SY_RELEASE_SAFELY(_selectBkView);
    SY_RELEASE_SAFELY(_separatorImageView);
    SY_RELEASE_SAFELY(_selectedBkImageView);
    SY_RELEASE_SAFELY(_selectedFlagImageView);
    SY_RELEASE_SAFELY(_bkimageView);
    if (_topLineView) {
        SY_RELEASE_SAFELY(_topLineView);
    }
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _preFrame = CGRectZero;
        // bottomBoardLine
        if (!_separatorImageView) {
            _separatorImageView = [[UIImageView alloc] init];
            _separatorImageView.backgroundColor = [UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:1];
            [self addSubview:_separatorImageView];
        }
        _separatorLeftMargin = 0;
        _separatorRightMargin = 0;
        CGFloat h = INTERFACE_IS_PAD ? kPadSepHeight : kPhoneSepHeight;
        _separatorImageView.frame = CGRectMake(_separatorLeftMargin, self.height - h, self.width-_separatorLeftMargin, h);
        if (!_bkimageView) {
            _bkimageView = [[UIImageView alloc]init];
            [self addSubview:_bkimageView];
            [self sendSubviewToBack:_bkimageView];
        }
        [self setup];
        [self setupForPhone];
    }
    return self;
}

- (void)setup {
}

- (void)setupForPhone {
    
}

- (void)setupForPad {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setBkViewColor:(UIColor *)aColor {
    if (!_bkView) {
        _bkView = [[UIView alloc] initWithFrame:self.bounds];
        self.backgroundView = _bkView;
    }
    _bkView.backgroundColor = aColor;
}
- (void)setSeparatorColor:(UIColor *)aColor
{
    _separatorImageView.image = nil;
    _separatorImageView.backgroundColor = aColor;
}
- (void)setSelectBkViewColor:(UIColor *)aColor {
    
    if (!_selectBkView) {
        _selectBkView = [[SyBaseTableViewCellSelectView alloc] initWithFrame:self.bounds];
        self.selectedBackgroundView =_selectBkView;
    }
    _selectBkView.backgroundColor = aColor;
}

- (void)setSelectedBkImage:(UIImage *)aImage
{    
    if (!_selectedBkImageView) {
        _selectedBkImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.selectedBackgroundView = _selectedBkImageView;
    }
    _selectedBkImageView.image = aImage;
}

- (void)setFrame:(CGRect)frame{
    BOOL isResizing = YES;
    if (frame.size.width == _preFrame.size.width && frame.size.height == _preFrame.size.height) {
        isResizing = NO;
    }
    [super setFrame:frame];
    _preFrame = frame;
    if (isResizing) {

        [self layoutSubviewsWithFrame:frame];
    }
}

- (void)setSeparatorFrame:(CGRect)aFrame{
    _separatorImageView.frame = aFrame;
}

- (void)setSeparatorLeftMargin:(CGFloat)separatorLeftMargin
{
    if (_separatorLeftMargin != separatorLeftMargin) {
        _separatorLeftMargin = separatorLeftMargin;
        [self layoutSubviewsWithFrame:self.frame];
    }
}
- (void)setSeparatorHide:(BOOL)separatorHide
{
    _separatorImageView.hidden = separatorHide;
    _separatorHide = separatorHide;
}
- (void)setSeparatorRightMargin:(CGFloat)separatorRightMargin
{
    if (_separatorRightMargin != separatorRightMargin) {
        _separatorRightMargin = separatorRightMargin;
        [self layoutSubviewsWithFrame:self.frame];
    }
}

- (void)customLayoutSubviewsFrame:(CGRect)frame{
    
}

- (void)layoutSubviewsWithFrame:(CGRect)frame
{
    //zhengxf Add
    _bkView.frame = self.bounds;
    [self customLayoutSubviewsFrame:frame];
    if (self.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [self setSeparatorFrame:CGRectMake(_separatorLeftMargin, frame.size.height - kPadSepHeight, frame.size.width-_separatorLeftMargin-_separatorRightMargin, kPadSepHeight)];
        [_topLineView setFrame:CGRectMake(0, 0, self.width, kPadSepHeight)];
        [self layoutSubviewsForPadWithFrame:frame];
    }
    else {
        [self setSeparatorFrame:CGRectMake(_separatorLeftMargin, frame.size.height - kPhoneSepHeight, frame.size.width-_separatorLeftMargin-_separatorRightMargin, kPhoneSepHeight)];
        [_topLineView setFrame:CGRectMake(0, 0, self.width, kPhoneSepHeight)];
        [self layoutSubviewsForPhoneWithFrame:frame];
    }
    _selectBkView.lineHeight = _separatorImageView.height;
    _selectBkView.lineLeftMargin = _separatorLeftMargin;
    _selectBkView.lineRightMargin = _separatorRightMargin;
    [_selectBkView setupLineColor:_separatorImageView.backgroundColor];
    _selectBkView.frame = self.bounds;

}

- (void)layoutSubviewsForPadWithFrame:(CGRect)frame
{
    
}

- (void)layoutSubviewsForPhoneWithFrame:(CGRect)frame
{
    
}

- (void)setDefualtBkView
{
    [self setBkViewColor:[UIColor whiteColor]];
 
}
- (void)setDefualtSelectedBkImage
{
    [self setSelectBkViewColor:UIColorFromRGB(0xe8eef4)];
}

- (void)setClearBkViewColor
{
    self.backgroundView = nil;
    self.backgroundColor = [UIColor clearColor];
}

- (void)setShowSelectedFlag:(BOOL)showSelectedFlag
{
    _showSelectedFlag = showSelectedFlag;
}


-(void)addEdgeLineWithRow:(NSInteger)row RowCount:(NSInteger)rowCount
{
   
    [self addLineWithRow:row RowCount:rowCount separatorLeftMargin:25];
}

-(void)addLineWithRow:(NSInteger)row RowCount:(NSInteger)rowCount
{
    [self addLineWithRow:row RowCount:rowCount separatorLeftMargin:0];
}

-(void)addLineWithRow:(NSInteger)row RowCount:(NSInteger)rowCount separatorLeftMargin:(CGFloat)separatorLeftMargin
{
    BOOL isFirst = row ==0?YES:NO;
    BOOL isLast = row==rowCount-1?YES:NO;
    //上
    if (!_topLineView) {
        _topLineView = [[UIView alloc] init];
        _topLineView.backgroundColor = self.separatorImageView.backgroundColor;// RGBCOLOR(200, 199, 204);
        [self addSubview:_topLineView];
    }
    _topLineView.hidden = !isFirst;
    //    [self singleLineWithPosition:SyLinePositionTop];
    //    UIView *v = [self viewWithTag:87654+2];
    //    CGRect r = v.frame;
    //    r.size.width = self.bounds.size.width;
    //    v.frame = r;
    //    v.backgroundColor = RGBCOLOR(200, 199, 204);
    //    v.hidden = !isFirst;
    //下
    self.separatorImageView.hidden = NO;
    self.separatorLeftMargin = isLast? 0:separatorLeftMargin;
    self.separatorRightMargin = 0;
    if (_topLineView &&!_topLineView.hidden &&_topLineView.height == 0) {
        if (self.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            [_topLineView setFrame:CGRectMake(0, 0, self.width, kPadSepHeight)];
        }
        else {
            [_topLineView setFrame:CGRectMake(0, 0, self.width, kPhoneSepHeight)];
        }
    }
}

@end
