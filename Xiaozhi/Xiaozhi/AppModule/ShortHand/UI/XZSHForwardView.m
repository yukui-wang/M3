//
//  XZSHForwardView.m
//  M3
//
//  Created by wujiansheng on 2019/1/9.
//

#import "XZSHForwardView.h"
#import "XZCore.h"

#import "BNlpManager.h"
#import "XZTransWebViewController.h"
#import "XZShortHandParam.h"
#import "CMPContactsManager.h"

@interface XZSHForwardView () {
    UIView *_mainView;
}
@property(nonatomic, retain)UIButton *forwardCollBtn;
@property(nonatomic, retain)UIButton *forwardTaskBtn;
@property(nonatomic, retain)UIButton *forwardCalendarBtn;
@property(nonatomic, retain)UIButton *forwardMeetingBtn;
@property(nonatomic, retain)UIButton *forwardMsgBtn;
@property(nonatomic, retain)UIButton *closeBtn;
@property(nonatomic, retain)XZShortHandObj *data;

@property(nonatomic, assign)UIViewController *pushController;

@end


@implementation XZSHForwardView

- (void)dealloc {
    self.forwardDataBlock = nil;
    self.forwardCollBtn = nil;
    self.forwardTaskBtn = nil;
    self.forwardCalendarBtn = nil;
    self.forwardMeetingBtn = nil;
    self.forwardMsgBtn = nil;
    self.closeBtn = nil;
    [super dealloc];
}

+ (BOOL)canShortHandleForward {
    //语音速记是否有权限转发
    if ([[[XZCore sharedInstance] privilege] hasColNewAuth]) {
        return YES;
    }
    if ([[[XZCore sharedInstance] privilege] hasTaskAuth]) {
        return YES;
    }
    if ([[[XZCore sharedInstance] privilege] hasCalEventAuth]) {
        return YES;
    }
    if ([[[XZCore sharedInstance] privilege] hasMeetingAuth]) {
        return YES;
    }
    if ([[[XZCore sharedInstance] privilege] hasZhixinAuth]) {
        return YES;
    }
    return NO;
}

- (UIButton *)buttonWithTitle:(NSString *)title selector:(SEL)sel {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor blueColor]];
    [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)setup {
    
    if (!_mainView) {
        _mainView = [[UIView alloc] init];
        _mainView.backgroundColor =[UIColor whiteColor];
        [self addSubview:_mainView];
    }
    if (!self.forwardCollBtn && [[[XZCore sharedInstance] privilege] hasColNewAuth]) {
        self.forwardCollBtn = [self buttonWithTitle:@"coll"
                                           selector:@selector(forwardCollAction)];
        [_mainView addSubview:self.forwardCollBtn];
    }
    if (!self.forwardTaskBtn && [[[XZCore sharedInstance] privilege] hasTaskAuth]) {
        self.forwardTaskBtn = [self buttonWithTitle:@"task"
                                           selector:@selector(forwardTaskAction)];
        [_mainView addSubview:self.forwardTaskBtn];
    }
    if (!self.forwardCalendarBtn && [[[XZCore sharedInstance] privilege] hasCalEventAuth]) {
        self.forwardCalendarBtn = [self buttonWithTitle:@"calendar"
                                               selector:@selector(forwardCalendarAction)];
        [_mainView addSubview:self.forwardCalendarBtn];
    }
    if (!self.forwardMeetingBtn && [[[XZCore sharedInstance] privilege] hasMeetingAuth]) {
        self.forwardMeetingBtn = [self buttonWithTitle:@"meeting"
                                              selector:@selector(forwardMeetingAction)];
        [_mainView addSubview:self.forwardMeetingBtn];
    }
    if (!self.forwardMsgBtn && [[[XZCore sharedInstance] privilege] hasZhixinAuth]) {
        self.forwardMsgBtn = [self buttonWithTitle:@"msg"
                                          selector:@selector(forwardMsgAction)];
        [_mainView addSubview:self.forwardMsgBtn];
    }
    if (!self.closeBtn) {
        self.closeBtn = [self buttonWithTitle:@"close"
                                     selector:@selector(closeForwardView)];
        [_mainView addSubview:self.closeBtn];
    }
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapForwardView:)];
    [self addGestureRecognizer:tap];
    SY_RELEASE_SAFELY(tap);
}

- (void)customLayoutSubviews {
    
    
    [_mainView setFrame:CGRectMake(0, self.height-150, self.width, 150)];
    
    CGFloat width = 60;
    CGFloat height = 30;
    NSInteger marg = (self.width -width *5)/6;
    CGFloat x = marg;
    CGFloat y = 20;
    if (self.forwardCollBtn) {
        [self.forwardCollBtn setFrame:CGRectMake(x, y, width, height)];
        x += width+marg;
    }
    if (self.forwardTaskBtn) {
        [self.forwardTaskBtn setFrame:CGRectMake(x, y, width, height)];
        x += width+marg;
    }
    if (self.forwardCalendarBtn) {
        [self.forwardCalendarBtn setFrame:CGRectMake(x, y, width, height)];
        x += width+marg;
    }
    if (self.forwardMeetingBtn) {
        [self.forwardMeetingBtn setFrame:CGRectMake(x, y, width, height)];
        x += width+marg;
    }
    if (self.forwardMsgBtn) {
        [self.forwardMsgBtn setFrame:CGRectMake(x, y, width, height)];
        x += width+marg;
    }
    [self.closeBtn setFrame:CGRectMake(self.width/2-width/2, _mainView.height-height-20, width, height)];
}

- (void)forwardCollAction {
    self.forwardCollBtn.userInteractionEnabled = NO;
    __weak typeof(self) weakSelf = self;
    NSArray *keyArray = [NSArray arrayWithObjects:@"PER", nil];
    [[BNlpManager sharedInstance]requestAnalysisText:self.data.content keyArray:keyArray completion:^(NSDictionary *resultDic, NSError *error) {
        NSArray *memberNames = resultDic[@"PER"];
        if (memberNames.count >0) {
            [[CMPContactsManager defaultManager] memberListForNameArray:memberNames tbName:kFlowTempTable completion:^(NSArray *resultArray) {
                if (resultArray.count > 0) {
                    NSMutableString *idStr = [NSMutableString string];
                    for (CMPOfflineContactMember *member in resultArray) {
                        if (idStr.length > 0) {
                            [idStr appendFormat:@","];
                        }
                        [idStr appendString:member.orgID];
                    }
                    [weakSelf forwardCollWithIds:idStr];
                }
                else {
                    [weakSelf forwardCollWithIds:nil];
                }
            }];
        }
        else {
            [weakSelf forwardCollWithIds:nil];
        }
    }];
}

- (void)forwardCollWithIds:(NSString *)ids {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf forwardCollWithIdsInMainQueue:ids];
    });
}

- (void)forwardCollWithIdsInMainQueue:(NSString *)ids{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.data.title forKey:@"subject"];
    [dic setObject:self.data.content forKey:@"content"];
    if (![NSString isNull:ids]) {
        [dic setObject:ids forKey:@"members"];
    }
    [dic setObject:[NSString stringWithLongLong:self.data.shId]  forKey:@"relationId"];
    [dic setObject:@"1" forKey:@"appId"];
    [dic setObject:@"shorthand" forKey:@"forwardType"];
    [dic setObject:@"newCollaboration" forKey:@"openFrom"];
    XZTransWebViewController *webviewController = [[XZTransWebViewController alloc] init];
    webviewController.loadUrl = kXZTransferUrl;
    webviewController.gotoParams = dic;
    webviewController.hideBannerNavBar = NO;
    [self.pushController.navigationController pushViewController:webviewController animated:YES];
    self.forwardCollBtn.userInteractionEnabled = YES;
    [self closeForwardView];
}

- (void)forwardTaskAction {
    self.forwardTaskBtn.userInteractionEnabled = NO;
    __weak typeof(self) weakSelf = self;
    NSArray *keyArray = [NSArray arrayWithObjects:@"PER",@"TIME",@"LOC",nil];
    [[BNlpManager sharedInstance]requestAnalysisText:self.data.content keyArray:keyArray completion:^(NSDictionary *result, NSError *error) {
        
        long long startDate = 0;
        long long endDate = 0;
        NSDictionary *member = [NSDictionary dictionaryWithObjectsAndKeys:@"-6908732828084843480",@"id",@"吴杰",@"name",@"Member",@"type", nil];
        NSArray *members = [NSArray arrayWithObject:member];

        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:weakSelf.data.title forKey:@"subject"];
        [dic setObject:weakSelf.data.content forKey:@"content"];
        if (startDate > 0) {
            [dic setObject:[NSNumber numberWithLongLong:startDate] forKey:@"startDate"];
        }
        if (endDate > 0) {
            [dic setObject:[NSNumber numberWithLongLong:endDate] forKey:@"endDate"];
        }
        if (members.count >0) {
            [dic setObject:members forKey:@"participators"];
        }
        [dic setObject:[NSString stringWithLongLong:self.data.shId]  forKey:@"relationId"];
        [dic setObject:@"30" forKey:@"appId"];
        [dic setObject:@"shorthand" forKey:@"forwardType"];

        dispatch_async(dispatch_get_main_queue(), ^{
            XZTransWebViewController *webviewController = [[XZTransWebViewController alloc] init];
            webviewController.loadUrl = kXZTransferUrl;
            webviewController.gotoParams = dic;
            webviewController.hideBannerNavBar = NO;
            [weakSelf.pushController.navigationController pushViewController:webviewController animated:YES];
            weakSelf.forwardTaskBtn.userInteractionEnabled = YES;
            
            [weakSelf closeForwardView];
            
        });
    }];
    [self closeForwardView];
}




- (void)forwardCalendarAction {
    self.forwardCalendarBtn.userInteractionEnabled = NO;
    __weak typeof(self) weakSelf = self;
    NSArray *keyArray = [NSArray arrayWithObjects:@"PER", nil];
    [[BNlpManager sharedInstance]requestAnalysisText:self.data.content keyArray:keyArray completion:^(NSDictionary *result, NSError *error) {
        
        long long startDate = 0;
        long long endDate = 0;

        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:weakSelf.data.title forKey:@"subject"];
        [dic setObject:weakSelf.data.content forKey:@"content"];
        if (startDate > 0) {
            [dic setObject:[NSNumber numberWithLongLong:startDate] forKey:@"startDate"];
        }
        if (endDate > 0) {
            [dic setObject:[NSNumber numberWithLongLong:endDate] forKey:@"endDate"];
        }
        [dic setObject:[NSString stringWithLongLong:self.data.shId]  forKey:@"relationId"];
        [dic setObject:@"11" forKey:@"appId"];
        [dic setObject:@"shorthand" forKey:@"forwardType"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            XZTransWebViewController *webviewController = [[XZTransWebViewController alloc] init];
            webviewController.loadUrl = kXZTransferUrl;
            webviewController.gotoParams = dic;
            webviewController.hideBannerNavBar = NO;
            [weakSelf.pushController.navigationController pushViewController:webviewController animated:YES];
            weakSelf.forwardTaskBtn.userInteractionEnabled = YES;
            
            [weakSelf closeForwardView];
            
        });
    }];
}

- (void)forwardMeetingAction {
    self.forwardMeetingBtn.userInteractionEnabled = NO;
    __weak typeof(self) weakSelf = self;
    NSArray *keyArray = [NSArray arrayWithObjects:@"PER",@"TIME",@"OFFISPA",@"LOC",nil];
    [[BNlpManager sharedInstance]requestAnalysisText:self.data.content keyArray:keyArray completion:^(NSDictionary *result, NSError *error) {

        long long startDate = 0;
        long long endDate = 0;
        NSDictionary *member = [NSDictionary dictionaryWithObjectsAndKeys:@"-6908732828084843480",@"id",@"吴杰",@"name",@"Member",@"type", nil];
        NSArray *members = [NSArray arrayWithObject:member];
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:weakSelf.data.title forKey:@"meetingName"];
        [dic setObject:weakSelf.data.content forKey:@"content"];
        if (startDate > 0) {
            [dic setObject:[NSNumber numberWithLongLong:startDate] forKey:@"plannedStartTime"];
        }
        if (endDate > 0) {
            [dic setObject:[NSNumber numberWithLongLong:endDate] forKey:@"plannedEndTime"];
        }
        if (members.count >0) {
            [dic setObject:members forKey:@"conferees"];
        }
        [dic setObject:[NSString stringWithLongLong:self.data.shId]  forKey:@"relationId"];
        [dic setObject:@"6" forKey:@"appId"];
        [dic setObject:@"shorthand" forKey:@"forwardType"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            XZTransWebViewController *webviewController = [[XZTransWebViewController alloc] init];
            webviewController.loadUrl = kXZTransferUrl;
            webviewController.gotoParams = dic;
            webviewController.hideBannerNavBar = NO;
            [weakSelf.pushController.navigationController pushViewController:webviewController animated:YES];
            weakSelf.forwardTaskBtn.userInteractionEnabled = YES;
            
            [weakSelf closeForwardView];
            
        });
    }];
}

- (void)forwardMsgAction {
    if (self.forwardDataBlock) {
        self.forwardDataBlock(self.data,XZSHForwardType_Msg);
    }
    [self closeForwardView];
}

- (void)closeForwardView {
    [self removeFromSuperview];
}

- (void)tapForwardView:(UITapGestureRecognizer *)tap {
    CGPoint p = [tap locationInView:self];
    if (p.y < _mainView.originY) {
        [self closeForwardView];
    }
}

+ (void)showInView:(UIView *)view pushController:(UIViewController *)vc data:(XZShortHandObj *)data{
    XZSHForwardView *forwardView = [[XZSHForwardView alloc] initWithFrame:view.bounds];
    forwardView.data = data;
    forwardView.pushController = vc;
    [view addSubview:forwardView];
    SY_RELEASE_SAFELY(forwardView);
}

@end
