//
//  CMPMessageListViewController.h
//  CMPCore
//
//  Created by wujiansheng on 2017/6/22.
//
//

#import "CMPBannerHeadViewController.h"
#import "CMPMessageListView.h"
#import "CMPTopScreenView.h"

@interface CMPMessageListViewController : CMPBannerHeadViewController<UIGestureRecognizerDelegate,UIScrollViewDelegate>

- (NSArray*)getListData;

@property (nonatomic, assign) BOOL needRefreshMsg;
//负一屏使用-begin
@property (nonatomic, assign) CGFloat panOriginY;
@property (nonatomic, strong) NSMutableArray *panOriginYArr;
@property (nonatomic, assign) BOOL topScreenShow;
@property (nonatomic, assign) BOOL hasVibrated;
@property (nonatomic, weak) CMPMessageListView *weakListView;
@property (nonatomic, strong) CMPTopScreenView *topScreenView;
- (void)pushSearchView;//跳转到搜索页面
- (void)topScreenPushSearchView;
//负一屏使用-end

@end
