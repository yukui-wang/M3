//
//  CMPBaseTableViewCell.m
//  CMPCore
//
//  Created by wujiansheng on 2017/1/5.
//
//

#import "CMPBaseTableViewCell.h"

#define kMacro_SeperatorLineHeight 0.5

@interface CMPBaseTableViewCell()
{
    CGRect _preFrame;
}

@end

@implementation CMPBaseTableViewCell
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
        if (!_separatorImageView) {
            _separatorImageView = [[UIImageView alloc] init];
            _separatorImageView.backgroundColor = UIColorFromRGB(0xe7e7e7);
            [self addSubview:_separatorImageView];
        }
        _separatorLeftMargin = 0;
        _separatorRightMargin = 0;
        CGFloat h = kMacro_SeperatorLineHeight;
        _separatorImageView.frame = CGRectMake(_separatorLeftMargin, self.height - h, self.width-_separatorLeftMargin, h);
        if (!_bkimageView) {
            _bkimageView = [[UIImageView alloc]init];
            [self addSubview:_bkimageView];
            [self sendSubviewToBack:_bkimageView];
        }
        [self setup];
    }
    return self;
}

- (void)setup {
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
   //系统要自己调用啊
    _separatorImageView.image = nil;
//    _separatorImageView.backgroundColor = aColor;
}

- (void)setSelectBkViewColor:(UIColor *)aColor {
    
    if (!_selectBkView) {
        _selectBkView = [[CMPBaseTableViewCellSelectView alloc] initWithFrame:self.bounds];
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
    _bkView.frame = self.bounds;
    [self customLayoutSubviewsFrame:frame];
    [self setSeparatorFrame:CGRectMake(_separatorLeftMargin, frame.size.height - kMacro_SeperatorLineHeight, frame.size.width-_separatorLeftMargin-_separatorRightMargin, kMacro_SeperatorLineHeight)];
    [_topLineView setFrame:CGRectMake(0, 0, self.width, kMacro_SeperatorLineHeight)];
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
-(void)addLineWithRow:(NSInteger)row RowCount:(NSInteger)rowCount separatorLeftMargin:(CGFloat)separatorLeftMargin
{

    BOOL isLast = row==rowCount-1?YES:NO;
    self.separatorImageView.hidden = NO;
    self.separatorLeftMargin = isLast? 0:separatorLeftMargin;
    self.separatorRightMargin = 0;
    
    BOOL isFirst = row ==0?YES:NO;
    if (!_topLineView && isFirst) {
        _topLineView = [[UIView alloc] init];
        _topLineView.backgroundColor = self.separatorImageView.backgroundColor;
        [self addSubview:_topLineView];
    }
    _topLineView.hidden = !isFirst;
    if (_topLineView &&!_topLineView.hidden &&_topLineView.height == 0) {
        [_topLineView setFrame:CGRectMake(0, 0, self.width, kMacro_SeperatorLineHeight)];
    }
}


@end
