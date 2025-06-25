//
//  CMPLocationManager.h
//  M3
//
//  Created by 程昆 on 2019/5/24.
//

#import <Foundation/Foundation.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

typedef NS_ENUM(NSInteger, CMPLocationManagerType) {
    CMPLocationManagerTypeAuto = 0,
    CMPLocationManagerTypeGaode   = 1,
    CMPLocationManagerTypeGoogle  = 2
};

NS_ASSUME_NONNULL_BEGIN

/**
 *  @brief AMapLocatingCompletionBlock  定位返回Block
 *  @param location 定位信息
 *  @param regeocode 逆地理信息
 *  @param locationError 定位错误信息，参考 CLError
 *  @param searchError 搜索请求错误信息
 *  @param locationResultError 单次定位错误信息，参考 AMapLocationErrorCode
 */
typedef void (^CMPLocationCompletionBlock)(NSString *  _Nullable provider,AMapGeoPoint *  _Nullable location, AMapReGeocode *  _Nullable regeocode, NSError * _Nullable locationError, NSError * _Nullable searchError ,  NSError * _Nullable locationResultError);

typedef void(^CMPLastingLocationCallbackBlock)(AMapGeoPoint * _Nullable location,AMapReGeocode *_Nullable reGeocode);

@class CMPLoginConfigMapKey;
@interface CMPLocationManager : NSObject

@property (nonatomic, strong) CMPLoginConfigMapKey *mapKey;
@property (nonatomic, assign) CMPLocationManagerType locationManagerType;

+ (instancetype)shareLocationManager;

+ (instancetype)locationManager;

/**
 本地总定位服务是否开启
 */
- (BOOL)locationServiceEnable;

/**
 开启轮询定位
 */
//- (void)startPollingSingleLocation;

/**
 开启定位
 */
- (void)startUpdatingLocation;

/**
 停止定位
 */
- (void)stopUpdatingLocation;

/**
 停止连续定位并停止返回数据
 */
- (void)stopAndCleanUpdatingLocation;

///**
// 开启连续定位
// */
//- (void)startLastingLocationCallBack:(CMPLastingLocationCallbackBlock)lastingLocationCallback;
//
///**
// 停止定位
// */
//- (void)stopLastingLocation;

/**
 获取单次定位结果

 @param completionBlock 单次定位返回Block
 */
- (void)getSingleLocationWithCompletionBlock:(CMPLocationCompletionBlock)completionBlock;

/**
 获取连续定位结果
 
 @param completionBlock 连续定位返回Block
 */
- (void)getUpdatingLocationWithCompletionBlock:(CMPLocationCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
