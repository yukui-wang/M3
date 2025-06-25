//
//  CMPOnTimeMeetingTopView.m
//  M3
//
//  Created by Kaku Songu on 12/1/22.
//

#import "CMPOnTimeMeetingTopView.h"
#import "CMPMeetingManager.h"
#import <CMPLib/UIImageView+WebCache.h>
#import <CMPLib/NSObject+CMPHUDView.h>

@implementation CMPOnTimeMeetingTopModel
@end

@interface CMPOnTimeMeetingTopView()
{
    UIImageView *_headIconV;
    UILabel *_nameLb;
    UILabel *_desLb;
    UILabel *_numbLb;
    UILabel *_pwdLb;
    UIButton *_cancelBtn;
    UIButton *_openBtn;
    
    CMPOnTimeMeetingTopModel *_meetingInfo;
}
@end

@implementation CMPOnTimeMeetingTopView

-(instancetype)initWithMeetingInfo:(CMPOnTimeMeetingTopModel *)meetingInfo
{
    self = [super init];
    if (self) {
        _meetingInfo = [[CMPOnTimeMeetingTopModel alloc] init];
        _meetingInfo.iconUrl = meetingInfo.iconUrl;
        _meetingInfo.creatorName = meetingInfo.creatorName;
        _meetingInfo.content = meetingInfo.content;
        _meetingInfo.numb = meetingInfo.numb;
        _meetingInfo.pwd = meetingInfo.pwd;
        _meetingInfo.creatorId = meetingInfo.creatorId;
        _meetingInfo.createTime = meetingInfo.createTime;
        
        _nameLb.text = _meetingInfo.creatorName;
        _desLb.text = _meetingInfo.content;
//        _numbLb.text = [[SY_STRING(@"meeting_insNumb") stringByAppendingString:@": "] stringByAppendingString:_meetingInfo.numb];
//        _pwdLb.text = [[SY_STRING(@"meeting_insPwd") stringByAppendingString:@": "] stringByAppendingString:_meetingInfo.pwd];
        
        NSString *sepStr = @":";
        NSString *numberStr = [[SY_STRING(@"meeting_insNumb") stringByAppendingString:@" : "] stringByAppendingString:_meetingInfo.numb];
        NSRange range = [numberStr rangeOfString:sepStr];
        NSMutableAttributedString *attributedStr_numb = [[NSMutableAttributedString alloc] initWithString:numberStr];
        [attributedStr_numb addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xD4D4D4) range:NSMakeRange(0,range.location)];
        [attributedStr_numb addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(range.location+1,numberStr.length-1-range.location)];
        _numbLb.attributedText = attributedStr_numb;
        
        NSString *pwdStr = [[SY_STRING(@"meeting_insPwd") stringByAppendingString:@" : "] stringByAppendingString:_meetingInfo.pwd];
        range = [pwdStr rangeOfString:sepStr];
        NSMutableAttributedString *attributedStr_pwd = [[NSMutableAttributedString alloc] initWithString:pwdStr];
        [attributedStr_pwd addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xD4D4D4) range:NSMakeRange(0,range.location)];
        [attributedStr_pwd addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(range.location+1,pwdStr.length-1-range.location)];
        _pwdLb.attributedText = attributedStr_pwd;
        
        
        [_headIconV sd_setImageWithURL:[NSURL URLWithString:_meetingInfo.iconUrl] placeholderImage:[UIImage imageNamed:@"msg_group_default"]];
        
        NSString *openTitle = /*_meetingInfo.pwd ? SY_STRING(@"meeting_copyAndJoin"):*/SY_STRING(@"meeting_join");
        [_openBtn setTitle:openTitle forState:UIControlStateNormal];
        
        BOOL hasPwd = [NSString isNotNull:_meetingInfo.pwd];
        _pwdLb.hidden = !hasPwd;
        
        BOOL hasNumb = NO;// [NSString isNotNull:_meetingInfo.numb];
        _numbLb.hidden = !hasNumb;
        
        if (hasPwd && !hasNumb) {
            [_pwdLb mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_openBtn);
            }];
        }
    }
    return self;
}

-(void)setup
{
    [super setup];
    self.backgroundColor = UIColorFromRGB(0x333333);
    self.layer.cornerRadius = 10;
    
    _headIconV = [[UIImageView alloc] init];
    _headIconV.layer.cornerRadius = 20;
    _headIconV.layer.masksToBounds = YES;
    [self addSubview:_headIconV];
    [_headIconV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.offset(20);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    _nameLb = [[UILabel alloc] init];
    _nameLb.font = [UIFont boldSystemFontOfSize:16];
    _nameLb.numberOfLines = 1;
    _nameLb.textAlignment = NSTextAlignmentLeft;
    _nameLb.textColor = UIColorFromRGB(0xFFFFFF);
    [_nameLb sizeToFit];
    [self addSubview:_nameLb];
    [_nameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(18);
        make.left.offset(72);
    }];
    
    _desLb = [[UILabel alloc] init];
    _desLb.font = [UIFont systemFontOfSize:12];
    _desLb.numberOfLines = 0;
    _desLb.textAlignment = NSTextAlignmentLeft;
    _desLb.textColor = UIColorFromRGB(0xFFFFFF);
    [_desLb sizeToFit];
    [self addSubview:_desLb];
    [_desLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nameLb.mas_bottom).offset(5);
        make.left.equalTo(_nameLb.mas_left);
        make.right.offset(-20);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = UIColorFromRGB(0xE4E4E4);
    line.alpha = 0.5;
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(0.5);
        make.top.equalTo(_desLb.mas_bottom).offset(14);
        make.left.offset(20);
        make.right.offset(-20);
    }];
    
    _numbLb = [[UILabel alloc] init];
    _numbLb.font = [UIFont systemFontOfSize:12];
    _numbLb.numberOfLines = 0;
    _numbLb.textAlignment = NSTextAlignmentLeft;
    _numbLb.textColor = UIColorFromRGB(0xFFFFFF);
    [_numbLb sizeToFit];
    [self addSubview:_numbLb];
    [_numbLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_desLb.mas_bottom).offset(28);
        make.left.offset(20);
    }];
    
    _pwdLb = [[UILabel alloc] init];
    _pwdLb.font = [UIFont systemFontOfSize:12];
    _pwdLb.numberOfLines = 0;
    _pwdLb.textAlignment = NSTextAlignmentLeft;
    _pwdLb.textColor = UIColorFromRGB(0xFFFFFF);
    [_pwdLb sizeToFit];
    [self addSubview:_pwdLb];
    [_pwdLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_numbLb.mas_bottom).offset(4);
        make.left.offset(20);
//        make.bottom.offset(-14);
    }];
    
    _openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_openBtn setTitle:SY_STRING(@"meeting_join") forState:UIControlStateNormal];
    _openBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_openBtn setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
    [_openBtn setBackgroundColor:[UIColor cmp_colorWithName:@"theme-bgc"]];
    _openBtn.layer.cornerRadius = 13;
    [self addSubview:_openBtn];
    [_openBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-20);
//        make.centerY.equalTo(_numbLb.mas_bottom).offset(2);
        make.size.mas_equalTo(CGSizeMake(88, 26));
        make.top.equalTo(line.mas_bottom).offset(20);
        make.bottom.offset(-20);
    }];
    
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelBtn setTitle:SY_STRING(@"user_notification_ignore") forState:UIControlStateNormal];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_cancelBtn setTitleColor:[UIColor cmp_colorWithName:@"theme-bgc"] forState:UIControlStateNormal];
    [_cancelBtn setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
    _cancelBtn.layer.cornerRadius = 13;
    [self addSubview:_cancelBtn];
    [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_openBtn.mas_left).offset(-10);
        make.centerY.equalTo(_openBtn);
        make.size.mas_equalTo(CGSizeMake(64, 26));
    }];
    
    [_openBtn addTarget:self action:@selector(_openAct) forControlEvents:UIControlEventTouchUpInside];
    [_cancelBtn addTarget:self action:@selector(_cancelAct) forControlEvents:UIControlEventTouchUpInside];
}

-(void)_openAct
{
    [CMPMeetingManager otmOpenWithNumb:_meetingInfo.numb pwd:_meetingInfo.pwd link:_meetingInfo.link result:^(BOOL success, NSError * _Nonnull error) {
        if (!success && error) {
            if (error.code == -104) {
                [CMPObject cmp_showHUDWithText:@"会议链接格式有误，无法打开"];
            }
        }
    }];
    if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(cmpWindowAlertBaseView:didAct:ext:)]) {
        [self.baseDelegate cmpWindowAlertBaseView:self didAct:CMPWindowAlertBaseViewActionDismiss ext:_meetingInfo];
    }
}

-(void)_cancelAct
{
    if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(cmpWindowAlertBaseView:didAct:ext:)]) {
        [self.baseDelegate cmpWindowAlertBaseView:self didAct:CMPWindowAlertBaseViewActionDismiss ext:_meetingInfo];
    }
}

@end
