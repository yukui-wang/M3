//
//  XZShortHandListView.m
//  M3
//
//  Created by wujiansheng on 2019/1/7.
//

#import "XZShortHandListView.h"

@implementation XZShortHandListView


-(void)dealloc {
    SY_RELEASE_SAFELY(_tableView);
    self.createBtn = nil;
    [super dealloc];
}

- (void)setup {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = UIColorFromRGB(0xf4f4f4);
        _tableView.separatorStyle =  UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_tableView];
    }
    if (!self.createBtn) {
        self.createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.createBtn setImage:[UIImage imageNamed:@"XZbundle.bundle/xz_speakbtn_def.png"] forState:UIControlStateNormal];
        [self.createBtn setImage:[UIImage imageNamed:@"XZbundle.bundle/xz_speakbtn_pre.png"] forState:UIControlStateSelected];
        [self addSubview:self.createBtn];
    }
}

- (void)customLayoutSubviews {
    [_tableView setFrame:self.bounds];
    UIView *nothingView = [self viewWithTag:1000001];
    nothingView.frame = _tableView.frame;
    [self.createBtn setFrame:CGRectMake(self.width/2-30, self.height-80, 60, 60)];
}

@end
