//
//  KSCheckBox.h
//  MPlus
//
//  Created by Kaku_Songu on 2017/5/19.
//  Copyright © 2017年 Kaku Songu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CHECKSTATE_UNCHECK,
    CHECKSTATE_CHECKED,
    CHECKSTATE_DISABLE,
} CHECKSTATE;

typedef BOOL(^CheckPreAction)(BOOL checked);
typedef void(^CheckDoneAction)(BOOL checked);

@interface KSCheckBox : UIView

@property(nonatomic,assign) CHECKSTATE checkState;
@property(nonatomic,copy) CheckPreAction checkPreAction;//check变化之前
@property(nonatomic,copy) CheckDoneAction checkDoneAction;//check变化之后

@end
