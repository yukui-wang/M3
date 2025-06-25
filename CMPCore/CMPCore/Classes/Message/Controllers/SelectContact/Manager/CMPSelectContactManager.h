//
//  CMPSelectContactManager.h
//  M3
//
//  Created by Shoujian Rao on 2023/9/5.
//

#import <Foundation/Foundation.h>
#import "CMPSelectContactViewController.h"
#import "CMPMessageMultipleForwardView.h"
#define kNotificationName_SelectContactChanged @"kNotificationName_SelectContactChanged"


@interface CMPSelectContactManager : NSObject
+ (instancetype)sharedInstance;
@property(nonatomic,weak) UIViewController *vc;
@property(nonatomic,strong) CMPMessageMultipleForwardView *sendView;
@property (strong, nonatomic) NSMutableDictionary *selectedContact;
@property (strong, nonatomic) NSMutableArray *selectedCidArr;
- (BOOL)addSelectContact:(NSString *)cid name:(NSString *)name type:(NSInteger)type subType:(NSInteger)subType;
- (void)delSelectContact:(NSString *)cid;
- (void)showForwardView:(NSArray *)targetArr toView:(UIView *)view inVC:(UIViewController *)VC;

@property(nonatomic, retain) RCMessageModel *msgModel;
@property(nonatomic, copy) NSString *targetId;//聊天界面传,当前会话ID
@property (nonatomic, assign) CMPForwardSourceType forwardSource;
@property(nonatomic, strong) NSArray<RCMessageModel *> *selectedMessages;

@end

