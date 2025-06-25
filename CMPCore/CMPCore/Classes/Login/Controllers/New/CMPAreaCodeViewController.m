//
//  CMPAreaCodeViewController.m
//  M3
//
//  Created by zy on 2022/2/19.
//

#import "CMPAreaCodeViewController.h"
#import "CMPAreaCodeCell.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/UIViewController+CMPViewController.h>
#import <CMPLib/UIColor+Hex.h>
#import "CMPNewPhoneCodeLoginProvider.h"
#import <CMPLib/CMPCommonTool.h>

@interface CMPAreaCodeOptionsItem : CMPObject

@property (nonatomic, copy) NSString *areaName;
@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *phoneCode;
@property (nonatomic, copy) NSString *checkKey;

@end

@implementation CMPAreaCodeOptionsItem

@end
@interface CMPAreaCodeOptions : CMPObject

@property (nonatomic, copy) NSString *label;
@property (nonatomic, strong) NSArray <CMPAreaCodeOptionsItem *> *options;

@end

@implementation CMPAreaCodeOptions

@end


@interface CMPAreaCodeViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
//@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSArray <CMPAreaCodeOptions *> *sectionIndexs;
@property (nonatomic, strong) NSArray <NSString *> *sectionTextIndexs;
@property (nonatomic, strong) CMPNewPhoneCodeLoginProvider *provider;

@end

@implementation CMPAreaCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self fetchAreaCode];
}

- (void)setupViews {
    
    self.title = SY_STRING(@"login_sms_area_code_title");
//    self.view.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor cmp_colorWithName:@"p-bg"];
    
//    [self setupStatusBarViewBackground:[UIColor cmp_colorWithName:@"p-bg"]];
    [self.bannerNavigationBar hideBottomLine:YES];
    [self showNavBar:YES animated:YES];
    
//    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];
    
//    self.searchBar.frame = CGRectMake(14, self.bannerNavigationBar.cmp_bottom, self.view.width - 28, 44);
    self.tableView.sectionIndexColor = [UIColor cmp_colorWithName:@"sup-fc1"];//#999999
//    CGFloat tbOffsetY = self.searchBar.cmp_bottom + 10;
    self.tableView.backgroundColor = [UIColor cmp_colorWithName:@"p-bg"];
    CGFloat tbOffsetY = self.bannerNavigationBar.cmp_bottom;
    CGFloat tbHeight = self.view.height - tbOffsetY;
    self.tableView.frame = CGRectMake(0, tbOffsetY, self.view.width, tbHeight);
    self.sectionIndexs = @[];
    self.sectionTextIndexs = @[];
}

- (void)fetchAreaCode {
    __weak typeof(self) weakSelf = self;
    [self.provider phoneCodeLoginWithGetAreaCodeSuccess:^(NSString * _Nonnull response, NSDictionary * _Nonnull userInfo) {
        NSDictionary *dict = [CMPCommonTool dictionaryWithJsonString:response];
        if (dict) {
            NSNumber *code = dict[@"code"];
            NSString *message = dict[@"message"];
            NSDictionary *dataDict = dict[@"data"];
            if (code.intValue == 0) {
                NSArray *dataArr = [dataDict objectForKey:@"options"];
                NSMutableArray *dataTmp = [NSMutableArray array];
                NSMutableArray *titleTmp = [NSMutableArray array];
                for (NSDictionary *dataDic in dataArr) {
                    CMPAreaCodeOptions *model = [CMPAreaCodeOptions yy_modelWithDictionary:dataDic];
                    NSMutableArray *items = [NSMutableArray array];
                    for (NSDictionary *itemDict in model.options) {
                        CMPAreaCodeOptionsItem *itemModel = [CMPAreaCodeOptionsItem yy_modelWithDictionary:itemDict];
                        [items addObject:itemModel];
                    }
                    model.options = items;
                    [dataTmp addObject:model];
                    [titleTmp addObject:[model.label substringToIndex:1]];
                }
                weakSelf.sectionIndexs = [dataTmp copy];
                weakSelf.sectionTextIndexs = [titleTmp copy];
                [weakSelf.tableView reloadData];
            }else {
                [weakSelf showToastWithText:message];
            }
        }

    } fail:^(NSError * _Nonnull response, NSDictionary * _Nonnull userInfo) {
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSLog(@"sectionForSectionIndexTitle:%@,%@",title,@(index));
    return index;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.sectionTextIndexs;
}

#pragma mark - TableViewDelegate DataSource

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CMPAreaCodeHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"kCMPAreaCodeHeader"];
    [header setTitle:self.sectionIndexs[section].label];
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMPAreaCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kCMPAreaCodeCell"];
    CMPAreaCodeOptions *items = self.sectionIndexs[indexPath.section];
    if (items && items.options.count > 0) {
        CMPAreaCodeOptionsItem *item = items.options[indexPath.row];
        [cell setTitle:item.areaName desc:item.phoneCode];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CMPAreaCodeOptions *items = self.sectionIndexs[section];
    return items.options.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionIndexs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 26;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CMPAreaCodeOptions *items = self.sectionIndexs[indexPath.section];
    if (self.selectAreaCodeSuccess && items && items.options.count > 0) {
        CMPAreaCodeOptionsItem *item = items.options[indexPath.row];
        self.selectAreaCodeSuccess(item.areaName, item.phoneCode, item.countryCode, item.checkKey);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//- (UISearchBar *)searchBar {
//    if (!_searchBar) {
//        _searchBar = [[UISearchBar alloc] init];
//        _searchBar.barStyle = UIBarStyleDefault;
//        _searchBar.searchBarStyle = UISearchBarStyleProminent;
//        _searchBar.backgroundImage = [UIImage new];
//        _searchBar.placeholder = @"搜索";
//    }
//    return _searchBar;
//}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStyleGrouped];
        [_tableView registerClass:[CMPAreaCodeCell class] forCellReuseIdentifier:@"kCMPAreaCodeCell"];
        [_tableView registerClass:[CMPAreaCodeHeader class] forHeaderFooterViewReuseIdentifier:@"kCMPAreaCodeHeader"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (CMPNewPhoneCodeLoginProvider *)provider {
    if (!_provider) {
        _provider = [[CMPNewPhoneCodeLoginProvider alloc] init];
    }
    return _provider;
}

@end
