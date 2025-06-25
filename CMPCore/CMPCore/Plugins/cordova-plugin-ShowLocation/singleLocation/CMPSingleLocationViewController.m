//
//  CMPSingleLocationViewController.m
//  CMPCore
//
//  Created by wujiansheng on 16/8/24.
//
//




#import "CMPSingleLocationViewController.h"
#import "CMPSingleLocationView.h"
#import <MapKit/MapKit.h>
#import "CMPLbsCustomTableViewCell.h"
#import "CMPLbsImageShowTableViewCell.h"
#import "CMPLbsSoundShowTableViewCell.h"
#import <CMPLib/MAttachment.h>
#import "CMPImageShowViewController.h"
#import "CMPSoundPlayer.h"
#import <CMPLib/CMPFileTypeHandler.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataResponse.h>
#import "CMPLbsShowItem.h"
@interface CMPSingleLocationViewController ()<UITableViewDataSource, UITableViewDelegate,CMPLbsImageShowTableViewCellDelegate,CMPDataProviderDelegate>
{
    NSInteger _soundDuration;
    BOOL _needDownloadSound;
}

@property(nonatomic, retain)CMPLbsShowItem *lbsItem;
@property(nonatomic, copy)NSString *lbsComment;
@property(nonatomic, retain)NSMutableArray *imageList;
@property(nonatomic, retain)NSMutableArray *audioList;

@end

@implementation CMPSingleLocationViewController

- (id)init
{
    self = [super init];
    if (self) {
        _needDownloadSound = YES;
    }
    return self;
}

-(void)dealloc
{
    self.lbsItem = nil;
    self.memberIcon = nil;
    self.userName = nil;
    self.lbsComment = nil;
    self.imageList = nil;
    self.audioList = nil;
    self.memberIconUrl = nil;
    [_lbsUrl release];
    _lbsUrl = nil;
    [super dealloc];
}

- (void)backBarButtonAction:(id)sender
{
    [super backBarButtonAction:sender];
    if (_delegate && [_delegate respondsToSelector:@selector(singleLocationViewControllerDisimss:)]) {
        [_delegate singleLocationViewControllerDisimss:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bannerNavigationBar.leftViewsMargin = 0.0;
    self.bannerNavigationBar.rightViewsMargin = 0.0;
    self.bannerNavigationBar.leftMargin = 0.0f;
    self.bannerNavigationBar.rightMargin = 0.0f;
    // Do any additional setup after loading the view.
    [self  setTitle:SY_STRING(@"common_locationDetail")];
    self.backBarButtonItemHidden = NO;
    _singleView = (CMPSingleLocationView *)self.mainView;
    _singleView.tableView.delegate = self;
    _singleView.tableView.dataSource = self;
    [self requestData];
}

#pragma mark data Request  and Delegate
- (void)requestData
{
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = self.lbsUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    NSMutableDictionary *aDict = [NSMutableDictionary dictionaryWithObject:@"getLbsDetail" forKey:@"methd"];
    aDataRequest.userInfo = aDict;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [aDataRequest release];
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse
{
    if ([[[aRequest userInfo]objectForKey:@"methd"] isEqualToString:@"getLbsDetail"]) {
        NSDictionary*  lbsDataDictionary = [[aResponse responseStr] JSONValue];
        CMPLbsShowItem *item  = [[CMPLbsShowItem alloc] initWithDictionaryRepresentation:lbsDataDictionary];
        self.lbsItem = item;
        [item release];
        item = nil;
        //处理下 时间
        NSString *createDate = [lbsDataDictionary objectForKey:@"createDate"];
        NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[createDate longLongValue]/1000];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        self.lbsItem.createDate = [dateFormatter stringFromDate:confromTimesp];
        [dateFormatter release];
        
        [self handleData];
    }
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error{
    
}

- (void)providerDidStartLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest;
{
    
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest updateProgress:(float)aProgress
{
    
}

- (void)handleData
{

    [_singleView showDateTime:self.lbsItem.createDate];
    [self handleAttachment];
    [self tableViewMaxHeight];
    BOOL needDownloadSound = [self requestDownloadSound];
    if (!needDownloadSound) {
        [_singleView.tableView reloadData];
    }
    [_singleView.tableView reloadData];
    [self addAnnotation];
    SyFaceDownloadObj *obj = [[SyFaceDownloadObj alloc] init];
    obj.serverId = [CMPCore sharedInstance].serverID;
    obj.memberId = [NSString stringWithFormat:@"%lld",self.lbsItem.ownerId];
//    obj.downloadUrl = self.lbsItem.;
    _singleView.currentMemberMemberIcon = obj;
    [obj release];
    obj = nil;
}
- (void)handleAttachment
{
    //意见
    NSMutableString *strM = [NSMutableString stringWithString:self.lbsItem.lbsComment?self.lbsItem.lbsComment:@""];
    int  i = 0;
    for (NSString *strT in self.lbsItem.senderNames) {
        [strM appendString:strT];
        i++;
        if(i >= 10){
            [strM appendString:@"..."];
            break;
        }
    }
    self.lbsComment = strM;
    //图片
    if (!_imageList) {
        _imageList = [[NSMutableArray alloc] init];
    }
    [_imageList removeAllObjects];
    for (MAttachment *att in self.lbsItem.attachmentList) {
        if([CMPFileTypeHandler fileType:att.suffix] == kFileType_Image){
            [_imageList addObject:att];
        }
    }
    //语音
    if (!_audioList) {
        _audioList = [[NSMutableArray alloc] init];
    }
    [_audioList removeAllObjects];
    for (MAttachment *att in self.lbsItem.attachmentList) {
        if([CMPFileTypeHandler fileType:att.suffix] == kFileType_Audio){
            [_audioList addObject:att];
        }
    }
}

- (void)tableViewMaxHeight
{
    CGFloat h = [self adressCellHeight]+13;
    if (self.lbsComment && self.lbsComment.length >0) {
        h += [self commentCellHeight];
    }
    if (self.audioList && self.audioList.count >0) {
        h += [self soundCellHeight];
    }
    if (self.imageList && self.imageList.count >0) {
        h += [self imageCellHeight];
    }
    _singleView.tableViewMaxHeight = h;
}



- (void)addAnnotation
{
    MKPointAnnotation  *annotation = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D coordinate2D;
    coordinate2D.longitude = self.lbsItem.lbsLongitude;
    coordinate2D.latitude = self.lbsItem.lbsLatitude;
    annotation.coordinate = coordinate2D;
    [_singleView.mapView addAnnotation:annotation];
    
    MKCoordinateRegion centerRegion;
    MKCoordinateSpan span;
    span.longitudeDelta = 0.008;
    span.latitudeDelta = 0.008;
    centerRegion.span = span;
    centerRegion.center.latitude = coordinate2D.latitude;
    centerRegion.center.longitude = coordinate2D.longitude;
    [_singleView.mapView setRegion:centerRegion animated:YES];
    
    [_singleView.mapView addAnnotation:annotation];
    SY_RELEASE_SAFELY(annotation);
    
}

#pragma mark row index
- (NSInteger)commentRow {
    if (self.lbsComment && self.lbsComment.length >0) {
        return 1;
    }
    return -1;
}
- (NSInteger)audioRow {
    NSInteger row = 0;
    if (self.lbsComment && self.lbsComment.length >0) {
        row ++;
    }
    if (self.audioList && self.audioList.count >0) {
        row ++;
    }
    return row>0 ?row :-1;
}

- (NSInteger)imageRow {
    NSInteger row = 0;
    if (self.lbsComment && self.lbsComment.length >0) {
        row ++;
    }
    if (self.audioList && self.audioList.count >0) {
        row ++;
    }
    if (self.imageList && self.imageList.count >0) {
        row ++;
    }
    return row>0 ?row :-1;
}
#pragma mark cell  height
- (CGFloat)adressCellHeight {
    CGSize size = [self.lbsItem.lbsAddr sizeWithFont:FONTSYS(15) constrainedToSize:CGSizeMake(self.view.width-110, 1000)];
    return size.height+32;
}
- (CGFloat)commentCellHeight
{
    CGSize size = [self.lbsComment sizeWithFont:FONTSYS(15) constrainedToSize:CGSizeMake(self.view.width-110, 1000)];
    return size.height + 32;
}
- (CGFloat)imageCellHeight
{
    NSInteger count = self.imageList.count;
    return (((count-1)/3)+1)*60+34+(count/3)*5;
}
- (CGFloat)soundCellHeight
{
    return  45;
}

#pragma mark cells
- (UITableViewCell *)adressCell
{
    static NSString *cellID1 = @"cellID1";
    CMPLbsCustomTableViewCell *cell = [[[CMPLbsCustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID1] autorelease];
    cell.cellType = 0;
    cell.contentText =  self.lbsItem.lbsAddr;
    return cell;
}
- (UITableViewCell *)imageCell
{
    static NSString *cellID3 = @"cellID3";
    CMPLbsImageShowTableViewCell *cell = [[[CMPLbsImageShowTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID3] autorelease];
    cell.delegate = self;
    [cell setCellWithAttachmentList:self.imageList];
    return cell;
}
- (UITableViewCell *)soundCell
{
    static NSString *cellID4 = @"cellID4";
    CMPLbsSoundShowTableViewCell *cell = [[[CMPLbsSoundShowTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID4] autorelease];
    [cell setCellWithAttachmentList:self.audioList];
    [cell setSoundSecond:_soundDuration];
    return cell;
}
- (UITableViewCell *)commentCell
{
    static NSString *cellID2 = @"cellID2";
    CMPLbsCustomTableViewCell *cell = [[[CMPLbsCustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID2] autorelease];
    cell.cellType = 1;
    cell.contentText =  self.lbsComment;
    
    return cell;
}

#pragma mark CMPLbsImageShowTableViewCellDelegate
- (void)lbsImageShowTableViewCell:(CMPLbsImageShowTableViewCell *)cell imageIndex:(NSInteger)index attchmentList:(NSArray *)imageList
{
    CMPImageShowViewController *aVC = [[CMPImageShowViewController alloc] init];
    aVC.attachmentList = imageList;
    aVC.pageIndex = index;
    
    [self.navigationController pushViewController:aVC animated:YES];
    
    SY_RELEASE_SAFELY(aVC);
}

#pragma mark UITableViewDataSource &&  UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSInteger count = 1;
    if (self.lbsComment && self.lbsComment.length >0) {
        count ++;
    }
    
    if (self.imageList && self.imageList.count >0) {
        count ++;
    }
    
    if (self.audioList && self.audioList.count >0) {
        count ++;
    }
    return count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        return [self adressCellHeight];
    }
    else if(indexPath.row == [self commentRow]){
        return [self commentCellHeight];
    }
    else if(indexPath.row == [self audioRow]){
        return [self soundCellHeight];
    }
    else if (indexPath.row == [self imageRow]){
        return [self imageCellHeight];
    }
    return 0;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        return [self adressCell];
    }
    else if(indexPath.row == [self commentRow]){
        return [self commentCell];
    }
    else if(indexPath.row == [self audioRow]){
        return [self soundCell];
    }
    else if (indexPath.row == [self imageRow]){
        return [self imageCell];
    }
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark download sound but not finish
- (BOOL)requestDownloadSound
{
    return NO;
    BOOL needDownloadSound = NO;
    MAttachment *att = nil;
    for (MAttachment *attachment in self.lbsItem.attachmentList) {
        if([attachment.suffix isEqualToString:@"AMR"] && !needDownloadSound){
            att = attachment;
            needDownloadSound = YES;
        }
    }
    if (!att) {
        return NO;
    }
    if (!_needDownloadSound) {
        return NO;
    }
    _needDownloadSound = NO;
//    SyAttachment *aAttachment = [[SyAttachment alloc] initWithMAttachmentBase:att];
//    [_fileDownloadBiz cancel];
//    [_fileDownloadBiz release];
//    SyFileDownloadBizParam *aParam = [[SyFileDownloadBizParam alloc] init];
//    aParam.delegate = self;
//    aParam.title = aAttachment.fullName;
//    aParam.createDate = aAttachment.value.createDate;
//    aParam.modifyTime = aAttachment.value.modifyTime;
//    aParam.size = aAttachment.value.size;
//    aParam.attID = [NSString stringWithFormat:@"%lld",att.attID];
//    aParam.type = kDownloadFileType_Att;
//    aParam.vCode = aAttachment.value.verifyCode;
//    _fileDownloadBiz = [SyBizManager instanceSyFileDownloadBiz:aParam];
//    [_fileDownloadBiz request];
//    [aParam release];
//    // show infor
//    if (att.size > 1024*1024*10) {
//        [[SyGlobleManager sharedSyGlobleManager] pushMarqueeView:SY_STRING(@"common_downloadBidDoc_needToolongTime_instability")];
//    }
//    SY_RELEASE_SAFELY(aAttachment);
    return YES;
}

/* download
- (void)bizDidStartLoad:(SyBaseBiz *)aBiz
{
    [self showLoadingView];
}

- (void)biz:(SyBaseBiz *)aBiz didFailLoadWithError:(NSError *)error
{
    [self hideLoadingView];
}
- (void)bizDidFinishLoad:(SyBaseBiz *)aBiz
{
    [self hideLoadingView];
    if(aBiz == _hepler.getAttendanceOtherByIdBiz){
        SyGetMAttendanceOtherByIdBiz *otherBiz = (SyGetMAttendanceOtherByIdBiz *)aBiz;
        _singleView.currentMemberMemberIcon = otherBiz.mAttendanceOther.belongUserIcon;
        _singleView.currrentUserName = otherBiz.mAttendanceOther.belongUserName;
        [_singleView showDetailWithItem:otherBiz.mAttendanceOther];
        [self addAnnotationWithItem:otherBiz.mAttendanceOther];
 
    }else if (aBiz == _fileDownloadBiz){
        SyFileDownloadBiz *biz = (SyFileDownloadBiz *)aBiz;
        NSString *aPath = biz.downloadDestinationPath;
        _soundDuration = [CMPSoundPlayer durationForSoundPath:aPath];
        [_singleView.tableView reloadData];
    }
}

- (void)handleBizAlertView:(SyBaseBiz *)aBiz infos:(NSDictionary *)aDict
{
    
    if(_fromRemoteMessage){
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
    }else{
        if(self.navigationController){
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
}
*/


@end

