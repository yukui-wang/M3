//
//  XZShortHandParam.h
//  CMPCore
//
//  Created by wujiansheng on 2019/1/8.
//

#ifndef XZShortHandParam_h
#define XZShortHandParam_h

//语音速记新建
#define kShorthandUrl_Create [NSString stringWithFormat:@"%@/seeyon/rest/xiaozhi/shorthand/save",[CMPCore sharedInstance].serverurl]
//语音速记列表
#define kShorthandUrl_List [NSString stringWithFormat:@"%@/seeyon/rest/xiaozhi/shorthand/get",[CMPCore sharedInstance].serverurl]
//语音速记更新
#define kShorthandUrl_Update [NSString stringWithFormat:@"%@/seeyon/rest/xiaozhi/shorthand/update",[CMPCore sharedInstance].serverurl]
//语音速记删除
#define kShorthandUrl_Delete [NSString stringWithFormat:@"%@/seeyon/rest/xiaozhi/shorthand/delete",[CMPCore sharedInstance].serverurl]
//语音速记列表
#define kShorthandUrl_ForwardList [NSString stringWithFormat:@"%@/seeyon/rest/xiaozhi/shorthand/getForwardApp",[CMPCore sharedInstance].serverurl]

#define kXZTransferUrl @"http://xiaoz.v5.cmp/v/html/transit-page.html"



#endif /* XZShortHandParam_h */
