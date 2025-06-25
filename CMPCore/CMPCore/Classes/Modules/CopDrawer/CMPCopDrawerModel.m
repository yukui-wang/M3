//
//  CMPCopDrawerModel.m
//  M3
//
//  Created by Shoujian Rao on 2023/12/13.
//

#import "CMPCopDrawerModel.h"
#import "CMPMessageManager.h"
#import "CMPShareToOtherAppKit.h"
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPCachedUrlParser.h>
/**
tell_meeting  //电话会议
uc //致信
qq //QQ
wechat //微信
collect //收藏
print //打印
screen_display //屏幕镜像
qr_code //生成二维码
qiyeWechat //企业微信
dingding //钉钉
other //其他应用
download //下载
*/

@implementation CMPCopDrawerModel
- (void)mapModel{
    if ([self.key isEqualToString:CMPShareComponentUCString]) {
        //致信
        if (CMPMessageManager.sharedManager.hasZhiXinPermissionAndServerAvailable){
            self.img = @"drawer_uc";
            self.title = SY_STRING(@"share_btn_my_colleague");
        }
    }else if ([self.key isEqualToString:CMPShareComponentQQString]) {
        //qq
        if (QQApiInterface.isQQInstalled){
            self.img = @"drawer_QQ";
            self.title = SY_STRING(@"share_btn_qq");
        }
    }else if ([self.key isEqualToString:CMPShareComponentWechatString]) {
        //微信
        if (CMPCommonTool.isInstalledWechat){
            self.img = @"drawer_wechat";
            self.title = SY_STRING(@"share_btn_wechat");
        }
    }else if ([self.key isEqualToString:CMPShareComponentWWechatString]) {
        //企业微信
        if (WWKApi.isAppInstalled) {
            self.img = @"drawer_w_wechat";
            self.title = SY_STRING(@"share_btn_wwechat");
        }
    }else if ([self.key isEqualToString:CMPShareComponentDingtalkString]) {
        //钉钉
        if (DTOpenAPI.isDingTalkInstalled) {
            self.img = @"drawer_dingding";
            self.title = SY_STRING(@"share_btn_dingtalk");
        }
    }else if ([self.key isEqualToString:CMPShareComponentOtherString]) {
        //其他应用
        self.img = @"drawer_other_app";
        self.title = SY_STRING(@"share_btn_other_app");
    }else if ([self.key isEqualToString:CMPShareComponentTelConfString]) {
        //电话会议
        self.img = @"drawer_tell_meeting";
        self.title = SY_STRING(@"share_btn_tel_confe");
    }else if ([self.key isEqualToString:CMPShareComponentScreenMirroringString]) {
        //无线投屏
        self.img = @"drawer_screen_display";
        self.title = SY_STRING(@"share_btn_screen_mirrioring");
    }else if ([self.key isEqualToString:CMPShareComponentQRCodeString]) {
        //二维码
        self.img = @"drawer_qrcode";
        self.title = SY_STRING(@"share_btn_generate_qrcode");
    }else if ([self.key isEqualToString:CMPShareComponentCollectString]) {
        //收藏
        self.img = @"drawer_collect";
        self.title = SY_STRING(@"share_btn_collect");
    }else if ([self.key isEqualToString:CMPShareComponentPrintString]) {
        //打印
        self.img = @"drawer_print";
        self.title = SY_STRING(@"share_btn_print");
    }else if ([self.key isEqualToString:CMPShareComponentDownloadString]) {
        //下载
        self.img = @"drawer_download";
        self.title = SY_STRING(@"share_btn_download");
        
    }else if(self.thumbImage.length){//应用包URL
        if ([CMPCachedUrlParser chacedUrl:[NSURL URLWithString:self.thumbImage]]) {
            self.localPath = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:self.thumbImage]];
            self.localPath = [self.localPath replaceCharacter:@"file://" withString:@""];            
        }
    }
}
@end
