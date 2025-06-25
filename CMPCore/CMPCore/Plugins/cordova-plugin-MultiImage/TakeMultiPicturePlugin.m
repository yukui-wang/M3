//
//  TakeMultiPicturePlugin.m
//  CMPCore
//
//  Created by wujiansheng on 16/8/4.
//
//

#import "TakeMultiPicturePlugin.h"
#import "AppDelegate.h"
#import "TZImagePickerController.h"
@interface TakeMultiPicturePlugin ()<TZImagePickerControllerDelegate>
@property (nonatomic, copy)NSString *callbackId;

@end

@implementation TakeMultiPicturePlugin
- (void)dealloc
{
    self.callbackId = nil;
    [super dealloc];
}

- (void)getPicture:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    TZImagePickerController *controller = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    AppDelegate *appDelegate =(AppDelegate *) self.appDelegate;
    [appDelegate.window.rootViewController presentViewController:controller animated:YES completion:nil];
    [controller release];
    controller = nil;
}

#pragma mark TZImagePickerControllerDelegate

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<NSString *> *)photoPaths sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    //todo

    NSArray *imagePathLis = photoPaths;
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:imagePathLis];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    AppDelegate *appDelegate =(AppDelegate *) self.appDelegate;
    [appDelegate.window.rootViewController dismissViewControllerAnimated:YES completion:^{
        
    }];

}

- (void)imagePickerControllerDidCancel:(TZImagePickerController *)picker
{
    //todo

//    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:imagePathLis];
//    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    AppDelegate *appDelegate =(AppDelegate *) self.appDelegate;
    [appDelegate.window.rootViewController dismissViewControllerAnimated:YES completion:^{
        
    }];

}

@end
