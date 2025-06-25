//
//  TakePicturePlugin.m
//  CMPCore
//
//  Created by wujiansheng on 16/8/4.
//
//

#import "CMPTakePicturePlugin.h"
#import "AppDelegate.h"
#import "CMPImagePickerViewController.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataResponse.h>
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/CMPBaseWebViewController.h>
#import <CMPLib/CMPDateHelper.h>
#import <CMPLib/CMPDevicePermissionHelper.h>
#import <CMPLib/CMPAlertView.h>


@interface CMPTakePicturePlugin ()<CMPImagePickerViewControllerDelegate,CMPDataProviderDelegate>

@property (nonatomic, copy)NSString *callbackId;
@property (nonatomic, copy)NSString *userName;
@property (nonatomic, copy)NSString *uploadPicUrl;
@property (nonatomic, retain)SyAddress *currentAddress;
@property (nonatomic, retain)CLLocation *currentLocation;
@property (nonatomic, copy)NSString *picPath;

@end

@implementation CMPTakePicturePlugin

- (void)dealloc
{
    self.callbackId = nil;
    self.userName = nil;
    self.uploadPicUrl = nil;
    self.currentAddress = nil;
    self.currentLocation = nil;
    self.picPath = nil;
    [super dealloc];
}

- (void)takePicture:(CDVInvokedUrlCommand*)command
{
    BOOL canTakePic = [CMPImagePickerViewController canUserCamear];
    
    if (!canTakePic) {
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:27003], @"code",@"Has no access to camera", @"message",@"",@"detail", nil];
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    if (![CMPDevicePermissionHelper isHasLocationPermission]) {
       //木有定位权限
        NSString *app_Name = [[NSBundle mainBundle]
                              objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString *message = [NSString stringWithFormat:SY_STRING(@"Sign_location_servicesSet_m3"),app_Name];
  
        UIAlertView *alertView = [[CMPAlertView alloc] initWithTitle:nil message:message cancelButtonTitle:nil otherButtonTitles:[NSArray arrayWithObject:SY_STRING(@"common_ok")] callback:^(NSInteger buttonIndex) {
        }];
        [alertView show];
        [alertView release];
        alertView = nil;
        
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:27004], @"code",@"Has no access to location", @"message",@"",@"detail", nil];
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_CameraWillShow object:nil];

    self.callbackId = command.callbackId;
    NSDictionary *parameter = [[command arguments] lastObject];
    self.userName = [parameter objectForKey:@"userName"];
    self.uploadPicUrl = [parameter objectForKey:@"uploadPicUrl"];
    NSString *serverDateUrl = [parameter objectForKey:@"serverDateUrl"];
    NSString *location = [parameter objectForKey:@"location"];
    CMPImagePickerViewController *controller = [[CMPImagePickerViewController alloc] init];
    controller.userName = self.userName;
    controller.serverDateUrl = serverDateUrl;
    controller.delegate = self;
    if (location && [location isKindOfClass:[NSString class]] && location.length >0) {
        controller.location = location;
    }
    if (self.viewController.navigationController) {
        [self.viewController.navigationController presentViewController:controller animated:YES completion:nil];
    }
    else {
        [self.viewController presentViewController:controller animated:YES completion:nil];
    }
    [controller release];
    controller = nil;
}

#pragma mark CMPImagePickerViewControllerDelegate
- (void)imagePickerController:(CMPImagePickerViewController *)picker didFinishPickingImagePath:(NSString *)imagePath  withAddress:(SyAddress *)aAddress currentLoaction:(CLLocation *)aLocation
{
    self.currentAddress = aAddress;
    self.currentLocation = aLocation;
    self.picPath = imagePath;
    [self uploadImageWithPath:imagePath];
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_CameraWillHide object:nil];

}

- (void)imagePickerControllerDidCancel:(CMPImagePickerViewController *)picker
{
    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:27003], @"code", SY_STRING(@"common_cancelPhotography"), @"message",@"",@"detail", nil];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_CameraWillHide object:nil];
}

- (void)imagePickerControllerHasNotLocationPermission:(CMPImagePickerViewController *)picker{
    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:27004], @"code",@"Has no access to location", @"message",@"",@"detail", nil];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_CameraWillHide object:nil];
}

#pragma mark upload image

-(void)uploadImageWithPath:(NSString *)imagePath
{
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = self.uploadPicUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"Post";
    aDataRequest.uploadFilePath = imagePath;
    // 设置header
    aDataRequest.headers = [CMPDataProvider headers];

    aDataRequest.requestType = kDataRequestType_FileUpload;
    NSString *callBackID = [self callbackId];
    NSString *aFileId = [NSString uuid];
    aDataRequest.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:callBackID, @"callBackID", aFileId, @"fileId", nil];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [aDataRequest release];
}

//回调
- (void)sendPluginResultWithUploadResponse:(NSString *)responseStr
{
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:[self.currentAddress deaultAddressDictionary]];
    NSDictionary *result = [responseStr JSONValue];
    NSArray *atts = [result objectForKey:@"atts"];
    NSDictionary *value = [atts lastObject];
    if (value) {
        NSString *filename = [value objectForKey:@"filename"];
        NSMutableDictionary *mValue = [[[NSMutableDictionary alloc] initWithDictionary:value] autorelease];
        [mValue setObject:filename forKey:@"name"];
        // 时间转换
        NSNumber *createdate = [value objectForKey:@"createdate"];
        if ([createdate isKindOfClass:[NSString class]] && [CMPDateHelper dateFromStr:(NSString *)createdate dateFormat:@"yyyy-MM-dd HH:mm"]) {
            // 需要判断是非是时间戳类型，如果是时间戳类型需要转换成时间格式
            [mValue setObject:createdate forKey:@"createDate"];
        }
        else {
            NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[createdate longLongValue]/1000];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSString *strDate = [dateFormatter stringFromDate:confromTimesp];
            [mValue setObject:strDate forKey:@"createDate"];
            [dateFormatter release];
        }
        // end
        [mValue setObject:[NSString stringWithFormat:@"file://%@",self.picPath] forKey:@"localSource"];
        NSMutableArray *listAttachment = [NSMutableArray arrayWithObject:mValue];
        [resultDict setObject:listAttachment forKey:@"listAttachment"];
    }
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

#pragma -mark CMPDataProviderDelegate

- (void)providerDidStartLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest
{

}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse
{
    NSString *aStr = aResponse.responseStr;
    [self sendPluginResultWithUploadResponse:aStr];
}

/**
 * 2. 当请求数据出现错误时调用
 *
 * aProvider: 数据访问类
 * anError: 错误信息
 * aRequest: 请求对象
 */
- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error
{
    NSDictionary *aDict = (NSDictionary *)aRequest.userInfo;
    NSString *aCallBackId = [aDict objectForKey:@"callBackID"];
    NSString *aFileId = [aDict objectForKey:@"fileId"];
    NSDictionary *aResult = [NSDictionary dictionaryWithObjectsAndKeys:aFileId, @"fileId", error.domain, @"msg", nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:aResult];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:aCallBackId];
}


/**
 * 4. 更新进度
 *
 */
- (void)providerProgessUpdate:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest ext:(NSDictionary *)aExt
{

}


@end
