//
//  DBGuestureLock.h
//  DBGuestureLock
//
//  Created by DeBao.Wu on 2/27/16.
//  Copyright © 2016 http://i36.Me/. All rights reserved.
//
#define kIncorrectCount_Max 5

#import <UIKit/UIKit.h>
#define DBFirstTimeSetupPassword @"Me_i36_DBGuestureLock_DBFirstSetupPswd"

@class DBGuestureLock;

// Button state
typedef NS_ENUM(NSInteger, DBButtonState) {
    DBButtonStateNormal = 0,
    DBButtonStateSelected,
    DBButtonStateIncorrect,
};

// Delegate
@protocol DBGuestureLockDelegate <NSObject>

@required
-(void)guestureLock:(DBGuestureLock *)lock didSetPassword:(NSString*)password;
-(void)guestureLock:(DBGuestureLock *)lock didGetCorrectPswd:(NSString*)password;
-(void)guestureLock:(DBGuestureLock *)lock didGetIncorrectPswd:(NSString*)password incorrectCount:(NSInteger)count;

-(void)guestureLock:(DBGuestureLock *)lock passwordAddPswd:(NSString*)password;

@optional
-(BOOL)showButtonCircleCenterPointOnState:(DBButtonState)buttonState;
-(BOOL)fillButtonCircleCenterPointOnState:(DBButtonState)buttonState;//NO for stroke, YES for fill
//-(CGFloat)radiusOfButtonCircleOnState:(DBButtonState)buttonState;
-(CGFloat)widthOfButtonCircleStrokeOnState:(DBButtonState)buttonState;
-(CGFloat)radiusOfButtonCircleCenterPointOnState:(DBButtonState)buttonState;
-(CGFloat)lineWidthOfGuestureOnState:(DBButtonState)buttonState;
-(UIColor *)colorOfButtonCircleStrokeOnState:(DBButtonState)buttonState;
-(UIColor *)colorOfButtonSmallCircleStrokeOnState:(DBButtonState)buttonState;
-(UIColor *)colorForFillingButtonCircleOnState:(DBButtonState)buttonState;
-(UIColor *)colorOfButtonCircleCenterPointOnState:(DBButtonState)buttonState;
-(UIColor *)lineColorOfGuestureOnState:(DBButtonState)buttonState;

@end

// Class
@interface DBGuestureLock : UIView

@property (nonatomic, readonly, assign)BOOL fillCenterPoint;
@property (nonatomic, readonly, assign)BOOL showCenterPoint;
@property (nonatomic, readonly, assign)CGFloat circleRadius;
@property (nonatomic, readonly, assign)CGFloat strokeWidth;
@property (nonatomic, readonly, assign)CGFloat centerPointRadius;
@property (nonatomic, readonly, strong)UIColor *fillColor;
@property (nonatomic, readonly, strong)UIColor *strokeColor;
@property (nonatomic, readonly, strong)UIColor *centerPointColor;
@property (nonatomic, readonly, strong)UIColor *smallCircleColor;
@property (nonatomic, assign)BOOL drawEnabled;//锁定了等待30s

@property (nonatomic, weak)id<DBGuestureLockDelegate> delegate;
@property (nonatomic, copy)NSString *correctGuestureLockPaswd;

// Password
+(BOOL)passwordSetupStatus;
+(void)clearGuestureLockPassword;
+(NSString *)getGuestureLockPassword;
+(instancetype)lockOnView:(UIView*)view delegate:(id<DBGuestureLockDelegate>)delegate;
@property (nonatomic, readonly, assign)BOOL isPasswordSetup;
@property (nonatomic, copy)NSString *firstTimeSetupPassword;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
