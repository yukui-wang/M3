//
//  CMPMSMLoginView.h
//  M3
//
//  Created by zy on 2022/2/14.
//

#import "CMPBaseLoginView.h"
#import "CMPLoginTextField.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMPSMSLoginView : CMPBaseLoginView

@property (nonatomic, retain) CMPLoginTextField *phoneTextField;
@property (nonatomic, retain) CMPLoginTextField *smsCodeField;

// 区号
@property (nonatomic, copy) NSString *areaCode;
// 手机号
@property (nonatomic, copy) NSString *phoneNumber;
// 手机号
@property (nonatomic, copy) NSString *smsCode;

- (CGFloat)viewHeight;

- (BOOL)isValidPhoneNumber;

@end

NS_ASSUME_NONNULL_END
