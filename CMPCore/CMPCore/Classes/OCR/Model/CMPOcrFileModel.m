//
//  CMPOcrFileModel.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/24.
//

#import "CMPOcrFileModel.h"

@implementation CMPOcrFileModel

//- (NSString *)fileTypeName{
//    switch (_fileType) {
//        case CMPOcrFileTypeJPG:
//            _fileTypeName = @"jpg";
//            break;
//        case CMPOcrFileTypePNG:
//            _fileTypeName = @"png";
//            break;
//        case CMPOcrFileTypePDF:
//            _fileTypeName = @"pdf";
//            break;
//            
//        default:
//            break;
//    }
//    return _fileTypeName;
//}
//
//- (CMPOcrFileType)fileType{
//    if (_fileType==0) {
//        //相册图片
//        if ([[_originalName lowercaseString] hasSuffix:@".png"]) {
//            _fileType = CMPOcrFileTypePNG;
//        }else if ([[_originalName lowercaseString] hasSuffix:@".jpg"]) {
//            _fileType = CMPOcrFileTypeJPG;
//        }
//        //文档
//        else if ([[_url lowercaseString] hasSuffix:@".pdf"]) {
//            _fileType = CMPOcrFileTypePDF;
//        }else if ([[_url lowercaseString] hasSuffix:@".png"]) {
//            _fileType = CMPOcrFileTypePNG;
//        }else if ([[_url lowercaseString] hasSuffix:@".jpg"]) {
//            _fileType = CMPOcrFileTypeJPG;
//        }
//    }
//    return _fileType;
//}

@end
