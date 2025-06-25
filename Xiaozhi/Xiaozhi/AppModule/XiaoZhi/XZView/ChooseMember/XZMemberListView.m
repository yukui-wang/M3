//
//  XZMemberListView.m
//  M3
//
//  Created by wujiansheng on 2017/11/13.
//

#import "XZMemberListView.h"
#import "XZMemberListCell.h"

@interface XZMemberListView() <UITableViewDelegate,UITableViewDataSource> {
    UITableView *_tableView;
    UILabel *_infoLabel;
    NSMutableArray *_dataList;
}
@end

@implementation XZMemberListView

- (void)dealloc
{
    [_tableView removeFromSuperview];
    SY_RELEASE_SAFELY(_tableView);
    [_infoLabel removeFromSuperview];
    SY_RELEASE_SAFELY(_infoLabel);
    SY_RELEASE_SAFELY(_dataList);
    [super dealloc];
}
- (void)setup {
    self.backgroundColor = [UIColor blackColor];
    self.alpha = 0.4;
}

- (void)customLayoutSubviews
{
    
}

- (void)setIsShow:(BOOL)isShow{
    _isShow = isShow;
    self.hidden = !isShow;
    _tableView.hidden = self.hidden;
    _infoLabel.hidden = self.hidden;

}

- (void)showMembers:(NSArray *)array
{
    _tableView.userInteractionEnabled = NO;
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] init];
    }
    [_dataList removeAllObjects];
    [_dataList addObjectsFromArray:array];
    
    CGRect r = self.bounds;
    r.size.width = 300;
    r.origin.x = self.width/2-150;
    if (array.count >0) {
        CGFloat y = CGRectGetMaxY(r);
        CGFloat height = 60 * (array.count >4 ? 4 : array.count);
        height = height > 233  ? 233 :height;
        height = height > y-20 ? y-20:height;
        r.origin.y = y -height-5;
        r.size.height = height;
        if (!_tableView) {
            _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
            _tableView.delegate = self;
            _tableView.dataSource = self;
            _tableView.backgroundColor = [UIColor whiteColor];
            _tableView.layer.cornerRadius = 12;
            _tableView.layer.masksToBounds = YES;
            _tableView.layer.shadowColor = UIColorFromRGB(0x006ff1).CGColor;// 阴影的颜色
            _tableView.layer.shadowOffset = CGSizeMake(4, 2);// 阴影的范围
            _tableView.alpha = 1;
            [self.superview addSubview:_tableView];//防止半透明
        }
        _tableView.frame = r;
        _tableView.hidden = NO;
        _infoLabel.hidden = YES;
        [_tableView reloadData];
        _tableView.userInteractionEnabled = YES;
    }
    else {
        CGFloat y = CGRectGetMaxY(r);
        r.origin.y = y -76-5;
        r.size.height = 76;
        if (!_infoLabel) {
            _infoLabel = [[UILabel alloc] initWithFrame:self.bounds];
            _infoLabel.font = FONTSYS(16);
            _infoLabel.text =  @"没找到该人员，请重新输入";
            _infoLabel.textColor = [UIColor blackColor];
            _infoLabel.textAlignment = NSTextAlignmentCenter;
            
            _infoLabel.backgroundColor = [UIColor whiteColor];
            _infoLabel.layer.cornerRadius = 12;
            _infoLabel.layer.masksToBounds = YES;
            _infoLabel.layer.shadowColor = UIColorFromRGB(0x006ff1).CGColor;// 阴影的颜色
            _infoLabel.layer.shadowOffset = CGSizeMake(4, 2);// 阴影的范围
            [self.superview addSubview:_infoLabel];//防止半透明
        }
        _infoLabel.frame = r;
        _tableView.hidden = YES;
        _infoLabel.hidden = NO;
    }
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    XZMemberListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"xzcellideltifier"];
    if (!cell) {
        cell = [[[XZMemberListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"xzcellideltifier"] autorelease];
    }
    if (row < _dataList.count) {
        CMPOfflineContactMember *member = [_dataList objectAtIndex:row];
        [cell setupDataWithMember:member];
    }
    [cell addLineWithRow:indexPath.row RowCount:_dataList.count];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row >= _dataList.count) {
        return ;
    }
    CMPOfflineContactMember *member = [_dataList objectAtIndex:row];
    if (_delegate && [_delegate respondsToSelector:@selector(memberListViewDidSelectMember:)]) {
        [_delegate memberListViewDidSelectMember:member];
    }

}
@end
