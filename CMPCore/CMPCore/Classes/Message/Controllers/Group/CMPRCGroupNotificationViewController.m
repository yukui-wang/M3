//
//  CMPRCGroupNotificationViewController.m
//  CMPCore
//
//  Created by CRMO on 2017/8/7.
//
//

#import "CMPRCGroupNotificationViewController.h"
#import "CMPRCGroupNotificationView.h"
#import "CMPRCGroupNotificationCell.h"
#import "CMPChatManager.h"
#import "CMPRCGroupNotificationManager.h"
#import <CMPLib/CMPConstant.h>
#import "CMPRCGroupNotificationObject.h"
#import <CMPLib/UIColor+Hex.h>
#import "CMPMessageManager.h"
#import "CMPReadedMessage.h"
#import <CMPLib/CMPDateHelper.h>

@interface CMPRCGroupNotificationViewController ()<UITableViewDelegate, UITableViewDataSource>{
    CMPRCGroupNotificationManager *_dataManager;
    CMPRCGroupNotificationView *_listView;
}

@property (nonatomic, retain) NSMutableArray *dataList; // 数据源


@end

@implementation CMPRCGroupNotificationViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_dataList removeAllObjects];
    SY_RELEASE_SAFELY(_dataList);
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:SY_STRING(@"msg_groupNotification")];
    if (CMPFeatureSupportControl.isBannarBackButtonShowText) {
        [self setBackButton];
    }
//    [self addRightButton];
    
    _listView = (CMPRCGroupNotificationView *)self.mainView;
    _listView.tableView.dataSource = self;
    _listView.tableView.delegate = self;
    
    _dataManager = [CMPChatManager sharedManager].groupNotificationManager;
    
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] init];
    }
    
    [self loadData];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadData) name:kNotificationName_MessageUpdate object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self sendReadedMessage];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self sendReadedMessage];
}

- (void)loadData {
    __weak CMPRCGroupNotificationView *listView = _listView;
    __weak NSMutableArray *datalist = _dataList;
    __weak CMPRCGroupNotificationViewController *weakself = self;
    [_dataManager getNotificationList:^(NSArray *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            listView.tableView.userInteractionEnabled = NO;
            [datalist removeAllObjects];
            [datalist addObjectsFromArray:result];
            [listView.tableView reloadData];
            [listView.tableView layoutIfNeeded];
            [weakself scrollToBottom];
            [listView showNothingView: result.count == 0];
            listView.tableView.userInteractionEnabled = YES;
            
//            if (datalist.count == 0) {
//                [self addRightButton:NO];
//            } else {
                [self addRightButton:YES];
//            }
        });
    }];
}

- (void)clearMessage {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:SY_STRING(@"common_confirm")
                                                                   message:SY_STRING(@"msg_clearGroupNotification")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:SY_STRING(@"common_cancel")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:SY_STRING(@"common_ok")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        [[CMPChatManager sharedManager] clearRCGroupNotification];
        [self loadData];
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -
#pragma mark -UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (row < _dataList.count) {
        CMPRCGroupNotificationObject *object = _dataList[row];
        CGFloat height = [CMPRCGroupNotificationCell getCellHeight:object width:self.view.width];
        if (row == _dataList.count-1) {
            height += 10;// 最后一个cell与底部留一点间距
        }
        return height;
    }
    return 10;
}


#pragma mark -
#pragma mark -UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"CMPRCGroupNotificationCellIdentifier";
    CMPRCGroupNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[CMPRCGroupNotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    NSInteger row = indexPath.row;
    if (row < _dataList.count) {
        [cell setupWithObject:_dataList[row]];
    }
    return cell;
}

#pragma mark -
#pragma mark -UI

- (void)setBackButton {
    UIButton *button = [[self.bannerNavigationBar leftBarButtonItems] lastObject];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(14, 6, 14, 10)];
    NSDictionary *attributeDic = @{NSFontAttributeName: [UIFont systemFontOfSize:16],
                                   NSForegroundColorAttributeName : [CMPThemeManager sharedManager].iconColor};
    NSAttributedString *buttonTitle = [[NSAttributedString alloc] initWithString:SY_STRING(@"msg_msgTitle")
                                                                      attributes:attributeDic];
    [button setAttributedTitle:buttonTitle forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 90, 44);
    [buttonTitle release];
    buttonTitle = nil;
}

- (void)addRightButton:(BOOL)isShow {
    self.bannerNavigationBar.rightViewsMargin = 0.0f;
    self.bannerNavigationBar.rightMargin = 0.0f;
    UIButton *clearButton = [UIButton buttonWithImageName:@"msg_clear" frame:kBannerImageButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
    [clearButton addTarget:self action:@selector(clearMessage) forControlEvents:UIControlEventTouchUpInside];
    if (isShow) {
        [self.bannerNavigationBar setRightBarButtonItems: [NSArray arrayWithObjects:clearButton, nil]];
    } else {
        [self.bannerNavigationBar setRightBarButtonItems: nil];
    }
    
}

- (void)scrollToBottom {
//    CGFloat yOffset = 0; //设置要滚动的位置 0最顶部 CGFLOAT_MAX最底部
    UITableView *tableView = _listView.tableView;
//    if (tableView.contentSize.height > tableView.bounds.size.height) {
//        yOffset = tableView.contentSize.height - tableView.bounds.size.height;
//    }
//    [tableView setContentOffset:CGPointMake(0, yOffset) animated:NO];
    //ks fix --- V5-14625 【1130上架-iOS14】致信群系统消息没有定位到最下方
    if (_dataList.count>0) {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_dataList.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

/**
 多端消息阅读状态同步，点击消息，发送自定义消息类型CMPReadedMessage，其它端接收到标记该消息为已读。
 */
- (void)sendReadedMessage {
    [[CMPChatManager sharedManager].groupNotificationManager getLatestNotification:^(CMPRCGroupNotificationObject *object) {
        NSDate *date = [CMPDateHelper dateFromStr:object.receiveTime dateFormat:@"yyyy-MM-dd HH:mm:ss"];
        long long timestamp = [date timeIntervalSince1970];
        CMPReadedMessage *message = [[CMPReadedMessage alloc] init];
        NSDictionary *extraDic = @{@"itemId" : kRCGroupNotificationTargetID,
                                   @"conversationType" : @"-1",
                                   @"timestamp" : [NSString stringWithFormat:@"%lld", timestamp * 1000]};
        message.extra = [extraDic JSONRepresentation];

        [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:[CMPCore sharedInstance].userID content:message pushContent:nil pushData:nil success:^(long messageId) {
            
        } error:^(RCErrorCode nErrorCode, long messageId) {
            NSLog(@"RC---发送CMPReadedMessage失败nErrorCode=%ld", nErrorCode);
        }];
        
        [message release];
        message = nil;
    }];
}



@end
