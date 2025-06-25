//
//  CMPFileTypeHandler.h.m
//  M1Core
//
//  Created by xiang fei on 12-2-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CMPFileTypeHandler.h"
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>



@interface CMPFileTypeHandler ()

@end

@implementation CMPFileTypeHandler

static NSMutableSet *imgTags = nil;
static NSMutableSet *audioTags = nil;
static NSMutableSet *compressionTags = nil;
static NSMutableSet *textTags = nil;
static NSMutableSet *wpsandEtTags = nil;
static NSMutableSet *webTags = nil;

static NSString * const kFileTypeString = @"audio,application,text";

static NSString * const kFileTypeString1 = @"application/vnd.openxmlformats-officedocument.wordprocessingml.document,text/plain,application/vnd.openxmlformats-officedocument.presentationml.presentation,application/vnd.ms-powerpoint,application/msword,application/pdf,application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

+ (NSInteger)fileType:(NSString *)aFileExtend 
{
    if (!imgTags) {
        imgTags = [[NSMutableSet alloc] initWithObjects:@"PNG", @"JPG", @"JPEG", @"BMP", 
                   @"TIFF", @"TIF", @"TGA", @"WMF", @"ICO", @"DIB", nil];
    }
    if (!audioTags) {
        audioTags = [[NSMutableSet alloc] initWithObjects:@"CAF", @"MP3", @"WAV", @"MID", @"MP1", @"MP2",
                     @"RA", @"ASF", @"WMA", @"AMR", nil];
    }
    if (!compressionTags) {
        compressionTags = [[NSMutableSet alloc] initWithObjects:@"ZIP", @"RAR", @"TZ", nil];
    }
    if (!textTags) {
        // change buy wujs OA-209905 BAT 不支持查看
        textTags = [[NSMutableSet alloc] initWithObjects:@"TXT", @"INI", @"JAVA", @"M",
                    @"MM", @"H", @"CPP", nil];
    }
    if (!wpsandEtTags) {
        wpsandEtTags = [[NSMutableSet alloc] initWithObjects:@"WPS", @"ET", nil];
    }
    if (!webTags) {
        webTags = [[NSMutableSet alloc] initWithObjects:@"PDF", @"DOC", @"XLS", @"DOCX", @"XLSX", @"PPT", 
                   @"PPTX", @"RTF", @"PHP", @"GIF", @"MP4", @"MOV", @"M4V",  @"HTM", @"HTML", nil];
    }
 	if ( [imgTags containsObject:aFileExtend] ) {
		return kFileType_Image;
	}
 	else if ( [audioTags containsObject:aFileExtend] ) {
		return kFileType_Audio;
	}
 	else if ( [compressionTags containsObject:aFileExtend] ) {
		return kFileType_Compression;
	}
 	else if ( [textTags containsObject:aFileExtend] ) {
		return kFileType_TEXT;
	}	
 	else if ( [wpsandEtTags containsObject:aFileExtend] ) {
		return kFileType_WPSET;
	}		
 	else if ( [webTags containsObject:aFileExtend] ) {
		return kFileType_WebView;
	}
 	return kFileType_Other;	
}

+ (NSString *)getFileIcon:(id)aObeject
{
    NSString *fileImgName = nil;

    
    return fileImgName;

}

+ (NSString *)loadAttachmentImageForPhone:(NSString *)fileName
{
    NSString *fileImgName = nil;
    NSString *aTitle = [fileName.pathExtension lowercaseString];
   
    if (!aTitle) {
        return  @"ic_unkown_24.png";
    }
    if ([aTitle isEqualToString:@"html"] == YES|| [ aTitle isEqualToString:@"htm"] == YES ) {
        fileImgName = @"ic_htm_24.png";
    }
    else if ([aTitle isEqualToString:@"pdf"] == YES ) {
        fileImgName = @"ic_pdf_24.png";
    }
    else if ([aTitle isEqualToString:@"doc"] == YES || [aTitle isEqualToString:@"docx"] ==YES ) {
        fileImgName = @"ic_doc_24.png";
    }
    else if([aTitle isEqualToString:@"gif"] == YES){
        fileImgName = @"ic_picture_24.png";
    }
    else if([aTitle isEqualToString:@"caf"] ==YES) {
        fileImgName = @"ic_video_24.png";
    }
    else if([aTitle isEqualToString:@"mp3"] == YES ) {
        fileImgName = @"ic_mp3_24.png";
    }
    else if([aTitle isEqualToString:@"mp4"] ==YES) {
        fileImgName = @"ic_mp4_24.png";
    }
    else if([aTitle isEqualToString:@".m4v"] ==YES) {
        fileImgName = @"ic_mp4_24.png";
    }
    else if([aTitle isEqualToString:@"mov"] ==YES) {
        fileImgName = @"ic_mp4_24.png";
    }
    else if([aTitle isEqualToString:@".3gp"] ==YES) {
        fileImgName = @"ic_mp4_24.png";
    }
    else if([aTitle isEqualToString:@"wps"] == YES ) {
        fileImgName = @"ic_wps_24.png";
    }
    else if([aTitle isEqualToString:@"ppt"] == YES || [aTitle isEqualToString:@"pptx"] == YES) {
        fileImgName = @"ic_ppt_24.png";
    }
    else if([aTitle isEqualToString:@"xlsx"] == YES || [aTitle isEqualToString:@"xls"] == YES) {
        fileImgName = @"ic_xls_24.png";
    }
    else if([aTitle isEqualToString:@"txt"] == YES){
        fileImgName = @"ic_txt_24.png";
    }
    else if([aTitle isEqualToString:@"jpg"] == YES || [aTitle isEqualToString:@"png"] ==YES || [aTitle isEqualToString:@"jpeg"] ==YES){
        fileImgName = @"ic_picture_24.png";
    }
    else if([aTitle isEqualToString:@"bmp"] == YES ){
        fileImgName = @"ic_picture_24.png";
    }
    else if([aTitle isEqualToString:@"tif"] == YES ){
        fileImgName = @"ic_picture_24.png";
    }
    else if([aTitle isEqualToString:@"png"] ==YES){
        fileImgName = @"ic_picture_24.png";
    }
    else if ([aTitle isEqualToString:@"et"] == YES) {
        fileImgName = @"ic_et_24.png";
    }
    else if ([aTitle isEqualToString:@"amr"] == YES || [aTitle isEqualToString:@"caf"] ==YES){
        fileImgName = @"ic_video_24.png";
    }
    else {
        fileImgName = @"ic_unkown_24.png";
    }
    
    
    return fileImgName;
    
}


+ (NSString *)getSize:(long long) aSize
{
    NSString *result = @"0k";
    
    if(aSize >= 1048576) {
        NSInteger finalSize = aSize / 1048576 + 1;
        result = [NSString stringWithFormat:@"%ldMB", (long)finalSize];
    }
    else{
        NSInteger finalSize = aSize / 1024 + 1;
        result = [NSString stringWithFormat:@"%ldKB", (long)finalSize];
    }
    return result;
}

+ (NSString *)fileMIMETypeWithName:(NSString *)fName
{
    fName = [fName lowercaseString];
	NSString *fileType = @"";
    
	if ([fName hasSuffix:@"doc"] == YES || [fName hasSuffix:@"docx"] == YES) {
		fileType = @"application/msword";
	} 
    else if ([fName hasSuffix:@"xls"] == YES || [fName hasSuffix:@"xlsx"] == YES ) {
		fileType = @"application/excel";
	} 
    else if ([fName hasSuffix:@"htm"] == YES || [fName hasSuffix:@"html"] == YES) {
		fileType = @"text/html";
	}
    else if ([fName hasSuffix:@"ppt"] == YES) {
		fileType = @"application/vnd.ms-powerpoint";
	}
    else if ([fName hasSuffix:@"pdf"] == YES) {
		fileType = @"application/pdf";
	}
    else if ([fName hasSuffix:@"txt"] == YES) {
		fileType = @"text/plain";
	}
	return fileType;
}

+ (BOOL )isEqualPicture:(NSString *)title
{
    BOOL isPicture = NO;
    NSString *suffix = [[title pathExtension] lowercaseString];

    if ([suffix isEqualToString:@"png"] || [suffix isEqualToString:@"bmp"] || [suffix isEqualToString:@"jpg"] || [suffix isEqualToString:@"jpeg"]|| [suffix isEqualToString:@"gif"]) {
        isPicture = YES;
    }
    return isPicture;
}
+ (BOOL)isPictureBySuffix:(NSString *)suffix
{
//   NSArray *pictures =  [[NSMutableSet alloc] initWithObjects:@"caf", @"mp3", @"wav", @"MID", @"MP1", @"MP2",
//     @"RA", @"ASF", @"WMA", @"AMR", nil];
    NSString *lowSuffix = [suffix lowercaseString];
    if ([lowSuffix isEqualToString:@"png"] || [lowSuffix isEqualToString:@"bmp"] || [lowSuffix isEqualToString:@"jpg"] || [lowSuffix isEqualToString:@"jpeg"]) {
        return  YES;
    }
    return NO;

}

+ (NSString *)getFileMineTypeWithFilePath:(NSString *)path {
    //path为要获取MIMEType的文件路径
    if (![path containsString:NSHomeDirectory()]) {
        path = [NSString stringWithFormat:@"%@/%@",NSHomeDirectory(),path];
    }
    
    if (![NSFileManager.defaultManager fileExistsAtPath:path]) {
        return nil;
    }
    return [CMPFileTypeHandler mineTypeWithPathExtension:path.pathExtension];
    
//    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)path.pathExtension.lowercaseString, NULL);
//    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
//    CFRelease(UTI);
//    if (!MIMEType) {
//        return @"unknown/octet-stream";
//    }
//    return (__bridge NSString *)(MIMEType);
}
+ (NSString *)mineTypeWithPathExtension:(NSString *)pathExtension {
    if ([NSString isNull:pathExtension]) {
        return @"unknown/octet-stream";
    }
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)pathExtension.lowercaseString, NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
#if defined(__arm__)
    CFRelease(UTI);
#endif
    if (!MIMEType) {
        return @"unknown/octet-stream";
    }
    return (__bridge NSString *)(MIMEType);
}

+ (NSInteger)fileMineTypeWithMineType:(NSString *)mineType {
    
    if ([NSString isNull:mineType]) {
        return CMPFileMineTypeUnknown;
    }
    NSString *type = mineType.pathComponents.firstObject;
    if ([type isEqualToString:@"image"]) {
        return CMPFileMineTypeImage;
    }
    else if ([type isEqualToString:@"video"]) {
        return CMPFileMineTypeVideo;
    }else if ([type isEqualToString:@"audio"]) {
        return CMPFileMineTypeAudio;
    }
    else if (([type isEqualToString:@"text"] && ![mineType isEqualToString:@"text/javascript"]) ||
              [kFileTypeString1 containsString:mineType]) {
        return CMPFileMineTypeFile;
    }
    else {
        return CMPFileMineTypeUnknown;
    }
}




@end
