//
//  CMPImpAlertViewController.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/8/23.
//

#import "CMPImpAlertViewController.h"
#import "CMPImpAlertView.h"

@interface CMPImpAlertViewController ()
{
    id _datas;
}
@end

@implementation CMPImpAlertViewController

-(instancetype)initWithDatas:(id)datas
{
    if (self = [super init]) {
        _datas = datas;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    CMPImpAlertView *mainView = (CMPImpAlertView *)self.mainView;
    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).offset(0);
    }];
    
//    if (!_datas) {
//        _datas = @[@{@"url":@"http://10.3.10.81/seeyon/rest/commonImage/showImage?id=661425541371347080&createDate=2023-08-30&type=image&w=627&h=189",@"html":@"<html>"
//                             "<style type=\"text/css\">"
//                             "<!--"
//                             "body{font-size:40pt;line-height:60pt;}"
//                             "-->"
//                             "</style>"
//                             "<body>"
//                             "hhhhhhhh1"
//                             "</body>"
//                             "</html>"},
//                           @{@"url":@"http://pic1.win4000.com/wallpaper/c/568df51858fe1.jpg",@"html":@"<html>"
//                             "<style type=\"text/css\">"
//                             "<!--"
//                             "body{font-size:40pt;line-height:60pt;}"
//                             "-->"
//                             "</style>"
//                             "<body>"
//                             "hhhhhhhh2"
//                             "</body>"
//                             "</html>"},
//                           @{@"url":@"https://up.enterdesk.com/edpic/e6/91/24/e69124240a9ece9b41d008e2f5da2573.jpg",@"html":@"<html>"
//                             "<style type=\"text/css\">"
//                             "<!--"
//                             "body{font-size:40pt;line-height:60pt;}"
//                             "-->"
//                             "</style>"
//                             "<body>"
//                             "hhhhhhhh3"
//                             "</body>"
//                             "</html>"}];
//    }
    
    [mainView setDatas:_datas ext:nil completion:^{
            
    }];
    
}

@end
