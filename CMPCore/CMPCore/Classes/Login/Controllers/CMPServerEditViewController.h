//
//  CMPServerEditViewController.h
//  M3
//
//  Created by CRMO on 2017/10/30.
//

#import <UIKit/UIKit.h>
#import <CMPLib/CMPBannerViewController.h>
#import <CMPLib/CMPServerModel.h>

typedef NS_ENUM(NSUInteger, CMPServerEditViewControllerMode) {
    CMPServerEditViewControllerModeAdd,
    CMPServerEditViewControllerModeEdit,
};

@interface CMPServerEditViewController : CMPBannerViewController

@property (nonatomic, assign) CMPServerEditViewControllerMode mode;
@property (nonatomic, strong) CMPServerModel *oldServer;

- (void)saveServerWithHost:(NSString *)aHost
                      port:(NSString *)aPort
                      note:(NSString *)aNote;
- (void)saveServerWithHost:(NSString *)aHost port:(NSString *)aPort note:(NSString *)aNote fail:(void(^)(NSError *))fail;

@end
