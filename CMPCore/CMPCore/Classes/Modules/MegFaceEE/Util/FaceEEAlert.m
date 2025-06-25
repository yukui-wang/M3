//
//  FaceEEAlert.m
//  MegFaceEEDemo
//
//  Created by Megvii on 2023/2/24.
//

#import "FaceEEAlert.h"

@implementation FaceEEAlert

+ (void)alertWithViewController:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message cancelText:(NSString *)cancelTex confirmText:(NSString *)confirmText needCancle:(BOOL)needCancle cancelHandler:(FaceEEAlertHandler)cancelHandler confirmHandler:(FaceEEAlertHandler)confirmHandler {
    UIAlertController* alertC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    if (needCancle) {
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:cancelTex style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            cancelHandler(action);
        }];
        [alertC addAction:cancelAction];
    }
    UIAlertAction* sureAction = [UIAlertAction actionWithTitle:confirmText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        confirmHandler(action);
    }];
    [alertC addAction:sureAction];
    
    NSMutableParagraphStyle *paragraphStype = [[NSMutableParagraphStyle alloc] init];
    paragraphStype.alignment = NSTextAlignmentCenter;
    paragraphStype.lineSpacing = 0;
    NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStype, NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:14]};
    NSAttributedString *attributeStr = [[NSAttributedString alloc]initWithString:message attributes:attributes];
    [alertC setValue:attributeStr forKey:@"attributedMessage"];
    [viewController presentViewController:alertC animated:YES completion:nil];
}

@end
