//
//  XZStatisticsMsgItemView.h
//  M3
//
//  Created by wujiansheng on 2018/9/18.
//

#import "XZBaseView.h"

@interface XZStatsMsgItemView : XZBaseView {
    UILabel *_countLabel;
    UILabel *_contentLabel;
}
- (id)initWithCount:(NSString *)count content:(NSString *)content;
- (void)layoutCount:(NSString *)count content:(NSString *)content;

@end
