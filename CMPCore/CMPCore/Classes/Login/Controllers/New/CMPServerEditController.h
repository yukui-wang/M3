//
//  CMPServerEditViewController.h
//  M3
//
//  Created by CRMO on 2017/10/30.
//

#import <UIKit/UIKit.h>
#import <CMPLib/CMPBaseViewController.h>
#import <CMPLib/CMPServerModel.h>

typedef NS_ENUM(NSUInteger, CMPServerEditControllerMode) {
    CMPServerEditControllerModeAdd,
    CMPServerEditControllerModeEdit,
};

@interface CMPServerEditController : CMPBaseViewController

@property (nonatomic, assign) CMPServerEditControllerMode mode;
@property (nonatomic, strong) CMPServerModel *oldServer;

/* host */
@property (copy, nonatomic) NSString *host;
/* port */
@property (copy, nonatomic) NSString *port;

- (void)saveServerWithHost:(NSString *)aHost
                      port:(NSString *)aPort
                      note:(NSString *)aNote;
- (void)saveServerWithHost:(NSString *)aHost port:(NSString *)aPort note:(NSString *)aNote fail:(void(^)(NSError *))fail;
- (void)autoSaveServerWithHost:(NSString *)aHost port:(NSString *)aPort note:(NSString *)aNote fail:(void(^)(NSError *))fail;

@end
