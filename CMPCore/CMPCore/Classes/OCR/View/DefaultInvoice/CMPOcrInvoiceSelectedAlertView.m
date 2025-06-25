//
//  CMPOcrInvoiceSelectedAlertView.m
//  CMPOcr
//
//  Created by 张艳 on 2021/11/25.
//

#import "CMPOcrInvoiceSelectedAlertView.h"
#import "CMPOcrInvoiceSelectedAlertCell.h"
#import "CustomDefine.h"
#import <CMPLib/Masonry.h>
#import "UIView+Layer.h"

@interface CMPOcrInvoiceSelectedAlertView ()<UITableViewDelegate, UITableViewDataSource, CMPOcrInvoiceSelectedAlertCellDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *datas;

@end

@implementation CMPOcrInvoiceSelectedAlertView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
//    self.userInteractionEnabled = YES;
//    self.tableView.userInteractionEnabled = YES;
//    UIView *backView = [[UIView alloc] init];
//    backView.backgroundColor = ESWhiteAlpha(0, 0.3);
//
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
//    [backView addGestureRecognizer:tap];
//
//    UIView *backBottomView = [[UIView alloc] init];
//    backBottomView.backgroundColor = [UIColor clearColor];
//
//    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
//    [backBottomView addGestureRecognizer:tap1];

    
    UIButton *backView = [UIButton buttonWithType:UIButtonTypeCustom];
    [backView addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
    backView.backgroundColor = ESWhiteAlpha(0, 0.3);
    
    UIButton *backBottomView = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBottomView addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
    backBottomView.backgroundColor = [UIColor clearColor];

    [self addSubview:backBottomView];
    [self addSubview:backView];
    [self addSubview:self.tableView];
    
    [backBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo((50 + IKBottomSafeEdge));
        make.bottom.mas_equalTo(self);
    }];
    
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self);
        make.bottom.mas_equalTo(self).offset(- (50 + IKBottomSafeEdge));
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(65 * 2);
        make.leading.trailing.mas_equalTo(self);
        make.bottom.mas_equalTo(backView.mas_bottom);
    }];
    
    self.alpha = 0;
    self.hidden = YES;
}

- (void)updateTBHeight {
    NSInteger count = self.datas.count > 4 ? 4 : self.datas.count;
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(65 * count);
    }];
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
}

- (void)show:(NSArray *)items {
    [self.datas removeAllObjects];
    [self.datas addObjectsFromArray:items];
    [self updateTBHeight];
    self.alpha = 0;
    self.hidden = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        self.hidden = YES;
        [self removeFromSuperview];
        
    }];
}

- (void)tapAction {
    [self dismiss];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMPOcrInvoiceSelectedAlertItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CMPOcrInvoiceSelectedAlertItemCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.item = self.datas[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)invoiceSelectedAlertCellDelete:(CMPOcrInvoiceSelectedAlertItemCell *)cell {
    if (self.deleteCompletion) {
        self.deleteCompletion(cell.item);
    }
    
    NSMutableArray *remove = [NSMutableArray new];
    [remove addObject:cell.item];
    for (CMPOcrInvoiceItemModel *model in self.datas) {
        if ([model.relationInvoiceId isEqual:cell.item.invoiceID]) {
            [remove addObject:model];
        }
    }
    
    [self.datas removeObjectsInArray:remove];
    
    if (self.datas.count<=0) {
        [self dismiss];
    }else{
        [self updateTBHeight];
    }
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.backgroundColor = [UIColor whiteColor];
        [_tableView registerClass:[CMPOcrInvoiceSelectedAlertItemCell class]  forCellReuseIdentifier:@"CMPOcrInvoiceSelectedAlertItemCell"];
//        [_tableView registerNib:[UINib nibWithNibName:@"CMPOcrInvoiceSelectedAlertCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CMPOcrInvoiceSelectedAlertCell"];
    }
    return _tableView;
}

- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [[NSMutableArray alloc] init];
    }
    return _datas;
}
@end
