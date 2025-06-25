//
//  CMPMigrateWebDataViewController.m
//  M3
//
//  Created by youlin on 2017/11/22.
//

#import "CMPMigrateWebDataViewController.h"
#import <CMPLib/CMPServerModel.h>
#import "CMPGestureHelper.h"
#import "AppDelegate.h"
#import <CMPLib/CMPLoginDBProvider.h>
#import "CMPLoginResponse.h"
#import <CMPLib/GTMUtil.h>
#import <CMPLib/CMPCore.h>
#import "CMPNativeToJsModelManager.h"
#import <WebKit/WebKit.h>
#import "CMPJSLocalStorageDataHandler.h"
#import <CMPLib/CMPAlertView.h>
#import <CMPLib/KSLogManager.h>
#import "M3LoginManager.h"
#import "CMPCommonManager.h"

#define kM3VersionKey @"m3version"

@interface CMPMigrateWebDataViewController ()
{
    __block void(^_syncH5CacheBlk)(void);
}
@property(nonatomic,strong) NSMutableArray *taskArr;
@property(nonatomic,assign) BOOL isWebDataReady;
@property (nonatomic, copy) void (^migarateWebDataDidReadyBlk)(id obj, NSError *error);
@end

@implementation CMPMigrateWebDataViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageDidLoad:) name:CDVPageDidLoadNotification object:_webViewEngine.engineWebView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setDevNoti:) name:@"kNotificationName_SetDevMode" object:nil];
    self.view.backgroundColor = [UIColor whiteColor];
    [CMPNativeToJsModelManager shareManager];
    NSLog(@"CMPMigrateWebDataViewController viewDidLoad");
    
//    __weak typeof(self) wSelf = self;
//    _syncH5CacheBlk = ^void{
//        NSLog(@"ks log --- migrate -- ext=33,resync local server to h5");
//        NSString *data = [[CMPCore sharedInstance].currentServer.h5CacheDic JSONRepresentation];
//        if (data && [data isKindOfClass:NSString.class]) {
//            NSString *aStr = [NSString stringWithFormat:@"m3API.setServerInfo(%@)", data];
//            [wSelf excuteJs:aStr result:^(id obj, NSError *error) {
//                [wSelf _lsBeginSyncData];
//            }];
//        }else{
//            [wSelf _lsBeginSyncData];
//        }
//    };
}

- (NSURL*)appUrl {
    NSString *oldPath = [[NSBundle mainBundle] pathForResource:@"m3datauprage" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:oldPath];
    return url;
}

static bool _needMoveWebDataToNative;

+ (BOOL)needMoveWebDataToNative
{
    // 判断当前版本标识
    NSString *aOldVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kM3VersionKey];
    NSString *aCurrentVersion = [CMPCore clinetVersion];
    [[NSUserDefaults standardUserDefaults] setObject:aCurrentVersion forKey:kM3VersionKey];
    
    if (!aOldVersion) {
        return YES;
    }
    return NO;
}

static CMPMigrateWebDataViewController *_instance;
static dispatch_once_t onceToken;

+ (CMPMigrateWebDataViewController *)shareInstance
{
    dispatch_once(&onceToken, ^{
        _instance = [[CMPMigrateWebDataViewController alloc] init];
        UIWindow *aWindow = [AppDelegate shareAppDelegate].window;
        [aWindow insertSubview:_instance.view atIndex:0];
    });
    return _instance;
}

#pragma mark-
#pragma mark 迁移老版本数据

- (void)startMigrateWebDataToNative:(void(^)(NSError *error))didFinished {
    if (self.migarateFinish) {
        if (didFinished) {
            didFinished(nil);
        }
        return;
    }
    _needMoveWebDataToNative = [CMPMigrateWebDataViewController needMoveWebDataToNative];
    _instance.migarateWebDataDidFinished = didFinished;
}

/**
 迁移服务器列表、当前设置服务器
 
 @param aServerListStr 服务器列表
 @param aCurrentServerStr 当前设置服务器
 */
- (void)migrateServerList:(NSString *)aServerListStr currentServer:(NSString *)aCurrentServerStr
{
    if ([NSString isNull:aServerListStr] || [NSString isNull:aCurrentServerStr]) {
        return;
    }
    NSArray *aList = [aServerListStr JSONValue];
    NSDictionary *aCurrentServerDic = [aCurrentServerStr JSONValue];
    if (!aList ||  !aCurrentServerDic) {
        return;
    }
    // 根据当前url地址生成md5作为唯一key
    NSString *aCurrentServerUrl = [aCurrentServerDic objectForKey:@"serverurl"];
    NSString *aCurrentKey = [NSString md5:aCurrentServerUrl];
    for (NSDictionary *aServerDict in aList) {
        NSString *aServerId = aServerDict[@"serverID"];
        if ([NSString isNull:aServerId]) {
            continue;
        }
        CMPServerModel *aServerInfo = [[CMPServerModel alloc] init];
        NSString *aUrl = aServerDict[@"serverurl"];
        NSString *aUniqueId = [NSString md5:aUrl];
        aServerInfo.uniqueID = aUniqueId;
        aServerInfo.serverID = aServerId;
        aServerInfo.host = aServerDict[@"ip"];
        aServerInfo.port = aServerDict[@"port"];
        NSString *aScheme = aServerDict[@"model"];
        aServerInfo.isSafe = [[aScheme lowercaseString] isEqualToString:@"https"];
        aServerInfo.scheme = aScheme;
        aServerInfo.note = aServerDict[@"remarks"];
        aServerInfo.fullUrl = [NSString stringWithFormat:@"%@://%@:%@", aScheme, aServerInfo.host, aServerInfo.port];
        
        // 解决1.6.5版本升级上来没有服务器版本号问题
        aServerInfo.serverVersion = [CMPCore oldServerVersion];
        
        if ([aCurrentKey isEqualToString:aUniqueId]) {
            aServerInfo.inUsed = YES;
        }
        [[CMPCore sharedInstance].loginDBProvider addServerWithModel:aServerInfo];
        [[CMPCore sharedInstance] setup];
    }
}

/**
 迁移保存的用户信息
 
 @param aUserInfo
 */
- (void)migrateUserInfo:(NSString *)aUserInfo
{
    if ([NSString isNull:aUserInfo]) {
        return;
    }
    NSDictionary *aDic = [aUserInfo JSONValue];
    NSString *aAccount = aDic[@"account"];
    if ([NSString isNull:aAccount]) {
        return;
    }
    CMPLoginAccountModel *aUser = [[CMPLoginAccountModel alloc] init];
    aUser.serverID = [CMPCore sharedInstance].serverID;
    aUser.userID = aDic[@"userId"];
    aUser.loginName = aDic[@"account"];
    aUser.loginPassword = aDic[@"psw"];
    aUser.name = aDic[@"name"];
    aUser.gesturePassword = [CMPGestureHelper shareInstance].gesturePwd;
    aUser.gestureMode = [aDic[@"gesture"] integerValue];
    [[CMPCore sharedInstance].loginDBProvider addAccount:aUser inUsed:YES];
    [[CMPCore sharedInstance] setup];
}

#pragma mark-
#pragma mark 写Local Storage方法

- (void)initSeverVersion:(NSString *)serverVersion companyID:(NSString *)companyID {
    
    [CMPJSLocalStorageDataHandler initSeverVersion:serverVersion companyID:companyID];
    
    NSString *aStr = [NSString stringWithFormat:@"m3API.initServerVersion('%@', '%@')", serverVersion, companyID];
    [self excuteJs:aStr];
    [self _saveJsModelsByString:aStr];
}

- (void)saveServerInfo:(NSString *)data {
    //theme default dark
    
    [CMPJSLocalStorageDataHandler saveServerInfo:data];
    
    NSString *aStr = [NSString stringWithFormat:@"m3API.setServerInfo(%@)", data];
    [self excuteJs:aStr];
    [self _saveJsModelsByString:aStr];
}

- (void)saveLoginCache:(NSString *)data loginName:(NSString *)loginName password:(NSString *)password serverVersion:(NSString *)version {
    
    [CMPJSLocalStorageDataHandler saveLoginCache:data loginName:loginName password:password serverVersion:version];
    
    NSString *aStr = [NSString stringWithFormat:@"m3API.setV5LoginCache(%@,'%@','%@','%@','%@')", data, loginName, password, [GTMUtil decrypt:loginName], version];
    [self excuteJs:aStr];
    [self _saveJsModelsByString:aStr];
}

- (void)updateAccountID:(NSString *)accountID
            accountName:(NSString *)accountName
              shortName:(NSString *)shortName
            accountCode:(NSString *)accountCode
             configInfo:(NSString *)configInfo
            currentInfo:(id)currentInfo
                preInfo:(id)preInfo {
    
    [CMPJSLocalStorageDataHandler updateAccountID:accountID accountName:accountName shortName:shortName accountCode:accountCode configInfo:configInfo currentInfo:currentInfo preInfo:preInfo];
    
    NSDictionary *data = @{@"accountId" : accountID,
                           @"accName" : accountName,
                           @"accShortName" : shortName,
                           @"code" : accountCode};
    
    NSString *aStr = [NSString stringWithFormat:@"m3API.switchAccount(%@,%@)", [data JSONRepresentation], configInfo];
    [self excuteJs:aStr result:nil];
    [self _saveJsModelsByString:aStr];
}

- (void)saveConfigInfo:(NSString *)data {
    
    [CMPJSLocalStorageDataHandler saveConfigInfo:data];
    
    NSString *aStr = [NSString stringWithFormat:@"m3API.setConfig(%@)", data];
    [self excuteJs:aStr];
    [self _saveJsModelsByString:aStr];
}

- (void)saveGestureState:(NSUInteger)state {
    
    [CMPJSLocalStorageDataHandler saveGestureState:state];
    
    NSString *aStr = [NSString stringWithFormat:@"m3API.setGesture(%d, '%@')", (int)state, [CMPCore sharedInstance].currentServer.serverVersion];
    [self excuteJs:aStr];
    [self _saveJsModelsByString:aStr];
}

- (void)saveV5Product:(NSString *)product {
    
    [CMPJSLocalStorageDataHandler saveV5Product:product];
    
    NSString *aStr = [NSString stringWithFormat:@"m3API.setV5Product('%@')", product];
    [self excuteJs:aStr];
    [self _saveJsModelsByString:aStr];
}


-(void)_saveJsModelsByString:(NSString *)jsStr
{
    [[CMPNativeToJsModelManager shareManager] saveJsModelStr:jsStr];
}

-(void)excuteJs:(NSString *)jsStr result:(void(^)(id obj,NSError* error))result
{
//    @synchronized (self) {
        [self dispatchSyncToMain:^{
            NSLog(@"ks log --- migrate excuteJs begin : %@",jsStr);
            [self.webViewEngine evaluateJavaScript:jsStr completionHandler:^(id obj, NSError *aError) {
                NSLog(@"ks log --- migrate excuteJs end :  ---%@ --- %@",obj?:@"obj nil",aError?[NSString stringWithFormat:@"error domain:%@ code:%ld",aError.domain,aError.code]:@"aError nil");
                if (result) {
                    result(obj,aError);
                }
            }];
          /*  if (self.wkWebview) {
                [self.wkWebview evaluateJavaScript:jsStr completionHandler:nil];
            }else {
                [self.webview stringByEvaluatingJavaScriptFromString:jsStr];
            }
            */
        }];
//    }
    
}

- (void)excuteJs:(NSString *)jsStr {
    
//    if (IOS11_Later) {
        BOOL pushSuccess = [self _pushTask:jsStr];
        NSLog(@"ks log --- migrate -- push task result: %@",@(pushSuccess));
        if (pushSuccess) {
            [self _lsBeginSyncData];
        }
//    }else{
//        [self excuteJs:jsStr result:^(id obj, NSError *error) {
//        }];
//    }
}

#pragma mark-
#pragma mark WebView事件监听

- (void)pageDidLoad:(NSNotification *)notification {
    
    NSLog(@"CMPMigrateWebDataViewController pageDidLoad");
    if (_needMoveWebDataToNative) {
        __block NSString *serverList = nil;
        __block NSString *userInfo = nil;
        __block NSString *currentServerInfo = nil;
        __weak typeof(self) weakSelf = self;
            [self.webViewEngine evaluateJavaScript:@"m3API.getServerList()" completionHandler:^(id string, NSError *err) {
                serverList = string;
            }];
            [self.webViewEngine evaluateJavaScript:@"m3API.getUserInfo()" completionHandler:^(id string, NSError *err) {
                userInfo = string;
            }];
            [self.webViewEngine evaluateJavaScript:@"m3API.getCurServerInfo()" completionHandler:^(id string, NSError *err) {
                currentServerInfo = string;
                [weakSelf migrateServerList:serverList currentServer:currentServerInfo];
                [weakSelf migrateUserInfo:userInfo];
            }];
    }
    
    self.migarateFinish = YES;
    
    if (self.migarateWebDataDidFinished) {
        self.migarateWebDataDidFinished(nil);
        self.migarateWebDataDidFinished = nil;
    }
    
    [self _lsBeginSyncData];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"ks log --- CMPMigrateWebDataViewController didReceiveMemoryWarning");
    
    if ([KSLogManager shareManager].isDev && [CMPCommonManager isM3InHouse]) {
//        if (!IOS10_Later) {
//            CMPAlertView *alert = [[CMPAlertView alloc] initWithTitle:NULL message:@"设备内存不足" cancelButtonTitle:@"刷新" otherButtonTitles:nil callback:^(NSInteger buttonIndex) {
//                [CMPMigrateWebDataViewController reset];
//            }];
//            [alert show];
//        }
    }
}

+(void)reset
{
    NSLog(@"ks log --- CMPMigrateWebDataViewController reset");
    if (_instance.view) {
        [_instance.view removeFromSuperview];
    }
    _instance = nil;
    onceToken = 0;
    
    [[CMPMigrateWebDataViewController shareInstance] evalAfterWebDataDidReady:^(id obj,NSError *error) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [[UIApplication sharedApplication].delegate performSelector:@selector(reloadApp)];
#pragma clang diagnostic pop
    }];
}

-(void)setDevNoti:(NSNotification *)noti
{
    if (self.migarateFinish) {
        id obj = noti.object;
        NSString *dev = [(NSNumber *)obj stringValue];
        NSString *aStr = [NSString stringWithFormat:@"m3API.setDev('%@')",dev];
        __weak typeof(self) wSelf = self;
        [self excuteJs:aStr result:^(id obj, NSError *error) {
            NSString *aStr2 = @"m3API.getIsDev()";
            [wSelf excuteJs:aStr2 result:^(id obj, NSError *error) {
                NSLog(@"ks log --- 设置js开发模式结果：%@",obj);
            }];
        }];
    }
}

-(NSMutableArray *)taskArr
{
    if (!_taskArr) {
        _taskArr = [[NSMutableArray alloc] init];
    }
    return _taskArr;
}

//level : 1 < 2 < 3 ...
-(BOOL)_pushTask:(NSString *)taskStr
{
    NSLog(@"ks log --- migrate -- _pushTask: %@",taskStr);
    @synchronized (self) {
        if (taskStr && taskStr.length) {
            NSString *s = @"(";
            if ([taskStr containsString:s]) {
                NSArray *arr = [taskStr componentsSeparatedByString:s];
                if (arr.count) {
                    NSString *identifier = arr[0];
                    NSUInteger level = 1;
                    if ([identifier isEqualToString:@"m3API.setServerInfo"]) {
                        level = 3;
                    }else if ([identifier isEqualToString:@"m3API.setV5LoginCache"]) {
                        level = 2;
                    }
                    NSDictionary *dic = @{@"task":taskStr,@"level":@(level),@"identifier":identifier};
                    [self.taskArr addObject:dic];
                    NSLog(@"ks log --- migrate -- current all task before sort :%@",self.taskArr);
                    [self.taskArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                        NSInteger level1 = [obj1[@"level"] integerValue];
                        NSInteger level2 = [obj2[@"level"] integerValue];
                        if (level1 < level2) {
                            return NSOrderedDescending;
                        } else if (level1 == level2) {
                            return NSOrderedSame;
                        } else {
                            return NSOrderedAscending;
                        }
                    }];
                    NSLog(@"ks log --- migrate -- current all task after sort :%@",self.taskArr);
                    return YES;
                }
            }
        }
        return NO;
    }
}

-(void)_lsBeginSyncData
{
    NSLog(@"ks log --- migrate -- _lsBeginSyncData begin");
    NSString *serverId = [CMPCore sharedInstance].currentServer.serverID;
    if (!serverId || [NSString isNull:serverId]) {
        NSLog(@"ks log --- migrate -- current serverid null");
        return;
    }
    __weak typeof(self) wSelf = self;
    [self _ifCanSyncDataToJsWithResult:^(BOOL canSync, NSError *error, _Nullable id ext) {
        NSLog(@"ks log --- migrate -- _ifCanSyncDataToJsWithResult result: %@,%@,%@",@(canSync),error,ext?:@"null");
        if (_syncH5CacheBlk && ext && [ext isKindOfClass:NSNumber.class] && ((NSNumber *)ext).integerValue == 33) {
            NSLog(@"eval _syncH5CacheBlk");
            [self _refreshJsAllLocalStorage];
            _syncH5CacheBlk();
            _syncH5CacheBlk = nil;
            return;
        }
        //V5-39980 公司协同反馈问题：m3修改密码后，登录仍然提示无效用户名（需杀进程重新登录才行）
        //ks fix -- 无奈之举，不明白为什么上述方法有的时候会报错（getItem('editAddress') result: (null),Error Domain=WKErrorDomain Code=5 "执行JavaScript返回结果的类型不受支持" UserInfo={NSLocalizedDescription=执行JavaScript返回结果的类型不受支持}）
        //兼容处理，不然会出现点击登陆按钮无法进入的情况
        if (error && error.code == 5) {
            canSync = YES;
        }
        if (error && error.code == 1005) {//getItem("editAddress")解析失败问题
            canSync = YES;
        }
        if (error && error.code == 1002) {//
            canSync = YES;
        }
        //end
        if (canSync) {
            [wSelf _finalEvalSyncData];
        }else{
            NSLog(@"ks log --- migrate -- _lsBeginSyncData:%@",error);
        }
    }];
}

-(void)_ifCanSyncDataToJsWithResult:(void(^)(BOOL can, NSError*err, __nullable id ext))result
{
    NSLog(@"ks log --- migrate -- _ifCanSyncDataToJsWithResult begin");
    if (!result) {
        return;
    }
    if (!self.migarateFinish) {
        result(NO,[NSError errorWithDomain:@"unloadfinish" code:1001 userInfo:nil],nil);
        return;
    }
    if (!self.taskArr.count) {
//        result(NO,[NSError errorWithDomain:@"task arr count = 0" code:1002 userInfo:nil],nil);
        return;
    }
    //先执行js查询本地有没有服务器地址信息，并和当前原生的比较
    //如果没有，或者比较不一样，就得先检查有没有服务器信息和人员信息，都有，才能同步，就得添加同步server信息方法，先执行serverconfig，再执行设置人员信息方法
    //如果有，且一样，就可以只检查有没有人员信息，有就可以同步
    __weak typeof(self) wSelf = self;
    [self.webViewEngine evaluateJavaScript:@"localStorage.getItem('editAddress')" completionHandler:^(NSString *string, NSError *err) {
        NSLog(@"ks log --- migrate -- _ifCanSyncDataToJsWithResult -- getItem('editAddress') result: %@,%@",string?:@"string null",err?[NSString stringWithFormat:@"error domain:%@ code:%ld",err.domain,err.code]:@"err nil");
        if (!err) {
            CMPServerModel *currentServer = [CMPCore sharedInstance].currentServer;
            NSString *curIp = currentServer.host;
            if ([NSString isNotNull:string] && [curIp isEqualToString:string]) {
                //只检查有没有人员信息，有就可以同步
                NSString *server = [NSString stringWithFormat:@"%@://%@:%@",currentServer.scheme,currentServer.host,currentServer.port];
                NSString *aKey = [@"userId_" stringByAppendingString:server];
                [wSelf.webViewEngine evaluateJavaScript:[NSString stringWithFormat:@"localStorage.getItem('%@')",aKey] completionHandler:^(id userid, NSError *err) {
                    NSLog(@"ks log --- _ifCanSyncDataToJsWithResult -- getItem('%@') result: %@,%@",aKey,string,err);
                    NSString *curMid = [CMPCore sharedInstance].currentUser.userID;
                    if (!err && [NSString isNotNull:userid] && [curMid isEqualToString:userid]) {
                        result(YES,nil,nil);
                    }else{
                        BOOL c = [wSelf _checkIfContainSelectorByIdentifier:@"m3API.setV5LoginCache"];
                        result(c,c? nil:[NSError errorWithDomain:@"has no member info" code:1003 userInfo:nil],nil);
                    }
                }];
            }else{
                //先检查有没有服务器信息和人员信息，都有，才能同步
                BOOL c = [wSelf _checkIfContainSelectorByIdentifier:@"m3API.setServerInfo"];
                if (c) {
                    NSString *server = [NSString stringWithFormat:@"%@://%@:%@",currentServer.scheme,currentServer.host,currentServer.port];
                    NSString *aKey = [@"userId_" stringByAppendingString:server];
                    [wSelf.webViewEngine evaluateJavaScript:[NSString stringWithFormat:@"localStorage.getItem('%@')",aKey] completionHandler:^(id userid, NSError *err) {
                        NSLog(@"ks log --- migrate -- _ifCanSyncDataToJsWithResult -- getItem('%@') result: %@,%@",aKey,string,err);
                        NSString *curMid = [CMPCore sharedInstance].currentUser.userID;
                        if (!err && [NSString isNotNull:userid] && [curMid isEqualToString:userid]) {
                            result(YES,nil,nil);
                        }else{
                            BOOL c1 = [wSelf _checkIfContainSelectorByIdentifier:@"m3API.setV5LoginCache"];
                            result(c1,c1? nil:[NSError errorWithDomain:@"has no member info" code:1005 userInfo:nil],nil);
                        }
                    }];
                    
                }else{
                    result(NO,[NSError errorWithDomain:@"has no server info" code:1004 userInfo:nil],@33);
                }
            }
        }else{
            NSLog(@"ks log --- migrate -- _ifCanSyncDataToJsWithResult fetch js editAddress error: %@",err);
            result(NO,err,@33);
        }
    }];
}

-(void)_finalEvalSyncData
{
    @synchronized (self) {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:self.taskArr];
        NSLog(@"ks log --- migrate _finalEvalSyncData begin --- self.taskArr: %@",self.taskArr);
        for (NSDictionary *obj in arr) {
            NSString *task = obj[@"task"];
            [self excuteJs:task result:^(id obj, NSError *error) {
                
            }];
            [self.taskArr removeObject:obj];
        }
        NSLog(@"ks log --- migrate _finalEvalSyncData end --- self.taskArr: %@",self.taskArr);
    }
    _isWebDataReady = YES;
    
    [self _refreshJsAllLocalStorage];
    if (_migarateWebDataDidReadyBlk) {
        _migarateWebDataDidReadyBlk(nil,nil);
        _migarateWebDataDidReadyBlk = nil;
        
        [self dispatchAsyncToMain:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationName_MigrateWebDataSyncFinish" object:nil];
        }];
    }
}

-(BOOL)_checkIfContainSelectorByIdentifier:(NSString *)identifier
{
    @synchronized (self) {
        NSLog(@"ks log --- migrate -- _checkIfContainSelectorByIdentifier -- identifier:%@",identifier);
        if (!self.taskArr.count) {
            return NO;
        }
        if (identifier && identifier.length) {
            for (NSDictionary *obj in self.taskArr) {
                NSString *objIde = obj[@"identifier"];
                if ([identifier isEqualToString:objIde]) {
                    NSLog(@"ks log --- migrate -- _checkIfContainSelectorByIdentifier -- result: 1");
                    return YES;
                }
            }
        }
        return NO;
    }
}


-(void)evalAfterWebDataDidReady:(void(^)(id,NSError*))completion
{
    NSLog(@"ks log --- migrate -- evalAfterWebDataDidReady -- begin");
    
    [[CMPMigrateWebDataViewController shareInstance] excuteJs:@"localStorage.getItem('editAddress')" result:^(id obj, NSError *error) {
        if (error && error.code == 5) {
            [CMPCore sharedInstance].localstorageTag = @"1";
            NSLog(@"localstorageTag = 1");
        }else{
            [CMPCore sharedInstance].localstorageTag = nil;
            NSLog(@"localstorageTag = nil");
        }
        
        [[CMPMigrateWebDataViewController shareInstance] startMigrateWebDataToNative:^(NSError *error) {
           
    //        if (IOS11_Later) {
            self->_migarateWebDataDidReadyBlk = ^(id obj, NSError *error) {};
                if (self->_migarateFinish && self->_isWebDataReady) {
                    NSLog(@"ks log --- migrate -- evalAfterWebDataDidReady -- all is ready,can eval block");
                    [self _refreshJsAllLocalStorage];
                    if (self->_migarateWebDataDidReadyBlk) {
                        self->_migarateWebDataDidReadyBlk(nil,nil);
                        self->_migarateWebDataDidReadyBlk = nil;
                        
                        [self dispatchAsyncToMain:^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationName_MigrateWebDataSyncFinish" object:nil];
                        }];
                    }
                }else{
                    NSLog(@"ks log --- migrate -- evalAfterWebDataDidReady -- is not ready,cannot eval block");
                }
    //        }else{
    //            [self _refreshJsAllLocalStorage];
    //            if (completion) {
    //                completion(nil,nil);
    //            }
    //        }
        }];
        
        if (completion) completion(nil,nil);
    }];
}


-(void)logoutWithResult:(void(^)(id obj, NSError *error))result
{
    NSLog(@"ks log --- migrate -- CMPMigrateWebDataViewController logout");
    [self excuteJs:@"localStorage.clear()" result:^(id obj, NSError *error) {
        
    }];
    [self.taskArr removeAllObjects];
    self.isWebDataReady = NO;
}

-(void)_refreshJsAllLocalStorage
{
    [self excuteJs:@"setAllData2LocalStorageOrigin()" result:^(id obj, NSError *error) {

    }];
}

@end
