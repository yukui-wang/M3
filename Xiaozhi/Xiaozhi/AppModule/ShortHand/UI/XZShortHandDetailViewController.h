//
//  XZShortHandDetailViewController.h
//  M3
//
//  Created by wujiansheng on 2019/1/7.
//
//语音速记详情界面
#import "CMPBannerViewController.h"
#import "XZShortHandObj.h"

@interface XZShortHandDetailViewController : CMPBannerViewController

@property(nonatomic, retain)XZShortHandObj *data;
@property(nonatomic, copy)void (^updateSucessBlock)(void);
@property(nonatomic, copy)void (^deleteSucessBlock)(void);

@end

