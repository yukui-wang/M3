//
//  CMPOfflineContactCell.h
//  CMPCore
//
//  Created by wujiansheng on 2017/1/5.
//
//

#import <CMPLib/CMPBaseTableViewCell.h>
#import <CMPLib/CMPOfflineContactMember.h>
#import "CMPSearchResultLabel.h"
@interface CMPOfflineContactCell : CMPBaseTableViewCell

@property (nonatomic, strong) UIImageView *selectImageView;
@property (nonatomic, assign) BOOL selectCell;
@property (nonatomic,copy) NSString *searchText;
- (void)setSelectImageConfig;//设置多选图标

- (void)setupDataWithMember:(CMPOfflineContactMember *)member;
- (void)setupDataWithMember:(CMPOfflineContactMember *)member key:(NSString *)key;
- (void)addLineWithRow:(NSInteger)row RowCount:(NSInteger)rowCount;
- (void)addLineWithSearchRow:(NSInteger)row RowCount:(NSInteger)rowCount;
- (void)setStyleType:(NSInteger)styleType;

+ (CGFloat)cellHeight;
- (void)loadFaceImage;
+ (CGFloat)cellHeightWithModel:(CMPOfflineContactMember *)member styleType:(NSInteger)styleType;
@end
