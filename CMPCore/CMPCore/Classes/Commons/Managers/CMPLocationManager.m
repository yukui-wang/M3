//
//  CMPLocationManager.m
//  M3
//
//  Created by 程昆 on 2019/5/24.
//

#import "CMPLocationManager.h"
#import "CMPCommonManager.h"
#import "CMPGoogleLocationManager.h"

#import <CMPLib/CMPCore.h>
#import <CMPLib/MSWeakTimer.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CLGeocoder+CMPGeocoder.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "CMPLoginConfigInfoModel.h"
#import <CMPLib/CMPThreadSafeMutableArray.h>
#import <CMPLib/CMPServerVersionUtils.h>
#import "CMPPreferenceManager.h"
#import <CMPLib/NSObject+CMP.h>
#import "KSLocationManager+Ext.h"
#import <CMPLib/KSLogManager.h>
#import <CMPLib/SOLocalization.h>

#define kLocationTimeInterval 60.0

@interface CMPLocationManager ()<AMapLocationManagerDelegate,AMapSearchDelegate>
{
    KSLocationManager *_ksLocationManager;
}
@property (strong, nonatomic) AMapLocationManager *lastingLocationMgr;
/* 持续定位中上次定位点 */
@property (strong, nonatomic) CLLocation *lastUpdatingLocation;

@property (nonatomic,strong) AMapLocationManager *locationManager;
@property (nonatomic,strong) AMapSearchAPI *locationSearch;
@property (nonatomic,strong) MSWeakTimer *locationTimer;

@property (nonatomic,strong) NSDate *lastUpdateLocationTime;
@property (nonatomic,strong) AMapReGeocode *lastUpdateRegeocode;
@property (nonatomic,strong) AMapGeoPoint *lastUpdateLocation;

@property (nonatomic,copy) CMPLocationCompletionBlock updatingLocationCompletionBlock;

/* 持续定位回调 */
@property (copy, nonatomic) CMPLastingLocationCallbackBlock lastingLocationCallback;

/* 用于检测定位点是不是在中国 */
@property(nonatomic,strong)CLGeocoder *geocoder;

/* 上次定位的provider */
@property (copy, nonatomic) NSString *lastLocationProvider;


@property (retain, nonatomic)CMPThreadSafeMutableArray *singleLocationBlockArray;

@property (nonatomic,assign) BOOL isUpdatingLocateOnWork;//是否连续定位在工作中

@end

@implementation CMPLocationManager

+ (instancetype)shareLocationManager {
    static CMPLocationManager *locationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationManager = [[self alloc] init];
        NSLog(@"ks log --- CMPLocationManager -- 单例初始化shareLocationManager");
        [AMapServices sharedServices].apiKey = [CMPCommonManager lbsAPIKey];
        [locationManager configLocationManager];
        [locationManager configLocationSearch];
    });
    return locationManager;
}

+ (instancetype)locationManager {
    CMPLocationManager * aLocationManager = [[self alloc] init];
    NSLog(@"ks log --- CMPLocationManager -- 初始化locationManager");
    if (![AMapServices sharedServices].apiKey || ![AMapServices sharedServices].apiKey.length) {
        [AMapServices sharedServices].apiKey = [CMPCommonManager lbsAPIKey];
    }
    [aLocationManager configLocationManager];
    [aLocationManager configLocationSearch];
    return aLocationManager;
}

-(instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_setGeocodeLanguage) name:@"kNotificationName_ChangeLanguage" object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kNotificationName_ChangeLanguage" object:nil];
}

-(void)setMapKey:(CMPLoginConfigMapKey *)mapKey {
    _mapKey = mapKey;
    NSLog(@"ks log --- CMPLocationManager -- setMapKey");
    NSString *googleMapKey = mapKey.googleMapKey;
    if ([NSString isNotNull:googleMapKey]) {
        [CMPGoogleLocationManager initGoogleMapsWirhMapKey:googleMapKey];
    }
}

- (void)configLocationManager {
    [AMapLocationManager updatePrivacyAgree:AMapPrivacyAgreeStatusDidAgree];
    [AMapLocationManager updatePrivacyShow:AMapPrivacyShowStatusDidShow privacyInfo:AMapPrivacyInfoStatusDidContain];
    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManagerType = CMPLocationManagerTypeAuto;
    self.locationManager.reGeocodeLanguage = [CMPCore language_ZhCN]?AMapLocationReGeocodeLanguageChinse:AMapLocationReGeocodeLanguageEnglish;
    self.locationManager.delegate = self;
    self.locationManager.detectRiskOfFakeLocation = YES;
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    self.locationManager.locationTimeout = 3;
    self.locationManager.reGeocodeTimeout = 3;
    
    _ksLocationManager = [[KSLocationManager alloc] init];
}

-(void)_setGeocodeLanguage
{
    NSString *language = [CMPCore languageCode];
    if ([language.lowercaseString hasPrefix:@"zh-"]
        ||[language.lowercaseString hasPrefix:@"zh_"]) {
        if (_locationManager) {
            _locationManager.reGeocodeLanguage = AMapLocationReGeocodeLanguageChinse;
        }
        if (_locationSearch) {
            _locationSearch.language = AMapSearchLanguageZhCN;
        }
        if (_lastingLocationMgr) {
            _lastingLocationMgr.reGeocodeLanguage = AMapLocationReGeocodeLanguageChinse;
        }
    }else{
        if (_locationManager) {
            _locationManager.reGeocodeLanguage = AMapLocationReGeocodeLanguageEnglish;
        }
        if (_locationSearch) {
            _locationSearch.language = AMapSearchLanguageEn;
        }
        if (_lastingLocationMgr) {
            _lastingLocationMgr.reGeocodeLanguage = AMapLocationReGeocodeLanguageEnglish;
        }
    }
}

- (void)configLocationSearch {
    [AMapSearchAPI updatePrivacyShow:AMapPrivacyShowStatusDidShow privacyInfo:AMapPrivacyInfoStatusDidContain];
    [AMapSearchAPI updatePrivacyAgree:AMapPrivacyAgreeStatusDidAgree];
    self.locationSearch = [[AMapSearchAPI alloc] init];
    self.locationSearch.delegate = self;
//    self.locationSearch.language = [CMPCore language_ZhCN]?AMapSearchLanguageZhCN:AMapSearchLanguageEn;
    
    [self _setGeocodeLanguage];
}

- (CLGeocoder *)geocoder {
     if (_geocoder == nil) {
             _geocoder = [[CLGeocoder alloc] init];
       }
     return _geocoder;
}
- (CMPThreadSafeMutableArray *)singleLocationBlockArray{
    if (!_singleLocationBlockArray) {
        _singleLocationBlockArray = [[CMPThreadSafeMutableArray alloc] init];
    }
    return _singleLocationBlockArray;
}

//本地总定位服务是否开启
- (BOOL)locationServiceEnable {
    BOOL isOpen = [CLLocationManager locationServicesEnabled];
    NSLog(@"ks log --- CMPLocationManager -- locationServiceEnable: %@",@(isOpen));
    return isOpen;
}


//开启定位
- (void)startUpdatingLocation {
    [self.locationManager startUpdatingLocation];
    _isUpdatingLocateOnWork = YES;
}

//停止定位
- (void)stopUpdatingLocation {
     [self.locationManager stopUpdatingLocation];
    _isUpdatingLocateOnWork = NO;
    
    [_ksLocationManager stopUpdatingLocation];
}

//停止连续定位并停止返回数据
- (void)stopAndCleanUpdatingLocation {
    [self stopUpdatingLocation];
    self.updatingLocationCompletionBlock = nil;
    [self.singleLocationBlockArray removeAllObjects];
}

/**
 开启连续定位
 */
- (void)startLastingLocationCallBack:(CMPLastingLocationCallbackBlock)lastingLocationCallback {
    self.lastingLocationMgr = nil;
    [AMapLocationManager updatePrivacyAgree:AMapPrivacyAgreeStatusDidAgree];
    [AMapLocationManager updatePrivacyShow:AMapPrivacyShowStatusDidShow privacyInfo:AMapPrivacyInfoStatusDidContain];
    self.lastingLocationMgr = [[AMapLocationManager alloc] init];
    self.lastingLocationMgr.delegate = self;
    self.lastingLocationMgr.desiredAccuracy = kCLLocationAccuracyBest;
    //此时应用程序设置中选择“使用应用程序期间”的时候就会出现蓝条，选择“始终”的时候蓝条就不会出现
    self.lastingLocationMgr.allowsBackgroundLocationUpdates = NO;
    //移动多少米定位一次
    self.lastingLocationMgr.distanceFilter = 6.0;
    self.lastingLocationMgr.pausesLocationUpdatesAutomatically = YES;

    [self.lastingLocationMgr setLocatingWithReGeocode:YES];
    NSString *language = [CMPCore languageCode];
    if ([language.lowercaseString hasPrefix:@"zh-"]
        ||[language.lowercaseString hasPrefix:@"zh_"]) {
        _lastingLocationMgr.reGeocodeLanguage = AMapLocationReGeocodeLanguageChinse;
    }else{
        _lastingLocationMgr.reGeocodeLanguage = AMapLocationReGeocodeLanguageEnglish;
    }
    //定位可用
    [self.lastingLocationMgr startUpdatingLocation];
    self.lastingLocationCallback = lastingLocationCallback;
}

/**
 停止连续定位定位
 */
- (void)stopLastingLocation {
    [self.lastingLocationMgr stopUpdatingLocation];
    self.lastingLocationMgr = nil;
}

//单次定位
- (void)requestSingleLocation {
    NSLog(@"ks log --- CMPLocationManager -- requestSingleLocation");
    __weak typeof(self) weakSelf = self;
    self.locationManager.allowsBackgroundLocationUpdates = NO;
    self.locationManager.locationTimeout = 3;
    self.locationManager.reGeocodeTimeout = 3;
    
    if ([KSLogManager shareManager].locationTag == 2
        || [CMPPreferenceManager getMapTypeInUse] == MapTypeInUse_Apple) {

        KSLocateResultBlk locateResultBlk = ^(NSArray<CLLocation *> * _Nullable locations, NSError * _Nullable error){
            NSLog(@"ks log --- once locate result blk -- eval begin");
            if (error) {
                NSLog(@"ks log --- CMPLocationManager -- requestSingleLocation result final error: %@",error);
                if (weakSelf.singleLocationBlockArray.count > 0) {
                    CMPLocationManager.shareLocationManager.lastLocationProvider = CMPLocationManagerMapsTypeAmap;
                    NSArray *tempArray = [[NSArray alloc] initWithArray:weakSelf.singleLocationBlockArray];
                    [weakSelf.singleLocationBlockArray removeAllObjects];
                    for (CMPLocationCompletionBlock block in tempArray) {
                        block(CMPLocationManagerMapsTypeAmap,nil, nil, error, nil,nil);
                    }
                }
            }
        };

        KSLocationReverseResultBlk reverseResultBlk = ^(NSArray<CLPlacemark *> * _Nullable placemarks, NSString * _Nonnull locationAddressName, NSError * _Nullable error) {
            NSLog(@"ks log --- once reverse result blk -- eval begin");
            if (!error) {
                if (self.singleLocationBlockArray.count > 0 && placemarks.count) {
                    CLPlacemark *placeMark = placemarks.firstObject;
                    NSArray *tempArray = [[NSArray alloc] initWithArray:self.singleLocationBlockArray];
                    [self.singleLocationBlockArray removeAllObjects];
                    AMapGeoPoint *geoPoint = [KSLocationManager convertCLLocationToAMapGeoPoint:placeMark.location];
                    AMapReGeocode *aRegeo = [KSLocationManager convertCLPlacemarkToAMapReGeocode:placeMark];
                    for (CMPLocationCompletionBlock block in tempArray) {
                        block(CMPLocationManagerMapsTypeAmap,geoPoint,aRegeo, nil, nil,nil);
                    }
                }
            }else{
                if (weakSelf.singleLocationBlockArray.count > 0) {
                    CMPLocationManager.shareLocationManager.lastLocationProvider = CMPLocationManagerMapsTypeAmap;
                    NSArray *tempArray = [[NSArray alloc] initWithArray:weakSelf.singleLocationBlockArray];
                    [weakSelf.singleLocationBlockArray removeAllObjects];
                    for (CMPLocationCompletionBlock block in tempArray) {
                        block(CMPLocationManagerMapsTypeAmap,nil, nil, nil, error,nil);
                    }
                }
            }
        };

        [_ksLocationManager requestOnceLocationWithLocateResult:locateResultBlk reverseResult:reverseResultBlk];

        return;
    }
    
    __block BOOL needRefresh = NO;
    __block NSInteger curIndex = 0,maxIndex = 5;
    __block int locationTimeout = 3;
    __block int reGeocodeTimeout = 3;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        do {
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            needRefresh = NO;
            
            //5遍尝试超时时间：3-6-6-10-10,
            if (curIndex == 1 || curIndex == 2) {
                locationTimeout = 6;
                reGeocodeTimeout = 4;
            }else if (curIndex > 2) {
                locationTimeout = 10;
                reGeocodeTimeout = 5;
            }
            self.locationManager.locationTimeout = locationTimeout;
            self.locationManager.reGeocodeTimeout = reGeocodeTimeout;
            
            NSLog(@"ks log --- CMPLocationManager -- requestSingleLocation begin : 第%ld次", curIndex);
            [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
                NSLog(@"ks log --- CMPLocationManager -- requestSingleLocation result location : %@, error:%@", location,error);
                //属性精确度是米
                if (!error && (location.horizontalAccuracy < 0 || location.verticalAccuracy < 0)) {
                    if (curIndex < maxIndex) {
                        curIndex += 1;
                        needRefresh = YES;
                        NSLog(@"ks log --- CMPLocationManager -- requestSingleLocation result :需要刷新重新定位");
                        dispatch_semaphore_signal(semaphore);
                        return;
                    }
                }
                
                dispatch_semaphore_signal(semaphore);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        NSLog(@"ks log --- CMPLocationManager -- requestSingleLocation result final error: %@",error);
                        if (weakSelf.singleLocationBlockArray.count > 0) {
                            CMPLocationManager.shareLocationManager.lastLocationProvider = CMPLocationManagerMapsTypeAmap;
                            NSArray *tempArray = [[NSArray alloc] initWithArray:weakSelf.singleLocationBlockArray];
                            [weakSelf.singleLocationBlockArray removeAllObjects];
                            for (CMPLocationCompletionBlock block in tempArray) {
                                block(CMPLocationManagerMapsTypeAmap,nil, nil, nil, nil,error);
                            }
                        }
                        return ;
                    }

                    NSLog(@"ks log --- CMPLocationManager -- requestSingleLocation result final success begin 逆地理解析");
                    [weakSelf amapLocationManager:weakSelf.locationManager didUpdateLocation:location reGeocode:regeocode];
                });
            }];

            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
        } while (needRefresh);
    });

}

// 获取单次定位结果
- (void)getSingleLocationWithCompletionBlock:(CMPLocationCompletionBlock)completionBlock {
    NSLog(@"ks log --- %s",__FUNCTION__);
//    CMPLocationManager *shareLocationManager = [CMPLocationManager shareLocationManager];
//    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:shareLocationManager.lastUpdateLocationTime ?: [NSDate date]];
//    if (timeInterval <= kLocationTimeInterval && shareLocationManager.lastUpdateLocationTime) {
//        if (completionBlock) {
//            if (!shareLocationManager.lastLocationProvider.length) {
//                shareLocationManager.lastLocationProvider = CMPLocationManagerMapsTypeAmap;
//            }
//            completionBlock(shareLocationManager.lastLocationProvider,shareLocationManager.lastUpdateLocation,shareLocationManager.lastUpdateRegeocode,nil,nil,nil);
//        }
//    } else {
//        [self.singleLocationBlockArray addObject:completionBlock];
//        [self requestSingleLocation];
//    }
    
    [self.singleLocationBlockArray addObject:completionBlock];
    [self requestSingleLocation];
}

// 获取连续定位结果
- (void)getUpdatingLocationWithCompletionBlock:(CMPLocationCompletionBlock)completionBlock {
    NSLog(@"ks log --- %s",__FUNCTION__);
//    CMPLocationManager *shareLocationManager = [CMPLocationManager shareLocationManager];
//    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:shareLocationManager.lastUpdateLocationTime];
//    if (timeInterval <= kLocationTimeInterval) {
//        if (completionBlock) {
//           if (!shareLocationManager.lastLocationProvider.length) {
//                CMPLocationManager.shareLocationManager.lastLocationProvider = CMPLocationManagerMapsTypeAmap;
//            }
//            completionBlock(CMPLocationManager.shareLocationManager.lastLocationProvider,shareLocationManager.lastUpdateLocation,shareLocationManager.lastUpdateRegeocode,nil,nil,nil);
//        }
//    }
    self.locationManager.locatingWithReGeocode = YES;
    self.updatingLocationCompletionBlock = completionBlock;
    
    if ([KSLogManager shareManager].locationTag == 2
        || [CMPPreferenceManager getMapTypeInUse] == MapTypeInUse_Apple) {

        KSLocateResultBlk locateResultBlk = ^(NSArray<CLLocation *> * _Nullable locations, NSError * _Nullable error){
            NSLog(@"ks log --- updating locate result blk -- eval begin");
            if (error) {
                NSLog(@"ks log --- CMPLocationManager -- requestUpdatingLocation result final error: %@",error);
                if (self.updatingLocationCompletionBlock) {
                    CMPLocationManager.shareLocationManager.lastLocationProvider =  CMPLocationManagerMapsTypeAmap;
                    self.updatingLocationCompletionBlock(CMPLocationManagerMapsTypeAmap,nil,nil,error,nil,nil);
                }
            }
        };

        KSLocationReverseResultBlk reverseResultBlk = ^(NSArray<CLPlacemark *> * _Nullable placemarks, NSString * _Nonnull locationAddressName, NSError * _Nullable error) {
            NSLog(@"ks log --- updating reverse result blk -- eval begin");
            if (!error) {
                if (self.updatingLocationCompletionBlock && placemarks.count) {
                    CLPlacemark *placeMark = placemarks.firstObject;
                    AMapGeoPoint *geoPoint = [KSLocationManager convertCLLocationToAMapGeoPoint:placeMark.location];
                    AMapReGeocode *aRegeo = [KSLocationManager convertCLPlacemarkToAMapReGeocode:placeMark];
                    self.updatingLocationCompletionBlock(CMPLocationManagerMapsTypeAmap,geoPoint,aRegeo, nil, nil,nil);
                }

            }else{
                if (self.updatingLocationCompletionBlock) {
                    CMPLocationManager.shareLocationManager.lastLocationProvider =  CMPLocationManagerMapsTypeAmap;
                    self.updatingLocationCompletionBlock(CMPLocationManagerMapsTypeAmap,nil,nil,nil,error,nil);
                }
            }
        };

        [_ksLocationManager requestUpdatingLocationWithLocateResult:locateResultBlk reverseResult:reverseResultBlk];

        return;
    }
    [self.locationManager startUpdatingLocation];
}

// 逆地理解析
- (void)reGeocodeSearchWithLocation:(CLLocation *)location {
    NSLog(@"ks log --- %s",__FUNCTION__);
    [self reGeocodeSearchUsingAmapWithLocation:location];
    return;
    //判定定位点是不是在国内，不是在国内就用Google地图获取定位后的信息
    //[self reGeocodeSearchUsingAmapWithLocation:location];
    
//    __weak typeof(self) weakSelf = self;
    //如果是8.0的，本地有Googlekey 用google
    //其他版本的，判断前端传入的值是否是使用Google，并且本地有值，就使用google
    
    //ks fix 8.1版本时修改此逻辑
    //先判断本地是否有googlekey，没有则不执行下面的逻辑，直接高德
    //如果是8.1及以后的，根据本地设置，如果是google定位，则google
    //如果是8.1以前的，判断下位置，如果是国外，就google
    __block BOOL isUseGoogle = NO;
    NSString *googleKey = [CMPGoogleLocationManager googleMapKey];
    BOOL hasGoogleKey = [NSString isNotNull:googleKey];
    if (hasGoogleKey) {
        if ([CMPServerVersionUtils serverIsLaterV8_1]) {
            if ([CMPPreferenceManager getMapTypeInUse] == MapTypeInUse_Google) {
                isUseGoogle = YES;
            }
        }else{
//            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [self.geocoder cmp_reverseGeocodeWithCLLocation:location Block:^(BOOL isError, BOOL isInCHINA) {
                if (!isInCHINA) {
                    isUseGoogle = YES;
                }
                if (!isUseGoogle) {
                    [self reGeocodeSearchUsingAmapWithLocation:location];
                }else{
                    [self reGeocodeSearchUsingGoogleMapsWithLocation:location];
                }
//                dispatch_semaphore_signal(semaphore);
            }];
//            dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 10*NSEC_PER_SEC));
            return;
        }
    }
    if (!isUseGoogle) {
        [self reGeocodeSearchUsingAmapWithLocation:location];
    }else{
        [self reGeocodeSearchUsingGoogleMapsWithLocation:location];
    }
    
    
//    if (self.locationManagerType == CMPLocationManagerTypeAuto) {
//        [self.geocoder cmp_reverseGeocodeWithCLLocation:location Block:^(BOOL isError, BOOL isInCHINA) {
//            CMPLog(@"[isError %d, isInCHINA %d]",isError, isInCHINA);
//            if (isInCHINA) {
//                [weakSelf reGeocodeSearchUsingAmapWithLocation:location];
//            }else {
//                [weakSelf reGeocodeSearchUsingGoogleMapsWithLocation:location];
//            }
//        }];
//    } else if (self.locationManagerType == CMPLocationManagerTypeGaode) {
//        [self reGeocodeSearchUsingAmapWithLocation:location];
//    } else if (self.locationManagerType == CMPLocationManagerTypeGoogle) {
//        [self reGeocodeSearchUsingGoogleMapsWithLocation:location];
//    }
    
}

- (void)reGeocodeSearchUsingAmapWithLocation:(CLLocation *)location {
    NSLog(@"ks log --- %s",__FUNCTION__);
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location                    = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    regeo.requireExtension            = YES;
    [self.locationSearch AMapReGoecodeSearch:regeo];
    
}

- (void)reGeocodeSearchUsingGoogleMapsWithLocation:(CLLocation *)location {
    NSLog(@"ks log --- %s",__FUNCTION__);
    __weak typeof(self) weakSelf = self;
    [CMPGoogleLocationManager.sharedManager reGeocoderLocation:location pois:^(NSString *  _Nullable provider, NSArray * _Nullable pois, AMapLocationReGeocode * _Nullable bestPoi, AMapGeoPoint * _Nullable geoPoint, AMapReGeocode * _Nullable regeocode, NSError * _Nullable locationError, NSError * _Nullable searchError, NSError * _Nullable locationResultError) {
        if (weakSelf.lastingLocationCallback) {
            weakSelf.lastingLocationCallback(geoPoint, regeocode);
        }
        
        if (regeocode && geoPoint) {
            CMPLocationManager *shareLocationManager = [CMPLocationManager shareLocationManager];
            shareLocationManager.lastUpdateLocationTime = [NSDate date];
            shareLocationManager.lastUpdateRegeocode = regeocode;
            shareLocationManager.lastUpdateLocation = geoPoint;
        }
        
        if (weakSelf.singleLocationBlockArray.count > 0) {
            CMPLocationManager.shareLocationManager.lastLocationProvider = CMPLocationManagerMapsTypeGoogle;
            NSArray *tempArray = [[NSArray alloc] initWithArray:weakSelf.singleLocationBlockArray];
            [weakSelf.singleLocationBlockArray removeAllObjects];
            for (CMPLocationCompletionBlock block in tempArray) {
                block(CMPLocationManagerMapsTypeGoogle,geoPoint,regeocode, locationError, searchError,locationResultError);
            }
        }
        
        if (weakSelf.updatingLocationCompletionBlock) {
            CMPLocationManager.shareLocationManager.lastLocationProvider = CMPLocationManagerMapsTypeGoogle;
            weakSelf.updatingLocationCompletionBlock(CMPLocationManagerMapsTypeGoogle,geoPoint,regeocode, locationResultError, locationResultError,locationResultError);
        }
    }];
}

#pragma mark - AMapLocationManagerDelegate

- (void)amapLocationManager:(AMapLocationManager *)manager doRequireLocationAuth:(CLLocationManager*)locationManager {
    [locationManager requestAlwaysAuthorization];
}

- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"ks log --- %s -- %@",__FUNCTION__,error);
    if (self.singleLocationBlockArray.count > 0) {
        CMPLocationManager.shareLocationManager.lastLocationProvider =  CMPLocationManagerMapsTypeAmap;
        NSArray *tempArray = [[NSArray alloc] initWithArray:self.singleLocationBlockArray];
        [self.singleLocationBlockArray removeAllObjects];
        for (CMPLocationCompletionBlock block in tempArray) {
            block(CMPLocationManagerMapsTypeAmap,nil,nil,error,nil,nil);
        }
    }
    if (self.updatingLocationCompletionBlock) {
        CMPLocationManager.shareLocationManager.lastLocationProvider =  CMPLocationManagerMapsTypeAmap;
        self.updatingLocationCompletionBlock(CMPLocationManagerMapsTypeAmap,nil,nil,error,nil,nil);
    }
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location {
    [self reGeocodeSearchWithLocation:location];
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode
{
    NSLog(@"ks log --- %s -- %@",__FUNCTION__,location);
    //过滤掉误差较大的定位
    //ks fix -- 客户bug较多，首建定位到此处影响直接返回导致无法定位，20230322注释
//    if (location.horizontalAccuracy < 0 || location.verticalAccuracy < 0) {
//        return;
//    }
    //end
    
    //如果上次记录的点和这次定位到的点之间距离小于1.5米的时候，就返回
    CMPLocationManager *shareLocationManager = [CMPLocationManager shareLocationManager];
    if (shareLocationManager.lastUpdatingLocation && [self checkPlaceIsAssignedPlaceWithCoord:location coord2:shareLocationManager.lastUpdatingLocation meters:1.5] && shareLocationManager.lastUpdateRegeocode && shareLocationManager.lastUpdateLocation && shareLocationManager.lastLocationProvider) {
        shareLocationManager.lastUpdatingLocation = location;
        [self onReGeocodeSearchDoneWithUpdateRegeocode:shareLocationManager.lastUpdateRegeocode updateLocation:shareLocationManager.lastUpdateLocation locationProvider:shareLocationManager.lastLocationProvider];
        return;
    }

    shareLocationManager.lastUpdatingLocation = location;
    
    NSString *log = [NSString stringWithFormat:@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy];
    CMPLog(@"%@",log);
    if (reGeocode)
    {
        CMPLog(@"reGeocode:%@", reGeocode);
        
        //ks fix -- V5-30251
        NSString *googleKey = [CMPGoogleLocationManager googleMapKey];
        BOOL hasGoogleKey = [NSString isNotNull:googleKey];
        if (hasGoogleKey) {
            //先判断下高德的逆地理有没有信息，如果没有，则进行google判断
            NSString *formattedAddress = reGeocode.formattedAddress;
            NSString *country = reGeocode.country;
            NSString *province = reGeocode.province;
            NSString *city = reGeocode.city;
            
            BOOL con1 = formattedAddress && formattedAddress.length && ![formattedAddress.lowercaseString hasPrefix:@"unknow"];
            BOOL con1_1 = country && country.length && ![country.lowercaseString hasPrefix:@"unknow"];
            BOOL con1_2 = province && province.length && ![province.lowercaseString hasPrefix:@"unknow"];
            BOOL con1_3 = city && city.length && ![city.lowercaseString hasPrefix:@"unknow"];
            
            BOOL con0 = NO;
            if ([CMPServerVersionUtils serverIsLaterV8_1]) {
                if ([CMPPreferenceManager getMapTypeInUse] == MapTypeInUse_Google) {
                    BOOL con2 = [country hasPrefix:@"中国"]
                                || [country hasPrefix:@"中國"]
                                || [country.lowercaseString hasPrefix:@"china"];
                    con0 = !con2;
                }
            }
            if (!con1 || !con1_1 || !con1_2 || !con1_3 || con0) {
                [self reGeocodeSearchUsingGoogleMapsWithLocation:location];
                return;
            }
        }//end
    }
    [self reGeocodeSearchWithLocation:location];
    
}


#pragma mark - AMapSearchDelegate

// 逆地理编码回调
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    
//    BOOL isNeedUseGoogleMap =  [NSString isNull:response.regeocode.formattedAddress];
//    BOOL isUseGoogleMap = CMPLocationManager.shareLocationManager.isCanUseGoogleMap && isNeedUseGoogleMap;
//
//    if (isUseGoogleMap) {//这种情况下证明高德取不到定位逆地理信息，因此就使用Google地图
//        CLLocation *location = [[CLLocation alloc] initWithLatitude:request.location.latitude longitude:request.location.longitude];
//        [self reGeocodeSearchUsingGoogleMapsWithLocation: location];
//        return;
//    }
    
    /*  ks fix -- V5-30251
    NSString *googleKey = [CMPGoogleLocationManager googleMapKey];
    BOOL hasGoogleKey = [NSString isNotNull:googleKey];
    if (hasGoogleKey) {
        BOOL con0 = YES;
        if ([CMPServerVersionUtils serverIsLaterV8_1]) {
            if ([CMPPreferenceManager getMapTypeInUse] != MapTypeInUse_Google) {
                con0 = NO;
            }
        }
        if (con0) {
            //先判断下高德的逆地理有没有信息，如果没有，则进行google判断
            AMapReGeocode *regeocode = response.regeocode;
            NSString *formattedAddress = regeocode.formattedAddress;
            NSString *country = regeocode.addressComponent.country;
            NSString *province = regeocode.addressComponent.province;
            NSString *city = regeocode.addressComponent.city;
            
            BOOL con1 = formattedAddress && formattedAddress.length && ![formattedAddress.lowercaseString hasPrefix:@"unknow"];
            BOOL con1_1 = country && country.length && ![country.lowercaseString hasPrefix:@"unknow"];
            BOOL con1_2 = province && province.length && ![province.lowercaseString hasPrefix:@"unknow"];
            BOOL con1_3 = city && city.length && ![city.lowercaseString hasPrefix:@"unknow"];
            BOOL con2 = [country hasPrefix:@"中国"]
                        || [country hasPrefix:@"中國"]
                        || [country.lowercaseString hasPrefix:@"china"];
            BOOL con2_1 = [province containsString:@"香港"]||[province containsString:@"澳门"]||[province containsString:@"台湾"];
            BOOL con2_2 = [province containsString:@"香港"]||[province containsString:@"澳門"]||[province containsString:@"臺灣"];
            BOOL con2_3 = [province.lowercaseString containsString:@"hongkong"]||[province.lowercaseString containsString:@"hong kong"]||[province containsString:@"macao"]||[province containsString:@"taiwan"];
            if (!con1 || !con1_1 || !con1_2 || !con1_3 || !con2 || con2_1 || con2_2 || con2_3) {
                CLLocation *location = [[CLLocation alloc] initWithLatitude:request.location.latitude longitude:request.location.longitude];
                [self reGeocodeSearchUsingGoogleMapsWithLocation:location];
                return;
            }
        }
    }
    */
    [self onReGeocodeSearchDoneWithUpdateRegeocode:response.regeocode updateLocation:request.location locationProvider:CMPLocationManagerMapsTypeAmap];
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    NSLog(@"ks log --- %s -- %@",__FUNCTION__,error);
    if ([request isMemberOfClass:[AMapReGeocodeSearchRequest class]]) {
        AMapReGeocodeSearchRequest *reGeocodeSearchRequest = request;
        
        //ks fix -- V5-30251
        //判断下是否需要google逆地理
        NSString *googleKey = [CMPGoogleLocationManager googleMapKey];
        BOOL hasGoogleKey = [NSString isNotNull:googleKey];
        if (hasGoogleKey) {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:reGeocodeSearchRequest.location.latitude longitude:reGeocodeSearchRequest.location.longitude];
            if ([CMPServerVersionUtils serverIsLaterV8_1]) {
                if ([CMPPreferenceManager getMapTypeInUse] == MapTypeInUse_Google) {
                    [self reGeocodeSearchUsingGoogleMapsWithLocation:location];
                    return;
                }
            }else{
                [self.geocoder cmp_reverseGeocodeWithCLLocation:location Block:^(BOOL isError, BOOL isInCHINA) {
                    if (!isInCHINA) {
                        [self reGeocodeSearchUsingGoogleMapsWithLocation:location];
                    }else{
                        if (self.singleLocationBlockArray.count > 0) {
                            CMPLocationManager.shareLocationManager.lastLocationProvider =  CMPLocationManagerMapsTypeAmap;
                            NSArray *tempArray = [[NSArray alloc] initWithArray:self.singleLocationBlockArray];
                            [self.singleLocationBlockArray removeAllObjects];
                            for (CMPLocationCompletionBlock block in tempArray) {
                                block(CMPLocationManagerMapsTypeAmap,reGeocodeSearchRequest.location,nil,nil,error,nil);
                            }
                        }
                        if (self.updatingLocationCompletionBlock) {
                           CMPLocationManager.shareLocationManager.lastLocationProvider =  CMPLocationManagerMapsTypeAmap; self.updatingLocationCompletionBlock(CMPLocationManagerMapsTypeAmap,reGeocodeSearchRequest.location,nil,nil,error,nil);
                        }
                    }
                }];
                return;
            }
        }
        
        if (self.singleLocationBlockArray.count > 0) {
            CMPLocationManager.shareLocationManager.lastLocationProvider =  CMPLocationManagerMapsTypeAmap;
            NSArray *tempArray = [[NSArray alloc] initWithArray:self.singleLocationBlockArray];
            [self.singleLocationBlockArray removeAllObjects];
            for (CMPLocationCompletionBlock block in tempArray) {
                block(CMPLocationManagerMapsTypeAmap,reGeocodeSearchRequest.location,nil,nil,error,nil);
            }
        }
        if (self.updatingLocationCompletionBlock) {
           CMPLocationManager.shareLocationManager.lastLocationProvider =  CMPLocationManagerMapsTypeAmap; self.updatingLocationCompletionBlock(CMPLocationManagerMapsTypeAmap,reGeocodeSearchRequest.location,nil,nil,error,nil);
        }
    }else{
        if (self.singleLocationBlockArray.count > 0) {
            CMPLocationManager.shareLocationManager.lastLocationProvider =  CMPLocationManagerMapsTypeAmap;
            NSArray *tempArray = [[NSArray alloc] initWithArray:self.singleLocationBlockArray];
            [self.singleLocationBlockArray removeAllObjects];
            for (CMPLocationCompletionBlock block in tempArray) {
                block(CMPLocationManagerMapsTypeAmap,nil,nil,nil,error,nil);
            }
        }
        if (self.updatingLocationCompletionBlock) {
            CMPLocationManager.shareLocationManager.lastLocationProvider =  CMPLocationManagerMapsTypeAmap;
            self.updatingLocationCompletionBlock(CMPLocationManagerMapsTypeAmap,nil,nil,nil,error,nil);
        }
    }
}


/// 检测给定点两点之间的距离是不是在给定距离之内，是的话，返回YES，否则返回NO
/// @param coord 给定点1
/// @param coord2 给定点2
/// @param meters 给定距离
- (BOOL)checkPlaceIsAssignedPlaceWithCoord:(CLLocation *)coord coord2:(CLLocation *)coord2 meters:(CGFloat)meters {
    CLLocationDistance distance = [coord distanceFromLocation:coord2];
    return (distance < meters);
}

- (void)onReGeocodeSearchDoneWithUpdateRegeocode:(AMapReGeocode *)updateRegeocode updateLocation:(AMapGeoPoint *)updateLocation locationProvider:(NSString *) locationProvider {
    NSLog(@"ks log --- %s -- %@",__FUNCTION__,updateRegeocode.formattedAddress);
    CMPLocationManager *shareLocationManager = [CMPLocationManager shareLocationManager];
    shareLocationManager.lastUpdateLocationTime = [NSDate date];
    shareLocationManager.lastUpdateRegeocode = updateRegeocode;
    shareLocationManager.lastUpdateLocation = updateLocation;
    shareLocationManager.lastLocationProvider =  locationProvider;
    
    if (self.singleLocationBlockArray.count > 0) {
        NSArray *tempArray = [[NSArray alloc] initWithArray:self.singleLocationBlockArray];
        [self.singleLocationBlockArray removeAllObjects];
        for (CMPLocationCompletionBlock block in tempArray) {
            block(locationProvider,updateLocation,updateRegeocode, nil, nil,nil);
        }
    }
    if (self.updatingLocationCompletionBlock) {
        self.updatingLocationCompletionBlock(locationProvider,updateLocation,updateRegeocode, nil, nil,nil);
    }
    if (self.lastingLocationCallback) {
        self.lastingLocationCallback(updateLocation, updateRegeocode);
    }
}

@end
