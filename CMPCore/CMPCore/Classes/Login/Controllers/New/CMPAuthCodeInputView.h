//
//  CMPAuthCodeInputView.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/9/19.
//

#import <CMPLib/CMPBaseView.h>

NS_ASSUME_NONNULL_BEGIN

@class AuthCodeTextField;

@protocol AuthCodeDeleteDelegate <NSObject>

-(void)authCodeTextFieldDeleteBackward:(AuthCodeTextField *)textField;

@end

@interface AuthCodeTextField : UITextField

@property (nonatomic,weak) id <AuthCodeDeleteDelegate>auth_delegate;

@end



typedef void (^AuthCodeInputViewBlock)(BOOL success);

@interface CMPAuthCodeInputView :CMPBaseView

@property (nonatomic,copy) void(^fetchSmsAction)(void);
@property (nonatomic,copy) void(^smsCodeChangeAction)(NSString *code, BOOL complete);

-(instancetype)initWithFrame:(CGRect)frame
                    andPhone:(NSString *)phone
                   autoFetch:(BOOL)autoFetch;
- (void)fireCountdonwTimer:(NSInteger)count;
-(void)clearCodes;
@property (nonatomic,copy) AuthCodeInputViewBlock authSuccess;

@end


NS_ASSUME_NONNULL_END
