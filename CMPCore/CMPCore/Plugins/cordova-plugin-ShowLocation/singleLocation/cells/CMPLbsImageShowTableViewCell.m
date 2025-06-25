//
//  SyLbsImageShowTableViewCell.m
//  M1Core
//
//  Created by Aries on 14/12/16.
//
//

#import "CMPLbsImageShowTableViewCell.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/MAttachment.h>
#import "CMPImageView.h"
@interface CMPLbsImageShowTableViewCell ()
{
    UIImageView *_circleImageView;
    UIImageView *_bgImageView;

}
@property (nonatomic, retain) NSArray *imageList;
@end

@implementation CMPLbsImageShowTableViewCell
- (void)dealloc
{
    SY_RELEASE_SAFELY(_imageList);
    SY_RELEASE_SAFELY(_circleImageView);
    SY_RELEASE_SAFELY(_bgImageView);
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if(!_bgImageView){
            _bgImageView = [[UIImageView alloc] init];
            UIImage *image = [UIImage imageNamed:@"lbsShow.bundle/sign_atMe_bg.png"];
            _bgImageView.image = [image stretchableImageWithLeftCapWidth:14 topCapHeight:32];
            [self addSubview:_bgImageView];
        }
        if(!_circleImageView){
            _circleImageView = [[UIImageView alloc] init];
            _circleImageView.image = [UIImage imageNamed:@"lbsShow.bundle/sign_image.png"];
            [self addSubview:_circleImageView];
        }
    }
    return self;
}

-(void)setCellWithAttachmentList:(NSArray *)list
{
    for(int i = 0; i < list.count; i++){
        MAttachment *att = list[i];
        CMPImageView *imageView = [[CMPImageView alloc] init];
        imageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lbsShow.bundle/lbs_default_image.png"]];
        imageView.userInteractionEnabled = YES;
        imageView.tag = 1000+i;
        UITapGestureRecognizer *aTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [imageView addGestureRecognizer:aTap];
        SY_RELEASE_SAFELY(aTap);
        
        imageView.attachment = att;
        imageView.frame = CGRectMake(63+(i%3)*60+(i%3+1)*10, (i/3)*60+(i/3)*5+19, 60, 60);
        [self addSubview:imageView];
        SY_RELEASE_SAFELY(imageView);
    }
    CGFloat width = 230;
    if(list.count < 3){
        width = 30+list.count*60 + (list.count-1)*10;
    }
    _bgImageView.frame = CGRectMake(55, 12, width, 8+((list.count-1)/3+1)*65);
    self.imageList = list;
}

- (void)tapAction:(UITapGestureRecognizer *)aTap
{
    if(_delegate && [_delegate respondsToSelector:@selector(lbsImageShowTableViewCell:imageIndex:attchmentList:)]){
        [_delegate lbsImageShowTableViewCell:self imageIndex:aTap.view.tag -1000 attchmentList:_imageList];
    }
}

- (void)layoutSubviews
{
    _circleImageView.frame = CGRectMake(22, 22, 28, 28);
}
@end
