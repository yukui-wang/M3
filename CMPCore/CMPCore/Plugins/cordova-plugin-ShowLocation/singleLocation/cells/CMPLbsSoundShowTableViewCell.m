//
//  SyLbsSoundShowTableViewCell.m
//  M1Core
//
//  Created by Aries on 14/12/16.
//
//

#import "CMPLbsSoundShowTableViewCell.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/MAttachment.h>
#import <CMPLib/SyAttachment.h>
#import "CMPSoundPlayer.h"
@interface CMPLbsSoundShowTableViewCell ()/*<CMPSoundPlayerDelegate>*/
{
    UIImageView *_circleImageView;
    UIImageView *_bgImageView;
    UIView      *_lineView;
    UIImageView *_soundImageView;
    UILabel *_soundSecondLabel;
    
}
@property (nonatomic, retain) MAttachment *attachment;
@end

@implementation CMPLbsSoundShowTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self =[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if(!_bgImageView){
            _bgImageView = [[UIImageView alloc] init];
            UIImage *image = [UIImage imageNamed:@"lbsShow.bundle/sign_atMe_bg.png"];
            _bgImageView.image = [image stretchableImageWithLeftCapWidth:14 topCapHeight:20];
            _bgImageView.userInteractionEnabled = YES;
            [self addSubview:_bgImageView];
        }
        if(!_circleImageView){
            _circleImageView = [[UIImageView alloc] init];
            _circleImageView.image = [UIImage imageNamed:@"lbsShow.bundle/sign_sound_2.png"];
            [self addSubview:_circleImageView];
        }
        if (!_soundImageView) {
            _soundImageView = [[UIImageView alloc] init];
            [_soundImageView setAnimationDuration:1];
        }
        if (!_soundSecondLabel) {
            _soundSecondLabel = [[UILabel alloc] init];
            _soundSecondLabel.textAlignment = NSTextAlignmentLeft;
            _soundSecondLabel.textColor = UIColorFromRGB(0x7894a3);
            _soundSecondLabel.backgroundColor = [UIColor clearColor];
            _soundSecondLabel.font = FONTSYS(13);
            [self addSubview:_soundSecondLabel];
        }
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        tapGes.numberOfTapsRequired = 1;
        tapGes.numberOfTouchesRequired = 1;
        [_bgImageView addGestureRecognizer:tapGes];
        SY_RELEASE_SAFELY(tapGes);
        _soundImageView.image = [UIImage imageNamed:@"lbsShow.bundle/sign_play_sound3.png"];
        [self addSubview:_soundImageView];
    }
    return self;
}
- (void)tapAction:(UITapGestureRecognizer *)aTap
{
    SyAttachment *attachment = [[SyAttachment alloc] initWithMAttachmentBase:_attachment];
    [[CMPSoundPlayer sharedPlayer] playWithSyAttachment:attachment delegate:self];
    SY_RELEASE_SAFELY(attachment);

}
- (void)setCellWithAttachmentList:(NSArray *)list;
{
    SY_RELEASE_SAFELY(_attachment);
    if(list.count > 0)
    self.attachment = list[0];
    
}

- (void)setSoundSecond:(NSInteger)s
{
    _soundSecondLabel.text = [NSString stringWithFormat:@"%ld\"",(long)s];
}

- (void)layoutSubviews
{
    _circleImageView.frame = CGRectMake(22, 22, 28, 28);
    CGFloat w = INTERFACE_IS_PAD ? 230 :self.width/2;
    _bgImageView.frame = CGRectMake(55, 13, w, self.frame.size.height - 13);
    _soundImageView.frame = CGRectMake(70, 22, 15,16);

    CGFloat x = _bgImageView.width+_bgImageView.originX;
    x += 9;
    _soundSecondLabel.frame = CGRectMake(x, _bgImageView.originY, 80, _bgImageView.height);

}

- (void)dealloc
{
    SY_RELEASE_SAFELY(_bgImageView);
    SY_RELEASE_SAFELY(_circleImageView);
    SY_RELEASE_SAFELY(_lineView);
    SY_RELEASE_SAFELY(_soundImageView);
    SY_RELEASE_SAFELY(_soundSecondLabel);
    SY_RELEASE_SAFELY(_attachment);
    [super dealloc];
}
#pragma CMPSoundPlayerDelegate
- (void)soundPlayerDidStart:(CMPSoundPlayer *)soundPlayer
{
    // 开始
    [_soundImageView setAnimationImages:[NSArray arrayWithObjects:[UIImage imageNamed:@"lbsShow.bundle/sign_play_sound1.png"],[UIImage imageNamed:@"lbsShow.bundle/sign_play_sound2.png"],[UIImage imageNamed:@"lbsShow.bundle/sign_play_sound3.png"], nil]];
    [_soundImageView startAnimating];
}
- (void)soundPlayerDidPause:(CMPSoundPlayer *)soundPlayer
{
    // 暂停
    [_soundImageView stopAnimating];
    _soundImageView.image  = [UIImage imageNamed:@"lbsShow.bundle/sign_play_sound3"];
}
- (void)soundPlayer:(CMPSoundPlayer *)soundPlayer didFinishPlayWithPath:(NSString *)aPath
{
    // 完成
    [_soundImageView stopAnimating];
    _soundImageView.image  = [UIImage imageNamed:@"lbsShow.bundle/sign_play_sound3"];
}


@end
