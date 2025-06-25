//
//  CMPLoginViewTextField.h
//  M3
//
//  Created by CRMO on 2018/9/4.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CMPLoginViewTextFieldType) {
    CMPLoginViewTextFieldTypeUsername,
    CMPLoginViewTextFieldTypePassword,
    CMPLoginViewTextFieldTypePhone,
    CMPLoginViewTextFieldTypeMail,
    CMPLoginViewTextFieldTypeVerification,
    CMPLoginViewTextFieldTypeMokeyUsername
};

@class CMPLoginViewTextField;

@protocol CMPLoginViewTextFieldDelegate <NSObject>

@optional

- (BOOL)textField:(CMPLoginViewTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
- (BOOL)textFieldShouldReturn:(CMPLoginViewTextField *)textField;
- (void)textFieldDidClear:(CMPLoginViewTextField *)textField;
- (void)textFieldDidEndEditing:(CMPLoginViewTextField *)textField;

@end

@interface CMPLoginViewTextField : UITextField

@property (weak, nonatomic) id<CMPLoginViewTextFieldDelegate> textFieldDelegate;

- (instancetype)initWithFrame:(CGRect)frame
                  placeHolder:(NSString *)placeHolder
                         type:(CMPLoginViewTextFieldType)type NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithPlaceHolder:(NSString *)placeHolder
                               type:(CMPLoginViewTextFieldType)type;

@end
