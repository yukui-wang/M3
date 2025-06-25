//
//  FaceEEAlert.h
//  MegFaceEEDemo
//
//  Created by Megvii on 2023/2/24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^FaceEEAlertHandler)(UIAlertAction * action);

@interface FaceEEAlert : NSObject

+ (void)alertWithViewController:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message cancelText:(NSString *)cancelTex confirmText:(NSString *)confirmText needCancle:(BOOL)needCancle cancelHandler:(FaceEEAlertHandler _Nullable)cancelHandler confirmHandler:(FaceEEAlertHandler)confirmHandler;

@end

NS_ASSUME_NONNULL_END
