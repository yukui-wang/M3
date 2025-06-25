//
//  XZCore.m
//  M3
//
//  Created by wujiansheng on 2019/2/20.
//


#import "XZCore.h"
#import "SPTools.h"
#import "XZMainController.h"
#import "XZMainProjectBridge.h"
@implementation XZCore
static XZCore *_instance;

+ (XZCore *)sharedInstance {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (id)init {
    if (self = [super init]) {
        self.xzMsgRequestStatus = XiaozhiMessageRequestStatus_normal;
    }
    return self;
}

- (void)dealloc {
    [self clearData];
}

- (void)clearData {
    self.baiduSpeechInfo = nil;
    self.baiduUnitInfo = nil;
    self.baiduFaceInfo = nil;
    self.baiduNlpInfo = nil;
    self.baiduImageCInfo = nil;
    self.msgSwitchInfo = nil;
    self.msgRemindRule = nil;
    self.intentPrivilege = nil;
    self.privilege = nil;
    self.showInSetting = NO;
    self.outTime = 0;
    self.xiaozhiCode = 2002;
    self.tabbarIdArray = nil;
    self.speechInput = nil;
    self.qaPermissions = nil;
    self.robotConfig = nil;
    self.intentMd5 = nil;
    self.userProfileImage = nil;
    self.textLenghtLimit = -1;
    self.guidePage = nil;
    self.xzMsgRequestStatus = XiaozhiMessageRequestStatus_normal;
}

- (void)setupBaiduInfo:(NSDictionary *)result {
    self.baiduSpeechInfo = nil;
    self.baiduUnitInfo = nil;
    self.baiduFaceInfo = nil;
    self.baiduNlpInfo = nil;
    self.baiduImageCInfo = nil;
    self.intentPrivilege = nil;
    self.guidePage = nil;
    NSArray *allKeys = result.allKeys;
    NSString *key = @"baiduAppKey";
    if ([allKeys containsObject:key]) {
        NSDictionary *baiduAppKey = [SPTools dicValue:result forKey:key];
        _baiduSpeechInfo = [[SPBaiduSpeechInfo alloc] initWithBaiduIphoneVoiceApp:[SPTools dicValue:baiduAppKey forKey:@"baiduIphoneVoiceApp"]];
        _baiduUnitInfo = [[SPBaiduUnitInfo alloc] initWithBaiduUnitApp:[SPTools dicValue:baiduAppKey forKey:@"baiduUnitApp"]];
        _baiduFaceInfo = [[BaiduFaceIdApp alloc] initWithBaiduFaceIdApp:[SPTools dicValue:baiduAppKey forKey:@"baiduFaceDetectApp"]];
        _baiduNlpInfo = [[BaiduNlpApp alloc] initWithBaiduNlpApp:[SPTools dicValue:baiduAppKey forKey:@"baiduNlpApp"]];
        _baiduImageCInfo = [[BaiduImageClassifyApp alloc] initWithBaiduImageClassifyApp:[SPTools dicValue:baiduAppKey forKey:@"baiduImageClassifyApp"]];
    }
    key = @"commands";
    if ([allKeys containsObject:key]) {
        //老版本
        NSArray  *intents = [SPTools arrayValue:result forKey:key];
        _intentPrivilege = [[XZIntentPrivilege alloc] initWithResult:intents];
    }
    key = @"clientIntent";
    if ([allKeys containsObject:key]) {
        NSDictionary *clientIntent = [SPTools dicValue:result forKey:key];
        NSArray      *intentNames = [SPTools arrayValue:clientIntent forKey:@"intentNames"];
        _intentPrivilege = [[XZIntentPrivilege alloc] initWithIntentNameArray:intentNames];
        NSArray      *bootPages = [SPTools arrayValue:clientIntent forKey:@"bootPages"];
        [XZCore sharedInstance].guidePage = [XZGuidePage guidePageWithArray:bootPages];
        self.shortCutIds = [SPTools arrayValue:clientIntent forKey:@"shortCutIds"];
    }
    
    self.downloadIntent = NO;
    self.downloadSpeechError = NO;
    self.downloadRosterPinyin = NO;

    key = @"checkAppMd5";//配置单的校验结果
    if ([allKeys containsObject:key]) {
        NSDictionary *md5Info = [SPTools dicValue:result forKey:key];
        self.downloadIntent = [SPTools boolValue:md5Info forKey:@"download"];
        self.intentMd5Temp = [SPTools stringValue:md5Info forKey:@"md5"];
    }
    key = @"checkSpeechErrorMd5";//语音纠错的校验结果
    if ([allKeys containsObject:key]) {
        NSDictionary *md5Info = [SPTools dicValue:result forKey:key];
        self.downloadSpeechError = [SPTools boolValue:md5Info forKey:@"download"];
        self.spErrorCorrectionMd5Temp = [SPTools stringValue:md5Info forKey:@"md5"];
    }
    key = @"checkRosterPinyinMd5";//人员拼音的校验结果
    if ([allKeys containsObject:key]) {
        NSDictionary *md5Info = [SPTools dicValue:result forKey:key];
        self.downloadRosterPinyin = [SPTools boolValue:md5Info forKey:@"download"];
        self.pinyinRegularMd5Temp = [SPTools stringValue:md5Info forKey:@"md5"];
    }
}

+(NSString *)keyForConfig {
    return [[XZCore userID] stringByAppendingString:@"_CMPSpeechRobotConfig"];
}

- (CMPSpeechRobotConfig *)robotConfig {
    if (!_robotConfig) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:[XZCore keyForConfig]];
        if (data) {
            self.robotConfig = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        else {
            _robotConfig =  [[CMPSpeechRobotConfig alloc]init];
            _robotConfig.isOnOff = YES;
            _robotConfig.isOnShow = YES;
            _robotConfig.isAutoAwake = YES;
            _robotConfig.startTime = @"00:00";
            _robotConfig.endTime = @"23:59";
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.robotConfig];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:[XZCore keyForConfig]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    return _robotConfig;
}

+ (void)setCurrentUserRobotConfig:(CMPSpeechRobotConfig *)config {
    if (config) {
        [XZCore sharedInstance].robotConfig = config;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:config];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:[self keyForConfig]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_RobotConfigValueChanged object:config];
    }else{
        NSLog(@"CMPSpeechRobotConfigPlugin...config参数不存在");
    }
}

- (XZPrivilege *)privilege {
    if (!_privilege) {
        _privilege = [[XZPrivilege alloc] init];
        NSDictionary *privilegeDic =  [XZMainProjectBridge userPrivilegeDictionary];
        _privilege.hasColNewAuth = [privilegeDic[@"hasColNew"] boolValue];
        _privilege.hasAddressBookAuth =  [privilegeDic[@"hasAddressBook"] boolValue];
        _privilege.hasZhixinAuth = [CMPCore sharedInstance].hasPermissionForZhixin;
        _privilege.hasIndexPlugin = [privilegeDic[@"hasIndexPlugin"] boolValue];
    }
    return _privilege;
}

- (NSArray *)tabbarIdArray {
    if (!_tabbarIdArray) {
        NSArray *array = [XZMainProjectBridge tabbarIdList];
        _tabbarIdArray = [[NSArray alloc] initWithArray:array];
    }
    return _tabbarIdArray;
}

- (XZMsgSwitchInfo *)msgSwitchInfo {
    if (!_msgSwitchInfo) {
        NSString *key = [self msgSwitchKey];
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if (data) {
            self.msgSwitchInfo = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        else {
            _msgSwitchInfo =  [[XZMsgSwitchInfo alloc]init];
            _msgSwitchInfo.mainSwitch = YES;
            _msgSwitchInfo.cultureSwitch = YES;
            _msgSwitchInfo.statisticsSwitch = YES;
            _msgSwitchInfo.arrangeSwitch = YES;
            _msgSwitchInfo.chartSwitch = YES;
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.msgSwitchInfo];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    return _msgSwitchInfo;
}

- (XZIntentPrivilege *)intentPrivilege {
    if (!_intentPrivilege) {
        _intentPrivilege = [[XZIntentPrivilege alloc] initWithResult:nil];
    }
    return _intentPrivilege;
}

- (NSString *)msgSwitchKey {
    return [NSString stringWithFormat:@"%@_%@_msgSwitchKey", [XZCore userID], [CMPCore sharedInstance].serverID];
}


- (void)setupMsgSwitchInfo:(NSDictionary *)dic {
    NSString *key = [self msgSwitchKey];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL mainSwitch = [[dic objectForKey:@"mainSwitch"] boolValue];
    if (!_msgSwitchInfo.mainSwitch && mainSwitch) {
        //总开关 由关到开 重置状态  下次打开直接用
        // 下次不在提醒 按钮设置
        [userDefaults setObject:kXZ_MsgIsFirst forKey:[self msgFirstKey]];
        //轮询规则 时间重置
        [userDefaults setObject:@"" forKey:[self msgRemindPreTimeKey]];
        [userDefaults synchronize];
        [[XZMainController sharedInstance] addListenToTabbarControllerShow];
    }
    _msgSwitchInfo.mainSwitch = mainSwitch;
    _msgSwitchInfo.cultureSwitch = [[dic objectForKey:@"cultureSwitch"] boolValue];
    _msgSwitchInfo.statisticsSwitch = [[dic objectForKey:@"statisticsSwitch"] boolValue];
    _msgSwitchInfo.arrangeSwitch = [[dic objectForKey:@"arrangeSwitch"] boolValue];
    _msgSwitchInfo.chartSwitch = [[dic objectForKey:@"chartSwitch"] boolValue];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.msgSwitchInfo];
    
    [userDefaults setObject:data forKey:key];
    
    //消息重新轮询 todo  总开关由关到开
    [userDefaults synchronize];
}

- (void)setupMsgSwitchInfoWithMainSwitch:(BOOL)mainSwitch {
    NSString *key = [self msgSwitchKey];
    _msgSwitchInfo.mainSwitch = mainSwitch;
    _msgSwitchInfo.cultureSwitch = mainSwitch;
    _msgSwitchInfo.statisticsSwitch = mainSwitch;
    _msgSwitchInfo.arrangeSwitch = mainSwitch;
    _msgSwitchInfo.chartSwitch = mainSwitch;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.msgSwitchInfo];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:data forKey:key];
    [userDefaults synchronize];
}

- (NSString *)msgFirstKey {
    return [NSString stringWithFormat:@"%@_%@_msgFirstKey", [XZCore userID], [CMPCore sharedInstance].serverID];
}

- (BOOL)msgIsFirst {
    BOOL first = NO;
    NSString *key = [self msgFirstKey];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *isFirst = [userDefaults objectForKey:key];
    if ([NSString isNull:isFirst] || [isFirst isEqualToString:kXZ_MsgIsFirst]) {
        first = YES;
        [userDefaults setObject:kXZ_MsgIsNotFirst forKey:key];
        [userDefaults synchronize];
    }
    return first;
}

- (NSString *)msgViewSpeakKey {
    return [NSString stringWithFormat:@"%@_%@_canSpeak", [XZCore userID], [CMPCore sharedInstance].serverID];
}

- (BOOL)msgViewCanSpeak {
    NSString *key = [self msgViewSpeakKey];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *speak = [userDefaults objectForKey:key];
    if (speak == nil) {
        return YES;
    }
    return [speak boolValue];
}

- (void)setupMsgViewCanSpeak:(BOOL)speak {
    NSString *key = [self msgViewSpeakKey];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:speak] forKey:key];
    [userDefaults synchronize];
}

//消息轮询时间保存
- (NSString *)msgRemindPreTimeKey {
    return [NSString stringWithFormat:@"%@_%@_msgRemindPreTime", [XZCore userID], [CMPCore sharedInstance].serverID];
}

- (NSString *)msgRemindPreTime {
    NSString *key = [self msgRemindPreTimeKey];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *time = [userDefaults objectForKey:key];
    if ([NSString isNull:time] ) {
        time = @"2018-09-09 11:00:00";
    }
    return time;
}

- (void)updateMsgRemindPreTime:(NSString *)time {
    NSString *key = [self msgRemindPreTimeKey];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:time forKey:key];
    [userDefaults synchronize];
}

- (void)saveAppListId {
    [self saveAppListIdForXZ];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveAppListIdForXZ) name:kNotificationName_AppListDidUpdate object:nil];
}

- (void)saveAppListIdForXZ{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationName_AppListDidUpdate object:nil];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *xzAppList = [NSMutableArray array];
    [userDefaults setObject:xzAppList forKey:kXZ_M3APPLIST];
    [userDefaults synchronize];
    NSArray *array = [self m3AppList];
    [userDefaults setObject:array forKey:kXZ_M3APPLIST];
    [userDefaults synchronize];
}
- (NSArray *)m3AppList {
    NSMutableArray *result = [NSMutableArray array];
    NSString *jsonstr = [CMPCore sharedInstance].currentUser.appList;
    NSDictionary *dict = [SPTools dictionaryWithJsonString:jsonstr];
    NSArray *data = dict[@"data"];
    if ([[CMPCore sharedInstance] serverIsLaterV1_8_0]) {
        NSArray *tabbarIds = [NSArray arrayWithObjects:kM3AppID_My,kM3AppID_Todo,kM3AppID_Contacts, nil];//这三个的appId 不是default
        for (NSDictionary *appListData in data) {
            NSArray *appList = appListData[@"appList"];
            for (NSDictionary *appListObj in appList) {
                NSString *appType = appListObj[@"appType"];
                NSString *appId = appListObj[@"appId"];
                //7.0不过滤isShow 服务器已经过滤过了
                if ([appType isEqualToString:@"default"] ||
                    [tabbarIds containsObject:appId]) {
                    NSDictionary *m3AppType = appListObj[@"m3AppType"];
                    NSInteger edit = [m3AppType[@"edit"] integerValue];
                    if (edit != -1) {
                        [result addObject:appId];
                    }
                }
            }
        }
    }
    else {
        for (NSDictionary *listData in data) {
            NSString *appId = listData[@"appId"];
            if ([listData[@"isShow"] boolValue] &&
                [listData[@"appType"] isEqualToString:@"default"] &&
                ![NSString isNull:appId]) {
                [result addObject:appId];
            }
        }
    }
    return result;
    
}


- (long long)outTime {
    return self.baiduUnitInfo.endTime;
}

- (NSInteger)xiaozhiCode {
    return self.baiduSpeechInfo.baiduAppError.code;
}

- (NSString *)formJsonPath {
    return @"";
//    NSString *path = [CMPFileManager createFullPath:@"Documents/File/xiaozhijson"];
//    path = [path stringByAppendingPathComponent:@"form.json"];
//    return path;
}

- (NSDictionary *)formJson {
    NSString *aPath = [self formJsonPath]; //[[NSBundle mainBundle] pathForResource:@"form" ofType:@"json"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:aPath]) {
        return nil;
        //        aPath = [[NSBundle mainBundle] pathForResource:@"form" ofType:@"json"];
    }
    
    NSString *aValue = [NSString stringWithContentsOfFile:aPath encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *dic = [SPTools dictionaryWithJsonString:aValue];
    NSDictionary *commondStepDic = dic[@"data"];
    if (commondStepDic && [commondStepDic isKindOfClass:[NSDictionary class]]) {
        return commondStepDic;
    }
    return nil;
}

- (NSString *)intentMd5Key {
    NSString *md5Key = [NSString stringWithFormat:@"%@IntentMd5",[CMPCore sharedInstance].serverID];
    return md5Key;
}

- (void)setIntentMd5:(NSString *)intentMd5 {
    _intentMd5 = nil;
    if (intentMd5) {
        _intentMd5 = [intentMd5 copy];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:intentMd5 forKey:[self intentMd5Key]];
        [userDefaults synchronize];
    }
}

- (NSString *)intentMd5 {
    if (!_intentMd5) {
        NSString *md5 = [[NSUserDefaults standardUserDefaults] objectForKey:[self intentMd5Key]];
        if ([NSString isNull:md5]) {
            md5 = @"-1";
        }
        _intentMd5 = [md5 copy];
    }
    return _intentMd5;
}


- (NSString *)spErrorCorrectionMd5Key {
    NSString *md5Key = [NSString stringWithFormat:@"%@spErrorCorrectionMd5",[CMPCore sharedInstance].serverID];
    return md5Key;
}

- (void)setSpErrorCorrectionMd5:(NSString *)spErrorCorrectionMd5 {
    _spErrorCorrectionMd5 = nil;
    if (spErrorCorrectionMd5) {
        _spErrorCorrectionMd5 = [spErrorCorrectionMd5 copy];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:spErrorCorrectionMd5 forKey:[self spErrorCorrectionMd5Key]];
        [userDefaults synchronize];
    }
}

- (NSString *)spErrorCorrectionMd5 {
    if (!_spErrorCorrectionMd5) {
        NSString *md5 = [[NSUserDefaults standardUserDefaults] objectForKey:[self spErrorCorrectionMd5Key]];
        if ([NSString isNull:md5]) {
            md5 = @"-1";
        }
        _spErrorCorrectionMd5 = [md5 copy];
    }
    return _spErrorCorrectionMd5;
}

- (NSString *)pinyinRegularMd5Key {
    NSString *md5Key = [NSString stringWithFormat:@"%@pinyinRegularMd5Key",[CMPCore sharedInstance].serverID];
    return md5Key;
}

- (NSString *)pinyinRegularMd5 {
    if (!_pinyinRegularMd5) {
        NSString *md5 = [[NSUserDefaults standardUserDefaults] objectForKey:[self pinyinRegularMd5Key]];
        if ([NSString isNull:md5]) {
            md5 = @"-1";
        }
        _pinyinRegularMd5 = [md5 copy];
    }
    return _pinyinRegularMd5;
}

- (void)setPinyinRegularMd5:(NSString *)pinyinRegularMd5 {
    _pinyinRegularMd5 = nil;
    if (pinyinRegularMd5) {
        _pinyinRegularMd5 = [pinyinRegularMd5 copy];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:pinyinRegularMd5 forKey:[self pinyinRegularMd5Key]];
        [userDefaults synchronize];
    }
}

//小致是否可用
- (BOOL)xiaozAvailable {
    return [[XZCore sharedInstance].baiduSpeechInfo canUseXiaoZhi];
}

- (BOOL)isUnitLater2 {
    NSString *unitVersion = _baiduUnitInfo.unitVersion;
    if ([NSString isNull:unitVersion]) {
        return NO;
    }
    NSArray *array = [unitVersion componentsSeparatedByString:@"."];
    NSInteger firstV = [array[0] integerValue];
    return firstV >= 2;
}

//小致版本号判断
- (BOOL)isXiaozVersionLater2_2 {
    NSString *version = _baiduUnitInfo.xiaozVersion;
    if ([NSString isNull:version]) {
        return NO;
    }
    NSArray *array = [version componentsSeparatedByString:@"."];
    NSInteger int_1 = [array[0] integerValue];
    NSInteger int_2 = array.count > 1 ? [array[1] integerValue] : 0;
    return int_1 > 2 ||(int_1 == 2 && int_2 >= 2);
}
- (BOOL)isXiaozVersionLater3_1 {
    if ([self isM3ServerIsLater8]) {
        return YES;//todo
         NSString *version = _baiduUnitInfo.xiaozVersion;
           if ([NSString isNull:version]) {
               return NO;
           }
           NSArray *array = [version componentsSeparatedByString:@"."];
           NSInteger int_1 = [array[0] integerValue];
           NSInteger int_2 = array.count > 1 ? [array[1] integerValue] : 0;
           return int_1 > 3 ||(int_1 == 3 && int_2 >= 1);
    }
    return NO;
}

- (BOOL)isM3ServerIsLater8 {
    return [[CMPCore sharedInstance] serverIsLaterV8_0];
}


+ (NSString *)userID {
    NSString *userID = [CMPCore sharedInstance].userID;
    return userID ? userID:@"";
}

+ (NSString *)userName {
    return [CMPCore sharedInstance].userName;
}

+ (NSString *)departmentName {
    return [CMPCore sharedInstance].currentUser.departmentName;
}

+ (NSString *)postID {
    return [CMPCore sharedInstance].currentUser.postID;
}

+ (NSString *)postName {
    return [CMPCore sharedInstance].currentUser.postName;
}

+ (NSString *)accountID {
    return [CMPCore sharedInstance].currentUser.accountID;
}

+ (NSString *)serverurl {
    return [CMPCore sharedInstance].serverurlForSeeyon;
}
+ (NSString *)fullUrlForPath:(NSString *)path {
    return [CMPCore fullUrlForPath:path];
}

+ (NSString *)fullUrlForPathFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2) {
    va_list args;
    va_start(args, format);
    NSString *path = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [CMPCore fullUrlForPath:path];
}

+ (NSString *)serverID {
    return [CMPCore sharedInstance].serverID;
}

+ (BOOL)allowRotation {
    return [CMPCore sharedInstance].allowRotation;
}

@end
