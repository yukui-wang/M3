//
//  SPSmartEngine.h
//  MSCDemo
//
//  Created by CRMO on 2017/2/11.
//
//

#import <Foundation/Foundation.h>
#import "SPConstant.h"
#import "SPBaseCommondNode.h"
#import "XZCellModel.h"
#import "SPScheduleHelper.h"
#import "SPSearchHelper.h"
#import "SPCommondNodeFactory.h"
#import "SPViewCommondNode.h"
#import "SPTools.h"
#import "XZLeaveModel.h"
#import "XZMemberModel.h"
#import "XZLeaveTypesModel.h"
#import "XZLeaveErrorModel.h"
#import "XZOptionMemberModel.h"
#import "SPSearchColHelper.h"
#import "SPSearchDocHelper.h"
#import "SPSearchBulHelper.h"
#import "SPSearchNewsHelper.h"
#import "XZCreateModel.h"
#import "SPBaiduUnitInfo.h"
#import "BUnitManager.h"
#import "XZAppIntent.h"
#import "XZOpenAppIntent.h"
#import <CMPLib/CMPOfflineContactMember.h>
#import "XZOptionMemberParam.h"
@class SPSmartEngine;

typedef void(^SmartMembersBlock)(NSArray *result, BOOL cancel,NSString *extData);


@protocol SPSmartEngineDelegate <NSObject>

- (void)needReadWord:(NSString *)word speakContent:(NSString *)speakContent;
- (void)needShowHumanWord:(NSString *)word newLine:(BOOL)isNewLine;
- (void)needShowMemberPromt:(NSString *)members;
- (void)needHumanSpeakNewLine;
- (void)needAnswerFirstCommond;
- (void)needAnswerShortText;
- (void)needAnswerLongText;
- (void)needAnswerMemberIsShow:(BOOL)isShow isSelect:(BOOL)isSelect;

/*
 optionInfo contain :
    members  人员列表，必填
    speakContent 小致说的话，必填
    showContent 显示的文本，必填
    extData 额外信息，非必填
 */
- (void)needChooseFormOptionMembers:(XZOptionMemberParam *)param block:(SmartMembersBlock)block;
- (void)needHideMemberView;
- (void)needAnswerOption;
- (void)stepDidEnd:(BOOL)isRestart;
- (void)needSendColl:(NSDictionary *)result;
- (void)needJumpToColl:(NSDictionary *)result;
- (void)needShowCloseAlert;
- (void)needShowCloseAlertView;

//用于选人是否可以下一步
- (void)memberNodeWillNextStep:(BOOL)will;
/**隐藏小致页面*/
- (void)needClose;
/**睡眠回调*/
- (void)needSleep;
/**长文本识别结束*/
- (void)didCompleteLongText;
- (void)needUnknownCommond;
/*继续自动识别*/
- (void)needContinueRecognize;
/*需要启动唤醒*/
- (void)needStartWakeup;
/**是否有请假单*/
- (void)needCheckLeaveForm:(void(^)(BOOL success,NSString *msg))complete;
/*显示请假类型选项*/
- (void)needShowLeaveTypes:(XZLeaveTypesModel *)model;
/**发请假单*/
- (void)needSendLeaveForm:(XZLeaveModel *)model;
/*显示帮助信息*/
- (void)needShowHelpInfo;
/*能否发短信*/
- (BOOL)canSendSMS;
- (void)needCallPhone:(NSString *)number;
/*发短信*/
- (BOOL)needSendSMS:(NSString *)phoneNumber;
/*发致信*/
- (BOOL)needSendIMMsg:(CMPOfflineContactMember *)member content:(NSString *)content;

/*是否显示搜索子项*/
- (void)needShoWOrHideSearchType:(BOOL) show;
/*查看今日安排 */
- (void)needGetTodayArrange;
- (void)needShowSchedule:(SPScheduleHelper *)helper;
- (void)needShowTodo:(SPScheduleHelper *)result;
/*查协同*/
- (void)needSearchCollWithParam:(NSDictionary *)param;
/*查文档*/
- (void)needSearchDoc:(NSString *)title;
/*查公告*/
- (void)needSearchBul:(NSString *)title;
/*查找报销单 */
- (void)needSearchExpenseWithParam:(NSDictionary *)param;
/*查报表*/
- (void)needSearchStatistics:(NSString *)title;
/*查新闻*/
- (void)needSearchNews:(NSString *)title;
/**/
- (void)needSearchSmartMsg:(NSString *)date;
/*显示搜索结果*/
- (void)needShowSearch:(SPSearchHelper *)helper;
/*显示人员卡片*/
- (void)needShowMemberCard:(CMPOfflineContactMember *)member showOK:(BOOL)ok;
/*打开M3应用模块*/
- (void)needOpenM3AppWithAppId:(NSString *)appId result:(void(^)(BOOL sucess))result;
- (void)needCreateObject:(XZCreateModel *)model;
- (void)needShowObject:(XZCreateModel *)model;
/*QAj回答*/
- (void)needShowQAAnswer:(NSString *)answer;
- (void)needHandleIntent:(XZAppIntent *)intent;
- (void)needShowOptionIntents:(NSArray *)intentArray;
- (void)needShowCancelCardInHistory;
@end

@interface SPSmartEngine : NSObject {
    XZLeaveTypesModel *_currentLeaveTypeModel;
    XZLeaveModel *_currentLeaveModel;//当前请假model
    XZCreateModel *_currentCreateModel;
    NSDictionary *_m3AppInfo;
//    SPBaseCommondNode *_currentNode;
    XZCellModel *_currentCellModel;
    NSInteger _intentErrorCount;
    NSInteger _unitFailureCount;
}

@property (weak, nonatomic) id<SPSmartEngineDelegate> delegate;
@property (nonatomic, strong)XZCellModel *currentCellModel;
@property (nonatomic, assign)BOOL useUnit;

@property (nonatomic, strong)NSString *searchTitleInfo;

@property (nonatomic, strong)CMPOfflineContactMember *currentMember;
/** 保存当前收集的数据 **/
@property (nonatomic, strong) NSMutableDictionary *currentResult;

+ (instancetype)sharedInstance;
- (void)setupBaseInfo:(SPBaiduUnitInfo *)info;
- (BOOL)setResult:(NSString *)result;
- (void)needResetUnitDialogueState;
- (NSString *)handleTitle:(NSString *)title;
// 是否在协同场景
- (BOOL)isInCol;
// 是协同场景已经选人
// 是否在打电话场景
- (BOOL)isInCallPhone;
// 是否在发短信场景
- (BOOL)isInSendMessage;
// 是否在找人场景
- (BOOL)isInFindMan;
/** 重置 */
- (void)resetSmartEngine;
/** 睡眠之后被唤醒，调用该函数继续之前流程*/
- (void)wakeUp;
- (SPBaseCommondNode *)getCurrentNode;
//是否是多选人员
- (BOOL)isMultiSelectMember;
- (void)handleScheduleResult:(NSString *)result;
- (void)handleSearchColResult:(NSString *)result info:(NSDictionary *)info;
- (void)handleSearchExpenseResult:(NSString *)result info:(NSDictionary *)info;
- (void)handleSearchStatisticsResult:(NSString *)result title:(NSString *)title;
- (void)handleSearchDocResult:(NSString *)result title:(NSString *)title;
- (void)handleSearchBulResult:(NSString *)result title:(NSString *)title;
- (void)handleSearchNewsResult:(NSString *)result title:(NSString *)title;

- (BOOL)isInSearchColl;
- (BOOL)isInSearchDoc;
- (BOOL)isInSearchBul;
/*查查报表*/
- (BOOL)isInSearchStatistics;
- (BOOL)isInCreateColl;
- (BOOL)isInSearchNews;
- (BOOL)isInSearchSchedule;
//是否是在搜索意图
- (BOOL)isInSearchIntent;


- (void)createColl;
- (BOOL)unavailableTitle:(NSString *)title;
- (void)needStartWakeup;
- (void)needSpeakContent:(NSString *)content;
- (NSString *)collStateWithString:(NSString *)str;
- (NSString *)collSateStrWithState:(NSString *)str;
- (void)needAnalysisText:(NSString *)text;
- (void)showUnitSay:(BUnitResult *) result;
- (void)needShowSearch:(SPSearchHelper *) helper;
- (void)needContinueRecognize;

- (void)handleTextWithUnit:(NSString *)string
                completion:(void (^)(NSError *error, BUnitResult *resultObject))completionBlock;

@property (strong, nonatomic) SPBaseCommondNode *currentNode;
/** 保存当前收集的数据 **/
/** 协同是否已经选人 **/
@property (nonatomic) BOOL isColHasMember;

@property (nonatomic, strong)XZLeaveTypesModel *currentLeaveTypeModel;

@property (nonatomic, strong)XZLeaveModel *currentLeaveModel;//当前请假model

@property (nonatomic, strong)XZCreateModel *currentCreateModel;
@property (nonatomic, strong)NSDictionary *m3AppInfo;

- (void)needHideMemberView;
- (void)showSearchTitleInfo:(NSString *)string;
- (void)showLeaveTypes;
- (void)LeaveFinishWithInfo:(NSDictionary *)info;
- (BOOL)needOpenM3AppWithAppId:(NSString *)appId  result:(void(^)(BOOL sucess))result;

- (void)stepDidEnd:(BOOL)isRestart;
- (void)startCommond:(NSString *)commond index:(NSString *)index;

@property (nonatomic, assign)XZIntentState intentState;
@property (nonatomic, assign)BOOL isClarifyMembers;//重复人员选择;

@property(nonatomic, copy)SmartMembersBlock membersBlock;

- (void)showMemberCard:(CMPOfflineContactMember *)member showOK:(BOOL)ok;

@end
