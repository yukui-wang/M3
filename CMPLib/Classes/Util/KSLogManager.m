//
//  KSLogManager.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2021/11/4.
//

#import "KSLogManager.h"
#import "KSSysShareManager.h"
#import "CMPJSLocalStorageManager.h"
#import "ZipArchive.h"
#import "NSDate+CMP.h"
#import <CMPLib/KSActionSheetView.h>

@interface KSLogManager()

@property (nonatomic,weak) UIView *actionView;
@property (nonatomic,strong) NSMutableDictionary *objsInfoDic;
@property (nonatomic,strong) NSMutableArray *actBeforeShareBlkArr;

@end

@implementation KSLogManager

static KSLogManager *_instance;

+(KSLogManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[KSLogManager alloc] init];
    });
    return _instance;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)setDev:(BOOL)isDev
{
    [[NSUserDefaults standardUserDefaults] setBool:isDev forKey:@"devMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationName_SetDevMode" object:@(isDev)];
    });
}

-(BOOL)isDev
{
    BOOL dev = [[NSUserDefaults standardUserDefaults] boolForKey:@"devMode"];
    return dev;
}

-(void)shareLogInView:(UIView *)inView
{
    if (![self isDev]) return;
    if (!_logPath.length) return;
    if (![[NSFileManager defaultManager] fileExistsAtPath:_logPath]) return;
    
    NSString *dbPath = [CMPJSLocalStorageManager dbPath];
    if (dbPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
        if (paths.count) {
            
            [self.actBeforeShareBlkArr enumerateObjectsUsingBlock:^(void(^obj)(void), NSUInteger idx, BOOL * _Nonnull stop) {
                obj();
            }];
            
            NSLog(@"ks log --- device info :\n name:%@ \n systemName:%@ \n systemVersion:%@ \n memorySize:%llu",[UIDevice currentDevice].name,[UIDevice currentDevice].systemName,[UIDevice currentDevice].systemVersion,[NSProcessInfo processInfo].physicalMemory);
            
            NSString *docPath = paths[0];
            NSString *zipName = [NSString stringWithFormat:@"m3Log_%@(%@)_%@.zip",[CMPCore clinetVersion],[CMPCore clinetBuildVersion],[KSLogManager getCurrentTimes]];
            NSString *zipPath = [NSString stringWithFormat:@"%@/%@",docPath,zipName];//[docPath stringByAppendingString:@"/m3Log.zip"];
            
            NSArray*libPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            NSString *libPath = libPaths[0];
            NSString *bundleId =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
            NSString *plist = [NSString stringWithFormat:@"%@/Preferences/%@.plist",libPath,bundleId];
            
            
            ZipArchive* zip = [[ZipArchive alloc] init];
            BOOL ret = [zip CreateZipFile2:zipPath Password:@"7654321"];
            if (ret) {
                if (_logPath) {
                    [zip addFileToZip:_logPath newname:@"m3log.log"];
                }
                [zip addFileToZip:dbPath newname:@"m3jsls.db"];
                if ([[NSFileManager defaultManager] fileExistsAtPath:plist]) {
                    [zip addFileToZip:plist newname:@"m3Default.plist"];
                }
                [self.objsInfoDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    BOOL isDir;
                    BOOL ex = [[NSFileManager defaultManager] fileExistsAtPath:obj isDirectory:&isDir];
                    if (ex && !isDir) {
                        [zip addFileToZip:obj newname:key];
                    }else if (ex && isDir){
                        NSArray *subPaths = [[NSFileManager defaultManager] subpathsAtPath:obj];
                        for(NSString *subPath in subPaths){
                            NSString *fullPath = [obj stringByAppendingPathComponent:subPath];
                            BOOL isDir2;
                            if([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir2] && !isDir2){
                                [zip addFileToZip:fullPath newname:subPath];
                            }
                        }
                    }
                }];
            }
            BOOL ret2 = [zip CloseZipFile2];
            if (ret2) {
                [[KSSysShareManager shareInstance] presentDocumentInteractionInView:inView withLocalPath:zipPath displayName:zipName];
                return;
            }
        }
    }
    [[KSSysShareManager shareInstance] presentDocumentInteractionInView:inView withLocalPath:_logPath displayName:@"m3log.log"];
}

-(BOOL)addObjLocalPath:(NSString *)localPath newNameWithType:(NSString *)name
{
    if (!localPath || localPath.length==0) {
        return NO;
    }
//    if (![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
//        NSLog(@"ks log --- %s -- localpath no file",__func__);
//        return NO;
//    }
    NSString *akey = name;
    if (!name || name.length==0 || self.objsInfoDic[name]) {
        NSString *a = [localPath componentsSeparatedByString:@"/"].lastObject;
        akey = a;
    }
    [self.objsInfoDic setObject:localPath forKey:akey];
    return YES;
}

-(void)addActBeforeShareBlk:(void(^)(void))blk
{
    if (blk) {
        [self.actBeforeShareBlkArr addObject:blk];
    }
}

-(NSMutableDictionary *)objsInfoDic
{
    if (!_objsInfoDic) {
        _objsInfoDic = [NSMutableDictionary dictionary];
    }
    return _objsInfoDic;
}

-(NSMutableArray *)actBeforeShareBlkArr
{
    if (!_actBeforeShareBlkArr) {
        _actBeforeShareBlkArr = [NSMutableArray array];
    }
    return _actBeforeShareBlkArr;
}

- (void)redirectNSlogToDocumentFolderWithIde:(NSString *)ideStr {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSLog(@"document path:%@",documentDirectory);

    NSString *ide = ideStr?:@"default";
      NSString *preFix = [@"m3log_" stringByAppendingString:ide];
      NSFileManager *mgr = [NSFileManager defaultManager];

    NSString *fileName = [NSString stringWithFormat:@"%@.log",preFix];
    NSString *logFilePath =
        [documentDirectory stringByAppendingPathComponent:fileName];
//      [mgr removeItemAtPath:logFilePath error:nil];

    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+",
            stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+",
            stderr);
      
      _logPath = logFilePath;
}


//获取当前的时间
+(NSString*)getCurrentTimes{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddHHmmss"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    return currentTimeString;
}


+(BOOL)registerOnView:(UIView *)aView delegate:(id)delegate
{
    if (!aView ||![aView isKindOfClass:UIView.class]) {
        return NO;
    }
    [KSLogManager shareManager].actionView = aView;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:delegate?:[KSLogManager shareManager] action:@selector(_longPress:)];
    longPress.minimumPressDuration = 20;
    [aView addGestureRecognizer:longPress];
    return YES;
}

-(void)_longPress:(UILongPressGestureRecognizer *)ges
{
    if (ges.state == UIGestureRecognizerStateBegan) {
        
        BOOL logIsOpen = [KSLogManager shareManager].isDev;
//        BOOL vpnGlobalClose = [[UserDefaults valueForKey:@"cmpconfig_vpn_globelclose"] boolValue];
        KSActionSheetViewItem *item1 = [[[[KSActionSheetViewItem alloc] init] setKey:11] setTitle:[NSString stringWithFormat:@"切换开发模式(已%@)",logIsOpen ? @"打开":@"关闭"]];
        KSActionSheetViewItem *item2 = [[[[KSActionSheetViewItem alloc] init] setKey:12] setTitle:@"分享日志(需要开发模式已打开)"];
//        KSActionSheetViewItem *item3 = [[[[KSActionSheetViewItem alloc] init] setKey:13] setTitle:[NSString stringWithFormat:@"%@VPN (操作后需要重启APP)",vpnGlobalClose ? @"打开":@"关闭"]];
        KSActionSheetViewItem *item4 = [[[[KSActionSheetViewItem alloc] init] setKey:14] setTitle:@"清除本地日志"];
        
        BOOL preIsApple = self.locationTag == 2;
        KSActionSheetViewItem *item5 = [[[[KSActionSheetViewItem alloc] init] setKey:15] setTitle:[NSString stringWithFormat:@"%@Apple定位",preIsApple ? @"关闭":@"打开"]];
        
        KSActionSheetView *actionSheet = [KSActionSheetView showActionSheetWithTitle:@"测试" cancelButtonTitle:@"取消" destructiveButtonTitle:NULL otherButtonTitleItems:@[item1,item2,item4,item5] handler:^(KSActionSheetView *actionSheetView, KSActionSheetViewItem *actionItem, id ext) {
            
            switch (actionItem.key) {
                case 11:
                {
                    [[KSLogManager shareManager] setDev:!logIsOpen];
                }
                    break;
                case 12:
                {
                    [[KSLogManager shareManager] shareLogInView:[KSLogManager shareManager].actionView];
                }
                    break;
                case 13:
                {
//                    [UserDefaults setValue:@(!vpnGlobalClose) forKey:@"cmpconfig_vpn_globelclose"];
                }
                    break;
                case 14:
                {
                    if (!self->_logPath) {
                        return;
                    }
                    NSFileManager *mgr = [NSFileManager defaultManager];
                    [mgr removeItemAtPath:self->_logPath error:nil];
                    [self redirectNSlogToDocumentFolderWithIde:nil];
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
                    NSString *aPath = [paths[0] stringByAppendingPathComponent:@"LoadLog"];
                    [mgr removeItemAtPath:aPath error:nil];
                    
                    aPath = [paths[0] stringByAppendingPathComponent:@"ReqLog"];
                    [mgr removeItemAtPath:aPath error:nil];

                }
                    break;
                case 15:
                {
                    self.locationTag = preIsApple ? 0 : 2;
                }
                    break;
                    
                default:
                    break;
            }
        }];
        [actionSheet show];
    }
}

-(void)setLocationTag:(NSInteger)locationTag
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",(long)locationTag] forKey:@"ksdev_location"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSInteger)locationTag
{
    NSString *tag = [[NSUserDefaults standardUserDefaults] objectForKey:@"ksdev_location"];
    if (tag && [@"2" isEqualToString:tag]) {
        return 2;
    }
    return 0;
}

@end
