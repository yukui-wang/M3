//
//  CMPQuickRouterDataProvider.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/1/11.
//

#import <CMPLib/CMPBaseDataProvider.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPQuickRouterDataProvider : CMPBaseDataProvider

-(void)fetchQuickItemsWithResult:(CommonResultBlk)result;

@end

NS_ASSUME_NONNULL_END
