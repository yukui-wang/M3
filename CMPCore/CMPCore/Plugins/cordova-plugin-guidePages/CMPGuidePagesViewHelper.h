//
//  CMPGuidePagesViewHelper.h
//  M3
//
//  Created by youlin on 2017/11/23.
//

#import <CMPLib/CMPObject.h>
#import "CMPGuidePagesView.h"
typedef void (^GuidePagesViewDismissBlock)(void);
@interface CMPGuidePagesViewHelper : CMPObject<CMPGuidePagesViewDelegate>

+ (BOOL)needShowGuidePagesView;
- (void)showGuidePagesView:(NSArray *)imagePathArray dismissComplete:(GuidePagesViewDismissBlock)omplete;
- (void)hideGuidePagesView;

@end
