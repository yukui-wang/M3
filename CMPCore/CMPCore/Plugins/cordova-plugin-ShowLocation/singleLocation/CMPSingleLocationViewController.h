//
//  CMPSingleLocationViewController.h
//  CMPCore
//
//  Created by wujiansheng on 16/8/24.
//
//

#import <CMPLib/CMPBannerViewController.h>
#import "CMPSingleLocationView.h"

@protocol CMPSingleLocationViewControllerDelegate;

@interface CMPSingleLocationViewController : CMPBannerViewController
{
    CMPSingleLocationView *_singleView;
}

@property (nonatomic, assign) id<CMPSingleLocationViewControllerDelegate> delegate;

@property (nonatomic, retain) MMemberIcon *memberIcon;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *lbsUrl;
@property (nonatomic, copy) NSString *memberIconUrl;


@end

@protocol CMPSingleLocationViewControllerDelegate <NSObject>
- (void)singleLocationViewControllerDisimss:(CMPSingleLocationViewController *)aSingleViewController;
@end
