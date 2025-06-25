//
//  KSSysShareManager.h
//  XGiant
//
//  Created by Songu Kaku on 2018/11/24.
//  Copyright © 2018 com.xinjucn. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSSysShareManager : NSObject

+(instancetype)shareInstance;
- (void)presentDocumentInteractionInView:(UIView *)inView
                           withLocalPath:(NSString *)localPath
                             displayName:(NSString *)displayName;

-(void)presentActivityViewControllerOn:(UIViewController *)controller
                            sourceView:(UIView *)sourceView
                         shareItemsArr:(NSArray *)shareItemsArr
                        unSupportTypes:(NSArray<UIActivityType>*)types
            completionWithItemsHandler:(UIActivityViewControllerCompletionWithItemsHandler)completionWithItemsHandler;

@end

NS_ASSUME_NONNULL_END
