//
//  XZQABottomCoverView.h
//  Xiaozhi
//
//  Created by Kaku Songu on 3/23/21.
//  Copyright © 2021 wujiansheng. All rights reserved.
//

#import <CMPLib/CMPBaseView.h>

typedef void(^StartAskBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface XZQABottomCoverView : CMPBaseView
@property(nonatomic, copy)StartAskBlock startAskBlock;
@end

NS_ASSUME_NONNULL_END
