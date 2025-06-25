//
//  XZMemberListCell.m
//  M3
//
//  Created by wujiansheng on 2017/11/22.
//

#import "XZMemberListCell.h"
#import <CMPLib/CMPOfflineContactMember.h>
#import <CMPLib/CMPOfflineContactFaceview.h>

@interface XZMemberListCell ()
{
    CMPOfflineContactFaceview *_faceView;
    UILabel *_nameLabel;
    UILabel *_postLabel;

}
@end

@implementation XZMemberListCell

- (void)dealloc
{
    SY_RELEASE_SAFELY(_faceView);
    SY_RELEASE_SAFELY(_nameLabel);
    SY_RELEASE_SAFELY(_postLabel);
    [super dealloc];
}

- (void)setup
{
    if (!_faceView) {
        _faceView = [[CMPOfflineContactFaceview alloc] init];
        _faceView.layer.cornerRadius = 36/2;
        _faceView.layer.masksToBounds = YES;
        [self addSubview:_faceView];
    }
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = FONTSYS(16);
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = UIColorFromRGB(0x000000);
        [self addSubview:_nameLabel];
    }
    if (!_postLabel) {
        _postLabel = [[UILabel alloc]init];
        _postLabel.textAlignment = NSTextAlignmentLeft;
        _postLabel.font = FONTSYS(14);
        _postLabel.backgroundColor = [UIColor clearColor];
        _postLabel.textColor = UIColorFromRGB(0x999999);
        [self addSubview:_postLabel];
    }
    [self setBkViewColor:[UIColor whiteColor]];
    [self setSelectBkViewColor:UIColorFromRGB(0xdce9fb)];
    self.separatorRightMargin = 20;
}

- (void)customLayoutSubviewsFrame:(CGRect)frame
{
    CGFloat  x = 20;
    [_faceView setFrame:CGRectMake(x, self.height/2-18, 36, 36)];
    x +=_faceView.width+10;
    NSInteger nh = _nameLabel.font.lineHeight+1;
    NSInteger lh = _postLabel.font.lineHeight+1;

    CGFloat y = (self.height-nh-lh-4)/2;
    [_nameLabel setFrame:CGRectMake(x, y, self.width-x-14-20, nh)];
    [_postLabel setFrame:CGRectMake(x, self.height-lh-y, self.width-x-14-20, lh)];

}

- (void)setupDataWithMember:(CMPOfflineContactMember *)member
{
    _nameLabel.text = member.name;
    _postLabel.text = member.postName;
    _faceView.memberId = member.orgID;
}


- (void)addLineWithRow:(NSInteger)row RowCount:(NSInteger)rowCount
{
    [super addLineWithRow:row RowCount:rowCount separatorLeftMargin:_faceView.originX];
    BOOL isLast = row==rowCount-1?YES:NO;
    self.separatorImageView.hidden = isLast;
    _topLineView.hidden = YES;
}



- (void)loadFaceImage
{
    [_faceView loadImage];
}

+ (CGFloat)cellHeight
{
    return 68;
}
@end
