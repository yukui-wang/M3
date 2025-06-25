//
//  AttachmentPlugin.h
//  HelloCordova
//
//  Created by lin on 15/8/20.
//
//

#import <CordovaLib/CDVPlugin.h>

@interface AttachmentPlugin : CDVPlugin


/**
 从iCloud读取文件,默认所有文件类型

 @param command
 */
- (void)iCloudReadFile:(CDVInvokedUrlCommand *)command;
- (void)readAttachment:(CDVInvokedUrlCommand *)command;
- (void)openFile:(CDVInvokedUrlCommand *)command;

/**
 使用金格插件打开文档
 只读
 {
 "copyRight": "",
 "filename": "",
 "fileType": "",
 "extData": {
    "fileId": "",
    "lastModified": "",
    "iOSWpsKey": "xxx",
    "iOSWpsConfig": {
        "iAppOfficeRightsPublicIsBackup": "1"
        }
    }
 }
 */
- (void)openWithWps:(CDVInvokedUrlCommand *)command;


@end
