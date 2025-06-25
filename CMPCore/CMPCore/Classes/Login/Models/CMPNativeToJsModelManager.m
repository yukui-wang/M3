//
//  CMPNativeToJsModelManager.m
//  M3
//
//  Created by Kaku Songu on 6/21/21.
//

#import "CMPNativeToJsModelManager.h"
#import "CMPMigrateWebDataViewController.h"
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import <CMPLib/CMPLoginDBProvider.h>
#import <CMPLib/CMPCore.h>

@implementation CMPNativeToJsModelManager

static CMPNativeToJsModelManager *_instance;

+(CMPNativeToJsModelManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[CMPNativeToJsModelManager alloc] init];
    });
    return _instance;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didRecieveMemoryWarning:) name:@"kNotificationName_RecieveMemoryWarning" object:nil];
//
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appWillEnterForground) name:kNotificationName_ApplicationWillEnterForeground object:nil];
//
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_syncModelToJsNoti:) name:@"kNotificationName_SyncModelToJs" object:nil];
//
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageDidLoad:) name:CDVPageDidLoadNotification object:nil];
//
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageDidErrorLoad:) name:CDVPageLoadErrorNotification object:nil];
        
    }
    return self;
}


-(NSMutableArray *)runJsModelsArr
{
    if (!_runJsModelsArr) {
        _runJsModelsArr = [[NSMutableArray alloc] init];
    }
    return _runJsModelsArr;
}

-(void)saveJsModelStr:(NSString *)jsStr
{
    return;
    NSLog(@"存入执行js：%@",jsStr);
    if (jsStr.length) {
        [self.runJsModelsArr addObject:jsStr];
    }
}

-(void)_syncModelToJsNoti:(NSNotification *)noti
{
    [self syncModelToJsWithWebview:nil result:^(CMPSyncDataToJsResult state, NSError * _Nonnull err) {
        
    }];
}

/**
 setV5Product
 setServerInfo
 initServerVersion
 setGesture
 setV5LoginCache
 setConfig
 */
-(void)syncModelToJsWithWebview:(WKWebView *)webview result:(void(^)(CMPSyncDataToJsResult state,NSError *err))result
{
    return;
    
    NSLog(@"ks log --- syncModelToJsWithResult begin");
    NSString *jsStr = @"";
//    __block BOOL needMove = NO;
//    __block NSString *serverInfoStr = @"";
//    __weak typeof(self) wSelf = self;
//    [self.runJsModelsArr enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([obj hasPrefix:@"m3API.setV5LoginCache"]) {
//            serverInfoStr = obj;
//            if (idx != 0) {
//                needMove = YES;
//                [wSelf.runJsModelsArr removeObjectAtIndex:idx];
//            }
//            *stop = YES;
//        }
//    }];
//    if (needMove && serverInfoStr.length) {
//        [self.runJsModelsArr insertObject:serverInfoStr atIndex:0];
//    }
    NSLog(@"ks log --- 执行js数组：%@",self.runJsModelsArr);
    for (NSString *js in [NSArray arrayWithArray:self.runJsModelsArr]) {
        if (js.length) {
            jsStr = [jsStr stringByAppendingFormat:@"%@;",js];
        }
    }
    
    NSLog(@"ks log --- 执行js：%@",jsStr);
    __block int evalState = 0;
    if (jsStr.length) {
        __weak typeof(self) wSelf = self;
        WKWebView *_webview = (WKWebView*)([CMPMigrateWebDataViewController shareInstance].webViewEngine.engineWebView);
        dispatch_async(dispatch_get_main_queue(), ^{
            [_webview evaluateJavaScript:jsStr completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
                NSLog(@"ks log --- syncModelToJs结果信息：%@--%@",obj,error);
                if (!error) {
                    evalState = 1;
                    [wSelf _fetchStorageStateWithWebview:_webview result:^(int state) {
                        evalState = state;
                        if (state == 2) {
                            [CMPMigrateWebDataViewController reset];
                        }else if (state == 5) {
                            // 设置服务器信息到H5缓存Local Storage
                            CMPServerModel *serverModel = [CMPCore sharedInstance].loginDBProvider.inUsedServer;
                            [[CMPMigrateWebDataViewController shareInstance] saveServerInfo:serverModel.h5CacheDic.JSONRepresentation];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationName_SyncModelToJsResult" object:@(evalState)];
                        });
                    }];
                }else{
                    //写入报错
                    NSLog(@"ks log --- jsStr write err %@",error);
                    evalState = -1;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationName_SyncModelToJsResult" object:@(evalState)];
                    });
                }
            }];
        });
        
    }else{
        //要写入的数据为空
        NSLog(@"ks log --- jsStr null");
    }
}

-(BOOL)_ifHanldeWithUrl:(NSString *)url
{
    if (!url || url.length == 0) {
        return NO;
    }
    if ([url containsString:@"m3datauprage.html"]||
        [url containsString:@"nonetwork.html"]
        ||[url containsString:@"m3-scan-page.html"]
        ||[url containsString:@"m3-message-middle-page.html"]) {
        return NO;
    }
    if ([NSURL URLWithString:url].isFileURL) {
        return YES;
    }
//    if ([CMPCachedUrlParser chacedUrl:[NSURL URLWithString:url]]) {
//        return YES;
//    }
    return NO;
}

-(void)safeHandleIfForce:(BOOL)force
{
    [self syncInfoToJsWithUrl:nil isForce:force webview:nil result:nil];
}


-(void)syncInfoToJsWithUrl:(NSString *)url
                   isForce:(BOOL)isForce
                   webview:(WKWebView *)webview
                    result:(void(^)(CMPSyncDataToJsResult state,NSError *err))result
{
    return;
    if (!isForce) {
        NSLog(@"ks log --- webview_safeHandle 非强制同步");
        NSString *urlStr = url;
        WKWebView *_webview = webview;
        if (_webview && _webview.URL) {
            urlStr = webview.URL.absoluteString;
        }
        if (!urlStr || urlStr.length == 0) {
            _webview = (WKWebView*)([CMPMigrateWebDataViewController shareInstance].webViewEngine.engineWebView);
            urlStr = _webview.URL.absoluteString;
        }
        if (!urlStr || urlStr.length == 0) {
            NSLog(@"ks log --- webview_safeHandle urlStr 为空");
            return;
        }
        NSLog(@"ks log --- webview_safeHandle begin : %@",urlStr);
        
        BOOL ifHandle = [self _ifHanldeWithUrl:urlStr];
        
        NSLog(@"ks log --- webview_safeHandle if handle : %@",@(ifHandle));
        
        if (ifHandle) {
            
            __weak typeof(self) wSelf = self;
            [self _fetchStorageStateWithWebview:_webview result:^(int state) {
               
                if (state == 2) {//webview可能被释放
                    [CMPMigrateWebDataViewController reset];
                    
                } else if (state != 3) {
                    [wSelf syncModelToJsWithWebview:_webview result:^(CMPSyncDataToJsResult state, NSError * _Nonnull err) {
                        if (result) {
                            result(state,err);
                        }
                    }];
                }else{
                    if (result) {
                        result(state,nil);
                    }
                }
            }];
        }
        
    }else{
        NSLog(@"ks log --- webview_safeHandle 强制同步");
        [self syncModelToJsWithWebview:webview result:^(CMPSyncDataToJsResult state, NSError * _Nonnull err) {
            if (result) {
                result(state,err);
            }
        }];
    }
}


-(void)_fetchStorageStateWithWebview:(WKWebView *)webview result:(void(^)(int state))result
{
    if (!result) {
        return;
    }
    __block int evalState = 0;
    WKWebView *_webview = (WKWebView*)([CMPMigrateWebDataViewController shareInstance].webViewEngine.engineWebView);
    dispatch_async(dispatch_get_main_queue(), ^{
        [_webview evaluateJavaScript:@"localStorage.getItem('ctxPath')" completionHandler:^(id string, NSError *err) {
            NSLog(@"ks log --- xxxxx%@,,,%@",string,err);
            if (!err) {
                if ([NSString isNull:string]) {
                    //读取为空
                    NSLog(@"ks log --- jsStr read null: %@",string);
                    evalState = 2;
                }else{
                    //读取有值
                    NSLog(@"ks log --- jsStr read success: %@",string);
                    evalState = 3;
                    
                    if ([string hasPrefix:@"undefined"]) {
                        evalState = 5;
                    }
                }
            }else{
                //读取报错
                NSLog(@"ks log --- jsStr read err: %@",err);
                evalState = 4;
            }
    //        if (evalState == 3) { // ks log --- ！！！ 以下为在iOS15beta里发现，上面的path渠道值了，但是对应的人员信息的key依然饱含undefined拼接，导致无法正常读取人员信息进而报错，但只是模拟器偶尔发现一次，影响较大，故暂时先注释
    //            [[CMPMigrateWebDataViewController shareInstance].webViewEngine evaluateJavaScript:@"getCurrentUserInfo()" completionHandler:^(id string2, NSError *err2) {
    //                if (!err2) {
    //                    if ([NSString isNull:string2]) {
    //                        //读取为空
    //                        NSLog(@"ks log --- jsStr2 read null: %@",string2);
    //                        evalState = 2;
    //                    }else{
    //                        //读取有值
    //                        NSLog(@"ks log --- jsStr2 read success: %@",string2);
    //                        evalState = 3;
    //                    }
    //                }else{
    //                    //读取报错
    //                    NSLog(@"ks log --- jsStr2 read err: %@",err2);
    //                    evalState = 4;
    //                }
    //                result(evalState);
    //            }];
    //
    //        }else{
                result(evalState);
    //        }
        }];
    });
}

- (void)pageDidLoad:(NSNotification *)notification {
    
    NSLog(@"ks log --- pageDidLoad notification start");
    WKWebView *webv = notification.object;
    [self syncInfoToJsWithUrl:webv.URL.absoluteString isForce:NO webview:nil result:^(CMPSyncDataToJsResult state, NSError *err) {
        
    }];
}


- (void)pageDidErrorLoad:(NSNotification *)notification {
    
    NSLog(@"ks log --- pageDidErrorLoad notification start");
    WKWebView *webv = notification.object;
    [self syncInfoToJsWithUrl:webv.URL.absoluteString isForce:NO webview:nil result:^(CMPSyncDataToJsResult state, NSError *err) {
        
    }];
}

-(void)_didRecieveMemoryWarning:(NSNotification *)noti
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self safeHandleIfForce:YES];
    });
}

-(void)_appWillEnterForground
{
    [self safeHandleIfForce:NO];
}

-(void)clearData
{
    [_runJsModelsArr removeAllObjects];
    _runJsModelsArr = nil;
}

@end
