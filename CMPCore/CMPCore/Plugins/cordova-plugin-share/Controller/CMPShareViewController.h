//
//  CMPShareViewController.h
//  M3
//
//  Created by MacBook on 2019/10/24.
//

#import <UIKit/UIKit.h>

@class CMPShareFileModel,CMPFileManagementRecord;

UIKIT_EXTERN CGFloat const CMPShareViewTimeInterval;

NS_ASSUME_NONNULL_BEGIN

@interface CMPShareViewController : UIViewController

/* viewClicked */
@property (copy, nonatomic) void(^viewClicked)(void);

/* topList */
@property (copy, nonatomic) NSArray *topList;
/* bottomList */
@property (copy, nonatomic) NSArray *bottomList;

/* model */
@property (strong, nonatomic) CMPShareFileModel *shareFileModel;
/* mfr */
@property (strong, nonatomic) CMPFileManagementRecord *mfr;

@end

NS_ASSUME_NONNULL_END
