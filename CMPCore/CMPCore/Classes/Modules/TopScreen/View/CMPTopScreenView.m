//
//  CMPTopScreenView.m
//  M3
//
//  Created by Shoujian Rao on 2023/12/28.
//

#import "CMPTopScreenView.h"
#import <CMPLib/UIColor+Hex.h>
#import "CMPTopScreenViewCell.h"
#import "CMPTopScreenManager.h"
#import <CMPLib/UIImageView+WebCache.h>
#import <CMPLib/CMPCore.h>
#import <CMPLib/NSObject+CMPHUDView.h>
@interface CMPTopScreenView() <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSMutableArray *localDataArr;
@property (nonatomic, strong) NSMutableArray *secondFoorDataArr;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) CMPTopScreenManager *topScreenManager;
@property (nonatomic, weak) UIViewController *vc;

@property (nonatomic, weak) UIButton *searchBtn;

@property (nonatomic, assign) BOOL collapseSection0;

@end

@implementation CMPTopScreenView

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handlePermisson:(BOOL)can{
    self.searchBtn.userInteractionEnabled = can;
    self.tableView.userInteractionEnabled = can;
}

- (instancetype)initWithVC:(UIViewController *)vc frame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.vc = vc;
        //背景图
        UIImageView *igv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-70)];
        [self addSubview:igv];
        igv.contentMode = UIViewContentModeScaleToFill;
        igv.image = [UIImage imageNamed:@"top_screen_bg"];
        
        //顶部标题
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(24, 60, 150, 25)];
        titleLabel.text = SY_STRING(@"recently_title");// @"最近";
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:18 weight:(UIFontWeightMedium)];
        [self addSubview:titleLabel];
        
        //顶部搜索框-按钮
        UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _searchBtn = searchBtn;
        searchBtn.frame = CGRectMake(frame.size.width - 24-120, 56, 120, 34);
        searchBtn.backgroundColor = [[UIColor colorWithHexString:@"#F3F5FB"] colorWithAlphaComponent:0.1];
        [searchBtn setImage:[UIImage imageNamed:@"top_screen_search"] forState:(UIControlStateNormal)];
        [searchBtn setTitle:SY_STRING(@"common_search") forState:(UIControlStateNormal)];
        searchBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [searchBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [self addSubview:searchBtn];
        searchBtn.layer.cornerRadius = 17.f;
        searchBtn.layer.masksToBounds = YES;
        [searchBtn addTarget:self action:@selector(pushSearchView) forControlEvents:(UIControlEventTouchUpInside)];
        
        // 创建并设置UITableView
        
        CGFloat tableH = UIScreen.mainScreen.bounds.size.height - CMP_STATUSBAR_HEIGHT - self.vc.navigationController.navigationBar.frame.size.height;
        if (@available(iOS 11.0, *)) {
            CGFloat safeAreaBottom = UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
            tableH -= safeAreaBottom;
        }
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(24, 100, frame.size.width -2*24, tableH - 100) style:UITableViewStyleGrouped];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
//        if (@available(iOS 15.0, *)) {
//            self.tableView.sectionHeaderTopPadding = 0.1f;//UITableViewStylePlain才起作用
//        }
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.backgroundColor = UIColor.clearColor;
        [self.tableView registerClass:[CMPTopScreenViewCell class] forCellReuseIdentifier:@"CMPTopScreenViewCell"];
        [self addSubview:self.tableView];
                
        //底部提示语
        CGFloat botHeight = CMP_STATUSBAR_HEIGHT + CMP_SafeBottomMargin_height + 20;
        CGFloat maxHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat label_y = maxHeight - botHeight - 34 -10;//相对于底部遮罩后的位置
        _tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, label_y, frame.size.width-40, 34)];
        _tipLabel.text = SY_STRING(@"top_screen_recently_tip");// @"最近看过的文档、协同等将会出现在这里。";
        _tipLabel.numberOfLines = 3;
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.textColor = [UIColor colorWithHexString:@"#999999"];
        _tipLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_tipLabel];
        
        //蒙版
        self.maskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.maskView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.8];
        [self addSubview:self.maskView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadSecondFloorData) name:kNotificationTopScreenRefreshData_SecondFloor object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCommonData) name:kNotificationTopScreenRefreshData_Common object:nil];
    }
    return self;
}

- (void)pushSearchView{
//    [self delAllTopData];//测试清空本地记录
    if (_pushSearchBlock) {
        _pushSearchBlock();
    }
}

- (void)delAllTopData{
    if (self.localDataArr.count<=0) {
        return;
    }
    BOOL removeSuccess = [self.topScreenManager delAllTopData];
    if (removeSuccess) {
        [self.localDataArr removeAllObjects];
        [self refreshSections];
    }
}

- (void)loadData{
    [self loadCommonData];
    [self loadSecondFloorData];
}

- (void)loadCommonData{
    NSArray *arr = [self.topScreenManager getTopData];
    [self.localDataArr removeAllObjects];
    [self.localDataArr addObjectsFromArray:arr];
    [self refreshSections];
}

- (void)loadSecondFloorData{
    __weak typeof(self) weakSelf = self;
    [self.topScreenManager topScreenGetAllCompletion:^(id respData, NSError *error) {
        if (error) {
//            [weakSelf cmp_showHUDError:error];
        }else{
            NSArray *secondFoorArr = respData;
            [weakSelf.secondFoorDataArr removeAllObjects];
            [weakSelf.secondFoorDataArr addObjectsFromArray:secondFoorArr];
            [weakSelf refreshSections];
        }
    }];
}

- (void)refreshSections{
    [self.sections removeAllObjects];
    if (self.localDataArr.count) {
        [self.sections addObject:self.localDataArr];
    }
    if (self.secondFoorDataArr.count) {
        [self.sections addObject:self.secondFoorDataArr];
    }
    //如果有数据：隐藏底部tip文字
    self.tipLabel.hidden = self.localDataArr.count>0 || self.secondFoorDataArr.count>0;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && self.localDataArr.count>0) {
        return _collapseSection0?0:self.localDataArr.count;
    }
    return [self.sections[section] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat h = 36.f;
    if (section == 1) {
        h=21.f;
    }
    UIView *v = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, h)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, section==0?10:-5, self.tableView.frame.size.width-64, 20)];
    label.textColor = [UIColor colorWithHexString:@"#999999"];
    label.font = [UIFont boldSystemFontOfSize:14];
    if (section == 0) {
        if (self.sections.count == 1 && self.secondFoorDataArr.count) {
            label.text = SY_STRING(@"my_second_floor");// @"我的二楼";
        }else{
            label.text = SY_STRING(@"common_entry");//@"常用入口";
        }
    }else{
        label.text = SY_STRING(@"my_second_floor");//@"我的二楼";
    }
    [v addSubview:label];
    
    if (section == 0 && self.localDataArr.count) {
        UIButton *arrowBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        arrowBtn.frame = CGRectMake(self.tableView.frame.size.width - 64, 0, 60, 36);
        [arrowBtn setImage:[UIImage imageNamed:_collapseSection0?@"arrow_down":@"arrow_up"] forState:(UIControlStateNormal)];
        arrowBtn.imageEdgeInsets = UIEdgeInsetsMake(5, arrowBtn.frame.size.width - arrowBtn.imageView.frame.size.width, 0, 0);

        [arrowBtn addTarget:self action:@selector(expandAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [v addSubview:arrowBtn];
    }
    
    return v;
}

- (void)expandAction:(UIButton*)btn{
    _collapseSection0 = !_collapseSection0;
    [btn setImage:[UIImage imageNamed:_collapseSection0?@"arrow_down":@"arrow_up"] forState:(UIControlStateNormal)];
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0?36.f:21.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMPTopScreenViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CMPTopScreenViewCell" forIndexPath:indexPath];
    CMPTopScreenModel *model = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    //图标
    UIImage *defaultImage = [UIImage imageNamed:@"top_screen_app_def_app_icon"];
    if (model.iconUrl) {
        if (model.isSecondFloor) {
            if (model.iconUrlParsed.length) {
                NSString *iconName = [NSString stringWithFormat:@"top_screen_app_%@",model.iconUrlParsed];
                UIImage *iconImage = [UIImage imageNamed:iconName];
                if (!iconImage) {
                    //model.appId
                    CMPAppList_2 *appInfo = [self.topScreenManager getAppInfoByAppId:model.appId];
                    if (appInfo.iconUrl.length) {
                        NSURL *iconURL =[NSURL URLWithString:[[CMPCore sharedInstance].serverurl stringByAppendingString:appInfo.iconUrl]];
                        if ([appInfo.iconUrl hasPrefix:@"http"]) {
                            iconURL =[NSURL URLWithString:appInfo.iconUrl];
                        }
                        [cell.iconImageView sd_setImageWithURL:iconURL placeholderImage:defaultImage];
                    }
                }else{
                    cell.iconImageView.image = iconImage;
                }
            }else{
                NSURL *iconURL =[NSURL URLWithString:[[CMPCore sharedInstance].serverurl stringByAppendingString:model.iconUrl]];
                if ([model.iconUrl hasPrefix:@"http"]) {
                    iconURL =[NSURL URLWithString:model.iconUrl];
                }
                [cell.iconImageView sd_setImageWithURL:iconURL placeholderImage:defaultImage];
            }
        }else{
            NSURL *iconURL =[NSURL URLWithString:[[CMPCore sharedInstance].serverurl stringByAppendingString:model.iconUrl]];
            if ([model.iconUrl hasPrefix:@"http"]) {
                iconURL =[NSURL URLWithString:model.iconUrl];
            }
            [cell.iconImageView sd_setImageWithURL:iconURL placeholderImage:defaultImage];
        }
    }else{
        cell.iconImageView.image = defaultImage;
    }
    
    //名称
    cell.nameLabel.text = model.appName;
    //关闭按钮
    cell.closeButton.hidden = !model.isSecondFloor;

    __weak typeof(self) weakSelf = self;
    cell.closeBtnClickBlock = ^{
        [weakSelf.topScreenManager topScreenDelById:model.uniqueId completion:^(id respData, NSError *error) {
            if (error) {
//                [weakSelf cmp_showHUDError:error];
            }else{
                if ([respData respondsToSelector:@selector(boolValue)]) {
                    BOOL success = [respData boolValue];
//                    [weakSelf cmp_showHUDWithText:success?@"删除成功":@"删除失败"];
                    if (success) {
                        [weakSelf.secondFoorDataArr removeObject:model];
                        [weakSelf refreshSections];
                    }
                }
            }
        }];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    CMPTopScreenModel *model = self.sections[indexPath.section][indexPath.row];
    [self.topScreenManager jumpPage:model fromVC:self.vc];
}

#pragma mark - other
- (void)changeMask:(CGFloat)y{
    CGFloat alpha = ((150-y)/120.0);
    self.maskView.alpha = alpha;
}

- (void)showMask:(BOOL)show{
    self.maskView.hidden = !show;
}

#pragma mark - getter
- (CMPTopScreenManager *)topScreenManager{
    if (!_topScreenManager) {
        _topScreenManager = [CMPTopScreenManager new];
    }
    return _topScreenManager;
}

- (NSMutableArray *)localDataArr{
    if (!_localDataArr) {
        _localDataArr = [NSMutableArray new];
    }
    return _localDataArr;
}

- (NSMutableArray *)secondFoorDataArr{
    if (!_secondFoorDataArr) {
        _secondFoorDataArr = [NSMutableArray new];
    }
    return _secondFoorDataArr;
}

- (NSMutableArray *)sections{
    if (!_sections) {
        _sections = [NSMutableArray new];
    }
    return _sections;
}

@end
