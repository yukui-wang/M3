//
//  XZStatisticsMsgView.m
//  M3
//
//  Created by wujiansheng on 2018/9/7.
//  统计消息 工作统计

#import "XZStatisticsMsgView.h"
#import "XZStatisticsMsg.h"

@implementation XZStatisticsMsgView

- (void)dealloc {
    SY_RELEASE_SAFELY(_scrollView);
    SY_RELEASE_SAFELY(_prLabel);
    SY_RELEASE_SAFELY(_prNoteLabel);
    SY_RELEASE_SAFELY(_sendView);
    SY_RELEASE_SAFELY(_handleView);
    SY_RELEASE_SAFELY(_shareView);
    SY_RELEASE_SAFELY(_avgHandleTimeView);
    SY_RELEASE_SAFELY(_noteLabel);

    [super dealloc];
}

- (id)initWithMsg:(XZStatisticsMsg *)msg {
    if (self = [super initWithMsg:msg]) {
        NSRange range = [msg.processRank rangeOfString:@"/"];
        if (range.location != NSNotFound) {
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:msg.processRank];
            [str addAttribute:NSFontAttributeName
                        value:FONTSYS(60)
                        range:NSMakeRange(0, range.location)];

            [str addAttribute:NSFontAttributeName
                        value:FONTSYS(24)
                        range:NSMakeRange(range.location,msg.processRank.length -range.location)];
            
            
            //             //阴影
            NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
            shadow.shadowBlurRadius = 9;
            shadow.shadowColor = RGBACOLOR(46, 126, 208, 102.f/255.f);//  UIColorFromRGB(0x2E7ED0);
            shadow.shadowOffset = CGSizeMake(0, 7);
            [str addAttribute:NSShadowAttributeName
                        value:shadow
                        range:NSMakeRange(0, range.location)];
            
            NSShadow *shadow1 = [[[NSShadow alloc] init] autorelease];
            shadow1.shadowBlurRadius = 0;
            shadow1.shadowColor = [UIColor clearColor];
            shadow1.shadowOffset = CGSizeMake(0, 0);
            [str addAttribute:NSShadowAttributeName
                        value:shadow1
                        range:NSMakeRange(range.location,msg.processRank.length -range.location)];
            
            [_prLabel setAttributedText:str];
            SY_RELEASE_SAFELY(str);
        }
        [_prNoteLabel setText:[NSString stringWithFormat:@"%@整体绩效排名",msg.subTitle]];
        [_sendView layoutCount:msg.sendNum content:@"发流程（个）"];
        [_handleView layoutCount:msg.handNum content:@"处理流程（个）"];
        [_shareView layoutCount:msg.shareNum content:@"分享文档（个）"];
        NSArray *avgList = [msg.avgHandleTime componentsSeparatedByString:@","];
        NSString *avgHandleTime  = @"0";
        if (avgList.count >0) {
            NSInteger d = [[avgList objectAtIndex:0] integerValue];
            NSInteger h = 0;
            NSInteger m = 0;
            if (avgList.count >1) {
                h = [[avgList objectAtIndex:1] integerValue];
            }
            if (avgList.count >2) {
                m = [[avgList objectAtIndex:2] integerValue];
            }
            CGFloat t = d*24+h+m/60;
            if (t !=0) {
                avgHandleTime = [NSString stringWithFormat:@"%.1f",t];
            }
        }
        [_avgHandleTimeView layoutCount:avgHandleTime content:@"流程处理时效（小时）"];
    }
    return self;
}

- (void)setup {
    [super setup];
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        [self addSubview:_scrollView];
    }
    
    if (!_prLabel) {
        _prLabel = [[UILabel alloc] init];
        [_prLabel setBackgroundColor:[UIColor clearColor]];
        [_prLabel setTextColor:UIColorFromRGB(0x1F85EC)];
        [_prLabel setTextAlignment:NSTextAlignmentCenter];
        [_scrollView addSubview:_prLabel];
    }
    if (!_prNoteLabel) {
        _prNoteLabel = [[UILabel alloc] init];
        [_prNoteLabel setBackgroundColor:[UIColor clearColor]];
        [_prNoteLabel setTextColor:UIColorFromRGB(0x1F85EC)];
        [_prNoteLabel setFont:FONTSYS(14)];
        [_prNoteLabel setTextAlignment:NSTextAlignmentCenter];
        [_scrollView addSubview:_prNoteLabel];
    }
    if (!_sendView) {
        _sendView = [[XZStatsMsgItemView alloc] init];
        [_scrollView addSubview:_sendView];
    }
    if (!_handleView) {
        _handleView = [[XZStatsMsgItemView alloc] init];
        [_scrollView addSubview:_handleView];
    }
    if (!_shareView) {
        _shareView = [[XZStatsMsgItemView alloc] init];
        [_scrollView addSubview:_shareView];
    }
    if (!_avgHandleTimeView) {
        _avgHandleTimeView = [[XZStatsMsgItemView alloc] init];
        [_scrollView addSubview:_avgHandleTimeView];
    }
    
    if (!_noteLabel) {
        _noteLabel = [[UILabel alloc] init];
        [_noteLabel setBackgroundColor:[UIColor clearColor]];
        [_noteLabel setTextColor:UIColorFromRGB(0x939BAD)];
        [_noteLabel setFont:FONTSYS(14)];
        [_noteLabel setTextAlignment:NSTextAlignmentCenter];
        [_scrollView addSubview:_noteLabel];
        [_noteLabel setText:@"成功没有秘诀，贵在坚持不懈，加油哦~~~"];
    }
}

- (void)customLayoutSubviews {
    if (self.height == 0) {
        return;
    }
    [super customLayoutSubviews];
  
    CGFloat orgy = 50;
 
    [_scrollView setFrame:CGRectMake(0, orgy, self.width, self.height-orgy)];//440

    _scrollView.contentSize = CGSizeMake(_scrollView.width, _scrollView.height < 390 ? 410 :_scrollView.height);
    //_scrollView.height < 390 iphone 横屏， 设置410 防止UIPageControl 遮盖
    [_noteLabel setFrame:CGRectMake(0, MAX(_scrollView.height, 390) -25, self.width, 20)];
    CGFloat y1 = self.height > 440?(self.height-440)/3:0;
    [_prLabel setFrame:CGRectMake(0, 60-orgy+y1, self.width, _prLabel.font.lineHeight)];
    [_prNoteLabel setFrame:CGRectMake(0, 135-orgy+y1, self.width, _prNoteLabel.font.lineHeight)];

    CGFloat ymarg = 10;
    CGFloat temHeight = (_noteLabel.originY - CGRectGetMaxY(_prNoteLabel.frame)-ymarg-20)/2;
    CGFloat height =  temHeight > 101 ? 101 : temHeight;
    CGFloat x = 28;
    CGFloat xmarg = 11;
    NSInteger y = (_noteLabel.originY - (height *2+ymarg) +CGRectGetMaxY(_prNoteLabel.frame))/2;
    
    CGFloat width = (self.width-x*2-xmarg)/2;
    [_sendView setFrame:CGRectMake(x, y, width, height)];
    [_handleView setFrame:CGRectMake(self.width/2+5.5, y, width, height)];
    y += height+ymarg;
    [_shareView setFrame:CGRectMake(x, y, width, height)];
    [_avgHandleTimeView setFrame:CGRectMake(self.width/2+5.5, y, width, height)];

}

- (void)layoutSubviewsPhoneLandscape {
    //iphone 横屏
}
@end
