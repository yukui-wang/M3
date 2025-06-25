//
//  CMPServerEditView.h
//  M3
//
//  Created by CRMO on 2017/10/30.
//

#import <UIKit/UIKit.h>


@interface CMPServerEditNewView : UIView

@property (nonatomic, copy) void(^saveAction)(NSString *host, NSString *port, NSString *note);
@property (nonatomic, copy) void(^deleteAction)(void);
@property (nonatomic, assign) BOOL canDelete;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSString *port;
@property (nonatomic, strong) NSString *note;

@property (nonatomic, strong) UITextField *hostView;
@property (nonatomic, strong) UITextField *portView;
@property (nonatomic, strong) UITextField *noteView;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *deleteButton;

@property (nonatomic, assign, readonly) CGFloat landscapeKeyBoradMargin;
@property (nonatomic, assign) BOOL contentChanged;
@property (nonatomic, assign) BOOL valInitedDone;

- (void)dismissKeybord;
//- (void)showScanButtonWithAction:(void(^)(void))action;
-(BOOL)registerContentChangedAction;

@end
