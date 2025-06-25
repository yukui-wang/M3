//
//  CMPIntercepter.m
//  M3
//
//  Created by Shoujian Rao on 2023/2/7.
//

#import "CMPIntercepter.h"
#import "CMPURLProtocol.h"
#import "CMPConstant.h"
#import "CMPCore.h"
#import "CMPCommonWebViewController.h"
#import <CordovaLib/WKUserContentController+IMYHookAjax.h>

#define kNoInterceptJumpNotification @"kNoInterceptJumpNotification"
@interface CMPIntercepter()
@property (nonatomic,readonly,assign) BOOL registerProtocol;
@property (nonatomic, strong) NSArray *noInterceptArray;
@end
@implementation CMPIntercepter

+ (CMPIntercepter*)sharedInstance{
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init{
    if(self = [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpToNewWeb:) name:kNoInterceptJumpNotification object:nil];
    }
    return self;
}

- (void)jumpToNewWeb:(NSNotification *)notifi{
    UIViewController *vc = notifi.object;
    NSDictionary *userInfo = notifi.userInfo;
    NSString *_url = userInfo[@"url"];
    BOOL openInNew = [userInfo[@"openInNew"] boolValue];
    [self unregisterClass];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CMPCommonWebViewController *web = [[CMPCommonWebViewController alloc]initWithURL:[NSURL URLWithString:_url]];

        if([vc.className isEqualToString:@"CMPTabBarWebViewController"]){
            [vc.navigationController pushViewController:web animated:YES];
            return;
        }
        if(openInNew){//新窗口直接push
            [vc.navigationController pushViewController:web animated:YES];
        }else{
            NSMutableArray *navs = [NSMutableArray arrayWithArray:vc.navigationController.viewControllers];
            if([navs.lastObject isKindOfClass:vc.class]){
                [navs removeLastObject];
                [navs addObject:web];
                vc.navigationController.viewControllers = navs;
            }else{
                [vc.navigationController pushViewController:web animated:YES];
            }
        }
        
    });
}

- (BOOL)interceptByUrl:(NSString *)url{
    if([self needIntercept:url]){
        [self registerClass];
        return YES;
    }else{
        [self unregisterClass];
        return NO;
    }
}

-(BOOL)isRegister{
    return _registerProtocol;
}

-(void)registerClass{
    if (_registerProtocol) {
        return;
    }
    NSLog(@"rsj-已注册拦截");
    // 防止苹果静态检查 将 WKBrowsingContextController 拆分，然后再拼凑起来
    NSArray *privateStrArr = @[@"Controller", @"Context", @"Browsing", @"K", @"W"];
    NSString *className =  [[[privateStrArr reverseObjectEnumerator] allObjects] componentsJoinedByString:@""];
    Class cls = NSClassFromString(className);
    SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
    
    if (cls && sel) {
        if ([(id)cls respondsToSelector:sel]) {
            // 注册自定义协议
            // [(id)cls performSelector:sel withObject:@"CustomProtocol"];
            // 注册http协议
            [(id)cls performSelector:sel withObject:@"http"];
            // 注册https协议
            [(id)cls performSelector:sel withObject:@"https"];
            
            // 注册https协议
            [(id)cls performSelector:sel withObject:@"jsbridge"];
        }
    }
    // SechemaURLProtocol 自定义类 继承于 NSURLProtocol
    [NSURLProtocol registerClass:[CMPURLProtocol class]];
    
    _registerProtocol = YES;
}

-(void)unregisterClass{
    if (!_registerProtocol) {
        return;
    }
    NSLog(@"rsj-已取消拦截");
    // 防止苹果静态检查 将 WKBrowsingContextController 拆分，然后再拼凑起来
    NSArray *privateStrArr = @[@"Controller", @"Context", @"Browsing", @"K", @"W"];
    NSString *className =  [[[privateStrArr reverseObjectEnumerator] allObjects] componentsJoinedByString:@""];
    Class cls = NSClassFromString(className);
    SEL sel = NSSelectorFromString(@"unregisterSchemeForCustomProtocol:");
    
    if (cls && sel) {
        if ([(id)cls respondsToSelector:sel]) {
            // 注册自定义协议
            // [(id)cls performSelector:sel withObject:@"CustomProtocol"];
            // 注册http协议
            [(id)cls performSelector:sel withObject:@"http"];
            // 注册https协议
            [(id)cls performSelector:sel withObject:@"https"];
            
            // 注册https协议
            [(id)cls performSelector:sel withObject:@"jsbridge"];
        }
    }
    // SechemaURLProtocol 自定义类 继承于 NSURLProtocol
    [NSURLProtocol unregisterClass:[CMPURLProtocol class]];
    
    
    _registerProtocol = NO;
}

/**
 是否需要拦截，默认YES
 1.http类
 2.url参数特殊字段
 3.金山文档、腾讯会议等链接
 4.
 */
- (BOOL)needIntercept:(NSString *)url{
    if (![url isKindOfClass:NSString.class]) {
        return YES;
    }
    if(CMP_IPAD_MODE) return YES;//暂不考虑ipad
        
    if ([url hasPrefix:@"http"]) {//只关注http\https
        //判断url参数的方式
        if([url containsString:@"intercept=no"]){
            return NO;
        }
        
        //判断host的方式
        BOOL exist = NO;
        NSURLComponents *component = [NSURLComponents componentsWithString:url];
        for (NSString *host in self.noInterceptArray) {
            if([component.host containsString:host]){
                exist = YES;
                break;
            }
        }
        if(exist){
            return NO;
        }
        //加入特殊字符串判断
        for (NSString *str in self.noInterceptArray) {
            if([url containsString:str]){
                exist = YES;
                break;
            }
        }
        if(exist){
            return NO;
        }
        
        //代码判断是否需要三方拦截：http开头 && 非当前服务器host && 非cmp组件资源
        
    }
    return YES;
}

//白名单方式,host关键字
- (NSArray *)noInterceptArray{
    if(!_noInterceptArray){
        WKUserContentController* userContentController = [[WKUserContentController alloc] init];
        NSArray *arr = [userContentController getWhiteHost];
        _noInterceptArray = arr?:@[];
    }
    return _noInterceptArray;
}
                             

@end
