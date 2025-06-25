//
//  CMPShareViewController.m
//  M3
//
//  Created by MacBook on 2019/10/24.
//

#import "CMPShareViewController.h"
#import "CMPShareView.h"
#import "CMPShareFileModel.h"
#import "CMPShareCellModel.h"
#import <CMPLib/UIView+CMPView.h>

static CGFloat const kShareViewH = 286.f;
static NSString * const kHideShareViewKey = @"hideShareViewKey";
CGFloat const CMPShareViewTimeInterval = 0.3f;

static NSString * const CMPShareCollectionCellTopListPlist = @"CMPShareCollectionCellTopList.plist";
static NSString * const CMPShareCollectionCellBottomListPlist = @"CMPShareCollectionCellBottomList.plist";


@interface CMPShareViewController()<CAAnimationDelegate>

/* shareView */
@property (strong, nonatomic) CMPShareView *shareView;
/* shareView是否在显示中 */
@property (assign, nonatomic) BOOL isShareViewShowing;

@end

@implementation CMPShareViewController
#pragma mark - 懒加载
- (CMPShareView *)shareView {
    if (!_shareView) {
        CGFloat x = 0;
        CGFloat y = self.view.height;
        CGFloat w = self.view.width;
        CGFloat h = kShareViewH;
        _shareView = [CMPShareView.alloc initWithFrame:CGRectMake(x, y, w, h)];
    }
    return _shareView;
}

#pragma mark - life circle

- (void)dealloc {
    DDLogDebug(@"---%s---",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.clearColor;
    [self.view addSubview:self.shareView];
    if (self.shareFileModel) {
        [self handleShareFileModel];
    }else {
        self.shareView.isDefaultList = YES;
        [self loadPlistData];
    }
    self.shareView.userInteractionEnabled = YES;
    [self showShareView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.isShareViewShowing) {
        [self hideShareView];
        if (self.viewClicked) self.viewClicked();
    }else {
        [self showShareView];
    }
}

#pragma mark - 加载数据

- (void)handleShareFileModel {
    NSMutableArray *topDataArr = [NSMutableArray array];
    NSMutableArray *bottomDataArr = [NSMutableArray array];
    NSArray *shareBtnList = self.shareFileModel.shareBtnList.copy;
    NSInteger count = shareBtnList.count;
    for (NSInteger i = 0; i < count; i++) {
        CMPShareBtnModel *m = shareBtnList[i];
        if ([m.type isEqualToString:@"shareToH5App"]) {
            switch (m.appId.integerValue) {
                case 1:
                {
                    //协同
                    m.img = [CMPSharePluginIconsBundleName stringByAppendingString:@"share_icon_newcoaop"];
                    m.title = @"新建协同";
                }
                    break;
                case 55:
                {
                    //发起聊天
                    m.img = [CMPSharePluginIconsBundleName stringByAppendingString:@"share_icon_chat"];
                    m.title = @"发起聊天";
                }
                    break;
                case 6:
                {
                    //新建会议
                    m.img = [CMPSharePluginIconsBundleName stringByAppendingString:@"share_icon_newconf"];
                    m.title = @"新建会议";
                }
                    break;
                case 3:
                {
                    //文档中心
                    m.img = [CMPSharePluginIconsBundleName stringByAppendingString:@"share_icon_docCenter"];
                    m.title = @"文档中心";
                }
                    break;
                case 30:
                {
                    //新建任务
                    m.img = [CMPSharePluginIconsBundleName stringByAppendingString:@"share_icon_newtask"];
                    m.title = @"新建任务";
                }
                    break;
                case 11:
                {
                    //新建日程
                    m.img = [CMPSharePluginIconsBundleName stringByAppendingString:@"share_icon_newschedule"];
                    m.title = @"新建日程";
                }
                    break;
                    
                default:
                    break;
            }
            [topDataArr addObject:m];
        }else {
            if ([m.type isEqualToString:@"download"]) {
                //下载
                m.img = [CMPSharePluginIconsBundleName stringByAppendingString:@"share_icon_download"];
                m.title = @"下载";
            }else if ([m.type isEqualToString:@"collect"]) {
                //收藏
                m.img = [CMPSharePluginIconsBundleName stringByAppendingString:@"share_icon_favorates"];
                m.title = @"收藏";
            }else if ([m.type isEqualToString:@"print"]) {
                //打印
                m.img = [CMPSharePluginIconsBundleName stringByAppendingString:@"share_icon_print"];
                m.title = @"打印";
            }else if ([m.type isEqualToString:@"wechat"]) {
                //微信
                m.img = [CMPSharePluginIconsBundleName stringByAppendingString:@"share_icon_wechat"];
                m.title = @"微信";
            }else if ([m.type isEqualToString:@"QQ"]) {
                //QQ
                m.img = [CMPSharePluginIconsBundleName stringByAppendingString:@"share_icon_QQ"];
                m.title = @"QQ";
            }
            
            [bottomDataArr addObject:m];
        }
    }
    
    if ([self.shareFileModel.shareType isEqualToString:@"file"]) {
        CMPShareBtnModel *moreBtnModel = CMPShareBtnModel.alloc.init;
        moreBtnModel.img = [CMPSharePluginIconsBundleName stringByAppendingString:@"share_icon_more"];
        moreBtnModel.title = @"其他应用";
        [bottomDataArr addObject:moreBtnModel];
    }
    
    self.shareView.topDataArray = topDataArr.copy;
    self.shareView.bottomDataArray = bottomDataArr.copy;
}

- (void)loadPlistData {
    NSString *path = [NSBundle.mainBundle pathForResource:CMPShareCollectionCellTopListPlist ofType:nil];
    if (path) {
        self.topList = [NSArray arrayWithContentsOfFile:path];
    }
    
    path = [NSBundle.mainBundle pathForResource:CMPShareCollectionCellBottomListPlist ofType:nil];
    if (path) {
        self.bottomList = [NSArray arrayWithContentsOfFile:path];
    }
    
    self.shareView.topDataArray = self.topList.copy;
    self.shareView.bottomDataArray = self.bottomList.copy;
}

#pragma mark - 显示隐藏shareView
- (void)showShareView {
    self.isShareViewShowing = YES;
    [self animationWithFromValue:(self.view.height + self.shareView.height/2.f) toValue:(self.view.height - self.shareView.height/2.f) key:nil];
}

- (void)hideShareView {
    self.isShareViewShowing = NO;
    [self animationWithFromValue:(self.view.height - self.shareView.height/2.f) toValue:(self.view.height + self.shareView.height/2.f) key:kHideShareViewKey];
}

- (void)animationWithFromValue:(CGFloat)fromValue toValue:(CGFloat)toValue key:(NSString *)key {
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    moveAnimation.duration = CMPShareViewTimeInterval;//动画时间
    //动画起始值和终止值的设置
    moveAnimation.fromValue = @(fromValue);
    moveAnimation.toValue = @(toValue);
    //一个时间函数，表示它以怎么样的时间运行
    [moveAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    moveAnimation.repeatCount = 1;
    //这里如果设置了delegate的话，就记得要移除动画，否则会造成循环引用，因为这里的delegate是strong
    moveAnimation.delegate = self;
    moveAnimation.removedOnCompletion = NO;
    moveAnimation.fillMode = kCAFillModeBoth;
    //添加动画，后面有可以拿到这个动画的标识
    if (!key) {
        key = @"shareViewMoveAnimKey";
    }
    [self.shareView.layer addAnimation:moveAnimation forKey:key];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (!flag) return;
    
    CAAnimation *anim1 = [self.shareView.layer animationForKey:kHideShareViewKey];
    if (![anim isEqual:anim1]) {
        self.shareView.cmp_centerY = self.view.height - self.shareView.height/2.f;
    }else {
        //移除动画，以免造成循环引用
        [self.shareView.layer removeAllAnimations];
    }
}
@end
