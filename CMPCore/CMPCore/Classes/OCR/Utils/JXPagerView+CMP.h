//
//  JXPagerView+CMP.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2021/12/29.
//

#import <CMPLib/JXPagerView.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXPagerView (CMP)
@property (nonatomic, weak) id<JXPagerViewDelegate> delegate;
- (void)refreshTableHeaderView;
@end

NS_ASSUME_NONNULL_END
