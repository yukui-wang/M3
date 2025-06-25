//
//  RCSelectConversationViewController.m
//  RongCallKit
//
//  Created by 岑裕 on 16/3/12.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCSelectConversationViewController.h"
#import "RCKitUtility.h"
#import "RCSelectConversationCell.h"
#import "RCKitCommonDefine.h"
#import "RCCombineMessageUtility.h"
#import "RCIM.h"

typedef void (^CompleteBlock)(NSArray *conversationList);

@interface RCSelectConversationViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *selectedConversationArray;

@property (nonatomic, strong) UITableView *conversationTableView;

@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;

@property (nonatomic, strong) NSArray *listingConversationArray;

@property (nonatomic, strong) CompleteBlock completeBlock;

@end

@implementation RCSelectConversationViewController

- (instancetype)initSelectConversationViewControllerCompleted:
    (void (^)(NSArray<RCConversation *> *conversationList))completedBlock {
    if (self = [super init]) {
        self.completeBlock = completedBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavi];
    self.view.backgroundColor = RCDYCOLOR(0xf0f0f6, 0x000000);
    [self.view addSubview:self.conversationTableView];
    self.selectedConversationArray = [[NSMutableArray alloc] init];
    self.listingConversationArray =
        [[RCIMClient sharedRCIMClient] getConversationList:@[ @(ConversationType_PRIVATE), @(ConversationType_GROUP) ]];
}

- (void)setupNavi {
    self.title = NSLocalizedStringFromTable(@"SelectContact", @"RongCloudKit", nil);
    UIBarButtonItem *leftBarItem =
        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Cancel", @"RongCloudKit", nil)
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(onLeftButtonClick:)];
    leftBarItem.tintColor = [RCIM sharedRCIM].globalNavigationBarTintColor;
    self.navigationItem.leftBarButtonItem = leftBarItem;

    self.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(onRightButtonClick:)];
    self.rightBarButtonItem.tintColor = [RCIM sharedRCIM].globalNavigationBarTintColor;
    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;

    [self updateRightButton];
}

- (void)onLeftButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)onRightButtonClick:(id)sender {
    if (!self.selectedConversationArray) {
        return;
    }
    if (self.completeBlock) {
        self.completeBlock(self.selectedConversationArray);
    }
    [self.navigationController popViewControllerAnimated:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.listingConversationArray) {
        return 0;
    } else {
        return self.listingConversationArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.listingConversationArray.count <= indexPath.row) {
        return nil;
    }

    static NSString *reusableID = @"RCSelectConversationCell";
    RCSelectConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableID];
    if (!cell) {
        cell = [[RCSelectConversationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableID];
    }

    RCConversation *conversation = self.listingConversationArray[indexPath.row];
    BOOL ifSelected = [self.selectedConversationArray containsObject:conversation];
    [cell setConversation:conversation ifSelected:ifSelected];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.listingConversationArray.count) {
        return;
    }
    NSString *userId = self.listingConversationArray[indexPath.row];
    if ([self.selectedConversationArray containsObject:userId]) {
        [self.selectedConversationArray removeObject:userId];
    } else if (userId) {
        [self.selectedConversationArray addObject:userId];
    }
    [self updateRightButton];
    [UIView performWithoutAnimation:^{
        [self.conversationTableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)updateRightButton {
    [self.rightBarButtonItem setEnabled:self.selectedConversationArray.count > 0];
}

- (UITableView *)conversationTableView {
    if (!_conversationTableView) {
        _conversationTableView = [[UITableView alloc] init];
        CGFloat navBarHeight = 64;
        CGFloat homeBarHeight = [RCKitUtility getWindowSafeAreaInsets].bottom;
        if (homeBarHeight > 0) {
            navBarHeight = 88;
        }
        _conversationTableView.frame =
            CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - navBarHeight - homeBarHeight);
        _conversationTableView.dataSource = self;
        _conversationTableView.delegate = self;
        _conversationTableView.backgroundColor = [UIColor clearColor];
        _conversationTableView.tableFooterView = [[UIView alloc] init];
    }
    return _conversationTableView;
}

@end
