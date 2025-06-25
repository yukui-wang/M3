//
//  CMPPicListHeaderView.h
//  CMPLib
//
//  Created by MacBook on 2019/12/17.
//  Copyright © 2019 crmo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString * const CMPPicListHeaderViewId;

@interface CMPPicListHeaderView : UICollectionReusableView

/* title */
@property (copy, nonatomic) NSString *title;

@end

NS_ASSUME_NONNULL_END
