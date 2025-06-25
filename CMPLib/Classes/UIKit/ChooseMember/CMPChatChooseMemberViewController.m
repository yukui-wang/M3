//
//  CMPChatChooseMemberViewController.m
//  CMPCore
//
//  Created by wujiansheng on 16/8/19.
//
//

#import "CMPChatChooseMemberViewController.h"
#import <CMPLib/CMPCachedUrlParser.h>

@interface CMPChatChooseMemberViewController (){
    
}

@end

@implementation CMPChatChooseMemberViewController

- (void)dealloc
{
    [_excludeData release];
    _excludeData = nil;
    [_fillBackData release];
    _fillBackData = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    self.hideBannerNavBar = YES;
    NSString *aStr = @"http://cmp/v/page/cmp-common-page.html?ctrl=selectOrg4Webview";
    aStr = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:aStr]];
    self.startPage = aStr;//[NSString stringWithFormat:@"file://%@", aStr];
    [super viewDidLoad];
   
}
- (void)viewWillAppear:(BOOL)animated
{
    // View defaults to full size.  If you want to customize the view's size, or its subviews (e.g. webView),
    // you can do so here.
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
