//
//  SYLocationManager.h
//  M1Core
//
//  Created by Aries on 14-3-7.
//
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@protocol SyLocationManagerDelegate;

@interface SyLocationManager : NSObject
{
    
}
@property (nonatomic, assign) id <SyLocationManagerDelegate>delegate;
@property (nonatomic, assign) float gpsRefreshRate;
@property (nonatomic, readonly) BOOL locationServiceEnable;
- (void)checkThisAppLocationServiceEnable;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
- (void)cancelUpdatingLocation;
@end

@protocol SyLocationManagerDelegate <NSObject>

- (void)locationManager:(SyLocationManager *)manager didUpdateLocation:(CLLocation *)location;
- (void)locationManager:(SyLocationManager *)manager didFailWithError:(NSError *)error;
- (void)locationManager:(SyLocationManager *)manager thisAppLocationServiceEnable:(BOOL)isEnable errorCode:(CLError) errCode;
@end