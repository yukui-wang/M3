//
//  XZSchedule.m
//  M3
//
//  Created by wujiansheng on 2018/9/7.
//

#import "XZScheduleMsgView.h"
#import "XZScheduleMsg.h"
#import "XZScheduleMsgItem.h"
#import "XZMsgCellHeaderView.h"
#import "XZBaseMsgData.h"
#import "XZBaseMsgDataCell.h"
#import "XZTransWebViewController.h"
#import "SPTools.h"
#import "XZOpenM3AppHelper.h"

@implementation XZScheduleMsgView

- (void)dealloc {
    SY_RELEASE_SAFELY(_tableView);
    [super dealloc];
}

- (id)initWithMsg:(XZScheduleMsg *)msg {
    if (self = [super initWithMsg:msg]) {
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return self;
}

- (void)setup {
    [super setup];
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.bounces = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        [self addSubview:_tableView];
    }
}

- (void)customLayoutSubviews {
    [super customLayoutSubviews];
    [_tableView setFrame:CGRectMake(0, 55, self.width, self.height-55)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    XZScheduleMsg *msg = (XZScheduleMsg *) self.msg;
    return msg.datalist.count;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    XZScheduleMsg *msg = (XZScheduleMsg *)self.msg;
    XZScheduleMsgItem *item = [msg.datalist objectAtIndex:section];
    return item.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [XZMsgCellHeaderView cellHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    XZScheduleMsg *msg = (XZScheduleMsg *)  self.msg;
    XZScheduleMsgItem *item = nil;
    if (section < msg.datalist.count) {
        item = [msg.datalist objectAtIndex:section];
    }
    XZMsgCellHeaderView *view = [[[XZMsgCellHeaderView alloc]initWithMsg:item] autorelease];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 16;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.width, 16)];
    view.backgroundColor = [UIColor whiteColor];
    return [view autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    XZScheduleMsg *msg = (XZScheduleMsg *)self.msg;
    if (section < msg.datalist.count) {
        XZScheduleMsgItem *item = [msg.datalist objectAtIndex:section];
        if (row < item.items.count) {
            XZBaseMsgData *data = [item.items objectAtIndex:row];
            NSInteger height = [data cellHeightForWidth:_tableView.width-55];
            return height;
        }
    }
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    XZScheduleMsg *msg = (XZScheduleMsg *)self.msg;
    if (section < msg.datalist.count) {
        XZScheduleMsgItem *item = [msg.datalist objectAtIndex:section];
        if (row < item.items.count) {
            XZBaseMsgData *data = [item.items objectAtIndex:row];
            NSString *className = data.cellClass;
            NSString *cellIdentifier = data.ideltifier;
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[[NSClassFromString(className) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
            }
            if (section < msg.datalist.count) {
                XZScheduleMsgItem *item = [msg.datalist objectAtIndex:section];
                if (row < item.items.count) {
                    XZBaseMsgData *data = [item.items objectAtIndex:row];
                    ((XZBaseMsgDataCell *)cell).msgData = data;
                }
            }
            return cell;
        }
    }

    NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    XZScheduleMsg *msg = (XZScheduleMsg *)self.msg;
    if (section < msg.datalist.count) {
        XZScheduleMsgItem *item = [msg.datalist objectAtIndex:section];
        if (row < item.items.count) {
            if (self.willOpenViewBlock) {
                self.willOpenViewBlock();
            }
            XZBaseMsgData *data = [item.items objectAtIndex:row];
            if (data.gotoParams[@"openApi"]) {
                //新的c打开方式 参数： {"openApi":"openApp","appId":"11","params":{"linkType":"message.link.cal.view","id":"-1622357995509889437"}}
                [XZOpenM3AppHelper openH5AppWithParams:data.gotoParams url:nil inController:[SPTools currentViewController]];
            }
            else {
                XZTransWebViewController *vc = [[XZTransWebViewController alloc] init];
                vc.hideBannerNavBar = NO;
                vc.loadUrl = data.gotoUrl;
                vc.gotoParams = data.gotoParams;
                [[SPTools currentViewController] presentViewController:vc animated:YES completion:^{
                }];
                SY_RELEASE_SAFELY(vc);
            }
        }
    }
    //去掉选中状态
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
}


@end
