//
//  CMPCommonWebViewController.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/1/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPCommonWebViewController : UIViewController

@property (nonatomic,strong) NSURL *url;
@property (nonatomic,assign) BOOL needNav;
@property (nonatomic,copy) void(^loadResultBlk)(id obj,NSError *error,id ext);
-(instancetype)initWithURL:(NSURL *)url;
-(void)reload;

@property (nonatomic,copy) void(^closeBlock)(void);

@end

NS_ASSUME_NONNULL_END
