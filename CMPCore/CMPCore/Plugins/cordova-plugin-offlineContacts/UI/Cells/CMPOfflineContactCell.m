//
//  CMPOfflineContactCell.m
//  CMPCore
//
//  Created by wujiansheng on 2017/1/5.
//
//

#import "CMPOfflineContactCell.h"
#import <CMPLib/CMPOfflineContactFaceview.h>
#import <CMPLib/CMPFontModel.h>
#import <CMPLib/UIView+RTL.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/UIImageView+WebCache.h>

@interface CMPOfflineContactCell()
{
//    CMPOfflineContactFaceview *_faceView;
    UIImageView *_faceView;
    CMPSearchResultLabel *_nameLabel;
    UILabel *_levelLabel;
    UIButton *_arrowBtn;//8.1 new
    UILabel *_newPostLb;//8.1 new
    NSInteger _styleType;//8.1 new  0 :默认样式（8.1之前）  1 :8.1及以后初始  2 :8.1显示全路径
}
@end

@implementation CMPOfflineContactCell

- (void)dealloc
{
    SY_RELEASE_SAFELY(_faceView);
    SY_RELEASE_SAFELY(_nameLabel);
    SY_RELEASE_SAFELY(_levelLabel);
    SY_RELEASE_SAFELY(_newPostLb);
    _arrowBtn = nil;

    [super dealloc];
}

- (void)setup
{
    if (!_faceView) {
        _faceView = [[UIImageView alloc] init];
        _faceView.backgroundColor = UIColor.blueColor;
        _faceView.layer.cornerRadius = 40/2;
        _faceView.layer.masksToBounds = YES;
        [self addSubview:_faceView];
    }
    if (!_nameLabel) {
        _nameLabel = [[CMPSearchResultLabel alloc]init];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = FONTBOLDSYS(16);
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor =  [UIColor cmp_colorWithName:@"main-fc"];
        _nameLabel.keyColor = [UIColor cmp_colorWithName:@"theme-fc"];
        [self addSubview:_nameLabel];
    }
    if (!_levelLabel) {
        _levelLabel = [[UILabel alloc]init];
        _levelLabel.textAlignment = NSTextAlignmentLeft;
        _levelLabel.font = FONTSYS(12);
        _levelLabel.backgroundColor = [UIColor clearColor];
        _levelLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
        _levelLabel.numberOfLines = 0;
        [self addSubview:_levelLabel];
    }
    if (!_newPostLb) {
        _newPostLb = [[UILabel alloc]init];
        _newPostLb.textAlignment = NSTextAlignmentLeft;
        _newPostLb.font = FONTSYS(15);
        _newPostLb.backgroundColor = [UIColor clearColor];
        _newPostLb.textColor =  [UIColor cmp_colorWithName:@"main-fc"];
        [self addSubview:_newPostLb];
    }
    if (!_arrowBtn) {
        _arrowBtn = [UIButton buttonWithImage:[UIImage imageNamed:@"contact_arrowdown"]];
        [_arrowBtn setImageEdgeInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
        [_arrowBtn addTarget:self action:@selector(_arrowAct) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_arrowBtn];
    }
    self.selectionStyle =  UITableViewCellSelectionStyleNone;
    [self setBkViewColor:[UIColor cmp_colorWithName:@"white-bg"]];
    [self setSelectBkViewColor:[UIColor cmp_colorWithName:@"white-bg"]];
    self.separatorImageView.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
    self.separatorRightMargin = 20;
    
    [self setStyleType:0];
}

- (void)setStyleType:(NSInteger)styleType
{
    _styleType = styleType;
    switch (_styleType) {
        case 0:
        {
            _newPostLb.hidden = YES;
            _arrowBtn.hidden = YES;
        }
            break;
        case 1:
        {
            _newPostLb.hidden = NO;
            _arrowBtn.hidden = NO;
        }
            break;
        case 2:
        {
            _newPostLb.hidden = NO;
            _arrowBtn.hidden = YES;
        }
            break;
            
        default:
            break;
    }
}

- (void)customLayoutSubviewsFrame:(CGRect)frame
{
    CGFloat nameLabelSize = [CMPCore sharedInstance].currentFont.listHeadlinesFontSize;
    CGFloat levelLabelSize = [CMPCore sharedInstance].currentFont.bodyFontSize;
    CGFloat newPostLabelSize = levelLabelSize +1;
    
    _nameLabel.font = FONTSYS(nameLabelSize);
    _levelLabel.font = FONTSYS(levelLabelSize);
    _newPostLb.font = FONTSYS(newPostLabelSize);
    
    NSInteger nameLabelHeight = ceil([CMPCore sharedInstance].currentFont.listHeadlinesFontSize * 1.4) - ((int)ceil([CMPCore sharedInstance].currentFont.listHeadlinesFontSize * 1.4) % 2);
    NSInteger newPostLbHeight = ceil(newPostLabelSize * 1.4) - ((int)ceil(newPostLabelSize * 1.4) % 2);
    
    CGFloat x;
    CGFloat y;
    CGFloat w;
    CGFloat h;
    CGFloat imageW;
    
    switch ([CMPCore sharedInstance].currentFont.fontType) {
            
        case FontTypeNarrow:{
            
            imageW = 38;
            
        }
            break;
            
        case FontTypeStandard:{
            
            imageW = 40;
            
        }
            break;
            
        case FontTypeExpandOne:{
            
            imageW = 42;
            
        }
            break;
            
        case FontTypeExpandTwo:{
            
            imageW = 44;
            
        }
            break;
    }
        
    x = 14;
    
    if(_selectImageView){
        [_selectImageView setFrame:CGRectMake(x, 22, 20, 20)];
        x += _selectImageView.width + 10;
    }
    
    y = _styleType == 0 ? (self.height - imageW) * 0.5 : 14;
    w = imageW;
    h = imageW;
    [_faceView setFrame:CGRectMake(x, y, w, h)];
    _faceView.layer.cornerRadius = imageW * 0.5;
    
    NSInteger levelHeight = 0;
    if (_styleType != 2) {
        w = frame.size.width-x-imageW-10-20-20-10;
        levelHeight = ceil([CMPCore sharedInstance].currentFont.bodyFontSize * 1.4) - ((int)ceil([CMPCore  sharedInstance].currentFont.bodyFontSize * 1.4) % 2);
    }else{
        w = frame.size.width-x-imageW-10-20-20-10;
        levelHeight = [_levelLabel.text sizeWithFontSize:[UIFont systemFontOfSize:newPostLabelSize] defaultSize:CGSizeMake(w, MAXFLOAT)].height+4;
    }
    
    x += _faceView.width + 10;
    y = 14;
    h = nameLabelHeight;
    [_nameLabel setFrame:CGRectMake(x, y, w, h)];
    
    if (_styleType == 1 || _styleType ==2) {
        y = y + h + 5;
        h = newPostLbHeight;
        [_newPostLb setFrame:CGRectMake(x, y, w, h)];
    }
    
    y = CGRectGetMaxY(_newPostLb.frame)+5;
    if (y<=5 && _styleType == 0) {
        y = CGRectGetMaxY(_nameLabel.frame)+5;
    }
    h = levelHeight;
    [_levelLabel setFrame:CGRectMake(x, y, w, h)];
    
    [_arrowBtn setFrame:CGRectMake(frame.size.width-20-20, y, 20, 20)];
    
    [_faceView resetFrameToFitRTL];
    [_nameLabel resetFrameToFitRTL];
    [_levelLabel resetFrameToFitRTL];
    [_newPostLb resetFrameToFitRTL];
    
}

- (void)setupDataWithMember:(CMPOfflineContactMember *)member
{
//    _nameLabel.text = member.name;
    [_nameLabel setAttributedText:nil];
    NSAttributedString *attstr = [CMPCommonTool searchResultAttributeStringInString:member.name searchText:_searchText];
    [_nameLabel setAttributedText:attstr];
    
    
//    [_faceView layoutText:member.name];
//    _faceView.memberId = member.orgID;
    NSString *imageUrl = [CMPCore memberIconUrlWithId:member.orgID];
    [_faceView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"guesture.bundle/ic_def_person.png"]];
    
    switch (_styleType) {
        case 1:
        {
            _newPostLb.text = member.postName;
            _levelLabel.text = member.parentDepts.lastObject;
        }
            break;
        case 2:
        {
            _newPostLb.text = member.postName;
            _levelLabel.text = [member.parentDepts componentsJoinedByString:@"/"];
        }
            break;
            
        default:
            _levelLabel.text = member.postName;
            break;
    }
}

- (void)setupDataWithMember:(CMPOfflineContactMember *)member key:(NSString *)key
{
    [_nameLabel setText:member.name key:key];
//    [_faceView layoutText:member.name];
//    _faceView.memberId = member.orgID;
    NSString *imageUrl = [CMPCore memberIconUrlWithId:member.orgID];
    [_faceView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"guesture.bundle/ic_def_person.png"]];
    
    switch (_styleType) {
        case 1:
        {
            _newPostLb.text = member.postName;
            _levelLabel.text = member.parentDepts.lastObject;
        }
            break;
        case 2:
        {
            _newPostLb.text = member.postName;
            _levelLabel.text = [member.parentDepts componentsJoinedByString:@"/"];
        }
            break;
            
        default:
            _levelLabel.text = member.postName;
            break;
    }
}

- (void)addLineWithRow:(NSInteger)row RowCount:(NSInteger)rowCount
{
    [super addLineWithRow:row RowCount:rowCount separatorLeftMargin:_levelLabel.originX];
    BOOL isLast = row==rowCount-1?YES:NO;
    self.separatorImageView.hidden = isLast;
    _topLineView.hidden = YES;
}

-(void)addLineWithSearchRow:(NSInteger)row RowCount:(NSInteger)rowCount
{
    [super addLineWithRow:row RowCount:rowCount separatorLeftMargin:_levelLabel.originX];
}

- (void)loadFaceImage
{
//    [_faceView loadImage];
}

-(void)_arrowAct
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cmpBaseTableViewCell:didTapAct:ext:)]) {
        [self.delegate cmpBaseTableViewCell:self didTapAct:1 ext:nil];
    }
}

+ (CGFloat)cellHeight
{
    
    NSInteger nameLabelHeight = ceil([CMPCore sharedInstance].currentFont.listHeadlinesFontSize * 1.4) - ((int)ceil([CMPCore sharedInstance].currentFont.listHeadlinesFontSize * 1.4) % 2);
    NSInteger levelHeight = ceil([CMPCore sharedInstance].currentFont.bodyFontSize * 1.4) - ((int)ceil([CMPCore sharedInstance].currentFont.bodyFontSize * 1.4) % 2);
    
    CGFloat heigeht = nameLabelHeight + levelHeight + 14*2 + 2 ;
    
    return heigeht;

}

+ (CGFloat)cellHeightWithModel:(CMPOfflineContactMember *)member styleType:(NSInteger)styleType
{
    CGFloat finalH = 0;
    CGFloat levelLabelSize = [CMPCore sharedInstance].currentFont.bodyFontSize;
    CGFloat newPostLabelSize = levelLabelSize +1.5;
    
    NSInteger nameLabelHeight = ceil([CMPCore sharedInstance].currentFont.listHeadlinesFontSize * 1.4) - ((int)ceil([CMPCore sharedInstance].currentFont.listHeadlinesFontSize * 1.4) % 2);
    NSInteger newPostLbHeight = ceil(newPostLabelSize * 1.4) - ((int)ceil(newPostLabelSize * 1.4) % 2);
    
    CGFloat y;
    CGFloat h;
    
    NSInteger levelHeight = 0;
    if (styleType != 2) {
        levelHeight = ceil([CMPCore sharedInstance].currentFont.bodyFontSize * 1.4) - ((int)ceil([CMPCore  sharedInstance].currentFont.bodyFontSize * 1.4) % 2);
    }else{
        
        CGFloat x = 14;
        CGFloat imageW;
        
        switch ([CMPCore sharedInstance].currentFont.fontType) {
                
            case FontTypeNarrow:{
                
                imageW = 38;
                
            }
                break;
                
            case FontTypeStandard:{
                
                imageW = 40;
                
            }
                break;
                
            case FontTypeExpandOne:{
                
                imageW = 42;
                
            }
                break;
                
            case FontTypeExpandTwo:{
                
                imageW = 44;
                
            }
                break;
        }
        
        NSString *text = styleType == 2 ? [member.parentDepts componentsJoinedByString:@"/"] : member.parentDepts.lastObject;
        levelHeight = [text sizeWithFontSize:[UIFont systemFontOfSize:newPostLabelSize] defaultSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-x-imageW-10-20-20-10, MAXFLOAT)].height+4;
    }
    
    y = 14;
    h = nameLabelHeight;
    finalH += (y + h);
    
    if (styleType == 1 || styleType ==2) {
        
        y += h + 5;
        h = newPostLbHeight;
    }
    
    y += h + 5;
    h = levelHeight;
    
    finalH = y + h + 14;
    
    return finalH;
}

#pragma mark - 多选

- (void)setSelectImageConfig{
    if(!_selectImageView){
        _selectImageView = [UIImageView new];
        _selectImageView.image = [UIImage imageNamed:@"share_btn_unselected_circle"];
        [self addSubview:_selectImageView];
    }
}

- (void)setSelectCell:(BOOL)selectCell{
    _selectCell = selectCell;
    _selectImageView.image = _selectCell?[[CMPThemeManager sharedManager] skinColorImageWithName:@"share_btn_selected_circle"]:[UIImage imageNamed:@"share_btn_unselected_circle"];
}
@end
