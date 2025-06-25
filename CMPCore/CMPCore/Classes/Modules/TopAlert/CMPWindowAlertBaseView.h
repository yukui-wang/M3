//
//  CMPWindowAlertBaseView.h
//  M3
//
//  Created by Kaku Songu on 12/1/22.
//

#import <CMPLib/CMPBaseView.h>
@protocol CMPWindowAlertBaseViewDelegate;

typedef NS_ENUM(NSUInteger, CMPWindowAlertBaseViewAction) {
    CMPWindowAlertBaseViewActionDismiss
};

typedef enum : NSUInteger {
    CMPDirection_Top = 1,
    CMPDirection_Bottom,
    CMPDirection_Left,
    CMPDirection_Right,
    CMPDirection_None
} CMPDirection;

NS_ASSUME_NONNULL_BEGIN

@interface CMPWindowAlertBaseView : CMPBaseView
@property (nonatomic,assign) id <CMPWindowAlertBaseViewDelegate>baseDelegate;
@property (nonatomic,assign) CGFloat defaultDismissTime;
-(CGFloat)defaultHeight;
-(CMPDirection)defaultShowDirection;
-(CMPDirection)defaultDismissDirection;

@end


@protocol CMPWindowAlertBaseViewDelegate <NSObject>

-(void)cmpWindowAlertBaseView:(CMPWindowAlertBaseView *)alertView didAct:(CMPWindowAlertBaseViewAction)action ext:(nullable id)ext;

@end

NS_ASSUME_NONNULL_END
