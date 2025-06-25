//
//  CMPFileConstant.h
//  CMPCore
//
//  Created by youlin guo on 14-11-11.
//  Copyright (c) 2014年 CMPCore. All rights reserved.
//

#ifndef CMPCore_CMPFileConstant_h
#define CMPCore_CMPFileConstant_h

// 文件类型
#define kFileType_Image						1		// 图像文件
#define kFileType_Audio						2		// 音频文件
#define kFileType_Compression				3		// 压缩文件，此版本不支持
#define kFileType_TEXT						4		// TXT、INI、JAVA、M、MM、H、CPP、BAT
#define kFileType_WPSET						5		// WPS、ET文件
#define kFileType_WebView					6		// PDF、DOC、XLS、DOCX、XLSX、PPT、PPTX、HTML、HTM、PHP、RTF
#define kFileType_Other						7		// 其它文件都用WebView浏览
#define kFileType_Movie                     8       // 视频 zhengxf Add 2013.3.27

#define kFileTempPath                   @"Documents/File/temp"
#define kDownloadFilePath               @"Documents/File/Download"
#define kUploadTempFilePath             @"Documents/File/UploadTemp"
#define kMenuSettingsPath               @"Documents/File/MenuSettings"
#define kPromptFlagsPath                @"Documents/File/PromptFlags"
#define kFaceImagePath                  @"Documents/File/FaceImagePath"
#define kSkinPath                       @"Documents/File/Skin/%@/%@"
#define kLocalFilePath					@"Documents/File/Local"
#define kCMPIconPath					@"Documents/File/CMP/Icons"
#define kLocalSavedFilePath             @"Documents/File/Localfile"
#define kThumbnailImgPath               @"Documents/File/thumbnailImg"//我的文件缩略图位置，清除缓存不能清

#endif
