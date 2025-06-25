//
//  CMPKanbanWebViewController.h
//  M3
//
//  Created by 程昆 on 2020/5/16.
//

#import <CMPLib/CMPBannerWebViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPKanbanWebViewController : CMPBannerWebViewController

@property (nonatomic,strong) NSMutableDictionary *extDic;
 
+ (CMPKanbanWebViewController *)kanbanWebView1WithUrl:(NSString *)url params:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
