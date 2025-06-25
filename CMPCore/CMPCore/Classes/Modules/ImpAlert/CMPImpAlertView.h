//
//  CMPImpAlertView.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/8/23.
//

#import <CMPLib/CMPBaseView.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPImpAlertView : CMPBaseView
-(void)setDatas:(NSArray *)datas ext:(_Nullable id)ext completion:(void(^)(void))completion;
@end

NS_ASSUME_NONNULL_END
