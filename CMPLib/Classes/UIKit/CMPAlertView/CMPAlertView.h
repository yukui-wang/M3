//
//  CMPAlertView.h
//  CMPCore
//
//  Created by Kaku_Songu on 17/2/21.
//
//

#import <UIKit/UIKit.h>

typedef void(^ClickedButtonBlock)(NSInteger buttonIndex);

@interface CMPAlertViewController : UIAlertController

+(instancetype)alertControllerWithTitle:(NSString *)title
                                   html:(NSString *)html
                         preferredStyle:(UIAlertControllerStyle)preferredStyle
                                actions:(NSArray *)actions;

@end

@interface CMPAlertView : UIAlertView

@property (nonatomic, copy) ClickedButtonBlock clickedButtonBlock;

+(void)dismissAll;

-(instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles callback:(ClickedButtonBlock)callback;

@end


@interface CMPAlertViewRecorder : NSObject

@property (nonatomic, strong)NSMutableArray * alertViewArray;

+ (CMPAlertViewRecorder *)shareInstance;

@end
