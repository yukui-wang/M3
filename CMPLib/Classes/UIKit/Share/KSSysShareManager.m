//
//  KSSysShareManager.m
//  XGiant
//
//  Created by Songu Kaku on 2018/11/24.
//  Copyright © 2018 com.xinjucn. All rights reserved.
//

#import "KSSysShareManager.h"

@interface KSSysShareManager()<UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) UIDocumentInteractionController *documentController;
@property (nonatomic, strong) NSMutableArray *tmpURLs;
@end

@implementation KSSysShareManager

-(NSMutableArray *)tmpURLs
{
    if (!_tmpURLs) {
        _tmpURLs = [[NSMutableArray alloc] init];
    }
    return _tmpURLs;
}

+(instancetype)shareInstance
{
    static id manager ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}



-(void)presentDocumentInteractionInView:(UIView *)inView
                           withLocalPath:(NSString *)localPath
                             displayName:(NSString *)displayName
{
    if (!inView) {
        return;
    }
    if (!localPath || localPath.length==0) {
        return;
    }
    if (!displayName || displayName.length==0) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *tmpName = displayName;
        //用-替换/，/会被苹果识别为路径，然后就找不到文件，导致系统的分享失败
        tmpName = [tmpName stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
        
        NSURL *fileUrl= [NSURL fileURLWithPath:localPath];
        
        NSString *tempPath = NSTemporaryDirectory();
        NSString *tempFilePath = [tempPath stringByAppendingPathComponent:tmpName];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSError *error = nil;
        
        if([fileManager fileExistsAtPath:tempFilePath]){
            
            [fileManager removeItemAtURL:[NSURL fileURLWithPath:tempFilePath] error:nil];
        }
        //修改为真正的名字
        [fileManager copyItemAtURL:fileUrl toURL:[NSURL fileURLWithPath:tempFilePath] error:&error];
        
        
        if(!self.documentController){
            self.documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:tempFilePath]];
            self.documentController.delegate = self;
        }else {
            self.documentController.URL = [NSURL fileURLWithPath:tempFilePath];
        }
        
        [self.tmpURLs addObject:[NSURL fileURLWithPath:tempFilePath]];
        
        if (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad) {
            CGRect r = inView.bounds;
            [self.documentController presentOpenInMenuFromRect:CGRectMake(0, r.size.height, r.size.width,r.size.height * 3 /2)  inView:inView animated:YES];
        }else{
            [self.documentController presentOpenInMenuFromRect:inView.bounds inView:inView animated:YES];
        }
        
        
    });
    
}



-(void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    for (NSURL *fileUrl in self.tmpURLs) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtURL:fileUrl error:nil];
    }
    [self.tmpURLs removeAllObjects];
}





-(void)presentActivityViewControllerOn:(UIViewController *)controller
                            sourceView:(UIView *)sourceView
                         shareItemsArr:(NSArray *)shareItemsArr
                        unSupportTypes:(NSArray<UIActivityType>*)types
            completionWithItemsHandler:(UIActivityViewControllerCompletionWithItemsHandler)completionWithItemsHandler
{
    if (!controller || !shareItemsArr || !shareItemsArr.count) {
        return;
    }
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:shareItemsArr applicationActivities:nil];
    activity.excludedActivityTypes = types;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        activity.completionWithItemsHandler = completionWithItemsHandler;
    }
    
    UIPopoverPresentationController *popover = activity.popoverPresentationController;
    if (popover) {
        popover.sourceView = sourceView;
        CGRect r = sourceView.bounds;
        popover.sourceRect = CGRectMake(0, r.size.height, r.size.width,r.size.height * 3 /2);
        popover.permittedArrowDirections = UIPopoverArrowDirectionDown;
    }
    
    [controller presentViewController:activity animated:YES completion:NULL];
}


@end
