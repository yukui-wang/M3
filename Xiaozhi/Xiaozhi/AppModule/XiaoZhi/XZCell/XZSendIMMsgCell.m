//
//  XZSendIMMsgCell.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/6/22.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZSendIMMsgCell.h"
#import "XZSendIMMsgModel.h"
#import <CMPLib/CMPFaceView.h>
#import "XZCore.h"
#import "XZMainProjectBridge.h"
@interface XZSendIMMsgCell () {
    UIView *_bkView;
    UILabel *_topView;
    UIImageView *_contentBk;
    UILabel *_contentLabel;
    CMPFaceView *_faceView;
}

@end


@implementation XZSendIMMsgCell

- (void)setup {
    if(!_bkView) {
        _bkView = [[UIView alloc] init];
        _bkView.layer.cornerRadius = 10;
        _bkView.layer.masksToBounds = YES;
        _bkView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_bkView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickSendIMMsgCard)];
        [_bkView addGestureRecognizer:tap];
    }
    if (!_topView) {
        _topView = [[UILabel alloc] init];
        _topView.font = FONTSYS(14);
        _topView.textColor = [UIColor whiteColor];
        _topView.backgroundColor = UIColorFromRGB(0x297FFB);
        _topView.textAlignment = NSTextAlignmentCenter;
        [_bkView addSubview:_topView];
    }
    if (!_contentBk) {
        _contentBk = [[UIImageView alloc] init];
        _contentBk.layer.cornerRadius = 4;
        _contentBk.layer.masksToBounds = YES;
        _contentBk.image = XZ_IMAGE(@"xz_im_bk.png");
        [_bkView addSubview:_contentBk];
    }
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = FONTSYS(16);
        _contentLabel.textColor = [UIColor blackColor];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.numberOfLines = 0;
        [_bkView addSubview:_contentLabel];
    }
    if (!_faceView) {
        _faceView = [[CMPFaceView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _faceView.layer.cornerRadius = 20;
        _faceView.layer.masksToBounds = YES;
        [_bkView addSubview:_faceView];
        
    }
    self.separatorHide = YES;
    UIColor *bkColor = [UIColor clearColor];
    [self setBkViewColor:bkColor];
    self.backgroundColor = bkColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    [_bkView setFrame:CGRectMake(14, 0, self.width-28, self.height-20)];
    [_topView setFrame:CGRectMake(0, 0, _bkView.width, 40)];
    [_faceView setFrame:CGRectMake(_bkView.width-54, 60, 40, 40)];
  
    CGRect r = _contentLabel.frame;
    r.origin.y = 70;
    r.origin.x = _bkView.width- r.size.width- 77;
    [_contentLabel setFrame:r];
    
    r.origin.y =  61;
    r.origin.x -= 12;
    r.size.width += 30;
    r.size.height += 18;
    [_contentBk setFrame:r];
    
    _contentBk.image = [XZ_IMAGE(@"xz_im_bk.png") resizableImageWithCapInsets:UIEdgeInsetsMake(35, 14, 14, 35) resizingMode:UIImageResizingModeStretch];

}

- (void)setModel:(XZSendIMMsgModel *)model {
    [super setModel:model];
    
    [_topView setText:[NSString stringWithFormat:@"发送给：%@",model.targetMember.name]];
    [_contentLabel setText:model.content];
    [_contentLabel setFrame:CGRectMake(0, 0, model.contentSize.width, model.contentSize.height)];

    SyFaceDownloadObj *memberIcon = [[SyFaceDownloadObj alloc] init];
    memberIcon.memberId = [XZCore userID];
    memberIcon.serverId = [XZCore serverID];
    memberIcon.downloadUrl = [CMPCore memberIconUrlWithId:memberIcon.memberId];
    _faceView.memberIcon = memberIcon;
    [self customLayoutSubviewsFrame:self.frame];
}

- (void)clickSendIMMsgCard {
    XZSendIMMsgModel *model = (XZSendIMMsgModel *)self.model;
    [XZMainProjectBridge showChatWithMember:model.targetMember];
}

@end
