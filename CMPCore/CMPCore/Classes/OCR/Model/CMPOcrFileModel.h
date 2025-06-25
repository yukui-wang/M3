//
//  CMPOcrFileModel.h
//  M3
//
//  Created by Shoujian Rao on 2021/12/24.
//

#import <CMPLib/CMPObject.h>

///选择的原始文件model，例如图片、pdf等
@interface CMPOcrFileModel : CMPObject

@property (nonatomic, copy) NSString *fileType;//文件类型
@property (nonatomic, copy) NSString *imageFileIdentifier;//相册图片唯一id
@property (nonatomic, copy) NSString *originalName;//选择图片的名称
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *fileId;//用于收藏
@property (nonatomic, copy) NSString *localUrl;//用于选择手机本地文件

@end

