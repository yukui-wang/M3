//
//  CMPGestureHelper.h
//  CMPCore
//
//  Created by Kaku_Songu on 17/2/15.
//
//

#import <Foundation/Foundation.h>


typedef enum : NSUInteger {
    FROM_INIT=10,//设置手势
    FROM_RESET,
    FROM_VERIFY,//校验
    FROM_BACKGROUND//后台
} GESTURE_FROM;

typedef enum : NSUInteger {
    TYPE_FORGET = 22,
    TYPE_OTHER,
    TYPE_NORMAL,
    TYPE_SET,
    TYPE_RETURN,
    TYPE_PWDWRONG
} GESTURE_TYPE;

@class CMPGestureHelper;
@class CMPGestureView;

@protocol CMPGestureHelperDelegate <NSObject>
@required
- (void)gestureHelperDidFail:(CMPGestureHelper *)aHelper;
- (void)gestureHelperSkip:(CMPGestureHelper *)aHelper;
- (void)gestureHelperReturn:(CMPGestureHelper *)aHelper;

- (void)gestureHelper:(CMPGestureHelper *)aHelper didSetPassword:(NSString *)password;
- (void)gestureHelperDidGetCorrectPswd:(CMPGestureHelper *)aHelper;
- (void)gestureHelperDidGetIncorrectPswd:(CMPGestureHelper*)aHelper;
- (void)gestureHelperForgetPswd:(CMPGestureHelper *)aHelper inputPassword:(NSString *)password;
- (void)gestureHelperOtherVerify:(CMPGestureHelper *)aHelper;

@end


@interface CMPGestureHelper : NSObject

@property(nonatomic, readonly)CMPGestureView *currentGestureView;
@property(nonatomic,assign,setter=setGesSwitchState:,getter=getGesSwitchState) BOOL gesSwitchState;//手势密码开关
@property(nonatomic,assign) BOOL autoClose; //是否自动关闭
@property(nonatomic,copy,setter=setGesturePwd:,getter=getGesturePwd)NSString *gesturePwd;//用户设置的手势密码，关闭开关是，不要滞空
@property(nonatomic,retain) NSDate *beginTime;//进入后台的时间
@property(nonatomic,assign,getter=getLoginState)BOOL loginState;//用户登录状态
@property(nonatomic,assign)GESTURE_FROM from;
@property(nonatomic,weak)id<CMPGestureHelperDelegate>delegate;
@property(nonatomic,strong,readonly)id transParams;

+ (instancetype)shareInstance;
- (void)showGestureViewWithDelegate:(id<CMPGestureHelperDelegate>)aDelegate from:(GESTURE_FROM)from object:(NSDictionary *)object ext:(__nullable id)ext;
- (void)closeGestureViewWithType:(GESTURE_TYPE)aType;
- (void)hideGestureView;

@end
