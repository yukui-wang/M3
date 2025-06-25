//
//  CMPSingleLocationView.h
//  CMPCore
//
//  Created by wujiansheng on 16/8/24.
//
//

#import <CMPLib/CMPBaseView.h>
#import <CMPLib/CMPFaceView.h>
#import <CMPLib/SyFaceDownloadRecordObj.h>

@class MKMapView;
@interface CMPSingleLocationView : CMPBaseView
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) SyFaceDownloadObj *currentMemberMemberIcon;
@property (nonatomic, copy) NSString * currrentUserName;
@property (nonatomic, assign) CGFloat tableViewMaxHeight;

- (void)showDateTime:(NSString *)time;

@end
