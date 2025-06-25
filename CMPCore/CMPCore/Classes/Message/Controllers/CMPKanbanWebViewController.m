//
//  CMPKanbanWebViewController.m
//  M3
//
//  Created by 程昆 on 2020/5/16.
//

#import "CMPKanbanWebViewController.h"
#import <CMPLib/CMPCachedUrlParser.h>

@interface CMPKanbanWebViewController ()

@end

@implementation CMPKanbanWebViewController

-(void)layoutSubviewsWithFrame:(CGRect)frame {
    
}

+ (CMPKanbanWebViewController *)kanbanWebView1WithUrl:(NSString *)url params:(NSDictionary *)params {
    CMPKanbanWebViewController *viewController = [[CMPKanbanWebViewController alloc] init];
    NSString *urlStr = [url urlCFEncoded];
    NSURL *aUrl = [NSURL URLWithString:urlStr];
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:aUrl];
    
    if ([NSString isNull:localHref]) {
        DDLogError(@"zl---[%s]localHref为空", __FUNCTION__);
        return nil;
    }
    
    viewController.startPage = localHref;
    viewController.closeButtonHidden = YES;
    viewController.hideBannerNavBar = YES;
    viewController.pageParam = @{@"url" : localHref,
                                 @"param" : params };
    return viewController;
}

-(NSMutableDictionary *)extDic
{
    if (!_extDic) {
        _extDic = [NSMutableDictionary dictionary];
    }
    return _extDic;
}
@end
