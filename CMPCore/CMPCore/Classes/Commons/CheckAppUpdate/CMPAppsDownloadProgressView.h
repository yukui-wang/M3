//
//  CMPAppsDownloadView.h
//  M3
//
//  Created by youlin on 2018/6/14.
//

#import <CMPLib/CMPBaseView.h>

@interface CMPAppsDownloadProgressView : CMPBaseView

- (void)showUpdateProgress;
- (void)updateProgress:(CGFloat )aProgress;
//- (void)showError:(NSError *)aError;
- (void)showError:(NSError *)aError byZipAppName:(NSString *)zipAppName;

@end
