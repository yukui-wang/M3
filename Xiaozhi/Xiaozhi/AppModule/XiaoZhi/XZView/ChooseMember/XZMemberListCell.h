//
//  XZMemberListCell.h
//  M3
//
//  Created by wujiansheng on 2017/11/22.
//

#import <CMPLib/CMPBaseTableViewCell.h>
#import <CMPLib/CMPOfflineContactMember.h>

@interface XZMemberListCell : CMPBaseTableViewCell

- (void)setupDataWithMember:(CMPOfflineContactMember *)member;
- (void)addLineWithRow:(NSInteger)row RowCount:(NSInteger)rowCount;
+ (CGFloat)cellHeight;
- (void)loadFaceImage;

@end
