//
//  CMPOcrCardMainListView.h
//  M3
//
//  Created by Shoujian Rao on 2021/11/26.
//

#import <CMPLib/CMPBaseView.h>
#import <CMPLib/JXPagerView.h>
#import "CMPCustomLeftSwipeTableView.h"
NS_ASSUME_NONNULL_BEGIN

@interface CMPOcrCardMainListView : CMPBaseView <JXPagerViewListViewDelegate>
@property (nonatomic, copy) void(^listScrollCallback)(UIScrollView *scrollView);
@property (nonatomic, copy) void(^DidSelectRow)(NSInteger);
@property (nonatomic, strong) CMPCustomLeftSwipeTableView *tableView;
@property (nonatomic, copy) NSString *conditionId;
@property (nonatomic, assign) NSInteger fromPage;//0为首页，1为我的
-(void)refreshData:(NSArray *)data;

@end

NS_ASSUME_NONNULL_END
