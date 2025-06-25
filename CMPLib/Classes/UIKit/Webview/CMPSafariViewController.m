//
//  CMPSafariViewController.m
//  M3
//
//  Created by Kaku Songu on 3/13/22.
//

#import "CMPSafariViewController.h"
#import "CMPBannerWebViewController.h"

@interface CMPSafariViewController ()<SFSafariViewControllerDelegate>

@end

@implementation CMPSafariViewController

-(instancetype)initWithURL:(NSURL *)URL
{
    if (self = [super initWithURL:URL]) {
        [self _init];
    }
    return self;
}

-(instancetype)initWithURL:(NSURL *)URL configuration:(SFSafariViewControllerConfiguration *)configuration
{
    if (self = [super initWithURL:URL configuration:configuration]) {
        [self _init];
    }
    return self;
}

-(instancetype)initWithDictionaryRepresentation:(NSDictionary *)aDict
{
    if (self = [super initWithDictionaryRepresentation:aDict]) {
        [self _init];
    }
    return self;
}

-(void)_init
{
    self.delegate = self;
    _ifCanClose = YES;
}

-(void)loadView
{
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    BOOL needAct = NO;
    NSMutableArray *marr = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
    if (marr.count>=2) {
        UIViewController *ctrl = marr[marr.count-2];
        if ([ctrl isKindOfClass:CMPBannerWebViewController.class]) {
            NSURL *url = ((CMPBannerWebViewController *)ctrl).appUrl;
            if ([url.absoluteString containsString:@"cipH5.html"]) {
                [marr removeObject:ctrl];
                needAct = YES;
            }
        }
    }
    if (needAct) {
        self.navigationController.viewControllers = marr;
    }
}

-(void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    if (_ifCanClose) {
        if (controller.presentingViewController) {
            [controller dismissViewControllerAnimated:NO completion:^{
                        
            }];
        }else if (controller.navigationController){
            [controller.navigationController popViewControllerAnimated:YES];
        }
    }
}

-(void)safariViewControllerWillOpenInBrowser:(SFSafariViewController *)controller
{
    
}

-(void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully
{
    
}

-(void)safariViewController:(SFSafariViewController *)controller initialLoadDidRedirectToURL:(NSURL *)URL
{
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
