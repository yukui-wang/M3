//
//  XZShortHandDetailViewController.m
//  M3
//
//  Created by wujiansheng on 2019/1/7.
//

#define kTitleCount 20

#import "XZShortHandDetailViewController.h"
#import "CMPDataRequest.h"
#import "CMPDataProvider.h"
#import "XZShortHandParam.h"
#import "XZShortHandDetailView.h"
#import "CMPGlobleManager.h"

@interface XZShortHandDetailViewController ()<CMPDataProviderDelegate> {
    CMPDataRequest *_deleteRequest;
    CMPDataRequest *_updateRequest;
    XZShortHandDetailView *_detailView;
}

@end

@implementation XZShortHandDetailViewController

- (void)dealloc {
    self.data = nil;
    self.updateSucessBlock = nil;
    self.deleteSucessBlock = nil;
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
    SY_RELEASE_SAFELY(_deleteRequest);
    SY_RELEASE_SAFELY(_updateRequest);
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"语音速记"];
    self.backBarButtonItemHidden = NO;
    _detailView = (XZShortHandDetailView *)self.mainView;
    _detailView.data = self.data;
    [_detailView.editBtn addTarget:self action:@selector(editShorhand) forControlEvents:UIControlEventTouchUpInside];
    [_detailView.forwardBtn addTarget:self action:@selector(showForwardView) forControlEvents:UIControlEventTouchUpInside];
}

- (void)editShorhand {
    NSLog(@"editShorhand");
    
    [self requestUpdate];//xx
}

- (void)showForwardView {
    NSLog(@"showForwardView");
}

- (void)setupBannerButtons {
    UIButton *deleteBtn = [UIButton buttonWithImageName:@"CMPHandleWrite.bundle/ic_delete_all.png" frame:CGRectMake(0, 0, 42, 45) buttonImageAlignment:kButtonImageAlignment_Center];
    [deleteBtn addTarget:self action:@selector(requestDelete) forControlEvents:UIControlEventTouchUpInside];
    [self.bannerNavigationBar setRightBarButtonItems:[NSArray arrayWithObjects:deleteBtn, nil]];
}

- (void)requestDelete {
    NSString *url = kShorthandUrl_Delete;
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
    SY_RELEASE_SAFELY(_deleteRequest);
    _deleteRequest = [[CMPDataRequest alloc] init];
    _deleteRequest.requestUrl = url;
    _deleteRequest.delegate = self;
    _deleteRequest.requestMethod = @"POST";
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    [mDict setObject:[NSNumber numberWithLongLong:self.data.shId] forKey:@"id"];
    _deleteRequest.requestParam = [mDict JSONRepresentation];
    _deleteRequest.requestType = kDataRequestType_Url;
    [[CMPDataProvider sharedInstance] addRequest:_deleteRequest];
}

- (void)requestUpdate {
//    [self stopSpeech];
    NSString *title = _detailView.titleView.text;
    NSString *content = _detailView.contentView.text;
    if ([NSString isNull:title]) {
        if (content.length <= kTitleCount) {
            title = content;
        }
        else {
            title = [content substringToIndex:kTitleCount];
        }
    }
    NSString *url = kShorthandUrl_Update;
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
    SY_RELEASE_SAFELY(_updateRequest);
    _updateRequest = [[CMPDataRequest alloc] init];
    _updateRequest.requestUrl = url;
    _updateRequest.delegate = self;
    _updateRequest.requestMethod = @"POST";
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    [mDict setObject:title forKey:@"title"];
    [mDict setObject:content forKey:@"content"];
    [mDict setObject:[NSNumber numberWithLongLong:self.data.shId] forKey:@"id"];
    _updateRequest.requestParam = [mDict JSONRepresentation];
    _updateRequest.requestType = kDataRequestType_Url;
    [[CMPDataProvider sharedInstance] addRequest:_updateRequest];
}

- (void)providerDidStartLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest {
    
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse {
    if (_deleteRequest == aRequest) {
        if (self.deleteSucessBlock) {
            self.deleteSucessBlock();
            self.deleteSucessBlock = nil;
        }
        [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:@"删除成功"];
        [self backBarButtonAction:nil];
    }
    else if (_updateRequest == aRequest) {
        if (self.updateSucessBlock) {
            self.updateSucessBlock();
            self.updateSucessBlock = nil;
        }
        [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:@"更新成功"];
        [self backBarButtonAction:nil];
    }
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    if (_deleteRequest == aRequest) {
        [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:@"删除失败"];
    }
    else if (_updateRequest == aRequest) {
        [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:@"更新失败"];
    }
}

@end
