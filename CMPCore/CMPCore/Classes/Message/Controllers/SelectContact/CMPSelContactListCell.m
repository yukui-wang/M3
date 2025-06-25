//
//  CMPSelContactListCell.m
//  M3
//
//  Created by youlin guo on 2018/2/2.
//

#import "CMPSelContactListCell.h"
#import <CMPLib/CMPThemeManager.h>

@implementation CMPSelContactListCell

- (void)dealloc {
	SY_RELEASE_SAFELY(_faceView);
	SY_RELEASE_SAFELY(_userNameLabel);
	[super dealloc];
}

- (void)setup
{
	if (!_faceView) {
		_faceView = [[CMPFaceView alloc] init];
		_faceView.frame = CGRectMake(0, 0, 26, 26);
		_faceView.layer.cornerRadius = 13;
		_faceView.clipsToBounds = YES;
		[self addSubview:_faceView];
	}
	
	if (!_userNameLabel) {
		_userNameLabel = [[UILabel alloc]init];
		_userNameLabel.textAlignment = NSTextAlignmentLeft;
		_userNameLabel.font = FONTSYS(16);
		_userNameLabel.backgroundColor = [UIColor clearColor];
		_userNameLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
        _userNameLabel.numberOfLines = 2;
		[self addSubview:_userNameLabel];
	}
    
    if(!_adminImageView){
        _adminImageView = [UIImageView new];
        _adminImageView.image = [UIImage imageNamed:@"icon_pc_grouper"];
        [self addSubview:_adminImageView];
    }
    _adminImageView.hidden = YES;
    
    if(!_departmentLabel){
        _departmentLabel = [[UILabel alloc]init];
        _departmentLabel.text = @"部门群";
        _departmentLabel.textAlignment = NSTextAlignmentCenter;
        _departmentLabel.font = FONTSYS(12);
        _departmentLabel.backgroundColor = [[UIColor cmp_colorWithName:@"theme-fc"] colorWithAlphaComponent:0.6];
        _departmentLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
        _departmentLabel.numberOfLines = 1;
        [self addSubview:_departmentLabel];
    }
    _departmentLabel.hidden = YES;
        
    //share_btn_selected_circle  //share_btn_unselected_circle
	
    self.separatorImageView.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
	self.separatorLeftMargin = 14;
	self.selectionStyle  = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
}

- (void)setSelectImageConfig{
    if(!_selectImageView){
        _selectImageView = [UIImageView new];
        _selectImageView.image = [UIImage imageNamed:@"share_btn_unselected_circle"];
        [self addSubview:_selectImageView];
    }
}

- (void)setAdminImageConfig:(BOOL)show{
    _adminImageView.hidden = !show;
}

//设置部门群
- (void)setDepartment:(NSString *)text{
    if(text.length){
        _departmentLabel.text = text;
        _departmentLabel.hidden = NO;
        _adminImageView.hidden = YES;
    }else{
        _departmentLabel.hidden = YES;
    }
}

- (void)setSelectCell:(BOOL)selectCell{
    _selectCell = selectCell;
    _selectImageView.image = _selectCell?[[CMPThemeManager sharedManager] skinColorImageWithName:@"share_btn_selected_circle"]:[UIImage imageNamed:@"share_btn_unselected_circle"];
}

- (void)customLayoutSubviewsFrame:(CGRect)frame
{
	CGFloat x = 14;
	CGFloat y = (self.height - 26) * 0.5;
    if(_selectImageView){
        [_selectImageView setFrame:CGRectMake(x, 15, 20, 20)];
        x += _selectImageView.width + 10;
    }
    
	[_faceView setFrame:CGRectMake(x, y, 26, 26)];
	    
    //管理员图标
    CGFloat marginRight = 0;
//    if(_adminImageView){
        [_adminImageView setFrame:CGRectMake(self.width -14 - 20, (self.height - 14)/2, 14, 14)];
        marginRight = 40;
//    }
    
    //部门群标识
//    if(_departmentLabel){
        [_departmentLabel setFrame:CGRectMake(self.width - 40 - 20, (self.height - 16)/2, 40, 16)];
        marginRight = 68;
//    }
    
    x += _faceView.width + 10;
    [_userNameLabel setFrame:CGRectMake(x, 1, self.width - x -10 - marginRight, self.height - 2)];
}

@end
