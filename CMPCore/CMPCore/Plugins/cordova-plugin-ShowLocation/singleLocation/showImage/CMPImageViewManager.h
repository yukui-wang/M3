//
//  SyImageViewManager.h
//  M1Core
//
//  Created by youlin guo on 14-3-18.
//
//

#import <Foundation/Foundation.h>

@class CMPImageView;
@class MAttachment;
@interface CMPImageViewManager : NSObject

+ (CMPImageViewManager *)instance;
- (void)fetchImageWithAttachment:(MAttachment *)aMAttachment imageView:(CMPImageView *)aImageView onlyCache:(BOOL )aCache;

@end
