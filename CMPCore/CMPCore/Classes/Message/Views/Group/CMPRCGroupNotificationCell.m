//
//  CMPRCGroupNotificationCell.m
//  CMPCore
//
//  Created by CRMO on 2017/8/7.
//
//

#import "CMPRCGroupNotificationCell.h"
#import <CMPLib/CMPConstant.h>
#import "CMPRCGroupNotificationObject.h"
#import <CMPLib/CMPFaceView.h>
#import "CMPContactsManager.h"
#import <CMPLib/CMPDateHelper.h>
#import "CMPChatManager.h"
#import "CMPRCUserCacheManager.h"
#import <CMPLib/CMPThemeManager.h>

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

// --------------尺寸-----------------
static CGFloat const kTimeLabelMarginTop = 14; // 时间控件上边距
static CGFloat const kTimeLabelHeight = 16; // 时间控件高度
static CGFloat const kTimeLabelMarginBottom = 14; // 时间控件下边距
static CGFloat const kContentLabelMarginTop = 19;
static CGFloat const kContentLabelMarginRight = 15;
static CGFloat const kContentLabelMarginBottom = 11;
static CGFloat const kOperatorLabelHeight = 12;
//static CGFloat const kOperatorLabelMarginRight = 15;
static CGFloat const kOperatorLabelMarginBottom = 24;
static CGFloat const kMainViewMarginLeft = 10;
static CGFloat const kMainViewMarginRight = 10;
static CGFloat const kIconViewMarginLeft = 15;
static CGFloat const kIconViewMarginRight = 10;
static CGFloat const kIconViewMarginTop = 19;
static CGFloat const kIconViewWidth = 40;
static CGFloat const kIconViewHeight = 40;
// --------------字体-----------------
static CGFloat const kTimeLabelFont = 12;
static CGFloat const kContentLabelFont = 14;
static CGFloat const kOperatorLabelFont = 12;

@interface CMPRCGroupNotificationCell()

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) CMPFaceView *iconView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *operatorLabel;
@property (nonatomic, strong) NSString *msgID;

@end

@implementation CMPRCGroupNotificationCell

- (void)dealloc
{
    SY_RELEASE_SAFELY(_mainView);
    SY_RELEASE_SAFELY(_iconView);
    SY_RELEASE_SAFELY(_contentLabel);
    SY_RELEASE_SAFELY(_operatorLabel);
    SY_RELEASE_SAFELY(_timeLabel);
    SY_RELEASE_SAFELY(_msgID);
    [super dealloc];
}


- (void)setupWithObject:(CMPRCGroupNotificationObject *)object {
    self.msgID = object.msgId;
    _timeLabel.text = [self timeStrWith:object.receiveTime];
    
    SyFaceDownloadObj *obj = [[SyFaceDownloadObj alloc] init];
    obj.serverId = [CMPCore sharedInstance].serverID;
    obj.memberId = [NSString stringWithFormat:@"rcgroup_%@",object.iconUrl] ;
    obj.downloadUrl = [CMPCore rcGroupIconUrlWithGroupId:object.iconUrl];
    _iconView.memberIcon = obj;
    [obj release];
    obj = nil;
    
    [[CMPContactsManager defaultManager] memberNameForId:object.operatorUserId completion:^(NSString *name) {
        if (![NSString isNull:name]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_msgID isEqualToString:object.msgId]) {
                    _operatorLabel.text = [NSString stringWithFormat:@"%@：%@", SY_STRING(@"msg_operator"),name];
                }
            });
            return;
        }
        
        CMPRCUserCacheManager *userCacheManager = [CMPChatManager sharedManager].userCacheManager;
        [userCacheManager getUserName:object.operatorUserId done:^(NSString *name) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_msgID isEqualToString:object.msgId]) {
                    _operatorLabel.text = [NSString stringWithFormat:@"%@：%@", SY_STRING(@"msg_operator"),name];
                }
            });
        }];
    }];
    
    NSString *content = object.content;
    _contentLabel.text = content;
    [self customLayoutSubviewsFrame:self.frame];
}

+ (CGFloat)getCellHeight:(CMPRCGroupNotificationObject *)object width:(CGFloat)width {
    NSString *content = object.content;
    CGFloat contentLableHeight = [CMPRCGroupNotificationCell contentLabelSize:content cellWidth:width].height;
    return kTimeLabelMarginTop + kTimeLabelHeight + kTimeLabelMarginBottom + kContentLabelMarginTop + contentLableHeight + kContentLabelMarginBottom + kOperatorLabelHeight + kOperatorLabelMarginBottom;
}


#pragma mark -
#pragma mark -TimeLabel Format

/**
 根据群系统消息时间显示规则处理时间
 当天：时+分
 昨天：昨天+时+分
 前天：月+日+时+分
 去年及之前：年+月+日+时+分
 @param time 待处理的时间，UNIX时间
 */
- (NSString *)timeStrWith:(NSString *)time {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *targetDate = [formatter dateFromString:time];
    
    NSString *result = @"";
    
    if ([self isThisYear:targetDate]) {
        if ([self isYesterday:targetDate]) { // 昨天
            [formatter setDateFormat:@"HH:mm"];
            result = [formatter stringFromDate:targetDate];
            result = [NSString stringWithFormat:@"%@ %@", SY_STRING(@"Common_Yesterday"),result];
        } else if ([self isToday:targetDate]) { // 今天
            [formatter setDateFormat:@"HH:mm"];
            result = [formatter stringFromDate:targetDate];
        } else { // 其它情况
            [formatter setDateFormat:@"MM-dd HH:mm"];
            result = [formatter stringFromDate:targetDate];
        }
    } else { // 不同年
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        result = [formatter stringFromDate:targetDate];
    }
    
    [formatter release];
    formatter = nil;
    
    return result;
}

- (BOOL)isYesterday:(NSDate *)date {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSString *nowString = [fmt stringFromDate:[NSDate date]];
    NSDate *nowDate = [fmt dateFromString:nowString];
    NSString *targetString = [fmt stringFromDate:date];
    NSDate *targetDate = [fmt dateFromString:targetString];
    
    // 比较
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    NSDateComponents *cmps = [calendar components:unit fromDate:targetDate toDate:nowDate options:0];
    
    [fmt release];
    fmt = nil;
    
    return cmps.year == 0
    && cmps.month == 0
    && cmps.day == 1;
}

- (BOOL)isToday:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    NSDateComponents *selfCmps = [calendar components:unit fromDate:date];
    
    return nowCmps.year == selfCmps.year
    && nowCmps.month == selfCmps.month
    && nowCmps.day == selfCmps.day;
}

- (BOOL)isThisYear:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger nowYear = [calendar component:NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger selfYear = [calendar component:NSCalendarUnitYear fromDate:date];
    return nowYear == selfYear;
}

#pragma mark -
#pragma mark -UI

- (void)setup {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = FONTSYS(kTimeLabelFont);
        _timeLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_timeLabel];
    }
    
    if (!_mainView) {
        _mainView = [[UIView alloc] init];
        _mainView.layer.cornerRadius = 10;
        _mainView.layer.borderWidth = 0.5;
        _mainView.layer.borderColor = [UIColor cmp_colorWithName:@"gray-bgc1"].CGColor;
        _mainView.layer.masksToBounds = YES;
        _mainView.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
        [self addSubview:_mainView];
    }
    
    if (!_iconView) {
        _iconView = [[CMPFaceView alloc] init];
        _iconView.frame = [self iconViewFrame];
        _iconView.layer.cornerRadius = kIconViewWidth / 2;
        _iconView.clipsToBounds = YES;
        _iconView.placeholdImage = [UIImage imageNamed:@"msg_group_default"];
        [_mainView addSubview:_iconView];
    }
    
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.font = FONTSYS(kContentLabelFont);
        _contentLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
        _contentLabel.numberOfLines = 0;
        [_mainView addSubview:_contentLabel];
    }
    
    if (!_operatorLabel) {
        _operatorLabel = [[UILabel alloc] init];
        _operatorLabel.textAlignment = NSTextAlignmentLeft;
        _operatorLabel.font = FONTSYS(kOperatorLabelFont);
        _operatorLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
        [_mainView addSubview:_operatorLabel];
    }
    [self setBackgroundColor:[UIColor cmp_colorWithName:@"liactive-bgc"]];
    self.selectionStyle  = UITableViewCellSelectionStyleNone;
    [self.separatorImageView removeFromSuperview];
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    [_timeLabel setFrame:[self timeLabelFrame]];
    CGRect oldContentLabelFrame = [self contentLabelFrame];
    CGRect oldOperatorLabelFrame = [self operatorLabelFrame];
    CGRect oldMainViewFrame = [self mainViewFrame];
    _contentLabel.frame = CGRectMake(oldContentLabelFrame.origin.x, oldContentLabelFrame.origin.y, oldContentLabelFrame.size.width, [CMPRCGroupNotificationCell contentLabelSize:_contentLabel.text cellWidth:self.width].height);
    _operatorLabel.frame = CGRectMake(oldOperatorLabelFrame.origin.x,
                                      _contentLabel.frame.origin.y + _contentLabel.frame.size.height + kContentLabelMarginBottom,
                                      oldOperatorLabelFrame.size.width, oldOperatorLabelFrame.size.height);
    _mainView.frame = CGRectMake(oldMainViewFrame.origin.x, oldMainViewFrame.origin.y, oldMainViewFrame.size.width, kContentLabelMarginTop + _contentLabel.frame.size.height + kContentLabelMarginBottom + kOperatorLabelHeight + kOperatorLabelMarginBottom);
}


+ (CGSize)contentLabelSize:(NSString *)content cellWidth:(CGFloat)cellWidth {
    CGFloat maxContentViewWidth = [CMPRCGroupNotificationCell maxContentLabelWidth:cellWidth];
    CGSize constraint = CGSizeMake(maxContentViewWidth, CGFLOAT_MAX);
    CGSize height = [content boundingRectWithSize:constraint
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName:FONTSYS(kContentLabelFont)}
                                          context:nil].size;
    return height;
}

+ (CGFloat)maxContentLabelWidth:(CGFloat)cellWidth {
    return cellWidth - kMainViewMarginLeft - kMainViewMarginRight - \
    kIconViewMarginLeft - kIconViewMarginRight - \
    kIconViewWidth - kContentLabelMarginRight;
}

- (CGRect)timeLabelFrame {
    return CGRectMake(kMainViewMarginLeft, kTimeLabelMarginTop,
                      self.width - kMainViewMarginLeft - kMainViewMarginRight,
                      kTimeLabelHeight);
}

- (CGRect)mainViewFrame {
    return CGRectMake(kMainViewMarginLeft,
                      kTimeLabelMarginTop + kTimeLabelMarginBottom + kTimeLabelHeight,
                      self.width - 10 * 2, 0);
}

- (CGRect)iconViewFrame {
    return CGRectMake(kIconViewMarginLeft,
                      kIconViewMarginTop,
                      kIconViewHeight, kIconViewWidth);
}

- (CGRect)contentLabelFrame {
    CGFloat width = [CMPRCGroupNotificationCell maxContentLabelWidth:self.width];
    return CGRectMake(kIconViewMarginLeft + kIconViewWidth + kIconViewMarginRight,
                      kContentLabelMarginTop, width, 0);
}

- (CGRect)operatorLabelFrame {
    CGFloat width = [CMPRCGroupNotificationCell maxContentLabelWidth:self.width];
    return CGRectMake(kIconViewMarginLeft + kIconViewWidth + kIconViewMarginRight,
                      0, width, kOperatorLabelHeight);
}

@end
