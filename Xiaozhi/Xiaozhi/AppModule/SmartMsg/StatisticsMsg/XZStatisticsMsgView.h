//
//  XZStatisticsMsgView.h
//  M3
//
//  Created by wujiansheng on 2018/9/7.
//

#import "XZBaseMsgView.h"
#import "XZStatsMsgItemView.h"

@interface XZStatisticsMsgView : XZBaseMsgView {
    UIScrollView *_scrollView;
    UILabel *_prLabel;//单位排名
    UILabel *_prNoteLabel;//单位排名说明
    XZStatsMsgItemView *_sendView;//发协同数
    XZStatsMsgItemView *_handleView;//处理协同数
    XZStatsMsgItemView *_shareView;//知识贡献数
    XZStatsMsgItemView *_avgHandleTimeView;//处理时效
    UILabel *_noteLabel;//最后说明
}

@end
