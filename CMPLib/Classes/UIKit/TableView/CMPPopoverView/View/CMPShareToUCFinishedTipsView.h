//
//  CMPShareToUCFinishedTipsView.h
//  CMPLib
//
//  Created by MacBook on 2020/2/13.
//  Copyright © 2020 crmo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPShareToUCFinishedTipsView : UIView

/* backClicked */
@property (copy, nonatomic) void(^backToFormerClicked)(void);

@end

NS_ASSUME_NONNULL_END
