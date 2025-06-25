//
//  CMPOcrCardPlugin.m
//  M3
//
//  Created by Shoujian Rao on 2021/11/24.
//

#import "CMPOcrCardPlugin.h"
#import "CMPOcrTabbarViewController.h"
#import "CMPOcrNotificationKey.h"
#import "CMPOcrDefaultInvoiceViewController.h"

#import "CMPOcrPackageModel.h"
#import "CMPOcrPackageDetailViewController.h"

#import "CMPOcrAddPhotoOrCameraOrFileTool.h"
#import "CMPOcrUploadManageViewController.h"

#import "CMPOcrPickFileTool.h"
#import "CMPOcrNotificationKey.h"
@interface CMPOcrCardPlugin()
@property (nonatomic, strong) CMPOcrPickFileTool *pickFileTool;

@property (nonatomic, copy) void(^CompleteOcrBlock)(id);
@end

@implementation CMPOcrCardPlugin

- (void)completeOcrPackage:(NSNotification *)notifi{
    NSDictionary *d = notifi.object;
    if (self.CompleteOcrBlock) {
        self.CompleteOcrBlock(d);
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationFormReimburseCompleted object:nil];
        self.CompleteOcrBlock = nil;
    }
}

//快速拍票
- (void)fastCreatePackage:(CDVInvokedUrlCommand *)command {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeOcrPackage:) name:kNotificationFormReimburseCompleted object:nil];
    
    NSDictionary *parameter = [command.arguments lastObject];
    NSInteger selectType = 0;
    if ([parameter[@"type"] respondsToSelector:@selector(integerValue)]) {
        selectType = [parameter[@"type"] integerValue];
    }
    
    __weak typeof(self) weakSelf = self;
    self.CompleteOcrBlock = ^(id obj) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:(CDVCommandStatus_OK) messageAsDictionary:obj];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    };

    //也需要传默认包
    switch (selectType) {
        case 1://拍票上传
        {
            __weak typeof(self) weakSelf = self;
            [CMPOcrAddPhotoOrCameraOrFileTool openCameraFromVC:self.viewController.navigationController cameraPhotos:^(NSArray<CMPOcrFileModel *> * imageArray) {
                CMPOcrUploadManageViewController *vc = [[CMPOcrUploadManageViewController alloc]initWithFileArray:imageArray package:nil ext:@3];
                vc.formData = parameter;
                [weakSelf.viewController.navigationController pushViewController:vc animated:YES];
            } cancel:^{
                
            }];
        }
            break;
        case 2://相册选取
        {
            __weak typeof(self) weakSelf = self;
            [CMPOcrAddPhotoOrCameraOrFileTool openCustomAlbumFromVC:self.viewController.navigationController choosedPhotos:^(NSArray<CMPOcrFileModel *> * imageArray) {
                CMPOcrUploadManageViewController *vc = [[CMPOcrUploadManageViewController alloc]initWithFileArray:imageArray package:nil ext:@3];
                vc.formData = parameter;
                [weakSelf.viewController.navigationController pushViewController:vc animated:YES];
            } cancel:^{
                
            }];
        }
            break;
        case 3://文件上传
        {
            __weak typeof(self) weakSelf = self;
            [self.pickFileTool pushPickToVC:self.viewController Completion:^(NSArray<CMPOcrFileModel *> *fileArray) {
                CMPOcrUploadManageViewController *vc = [[CMPOcrUploadManageViewController alloc]initWithFileArray:fileArray package:nil ext:@3];
                vc.formData = parameter;
                dispatch_after(0.2, dispatch_get_main_queue(), ^{
                    //等收藏页面pop返回后再跳转
                    [weakSelf.viewController.navigationController pushViewController:vc animated:YES];
                });
            }];
        }
            break;
            
        default:
            break;
    }
    
    
}

//票夹进入
- (void)fastSelectPackage:(CDVInvokedUrlCommand *)command {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeOcrPackage:) name:kNotificationFormReimburseCompleted object:nil];
    
    NSDictionary *parameter = [command.arguments lastObject];
    BOOL isDefaultInvoice = [parameter[@"default"] boolValue];
    NSDictionary *data = parameter[@"data"];
    NSString *pid = data[@"id"];
    NSString *pName = data[@"name"];
    NSArray *invoiceIdList = data[@"invoiceIdList"];//发票id集合
//    NSString *invoiceIdListStr = data[@"invoiceIdList"];//发票id集合
//    NSArray *invoiceIdList = invoiceIdListStr.length>0?[invoiceIdListStr componentsSeparatedByString:@","]:@[];
    
//    if (isDefaultInvoice) {
    CMPOcrPackageModel *package = [CMPOcrPackageModel new];
    package.pid = pid;
    package.name = pName;
    package.invoiceIdList = invoiceIdList;
    CMPOcrDefaultInvoiceViewController *vc = [[CMPOcrDefaultInvoiceViewController alloc] initWithPackage:package ext:@3];
    vc.formData = parameter[@"data"];
    [self.viewController.navigationController pushViewController:vc animated:YES];
//    }else{
//        CMPOcrPackageModel *model = [CMPOcrPackageModel yy_modelWithJSON:data];
//        CMPOcrPackageDetailViewController *vc = [[CMPOcrPackageDetailViewController alloc] initWithPackageModel:model ext:@(3)];
//        vc.formData = parameter[@"data"];
//        [self.viewController.navigationController pushViewController:vc animated:YES];
//    }
    
    __weak typeof(self) weakSelf = self;
    self.CompleteOcrBlock = ^(id obj) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:(CDVCommandStatus_OK) messageAsDictionary:obj];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    };
//    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
//    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//一键报销成功h5通知原生
- (void)oneClickReimbursementCall:(CDVInvokedUrlCommand *)command {
    NSDictionary *parameter = [command.arguments lastObject];
    NSArray*arr = parameter[@"invoiceIdList"];
    if ([arr isKindOfClass:NSArray.class] && arr.count) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOneClickReimbursementCall object:parameter];
    }
    //通知跳转页面
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//卡包创建包
- (void)createBagCall:(CDVInvokedUrlCommand *)command {
    NSDictionary *parameter = [command.arguments lastObject];
    //通知刷新 - 带新建包的参数
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCreateBagCall object:parameter];
    
    //通知跳转页面
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
//修改包
- (void)updateBagCall:(CDVInvokedUrlCommand *)command {
    NSDictionary *parameter = [command.arguments lastObject];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateBagCall object:parameter];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)dealloc{
    NSLog(@"CMPOcrCardPlugin delloc");
}

//打开票夹主页
//h5 call this，then open Card Home
- (void)openCardHomePage:(CDVInvokedUrlCommand *)command {
    
    CMPOcrTabbarViewController *tabBarController = [[CMPOcrTabbarViewController alloc]init];
    
    if (self.viewController.navigationController) {
        [self.viewController.navigationController pushViewController:tabBarController animated:YES];
    } else {
        [self.viewController presentViewController:tabBarController animated:YES completion:^{}];
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (CMPOcrPickFileTool *)pickFileTool{
    if (!_pickFileTool) {
        _pickFileTool = [CMPOcrPickFileTool new];
    }
    return _pickFileTool;
}


@end
