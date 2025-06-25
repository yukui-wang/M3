//
//  CMPQuickRouterView.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/3/10.
//

#import <CMPLib/CMPBaseView.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPQuickRouterView : CMPBaseView
- (instancetype)initWithBundleTableView:(UITableView *)tableView frame:(CGRect)frame;
-(void)refreshData;
@end

NS_ASSUME_NONNULL_END
