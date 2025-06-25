//
//  CMPNavigationBarMaskView.m
//  M3
//
//  Created by Shoujian Rao on 2024/1/9.
//

#import "CMPNavigationBarMaskView.h"
@interface CMPNavigationBarMaskView()
@property (nonatomic, weak) CMPBannerWebViewController *vc;
@property (nonatomic, copy) NSString * clickId;
@end

@implementation CMPNavigationBarMaskView

- (instancetype)initWithClickId:(NSString *)clickId fromVC:(CMPBannerWebViewController *)vc{
    if (self = [super init]) {
        self.vc = vc;
        self.clickId = clickId;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
        [self addGestureRecognizer:tapGesture];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)viewTapped:(UITapGestureRecognizer *)gesture {
    CMPNavigationBarMaskView *v = (CMPNavigationBarMaskView *)gesture.view;
    if (v.clickId) {
        NSString *js = [NSString stringWithFormat:@"cmp.event.trigger('CMPHeaderCloseFullScreenView', document, {id: '%@'})",v.clickId];
        [self.vc.webViewEngine evaluateJavaScript:js completionHandler:^(id obj, NSError *err) {
        }];
    }
}

@end
