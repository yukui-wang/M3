//
//  CMPOcrPickPackageViewController.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/7.
//

#import "CMPOcrPickPackageViewController.h"
#import "CMPOcrPickPackageCell.h"
#import "CMPOcrNotificationKey.h"
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import "CMPOcrPackageModel.h"
static NSString* kCMPOcrPickPackageCell = @"CMPOcrPickPackageCell";
static NSString* kCreatePackageCell = @"CreatePackageCell";
@interface CMPOcrPickPackageViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy) void(^PickBackBlock)(CMPOcrPackageModel *);

@end

@implementation CMPOcrPickPackageViewController

- (instancetype)initWithPackageArr:(NSArray *)packageArr select:(CMPOcrPackageModel *)selectedPackage pickBackBlock:(void (^)(CMPOcrPackageModel *))pickBackBlock{
    if (self = [super init]) {
        self.PickBackBlock = pickBackBlock;
        [self.dataSource addObjectsFromArray:packageArr];
        if (selectedPackage) {
            _selectedIndex = [packageArr indexOfObject:selectedPackage];
        }else{
            CMPOcrPackageModel *tmp;
            for (CMPOcrPackageModel *p in packageArr) {
                if (p.lastUsedTag == 1) {
                    tmp = p;
                    break;
                }
            }
            
            if (!tmp) {//找默认票夹
                NSString *defaultPid = [[NSUserDefaults standardUserDefaults] stringForKey:@"cmp_ocr_defaultPackageId"];
                for (CMPOcrPackageModel *p in packageArr) {
                    if ([p.pid isEqualToString:defaultPid]) {
                        tmp = p;
                        break;
                    }
                }
                if (!tmp) {
                    tmp = packageArr.firstObject;
                }
            }
            _selectedIndex = [packageArr indexOfObject:tmp];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择报销包";
    self.view.backgroundColor = [UIColor cmp_specColorWithName:@"gray-bgc"];
        
    [self setupView];
    //notification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadData:) name:kNotificationCreateBagCall object:nil];
}

- (void)loadData:(NSNotification *)notifi{
    //刷新数据并选中新创建的包
    NSDictionary *param = notifi.object;
    if (param) {
        CMPOcrPackageModel *package = [[CMPOcrPackageModel alloc]init];
        package.pid = param[@"id"];
        package.name = param[@"name"];
        package.formId = param[@"formId"];
        package.templateId = param[@"templateId"];
        id obj = param[@"lastUsedTag"];
        if ([NSString isNotNull:obj]) {
            package.lastUsedTag = [obj integerValue];
        }
        CMPOcrPackageModel *pack = [self.dataSource objectAtIndex:_selectedIndex];
        pack.lastUsedTag = 0;
        
        _selectedIndex = 0;
        [self.dataSource insertObject:package atIndex:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.tableView scrollsToTop];
        });
    }
}

- (void)setupView{
    CGFloat top = CGRectGetMaxY(self.bannerNavigationBar.frame);
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 0, 0) style:(UITableViewStylePlain)];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(top);
    }];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    _tableView.rowHeight = 50.f;
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 14, 0, 0);
    _tableView.separatorColor = [UIColor cmp_specColorWithName:@"gray-bgc"];
    [_tableView registerClass:CMPOcrPickPackageCell.class forCellReuseIdentifier:kCMPOcrPickPackageCell];
    [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:kCreatePackageCell];
    
    if (@available(iOS 15.0, *)) {
        _tableView.sectionHeaderTopPadding = 0;
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section==0?1:self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCreatePackageCell forIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:kCreatePackageCell];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:16];
        label.text = @"新建报销包";
        label.textColor = [UIColor cmp_specColorWithName:@"main-fc"];
        [cell.contentView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(14);
            make.centerY.mas_equalTo(cell.contentView);
        }];
        return cell;
    }
    CMPOcrPickPackageCell *cell = [tableView dequeueReusableCellWithIdentifier:kCMPOcrPickPackageCell forIndexPath:indexPath];
        
    CMPOcrPackageModel *packageModel = self.dataSource[indexPath.row];
    cell.label.text = packageModel.name;
    [cell selectRow:indexPath.row == _selectedIndex];
    
    cell.lastLabel.hidden = packageModel.lastUsedTag!=1;
    [cell updateLastLabelConstraint:cell.lastLabel.hidden];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        _selectedIndex = indexPath.row;
        [tableView reloadData];
    }else if(indexPath.section == 0){
        CMPBannerWebViewController *webCtrl = [[CMPBannerWebViewController alloc] init];
        NSString *href = @"http://ocr.v5.cmp/v1.0.0/html/createOcr.html";
        href = [href urlCFEncoded];
        NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:href]];
        if ([NSString isNotNull:localHref]) {
            href = localHref;
        }
        webCtrl.hideBannerNavBar = NO;
        webCtrl.startPage = href;
        [self.navigationController presentViewController:webCtrl animated:YES completion:^{}];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView *headerView = UIView.new;
        headerView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 10);
        headerView.backgroundColor = UIColor.clearColor;
        return headerView;
    }
    return UIView.new;
}

//确认btn
- (void)setupBannerButtons{
    self.bannerNavigationBar.leftMargin = 0;
    self.backBarButtonItemHidden = NO;
    UIButton *sureButton = [UIButton buttonWithFrame:kBannerImageButtonFrame title:@"确定"];
    [sureButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    self.bannerNavigationBar.rightBarButtonItems = [NSArray arrayWithObject:sureButton];
    [sureButton addTarget:self action:@selector(sureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}
//确认btn事件
- (void)sureButtonAction:(id)sender{
    CMPOcrPackageModel *pack = self.dataSource[_selectedIndex];
    if (_PickBackBlock && pack) {
        _PickBackBlock(pack);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - getter
- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}

@end
