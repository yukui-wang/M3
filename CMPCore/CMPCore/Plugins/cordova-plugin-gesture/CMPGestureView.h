//
//  CMPGestureView.h
//  CMPCore
//
//  Created by Kaku_Songu on 17/2/13.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    CMPGestureViewType_Set=0,//设置
    CMPGestureViewType_Verify,//验证
} CMPGestureViewType;

typedef enum : NSUInteger {
    Direction_Bottom = 1,
    Direction_Top,
    Direction_Left,
    Direction_Right,
    Direction_None
} Direction;

// Delegate
@class CMPGestureView;
@protocol CMPGestureViewDelegate <NSObject>
@required
- (void)gestureViewSkip:(CMPGestureView *)gestureView;
- (void)gestureViewReturn:(CMPGestureView *)gestureView;

- (void)gestureView:(CMPGestureView *)gestureView didSetPassword:(NSString *)password;
- (void)gestureViewDidGetCorrectPswd:(CMPGestureView *)gestureView;
- (void)gestureViewDidGetIncorrectPswd:(CMPGestureView*)gestureView;
- (void)gestureViewForgetPswd:(CMPGestureView *)gestureView inputPassword:(NSString *)password;
- (void)gestureViewOtherVerify:(CMPGestureView *)gestureView;

@end

@interface CMPGestureView : UIWindow

@property (nonatomic, copy)NSString *correctGuestureLockPaswd;
@property (nonatomic, copy)NSString *userpassword;

@property (nonatomic, assign)id<CMPGestureViewDelegate> gestureDelegate;
@property (nonatomic, assign)CMPGestureViewType viewType;
@property (nonatomic, copy)NSString *username;
@property (nonatomic, copy)NSString *imageUrl;
@property (nonatomic, assign)BOOL showLeftArrow;

-(void)loadViewsWithType:(CMPGestureViewType)type;
-(void)show;
-(void)close;
-(void)showAnimateFromDirection:(Direction)direction completion:(void(^)(void))completionBlock;
-(void)closeAnimateToDirection:(Direction)direction completion:(void(^)(void))completionBlock;
-(void)showLoading;
-(void)hideLoading;

@end

