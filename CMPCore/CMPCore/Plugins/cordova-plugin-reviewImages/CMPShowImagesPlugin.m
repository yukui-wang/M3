//
//  CMPReviewImagesPlugin.m
//  M3
//
//  Created by 程昆 on 2019/4/17.
//

#import "CMPShowImagesPlugin.h"
#import <CMPLib/YBImageBrowser.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import <CMPLib/CMPReviewImagesTool.h>
#import <CMPLib/CMPStringConst.h>

@implementation CMPShowImagesPlugin

- (void)showImages:(CDVInvokedUrlCommand *)command {
    NSDictionary *arguments = [command.arguments lastObject];
    NSInteger showIndex = [arguments[@"showIndex"] integerValue];
    NSArray *imageURLs = arguments[@"imageURLs"];
    NSString *from = arguments[@"from"];
    CMPFileFromType fromType = CMPFileFromTypeComeFromM3;
    
    BOOL canSave = arguments[@"canSave"] ? [arguments[@"canSave"] boolValue] : YES;
    BOOL canPrint = arguments[@"canPrint"] ? [arguments[@"canPrint"] boolValue] : [CMPFeatureSupportControl isSupportPrint];
    
    NSMutableArray *models = [NSMutableArray array];
    
    [imageURLs enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *url = dic[@"url"];
        NSString *origin = dic[@"origin"];
        NSString *imgName = dic[@"imageName"];
        if (![imgName containsString:@"."]) {
            imgName = [imgName stringByAppendingString:@".jpg"];
        }
        
        CMPImageBrowseCellDataModel *model = [[CMPImageBrowseCellDataModel alloc] init];
        model.from = from;
        model.fromType = fromType;
        model.filenName = imgName;
        
        if (![NSString isNull:url]) {
            if ([CMPCachedUrlParser chacedUrl:[NSURL URLWithString:url]]) {
                url = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:url]];
            }
            url = [url urlCFEncoded];
            model.showUrlStr = url;
        }
        if (![NSString isNull:origin]) {
            if ([CMPCachedUrlParser chacedUrl:[NSURL URLWithString:origin]]) {
                origin = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:origin]];
            }
            origin = [origin urlCFEncoded];
            model.originUrlStr = origin;
        }
        [models addObject:model];
    }];
    
    CMPBaseWebViewController *controller = nil;
    if ([self.viewController isKindOfClass:[CMPBaseWebViewController class]]) {
        controller = (CMPBaseWebViewController *)self.viewController;
    }
    
    [CMPReviewImagesTool showBrowserForMixedCaseWithDataModelArray:models.copy rcImgModels:nil index:showIndex fromControllerIsAllowRotation:controller.allowRotation canSave:canSave canPrint:canPrint isShowCheckAllPicsBtn:NO isUC:NO];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

@end
