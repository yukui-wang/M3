//
//  CMPMessageListCell.m
//  CMPCore
//
//  Created by wujiansheng on 2017/6/26.
//
//

#import "CMPMessageListCell.h"
#import "CMPModuleIconView.h"
#import <CMPLib/CMPDateHelper.h>
#import <CMPLib/CMPFaceView.h>
#import "CMPMessageManager.h"
#import "CMPChatManager.h"
#import <CMPLib/NSObject+FBKVOController.h>
#import <CMPLib/CMPFontModel.h>
#import <CMPLib/UIView+DragBlast.h>
#import <CMPLib/UIView+RTL.h>
#import <RongIMLib/RCIMClient.h>
#import "CMPContactsManager.h"
@interface CMPMessageListCell() {
    CMPModuleIconView *_imageView;
    CMPFaceView *_faceView;

    UILabel *_appNameLabel;
    UILabel *_timeLabel;
    UILabel *_contentLabel;
    UILabel *_unreadCountLabel;
    /** 关联账号专用未读标志 **/
    UIView *_assUnreadLabel;
    /** 消息免扰 **/
    UIImageView *_notDisturb;
    UILabel *_departmentTagLabel;
}

@end

@implementation CMPMessageListCell

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    if (!_imageView) {
        _imageView = [[CMPModuleIconView alloc] init];
//        _imageView.frame = CGRectMake(0, 0, 44, 44);
//        _imageView.layer.cornerRadius = 22;
        [self addSubview:_imageView];
        [self _restoreBackgroundColorWhenSelected:_imageView];
    }
    if (!_faceView) {
        _faceView = [[CMPFaceView alloc] init];
        _faceView.frame = CGRectMake(0, 0, 44, 44);
        _faceView.layer.cornerRadius = 22;
        _faceView.clipsToBounds = YES;
        [self addSubview:_faceView];
    }
    if (!_appNameLabel) {
        _appNameLabel = [[UILabel alloc]init];
        _appNameLabel.textAlignment = NSTextAlignmentLeft;
        _appNameLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        _appNameLabel.backgroundColor = [UIColor clearColor];
        _appNameLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
        [self addSubview:_appNameLabel];
    }
    
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = FONTSYS(12);
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
        [self addSubview:_timeLabel];
    }
    
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc]init];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
        [self addSubview:_contentLabel];
    }
    
    self.separatorImageView.backgroundColor = [UIColor clearColor];
//    self.separatorLeftMargin = 70;
    self.separatorHide = YES;
    self.selectionStyle  = UITableViewCellSelectionStyleDefault;
    [self setSelectBkViewColor:[UIColor cmp_colorWithName:@"liactive-bgc"]];
    
    _departmentTagLabel = [[UILabel alloc] init];
    _departmentTagLabel.backgroundColor = [[UIColor cmp_colorWithName:@"theme-bgc"] colorWithAlphaComponent:0.2];
    _departmentTagLabel.textColor = [UIColor cmp_colorWithName:@"theme-fc"];
    _departmentTagLabel.textAlignment = NSTextAlignmentCenter;
    _departmentTagLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    _departmentTagLabel.text = SY_STRING(@"common_dept");
    [self addSubview:_departmentTagLabel];
    [_departmentTagLabel sizeToFit];
    _departmentTagLabel.hidden = YES;
    [_departmentTagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_appNameLabel);
        make.height.equalTo(@17);
        make.left.mas_equalTo(_appNameLabel.mas_right).offset(@10);
    }];
}

/**
 修复cell被选中后，所有子view的背景色被改变问题
 */
- (void)_restoreBackgroundColorWhenSelected:(UIView *)view {
    [self.KVOController observe:view keyPath:@"backgroundColor" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        UIColor *newColor = change[NSKeyValueChangeNewKey];
        UIColor *oldColor = change[NSKeyValueChangeOldKey];
        if (![newColor isKindOfClass:[UIColor class]] || ![oldColor isKindOfClass:[UIColor class]]) {
            return;
        }
        if ([newColor isMemberOfClass:objc_getClass("UICachedDeviceWhiteColor")]) {
            if ([object respondsToSelector:@selector(setBackgroundColor:)]) {
                [object performSelector:@selector(setBackgroundColor:) withObject:oldColor];
            }
        }
    }];
}

- (void)showNotDisturb:(BOOL)isShow {
    if (isShow) {
        if (!_notDisturb) {
            _notDisturb = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
            _notDisturb.image = [UIImage imageNamed:@"msg_not_disturb"];
            [self addSubview:_notDisturb];
        }
        _notDisturb.hidden = NO;
        
        if (_unreadCountLabel) {
            _unreadCountLabel.hidden = YES;
        }
        if (_assUnreadLabel) {
            _assUnreadLabel.hidden = YES;
        }
    } else {
        _notDisturb.hidden = YES;
    }
}

- (void)showMarkUnread {
    [self showNotDisturb:NO];
    
    NSInteger h =20;
    if (!_unreadCountLabel) {
        _unreadCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, h*2, h)];
        _unreadCountLabel.textAlignment = NSTextAlignmentCenter;
        _unreadCountLabel.font = FONTSYS(13);
        _unreadCountLabel.textColor = [UIColor cmp_colorWithName:@"reverse-fc"];
        [_unreadCountLabel blastCompletion:^(BOOL finished) {
            if (finished) {
                if (self.dragAction) {
                    self.dragAction();
                }
            }
        }];
        [self addSubview:_unreadCountLabel];
        [self _restoreBackgroundColorWhenSelected:_unreadCountLabel];
    }
    _assUnreadLabel.hidden = YES;
    _unreadCountLabel.hidden = NO;
    _unreadCountLabel.layer.cornerRadius = h/2;
    _unreadCountLabel.layer.masksToBounds = YES;
    _unreadCountLabel.text = @"1";
    _unreadCountLabel.backgroundColor = [UIColor cmp_colorWithName:@"hl-bgc3"];
    _unreadCountLabel.textColor = [UIColor cmp_colorWithName:@"reverse-fc"];
}

- (void)addUnreadCount:(NSString *)count object:(CMPMessageObject *)object
{
    [self showNotDisturb:NO];
    if ([count integerValue] > 0 ) {
        // 其它企业消息,小广播展示小圆点
        if (object.type == CMPMessageTypeAssociate || object.type == CMPMessageTypeMassNotification) {
            if (!_assUnreadLabel) {
                _assUnreadLabel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
                _assUnreadLabel.backgroundColor = [UIColor cmp_colorWithName:@"hl-bgc3"];
                _assUnreadLabel.layer.cornerRadius = 5;
                _assUnreadLabel.layer.masksToBounds = YES;
                [_assUnreadLabel blastCompletion:^(BOOL finished) {
                    if (finished) {
                        if (self.dragAction) {
                            self.dragAction();
                        }
                    }
                }];
                if (object.type == CMPMessageTypeAssociate) {
                    _assUnreadLabel.dragBlast = NO;
                }
                [self addSubview:_assUnreadLabel];
                [self _restoreBackgroundColorWhenSelected:_assUnreadLabel];
            }if ( object.type == CMPMessageTypeMassNotification && (![CMPCore sharedInstance].pushAcceptInformation || ![CMPCore sharedInstance].inPushPeriod)) {
                _assUnreadLabel.backgroundColor = [[UIColor cmp_colorWithName:@"theme-bgc"] colorWithAlphaComponent:0.3];
            }else{
                _assUnreadLabel.backgroundColor = [UIColor cmp_colorWithName:@"hl-bgc3"];
            }
            _unreadCountLabel.hidden = YES;
            _assUnreadLabel.hidden = NO;
        } else {
            NSInteger h =20;
            if (!_unreadCountLabel) {
                _unreadCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, h*2, h)];
                _unreadCountLabel.textAlignment = NSTextAlignmentCenter;
                _unreadCountLabel.font = FONTSYS(13);
                _unreadCountLabel.textColor = [UIColor cmp_colorWithName:@"reverse-fc"];
                [_unreadCountLabel blastCompletion:^(BOOL finished) {
                    if (finished) {
                        if (self.dragAction) {
                            self.dragAction();
                        }
                    }
                }];
                [self addSubview:_unreadCountLabel];
                [self _restoreBackgroundColorWhenSelected:_unreadCountLabel];
            }
            _assUnreadLabel.hidden = YES;
            _unreadCountLabel.hidden = NO;
            
            if (object.type == CMPMessageTypeApp ||
                object.type == CMPMessageTypeAggregationApp) {
                
                if ([object.extra2 isEqualToString:@"0"] ||
                    ![CMPCore sharedInstance].pushAcceptInformation ||
                    ![CMPCore sharedInstance].inPushPeriod) {
                    _unreadCountLabel.backgroundColor = [[UIColor cmp_colorWithName:@"theme-bgc"] colorWithAlphaComponent:0.3];
                    _unreadCountLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc2"];
                } else {
                    _unreadCountLabel.backgroundColor = [UIColor cmp_colorWithName:@"hl-bgc3"];
                    _unreadCountLabel.textColor = [UIColor cmp_colorWithName:@"reverse-fc"];
                }
                
            } else if (object.type == CMPMessageTypeRC ||
                       object.type == CMPMessageTypeRCGroupNotification) {
                if (([[CMPChatManager sharedManager] getChatAlertStatus:object.cId] || [object.extra2 isEqualToString:@"0"])
                    || ![CMPCore sharedInstance].pushAcceptInformation
                    || ![CMPCore sharedInstance].inPushPeriod) {
                    //2021-11-11 增加[object.extra2 isEqualToString:@"0"]判断，设置消息不提醒后，消息提示应该为蓝色。增加判断为了弥补前一条件首次进入没有数据的问题
                    // 1.开启了消息免打扰，未读消息提醒背景色置蓝
                    // 2.关闭消息通知，所有未读消息提醒背景色置蓝
                    _unreadCountLabel.backgroundColor = [[UIColor cmp_colorWithName:@"theme-bgc"] colorWithAlphaComponent:0.3];
                    _unreadCountLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc2"];
                } else {
                    _unreadCountLabel.backgroundColor = [UIColor cmp_colorWithName:@"hl-bgc3"];
                    _unreadCountLabel.textColor = [UIColor cmp_colorWithName:@"reverse-fc"];
                }
            } else {
                _unreadCountLabel.backgroundColor = [UIColor cmp_colorWithName:@"hl-bgc3"];
                _unreadCountLabel.textColor = [UIColor cmp_colorWithName:@"reverse-fc"];
            }
            
            _unreadCountLabel.layer.cornerRadius = h/2;
            _unreadCountLabel.layer.masksToBounds = YES;
            _unreadCountLabel.text = [count integerValue]>99 ?@"99+":count;
        }
    }
    else {
        if (_unreadCountLabel) {
            _unreadCountLabel.hidden = YES;
        }
        if (_assUnreadLabel) {
            _assUnreadLabel.hidden = YES;
        }
    }
}

- (void)removeUnReadCount
{
    if (_unreadCountLabel) {
        _unreadCountLabel.hidden = YES;
    }
    if (_assUnreadLabel) {
        _assUnreadLabel.hidden = YES;
    }
}

- (void)setupObject:(CMPMessageObject *)object
{
    _timeLabel.hidden = NO;
    _timeLabel.text = [CMPDateHelper messageDateByDay:object.createTime hasTime:YES];
    
    _departmentTagLabel.hidden = YES;
    CGFloat deptWidth = 0;
    
    if (object.extradDataModel.isMarkUnread) {
        [self showMarkUnread];
    } else if ((object.type == CMPMessageTypeApp || object.type == CMPMessageTypeAggregationApp || (object.type == CMPMessageTypeRC && object.unreadCount == 0)) &&
        ([object.extra2 isEqualToString:@"0"] ||
         ![CMPCore sharedInstance].pushAcceptInformation ||
         ![CMPCore sharedInstance].inPushPeriod)) { // V7.1 SP1 V5消息展示免打扰图标，不展示气泡
            [self showNotDisturb:YES];
        } else {
            [self addUnreadCount:[NSString stringWithFormat:@"%ld",(long)object.unreadCount] object:object];
        }

    if(object.type == CMPMessageTypeApp ||
       object.type == CMPMessageTypeRCGroupNotification ||
       object.type == CMPMessageTypeAggregationApp ||
       object.type == CMPMessageTypeAssociate) {
        
        _appNameLabel.text  = SY_STRING(object.appName);
        if ([object.content isEqualToString:kMsg_NoMessage]) {
            _contentLabel.text  = @"";
        }
        else {
            _contentLabel.text  = object.content;
        }
        NSString *faceUrl = object.iconUrl;
        if ([NSString isNull:faceUrl] && ![NSString isNull:object.senderFaceUrl]) {
            faceUrl = object.senderFaceUrl;
        }
        [_imageView setImageWithIconUrl:faceUrl];
        _faceView.hidden = YES;
        _imageView.hidden = NO;
        if (object.type == CMPMessageTypeAssociate) {
            _timeLabel.hidden = YES;
        }
        
    } else if(object.type == CMPMessageTypeRC) {
        
        _faceView.hidden = NO;
        _imageView.hidden = YES;
        _appNameLabel.text  = object.appName;
        
        NSString *sendStatusStr = object.extra4;
        RCSentStatus sendStatus = SentStatus_SENT;
        if (sendStatusStr && sendStatusStr.length) {
            sendStatus = [sendStatusStr integerValue];
        }
        
        if (![NSString isNull:object.latestMessage]) {
            if (sendStatus == SentStatus_FAILED) {
                NSString *finalStr = [NSString stringWithFormat:@"！%@",NSLocalizedStringFromTable(object.content,@"RongCloudKit", nil)];
                NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:finalStr];
                [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,1)];
                [attributedStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:NSMakeRange(0,1)];
                _contentLabel.attributedText  = attributedStr;
            }else{
                _contentLabel.text  =  NSLocalizedStringFromTable(object.content,@"RongCloudKit", nil) ;
            }
        }
        else {
            if (object.hasUnreadMentioned &&
                object.unreadCount != 0) {
                NSString *metioned = SY_STRING(@"msg_metioned");
                NSString *content = [NSString stringWithFormat:@"%@%@", metioned ,object.content];
                NSUInteger metionedLength = [metioned length];
                if (sendStatus == SentStatus_FAILED) {
                    NSString *finalStr = [NSString stringWithFormat:@"！%@",content];
                    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:finalStr];
                    [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,1)];
                    [attributedStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:NSMakeRange(0,1)];
                    [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(1,metionedLength)];
                    _contentLabel.attributedText  = attributedStr;
                }else{
                    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:content];
                    [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(0,metionedLength)];
                    _contentLabel.attributedText  = attributedStr;
                }
            } else {
                if (sendStatus == SentStatus_FAILED) {
                    NSString *finalStr = [NSString stringWithFormat:@"！%@",object.content];
                    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:finalStr];
                    [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,1)];
                    [attributedStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:NSMakeRange(0,1)];
                    _contentLabel.attributedText  = attributedStr;
                }else{
                    _contentLabel.text  = object.content;
                }
            }
        }
        
        if ([object.content isEqualToString:@"OA:OAClearMsg"]) {
            _contentLabel.text = @"";
        }
        
        SyFaceDownloadObj *obj = [[SyFaceDownloadObj alloc] init];
        obj.serverId = [CMPCore sharedInstance].serverID;
        _faceView.imageView.image = nil;
        if (object.subtype == CMPRCConversationType_GROUP) {
            obj.memberId = [NSString stringWithFormat:@"rcgroup_%@",object.cId] ;
            obj.downloadUrl = [CMPCore rcGroupIconUrlWithGroupId:object.cId];
            _faceView.placeholdImage = [UIImage imageNamed:@"msg_group_default"];
            
            if (object.groupTypeInfo.groupType == 1) {
                _departmentTagLabel.hidden = NO;
                deptWidth = 32;
            }
        }
        else {
            obj.memberId = object.cId;
            obj.downloadUrl = [CMPCore memberIconUrlWithId:object.cId];
        }
        _faceView.memberIcon = obj;
        
    }else if(object.type == CMPMessageTypeUC){
        
        _appNameLabel.text = SY_STRING(@"msg_zhixin");
        _contentLabel.text  = [NSString stringWithFormat:@"%@:%@",object.appName,SY_STRING(object.content)];
        _faceView.hidden = YES;
        _imageView.hidden = NO;
        [_imageView setImageWithIconUrl:object.iconUrl];
        
    }else if(object.type == CMPMessageTypeUC){
        
        _appNameLabel.text = SY_STRING(@"msg_zhixin");
        _contentLabel.text  = [NSString stringWithFormat:@"%@:%@",object.appName,SY_STRING(object.content)];
        _faceView.hidden = YES;
        _imageView.hidden = NO;
        [_imageView setImageWithIconUrl:object.iconUrl];
        
    }else if(object.type == CMPMessageTypeMassNotification){
        
        _appNameLabel.text = SY_STRING(@"msg_xiaoguangbo");
        _contentLabel.text  = object.content;
        if (object.unreadCount == 0) {
            _timeLabel.text = @"";
            _contentLabel.text = @"";
        }
        _faceView.hidden = YES;
        _imageView.hidden = NO;
        [_imageView setImageWithIconUrl:@"image:msg_smallBroadcast:16754983"];
    }else if(object.type == CMPMessageTypeFileAssistant){
        
        _contentLabel.text  = object.content;
        
        if (object.msgId.length && object.subtype == CMPRCConversationType_PRIVATE) {
            //获取最近一条消息
            RCMessage *message = [[RCIMClient sharedRCIMClient] getMessageByUId:object.msgId];
            if (message) {
                _contentLabel.text  = object.content;
            }else{
                _contentLabel.text  = @"";
            }
        }
        
        _appNameLabel.text = SY_STRING(object.appName);
        
        if ([object.content isEqualToString:@""]) {
            _timeLabel.text = @"";
        }
        _faceView.hidden = YES;
        _imageView.hidden = NO;
        [_imageView setImageWithIconUrl:@"image:msg_file_assistant:2719739"];
    }

    [self setBkViewColor: object.isTop ? [UIColor cmp_colorWithName:@"input-bg"]:[UIColor clearColor]];
    [self undateUnreadCountLabelLayout];
    
    CGSize s = [_appNameLabel.text sizeWithAttributes:@{NSFontAttributeName:_appNameLabel.font}];
    [_departmentTagLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(deptWidth);
        make.left.equalTo(_appNameLabel.mas_left).offset(MIN(s.width, _appNameLabel.bounds.size.width)+6);
    }];

}

- (void)customLayoutSubviewsFrame:(CGRect)frame
{
    
    CGFloat appNameLabelSize = [CMPCore sharedInstance].currentFont.listHeadlinesFontSize;
    CGFloat timeLabelSize = [CMPCore sharedInstance].currentFont.supportingFontSize;
    CGFloat contentLabelSize = [CMPCore sharedInstance].currentFont.bodyFontSize;
    
    _appNameLabel.font = [UIFont systemFontOfSize:appNameLabelSize weight:UIFontWeightMedium];
    _timeLabel.font = FONTSYS(timeLabelSize);
    _contentLabel.font = [UIFont systemFontOfSize:contentLabelSize weight:UIFontWeightLight];
    
    NSInteger appNameLabelHeight = ceil([CMPCore sharedInstance].currentFont.listHeadlinesFontSize * 1.4) - ((int)ceil([CMPCore sharedInstance].currentFont.listHeadlinesFontSize * 1.4) % 2);
    NSInteger timeLabelHeight = ceil([CMPCore sharedInstance].currentFont.supportingFontSize * 1.4) - ((int)ceil([CMPCore sharedInstance].currentFont.supportingFontSize * 1.4) % 2);
    NSInteger contentLabelHeight = ceil([CMPCore sharedInstance].currentFont.bodyFontSize * 1.4) - ((int)ceil([CMPCore sharedInstance].currentFont.bodyFontSize * 1.4) % 2);
    
    if ([CMPCore sharedInstance].currentFont.fontType == FontTypeNarrow) {
        
        timeLabelHeight = ceil(12 * 1.4) - ((int)ceil(12 * 1.4) % 2);
        _timeLabel.font = FONTSYS(12);
        
    }
    
    CGFloat x;
    CGFloat y;
    CGFloat w;
    CGFloat h;
    CGFloat imageW;
    
    switch ([CMPCore sharedInstance].currentFont.fontType) {
            
        case FontTypeNarrow:{
            
            imageW = 42;
            
        }
            break;
            
        case FontTypeStandard:{
            
            imageW = 44;
            
        }
            break;
            
        case FontTypeExpandOne:{
            
             imageW = 46;
            
        }
            break;
            
        case FontTypeExpandTwo:{
            
           imageW = 48;
            
        }
            break;
    }
    
    x = 14;
    y = (self.height - imageW) * 0.5;
    [_imageView setFrame:CGRectMake(x, y, imageW, imageW)];
    [_faceView setFrame:CGRectMake(x, y, imageW, imageW)];
    
    _imageView.layer.cornerRadius = imageW * 0.5;
    _faceView.layer.cornerRadius = imageW * 0.5 ;
    
    x += _imageView.width + 10;
    y = 12;
    w = self.width - x - 100 - 14;
    h = appNameLabelHeight;
    [_appNameLabel setFrame:CGRectMake(x, y, w, h)];
    
    x += _appNameLabel.width;
    y = 14;
    w = 100;
    h = timeLabelHeight;
    [_timeLabel setFrame:CGRectMake(x, y, w, h)];
    
    x = _appNameLabel.originX;
    y = _appNameLabel.height + 12 + 2;
    w = self.width - x - 44;
    h = contentLabelHeight;
    [_contentLabel setFrame:CGRectMake(x, y, w, h)];
    
    [self undateUnreadCountLabelLayout];

//    [_imageView resetFrameToFitRTL];
//    [_faceView resetFrameToFitRTL];
//    [_appNameLabel resetFrameToFitRTL];
//    [_timeLabel resetFrameToFitRTL];
//    [_contentLabel resetFrameToFitRTL];
    [_imageView resetFrameToFitRTLWithSuperViewWidth:self.width];
    [_faceView resetFrameToFitRTLWithSuperViewWidth:self.width];
    [_appNameLabel resetFrameToFitRTLWithSuperViewWidth:self.width];
    [_timeLabel resetFrameToFitRTLWithSuperViewWidth:self.width];
    [_contentLabel resetFrameToFitRTLWithSuperViewWidth:self.width];

}

//- (void)undateUnreadCountLabelLayout {
//
//    CGFloat x = _appNameLabel.originX;
//    CGFloat h = _contentLabel.font.lineHeight+1;
//    CGFloat y = self.frame.size.height- h -13;
//    CGFloat w = 0 ;
//
//    if (_unreadCountLabel) {
//        w =[_unreadCountLabel.text sizeWithFontSize:_unreadCountLabel.font defaultSize:CGSizeMake(self.width, h)].width;
//        if (w > 25) {
//            w = w + 10;
//        } else if (w > 20) {
//            w = w + 4;
//        } else {
//            w = 20;
//        }
//    }
//
//    x += _contentLabel.width;
//    if (w < 25) {
//        x += 10;
//    }
//    [_unreadCountLabel setFrame:CGRectMake(x, y, w, 20)];
//    _unreadCountLabel.center = CGPointMake(_unreadCountLabel.center.x, _contentLabel.center.y);
//
//    if (_assUnreadLabel) {
//        [_assUnreadLabel setFrame:CGRectMake(x + 10, y, 10, 10)];
//    }
//
//}

- (void)undateUnreadCountLabelLayout {
    
    _unreadCountLabel.font = FONTSYS([CMPCore sharedInstance].currentFont.supportingFontSize);
    
    if ([CMPCore sharedInstance].currentFont.fontType == FontTypeNarrow) {
    
        _unreadCountLabel.font = FONTSYS(12);
        
    }
    
    CGFloat x = _appNameLabel.originX;
    CGFloat h = _contentLabel.font.lineHeight + 1;
    CGFloat y = self.frame.size.height - h -13;
    CGFloat w = 20 ;
    
    if (_unreadCountLabel) {
        
        w = [_unreadCountLabel.text sizeWithFontSize:_unreadCountLabel.font defaultSize:CGSizeMake(self.width, h)].width;
        
        if (w > 25) {
            
            w = w + 10;
            
        } else if (w > 20) {
            
            w = w + 4;
            
        } else {
            
            w = 20;
            
        }
    }
    
    h = 20;
    x = self.width - w - 14;
    [_unreadCountLabel setFrame:CGRectMake(x, y, w, h)];
    _unreadCountLabel.center = CGPointMake(_unreadCountLabel.center.x, _contentLabel.center.y);

    if (_assUnreadLabel) {
        [_assUnreadLabel setFrame:CGRectMake(x + 10, y, 10, 10)];
    }
    
    if (_notDisturb) {
        _notDisturb.cmp_x = self.cmp_width - 14 - 18;
        _notDisturb.cmp_y = _contentLabel.cmp_y + 2;
    }
    
    [_unreadCountLabel resetFrameToFitRTL];
    [_assUnreadLabel resetFrameToFitRTL];
    [_notDisturb resetFrameToFitRTL];
}

+ (CGFloat)height
{
    
    NSInteger appNameLabelHeight = ceil([CMPCore sharedInstance].currentFont.listHeadlinesFontSize * 1.4) - ((int)ceil([CMPCore sharedInstance].currentFont.listHeadlinesFontSize * 1.4) % 2)
    ;
    NSInteger contentLabelHeight = ceil([CMPCore sharedInstance].currentFont.bodyFontSize * 1.4) - ((int)ceil([CMPCore sharedInstance].currentFont.bodyFontSize * 1.4) % 2);
    
    CGFloat heigeht = appNameLabelHeight + contentLabelHeight + 12*2 + 2 ;
    
    return heigeht;
}

@end
