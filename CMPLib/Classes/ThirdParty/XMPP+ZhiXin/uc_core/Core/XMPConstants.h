//
//  XMPConstants.h
//  XmppDemo
//
//  Created by weitong on 13-1-31.
//  Copyright (c) 2013年 无锡恩梯梯数据有限公司. All rights reserved.
//

#ifndef XmppDemo_XMPConstants_h
#define XmppDemo_XMPConstants_h

//  整合状态为1,独立状态为0
#define UCWithM1                1

#define RGBCOLOR(r,g,b)         [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a)      [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define RGBA(r,g,b,a)           (r)/255.0f, (g)/255.0f, (b)/255.0f, (a)

#define XMP_IMAGE(__name)           [UIImage XMPImage:(__name)]

#define FONT(__size)            ([UIFont systemFontOfSize:(__size)])
#define FONT_BOLD(__size)       ([UIFont boldSystemFontOfSize:(__size)])

#define RELEASE(__POINTER)      { [__POINTER release]; }
#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }

#define DAJIAAppDelegate        ((AppDelegate *)[UIApplication sharedApplication].delegate)

#define IS_IPHONE_5             ( [[UIScreen mainScreen ] bounds].size.height == 568 )

#define LOCALIZATION_STRING_UC(__str)  (NSLocalizedStringFromTable((__str), @"UCLocalization", @""))

#define kXMPTextViewMax          1000



#define GetDocumentsDirectory       [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define GetAppDataDirectory         [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/.AppData"]
#define GetAmrDirectory             [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/.AppData/Amr"]
#define GetFilesDirectory           [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/.AppData/Files"]
#define GetPicDirectory             [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/.AppData/Pic"]
#define GetCacheDirectory           [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/.AppData/Cache"]
#define GetMovDirectory             [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/.AppData/Mov"]
#define GetTEMPDirectory            [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/.AppData/Temp"]

#define GetAmrPath(_file)           [NSString stringWithFormat:@"%@/%@",GetAmrDirectory,_file]
#define GetFilesPath(_file)         [NSString stringWithFormat:@"%@/%@",GetFilesDirectory,_file]
#define GetPicPath(_file)           [NSString stringWithFormat:@"%@/%@",GetPicDirectory,_file]
#define GetCachePath(_user,_file)   [NSString stringWithFormat:@"%@/%@/%@",GetCacheDirectory,_user,_file]
#define GetCacheUserPath(_user)     [NSString stringWithFormat:@"%@/%@",GetCacheDirectory,_user]
#define GetMovPath(_file)           [NSString stringWithFormat:@"%@/%@",GetMovDirectory,_file]
#define GetTEMPPath(_file)          [NSString stringWithFormat:@"%@/%@",GetTEMPDirectory,_file]

#define Resource @"UC"
#define NAVBGColor  [UIColor colorWithRed:60/255.f green:120/255.f blue:180/255.f alpha:1]
#define DomainSet @"10.3.4.118"
#define kIsHeadphone @"kIsHeadphone"

//uc 表情的正则表达式
#define  kUCRegexFace  @"(\\[[a-z]+\\])|\\[5_[1-9]\\]|\\[5_[1-3][0-9]\\]"
//static NSString* kRegexFace = @"(\\[[a-z]+\\])";//v5.1.2以前的（包括512）
//static NSString* kRegexFace = @"\\[wx\\]|\\[cy\\]|\\[dx\\]|\\[tl\\]|\\[huaix\\]|\\[hx\\]|\\[xa\\]|\\[wq\\]|\\[dk\\]|\\[sx\\]|\\[sq\\]|\\[han\\]|\\[zk\\]|\\[jy\\]|\\[yw\\]|\\[gz\\]|\\[bb\\]|\\[jb\\]|\\[yl\\]|\\[ws\\]|\\[hao\\]|\\[fd\\]|\\[dg\\]|\\[jz\\]|\\[zan\\]|\\[5_1\\]|\\[5_2\\]|\\[5_3\\]|\\[5_4\\]|\\[5_5\\]|\\[5_6\\]|\\[5_7\\]|\\[5_8\\]|\\[5_9\\]|\\[5_10\\]|\\[5_11\\]|\\[5_12\\]|\\[5_13\\]|\\[5_14\\]|\\[5_15\\]|\\[5_16\\]|\\[5_17\\]|\\[5_18\\]|\\[5_19\\]|\\[5_20\\]|\\[5_21\\]|\\[5_22\\]|\\[5_23\\]|\\[5_24\\]|\\[5_25\\]|\\[5_26\\]|\\[5_27\\]|\\[5_28\\]|\\[5_29\\]|\\[5_30\\]|\\[5_31\\]|\\[5_32\\]";
//static NSString* kRegexFace = @"\\[wx\\]|\\[cy\\]|\\[dx\\]|\\[tl\\]|\\[huaix\\]|\\[hx\\]|\\[xa\\]|\\[wq\\]|\\[dk\\]|\\[sx\\]|\\[sq\\]|\\[han\\]|\\[zk\\]|\\[jy\\]|\\[yw\\]|\\[gz\\]|\\[bb\\]|\\[jb\\]|\\[yl\\]|\\[ws\\]|\\[hao\\]|\\[fd\\]|\\[dg\\]|\\[jz\\]|\\[zan\\]|\\[5_[1-9]\\]|\\[5_[1-3][0-9]\\]";

#define kUCFaceviewHeight   [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 280:230//200//v5.1.2以前的（包括512）

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
#define SY_MULTILINE_TEXTSIZE(text, font, maxSize, mode) [text length] > 0 ? [text \
boundingRectWithSize:maxSize options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) \
attributes:@{NSFontAttributeName:font} context:nil].size : CGSizeZero;
#else
#define SY_MULTILINE_TEXTSIZE(text, font, maxSize, mode) [text length] > 0 ? [text \
sizeWithFont:font constrainedToSize:maxSize lineBreakMode:mode] : CGSizeZero;
#endif



#define kPadCreatUCGroupPOPNotification  @"kPadCreatUCGroupPOPNotification"
#define kOrganizationChooseMemberNeedChooseAgain  @"kOrganizationChooseMemberNeedChooseAgain"
#define kXMPMicrotalkCellShoudStopPlaying @"kXMPMicrotalkCellShoudStopPlaying"

#define IOS7_Later ([UIDevice currentDevice].systemVersion.floatValue >=7.0)
#define IOS8_Later ([UIDevice currentDevice].systemVersion.floatValue >=8.0)
#define IOS9_Later ([UIDevice currentDevice].systemVersion.floatValue >=9.0)
#define IOS6_Later ([UIDevice currentDevice].systemVersion.floatValue >=6.0)
#define IOS7       ([UIDevice currentDevice].systemVersion.floatValue >=7.0 && [UIDevice currentDevice].systemVersion.floatValue < 8.0)



#endif
