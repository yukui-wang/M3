//
//  CMPDocumentPickerTool.h
//  FileAccess_iCloud_QQ_Wechat
//
//  Created by 程昆 on 2018/12/13.
//  Copyright © 2018 zzh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*
 指定读取的文件类型
 文件类型IdentifierType 可参考https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html#//apple_ref/doc/uid/TP40009259-SW1
 */
typedef NSString * NSUniformIdentifierType;

extern NSUniformIdentifierType const UniformIdentifierTypeData; //二进制文件，所有文件类型

typedef void(^DownloadBlock)(NSString *filePath,NSString *fileName,NSString *flieExtension);
typedef void(^FailedBlock)(NSError *error);

@interface CMPDocumentPickerTool : NSObject


/**
 使用该方法默认指定所有文件类型

 @return CMPDocumentPickerTool
 */
-(instancetype)init;

/**
 使用该方法需传入指定的文件类型

 @param array 文件类型数组
 @return CMPDocumentPickerTool
 */
-(instancetype)initWithFileTypeArray:(NSArray<NSUniformIdentifierType> *)array;

/**
 使用该方法跳转到iCloud文件夹

 @param controller 指定从哪个控制器跳转
 @param completeBlock 从iCloud文件夹读取文件完成调用
 @param failedBlock 从iCloud文件夹读取文件失败调用,若失败filePath,fileName,flieExtension均为nil
 */
-(void)pickDocumentfromController:(UIViewController *)controller downloadCompleteBlock:(DownloadBlock)completeBlock downloadFailedBlock:(FailedBlock)failedBlock;


/**
 使用该方法跳转到iCloud文件夹,默认指定所有文件类型

 @param controller 指定从哪个控制器跳转
 @param completeBlock 从iCloud文件夹读取文件完成调用
 @param failedBlock 从iCloud文件夹读取文件失败调用,若失败filePath,fileName,flieExtension均为nil
 */
+(void)documentPickerToolPickDocumentfromController:(UIViewController *)controller downloadCompleteBlock:(DownloadBlock)completeBlock downloadFailedBlock:(FailedBlock)failedBlock;


/**
 使用该方法跳转到iCloud文件夹,需传入指定的文件类型

 @param array 文件类型数组
 @param controller 指定从哪个控制器跳转
 @param completeBlock 从iCloud文件夹读取文件完成调用
 @param failedBlock 从iCloud文件夹读取文件失败调用,若失败filePath,fileName,flieExtension均为nil
 */
+(void)documentPickerToolPickDocumentFileTypeArray:(NSArray<NSUniformIdentifierType> *)array fromController:(UIViewController *)controller downloadCompleteBlock:(DownloadBlock)completeBlock downloadFailedBlock:(FailedBlock)failedBlock;



@end


