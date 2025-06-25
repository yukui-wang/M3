//
//  CMPGuidePagesViewController.m
//  M3
//
//  Created by 程昆 on 2019/7/25.
//

#import "CMPGuidePagesViewController.h"
#import "CMPGuidePagesView.h"

@interface CMPGuidePagesViewController ()

@property (nonatomic,strong)CMPGuidePagesView *guidePagesView;
@property (nonatomic,strong)CMPGuidePagesViewHelper *guidePagesViewHelper;

@end

@implementation CMPGuidePagesViewController

-(instancetype)initWithGuidePagesViewHelper:(CMPGuidePagesViewHelper *)helper {
    if (self = [super init]) {
        self.guidePagesViewHelper = helper;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.guidePagesView = [[CMPGuidePagesView alloc] initWithFrame:self.view.bounds];
    [self.guidePagesView fillImageByInfoArray:nil];
    self.guidePagesView.delegate = self.guidePagesViewHelper;
    [self.view addSubview:self.guidePagesView];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.guidePagesView.frame = self.view.bounds;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}

@end
