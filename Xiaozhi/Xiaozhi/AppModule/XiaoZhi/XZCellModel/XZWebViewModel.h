//
//  XZWebViewModel.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/10.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZCellModel.h"

typedef void(^WebViewModelBlock)(NSDictionary *params);
@class XZTransWebViewController;
@interface XZWebViewModel : XZCellModel
- (id)initForQA;
@property(nonatomic, copy)NSString *loadUrl;
@property(nonatomic, strong)NSDictionary *gotoParams;

@property(nonatomic, strong)XZTransWebViewController *viewController;
@property(nonatomic, assign)CGFloat webviewHeight;
@property(nonatomic, copy)WebViewModelBlock optionValueBlock;
@property(nonatomic, copy)WebViewModelBlock nextIntentBlock;
@property(nonatomic, copy)WebViewModelBlock optionCommandsBlock;
@property(nonatomic, assign)BOOL showInHistory;//是否在历史记录中显示
@property(nonatomic, assign)BOOL canDisappear;
@property(nonatomic, copy)void(^webviewFinishLoad)(CGFloat webHeight);

@property(nonatomic, assign)UINavigationController *nav;//弱引用，用于原生聊天界面打开附件，直接打开会导致界面混乱

@end

