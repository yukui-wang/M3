//
//  CMPAssociateAccountView.h
//  M3
//
//  Created by CRMO on 2018/6/7.
//

#import <UIKit/UIKit.h>
#import "CMPLoginViewTextField.h"

@interface CMPAssociateAccountEditView : UIView

@property (nonatomic, copy) void(^deleteAction)(void);
@property (nonatomic, copy) void(^saveAction)(NSString *host, NSString *port, NSString *note, NSString *username, NSString *password);

@property (strong, nonatomic) UITextField *hostView;
@property (strong, nonatomic) UITextField *portView;
@property (strong, nonatomic) UITextField *usernameView;
@property (strong, nonatomic) CMPLoginViewTextField *passwordView;
@property (strong, nonatomic) UITextField *noteView;
@property (nonatomic, strong) UIButton *saveButton;
@property (strong, nonatomic) UIButton *deleteButton;
@property (nonatomic, assign) BOOL contentChanged;
- (void)dismissKeybord;
- (void)showScanButtonWithAction:(void(^)(void))action;
-(BOOL)registerContentChangedAction;
@end
