//
//  CMPBannerViewTitleLabel.h
//  CMPLib
//
//  Created by MacBook on 2020/1/13.
//  Copyright © 2020 crmo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPBannerViewTitleLabel : UILabel

/* viewClicked */
@property (copy, nonatomic) void(^viewClicked)(void);

@end

NS_ASSUME_NONNULL_END
