//
//  SPConstant.h
//  定义了各种常量，枚举值
//
//  Created by CRMO on 2017/2/11.
//
//

#ifndef SPConstant_h
#define SPConstant_h

//获取小致登录信息接口状态
typedef enum {
    XiaozhiMessageRequestStatus_normal = 0,//还没请求
    XiaozhiMessageRequestStatus_start,//开始
    XiaozhiMessageRequestStatus_success,//成功
    XiaozhiMessageRequestStatus_RequestFailed//失败
}XiaozhiMessageRequestStatus;


typedef enum {
    IntentType_Search = 0,
    IntentType_Create = 1
}IntentType;

typedef NS_ENUM(NSInteger,XZIntentState) {
    XZIntentState_Normal = 0,
    XZIntentState_SearchCol = 1,
    XZIntentState_SearchDoc = 2,
    XZIntentState_SearchBul = 3,
    XZIntentState_SearchNews = 4,
    XZIntentState_SearchStatistics = 5,//查报表
    XZIntentState_SearchSchedule = 6,//播报今日安排
    XZIntentState_Call = 7,
    XZIntentState_SendMessage = 8,
    XZIntentState_SendIMMessage = 9,
    XZIntentState_FindMan = 10,
    XZIntentState_InCreateColl = 11,
    XZIntentState_InLocalIntent = 12,//平台意图
    XZIntentState_InFAQIntent = 13,//FAQ 新建 平台意图
    XZIntentState_CWaiting = 14,//新建意图，流程已完成，等待以下事件：发送、查看、取消
    XZIntentState_PWaiting = 15,//显示人员卡片后，等待以下事件：打电话、发短信。。。。。
    XZIntentState_LWaiting = 16,//请假，等待以下事件：发送、取消、修改      新建日程   请假报错的等待 ？？？？？？？？
};

typedef enum {
    XZIntentJsonFile_Downloading = 1,
    XZIntentJsonFile_Sucess,
    XZIntentJsonFile_UpdateFailed,
    XZIntentJsonFile_DownloadFailed
} XZIntentJsonFileState;

typedef enum : NSUInteger {
    SPAnswerUnknown,    // 未知类型
    SPAnswerShortText,  // 短文本，例如：协同标题
    SPAnswerLongText,   // 长文本，例如：协同正文
    SPAnswerMember,     // 人员
    SPAnswerOption,     // 选项，例如：发送或取消
    SPAnswerSelectPeople, // 选人
    SPAnswerSelectPeopleOption, // 选人重复人员选择
    SPAnswerSubmit, // 提交
    SPAnswerView, // 查看
    SPAnswerPrompt, // 不需要用户回答，仅展示即可，如：查询文档时的结果展示
    SPAnswerSleep, // 睡眠，等待用户点击按钮继续选人
    SPAnswerExit, // 结束场景
} SPAnswerType;


typedef NS_ENUM(NSInteger, XZMoodState) {
    XZMoodStateInactive,//未激活
    XZMoodStateActive,//激活状态 动画
    XZMoodStateFlying,//动画中
    XZMoodStateAnalysising,//语义分析中
    XZMoodStateAnalysisFailure,//语义解析失败
    XZMoodStateError//遇到异常如断网、未识别成功（哭脸）
};

typedef NS_ENUM(NSUInteger, SPSpeechEngineType) {
    SPSpeechEngineIFly, //  科大讯飞
    SPSpeechEngineBaidu,    //  百度
    SPSpeechEngineSougou,   // 搜狗
};

typedef NS_ENUM(NSUInteger, SpeechRecognizeType) {
    SpeechRecognizeShortText,   // 短文本
    SpeechRecognizeLongText,  // 长文本
    SpeechRecognizeFirstCommond,  // 一级命令词
    SpeechRecognizeMember,  // 人员
    SpeechRecognizeMemberOption, //人员 重名
    SpeechRecognizeOption,  // 选项
    SpeechRecognizeSearchColText,  // 搜索协同
    SpeechRecognizeFullTextSearch,  // 全文检索-----非小致部分，仅用于M3全文检索
};

#define XZ_NAME(args) [NSString stringWithFormat:@"XZbundle.bundle/%@",args]
#define XZ_IMAGE(args) [UIImage imageNamed:XZ_NAME(args)]


//QA 界面显示
#define kNotificationName_QAChatOn @"kNotificationName_QAChatOn"
#define kNotificationName_QAChatOff @"kNotificationName_QAChatOff"


#define KXZIntentOpenType_LoadApp   @"loadApp"
#define KXZIntentOpenType_Url       @"url"

#define KXZIntentUrlType_Rest     @"rest"
#define KXZIntentUrlType_Remote   @"remote"

#define kIntentStepType_Text             @"text"//普通文本
#define kIntentStepType_LongText         @"longtext"//普通文本
#define kIntentStepType_Number           @"number"// 数字
#define kIntentStepType_Date             @"date" //日期控件 yyyy-MM-dd
#define kIntentStepType_Datetime         @"datetime" //日期时间控件 yyyy-MM-dd hh:mm
#define kIntentStepType_Timestamp         @"timestamp" //时间戳 string

#define kIntentStepType_Member           @"member" //单选人员
#define kIntentStepType_Multimember      @"multimember"//多选人员
/*单选人员，返回人员id,语音选人时，将选中的人员使用Member|id的方式组合返回数据*/
#define kIntentStepType_MemberId         @"memberId"
/*多选人员，返回多个人员id格式同上，多个人员用,逗号分隔，如：Member|id1,Member|id2*/
#define kIntentStepType_MultimemberId    @"multimemberId"
#define kIntentStepType_Department       @"department"//单选部门（待定是否支持
#define kIntentStepType_Multidepartment  @"multidepartment"//多选部门（待定是否支持）
#define kIntentStepType_Checkbox         @"checkbox"//复选框
#define kIntentStepType_Radio            @"radio"//单选框组
#define kIntentStepType_Enum             @"enum"// 枚举类型
#define kIntentStepType_ObtainOption     @"obtainOption"//需要发请求从server获取


#define kIntentSlot_Time        @"user_time"
#define kIntentSlot_BeginTime   @"user_begintime"
#define kIntentSlot_EndTime     @"user_endtime"
#define kIntentSlot_Title       @"user_wild_title"
#define kIntentSlot_Content     @"user_wild_content"
#define kIntentSlot_Person      @"user_person"
#define kIntentSlot_Location    @"user_location"

#define kIntentMemberKey_Id        @"id"
#define kIntentMemberKey_Name      @"name"
#define kIntentMemberKey_Type      @"type"
#define kIntentMemberKey_Post      @"post"
#define kIntentMemberKey_Account   @"account"

#define kIntentMember_Me                   @"我"
#define kIntentMemberTypeValue_Member      @"Member"
#define kIntentCommand_Cancel              @"取消"

#define kBUnitIntent_UserName    @"user_name"
#define kBUnitIntent_UserPerson  @"user_person"
#define kBUnit_Key_Title         @"user_wild_title"


#define kGetXiaozhiMessage @"/rest/xiaozhi/getXiaozhiMessage"

//url
#define kIntentCheckMd5Url              @"/rest/xiaozhi/platform/app/checkMd5"
#define kIntentJsonDownloadUrl          @"/rest/xiaozhi/platform/app/download"
#define kSPErrorCorrectionCheckUrl      @"/rest/xiaozhi/platform/speechErrorCorrection/checkMd5"
#define kSPErrorCorrectionDownloadUrl   @"/rest/xiaozhi/platform/speechErrorCorrection/download"

#define kPinyinRegularCheckUrl      @"/rest/xiaozhi/platform/rosterPinyin/checkMd5"
#define kPinyinRegularDownloadUrl   @"/rest/xiaozhi/platform/rosterPinyin/download"



#define kCreateCollUrl        @"/rest/coll/sendByRobot"
#define kSearchCollUrl        @"/rest/coll/getCollListByRobot"
#define kSearchStatisticsUrl  @"/rest/capForm/getFormQueryTree"
#define kSearchNewsUrl        @"/rest/cmpNewsList/searchByRobot?&option.n_a_s=1"
#define kDownloadAttUrl       @"/rest/attachment/file/%@"
#define kTodayArrangeUrl      @"/rest/events/arrangetimes"
#define kSearchDocUrl         @"/rest/docs/archiveList4XZ"
#define kSearchBulUrl         @"/rest/cmpBulletins/searchByRobot"
#define kLeaveDaysUrl         @"/rest/xiaozhi/cacldays"
#define kSendLeaveUrl         @"/rest/xiaozhi/send/leave"
#define kCheckLeaveUrl        @"/rest/xiaozhi/check/leave"
#define kSmartMsgUrl          @"/rest/xiaozhi/obtainMessage"
#define kCalEventAuthUrl      @"/rest/events/auths?&option.n_a_s=1"
#define kQAPermissionUrl      @"/rest/xiaozhi/aiApp"
#define kOpenQAUrl            @"/rest/xiaozhi/aiApp/%@"


#define kQAAppsUrl           @"/rest/xiaozhi/qa/getQaApps"
#define kQACategorysUrl      @"/rest/xiaozhi/qa/getQaCategorys"
#define kQACategoryInfoUrl   @"/rest/xiaozhi/qa/getQaInfoByCategoryId"
#define kAllQaKeywordUrl     @"/rest/xiaozhi/qa/getAllQaKeywordByCurrentUser"
#define kAllQaKeywordByAppIdUrl     @"/rest/xiaozhi/qa/getAllQaKeywordByQaAppId"
#define kQAChatUrl     @"/rest/xiaozhi/qa/chat?option.n_a_s=1"

#define kXiaozChatUrl     @"/rest/xiaozhi/ai/chatXiaoz?option.n_a_s=1"


#define kQAAppsCardUrl @"http://xiaoz.v5.cmp/v1.0.0/html/qa/xiaoz-qa-card.html"
#define kXiaozQACardUrl @"http://xiaoz.v5.cmp/v1.0.0/html/qa/xiaoz-qa-xzcard.html"
#define kXiaozAllSearchUrl @"http://xiaoz.v5.cmp/v1.0.0/html/xiaoz-all-search-card.html"
#define kXiaozQAMsgUrl @"http://xiaoz.v5.cmp/v1.0.0/html/message/xiaoz-intelligent-msg.html"
#define kXiaozQAMsgSettingUrl @"http://xiaoz.v5.cmp/v1.0.0/html/message/xiaoz-message-setting.html"
#define kXiaozQAView30HistoryUrl @"http://xiaoz.v5.cmp/v1.0.0/html/message/xiaoz-message-historyList.html?qaApp=true"


#define kIntentChoosedPersonMsg     @"已选择， 请继续选人或命令“##下一步##”。"
#define kIntentChoosePersonMutErrorMsg @"我没找到这个人，请继续选人或命令##下一步##。"
#define kIntentChoosePersonErrorMsg @"我没找到这个人。"
#define kChooseIntentInfo @"请问，你需要打开什么？"
#define kIntentUnavailable  @"对不起，没有找到该应用"
#define kXZContactsDowloading @"对不起，正在下载通讯录，请稍后使用小致!"
#define kXZContactsUnavailable @"对不起，你没有访问通讯录权限 ，请联系管理员进行授权。"
#define kBUnitErrorInfo @"我不知道应该怎么答复你。"


/*科大讯飞AppID*/
#define kIFLY_APPID      @"58aa9d54"

/*百度语音 --- 默认*/
#define kBaiduSpeechAppId     @"11164277" //299使用，用于测试，正式版本用server返回
#define kBaiduSpeechApiKey     @"aS93MLEXm7SX4Sj8LHqjGpTQ"//299使用，用于测试，正式版本用server返回
#define kBaiduSpeechSecretKey     @"j1L3EdCRZGYfCs32nTzGxX8PuphLvrOb"//299使用，用于测试，正式版本用server返回

#define kBUnitSceneID  @"15049"
#define kBUnitAppId     @"10559423"
#define kBUnitApiKey     @"9GncQTDh8A00kZ8tFVUGsy43"
#define kBUnitSecretKey     @"OdjdmkQvHLuPNzuQ17eVdcQ04zWKVcN5"

#define kFAQ_KB @"FAQ_KB_"//智能QA标志
#define kBUnitFAQResultKey   @"qid"
#define kBUnitFAQGuide @"faq_select_guide"

#define kFAQ_OPEN     @"FAQ_APP_OPEN"
#define kFAQ_PROCESS  @"FAQ_APP_FORM"
#define kFAQ_OPENTEMPLAT  @"FAQ_APP_TEMPLATE"


/* UNIT 场景意图*/
#define kBUnitIntent_CALL    @"CALL"//打电话
#define kBUnitIntent_SENDMESSAGE    @"SENDMESSAGE"//发短信
#define kBUnitIntent_ARRANGE    @"ARRANGE"//查看安排
//#define kBUnitIntent_CREATECOORDINATI    @"CREATECOORDINATI"//创建协同---弃用了
#define kBUnitIntent_LOOKUPPERSON    @"LOOKUPPERSON"//查人员
#define kBUnitIntent_LOOKUP    @"LOOKUP"//查询
#define kBUnitIntent_LEAVE @"LEAVE"//请假
#define kBUnitIntent_AGREE  @"AGREE"//同意 发送、、、、、、
#define kBUnitIntent_DISAGREE  @"DISAGREE"//不同意 取消、、、、、、
#define kBUnitIntent_MODIFY  @"MODIFY"//修改、、、、
#define kBUnitIntent_QUIT  @"QUIT"//退出小致
#define kBUnitIntent_HELP @"HELP"//帮助
#define kBUnitIntent_NUMSELECTION @"NUMSELECTION"//第几位 重名人员选择第几个
#define kBUnitIntent_INTRODUCE @"INTRODUCE"//介绍，≈≈帮助
#define kBUnitIntent_LOOKUPFLOW @"LOOKUPFLOW"//查协同
#define kBUnitIntent_LOOKUPSTA @"LOOKUPSTA" //查报表
#define kBUnitIntent_LOOKUPBUL @"LOOKUPBUL"//查公告
#define kBUnitIntent_LOOKUPDOC @"LOOKUPDOC"//查文档
#define kBUnitIntent_LOOKUPEXPENSE @"LOOKUPEXPENSE"//查找报销单
#define kBUnitIntent_LOOKUPNEWS @"LOOKUPNEWS"//查新闻


#define kBUnitIntent_CREATEFLOW @"CREATEFLOW"//创建协同--普通协同
/* UNIT 场景意图  -----  打开M3应用模块*/
#define kBUnitIntent_OPENSURVEY @"OPENSURVEY"//打开调查
#define kBUnitIntent_OPENTASK @"OPENTASK"//打开任务
#define kBUnitIntent_OPENSTATISTICS @"OPENSTATISTICS"//打开统计
#define kBUnitIntent_OPENARRANGE @"OPENARRANGE"//打开安排（时间安排）
#define kBUnitIntent_OPENDOCUMENT @"OPENDOCUMENT"//打开公文
#define kBUnitIntent_OPENSIGN @"OPENSIGN"//打开签到
#define kBUnitIntent_OPENNEWS @"OPENNEWS"//打开新闻
#define kBUnitIntent_OPENMEET @"OPENMEET"//打开会议
#define kBUnitIntent_OPENDOC @"OPENDOC"//打开文档
#define kBUnitIntent_OPENBUL @"OPENBUL"//打开公告
#define kBUnitIntent_OPENFLOW @"OPENFLOW"//打开协同
#define kBUnitIntent_OPENDISCUSS @"OPENDISCUSS"//打开讨论
#define kBUnitIntent_OPENSHOW @"OPENSHOW"//打开大秀享空间
#define kBUnitIntent_OPENSALARY @"OPENSALARY"//打开工资条
#define kBUnitIntent_OPENSTORE @"OPENSTORE"//打开我的收藏
#define kBUnitIntent_OPENPERFORMANCE @"OPENPERFORMANCE"//打开行为绩效
#define kBUnitIntent_OPENREPORT @"OPENREPORT" //打开报表
#define kBUnitIntent_OPENMINE @"OPENMINE"//打开我的
#define kBUnitIntent_OPENTODOLIST @"OPENTODOLIST"//打开待办
#define kBUnitIntent_OPENADDBOOK @"OPENADDBOOK"//打开通讯录

#define kBUnitIntent_MORE @"MORE" //加载、打开 更多
#define kBUnitIntent_OPEN @"OPEN"//打开
#define kBUnitIntent_SENDIMMESSAGE @"SENDIMMESSAGE"//发致信消息
#define kBUnitIntent_CREATESCHEDULE  @"CREATESCHEDULE"//发起日程

#define kBUnitIntent_LOOKUPSMARTMSG  @"LOOKUPSMARTMSG"//智能消息查询某天的工作提醒






//查协同
#define kBUnit_LOOKUPFLOW_TYPE_MANE @"发起人"
#define kBUnit_LOOKUPFLOW_TYPE_TITLE @"标题"
#define kBUnit_LOOKUPFLOW_STATE_DONE @"已办"
#define kBUnit_LOOKUPFLOW_STATE_TODO @"待办"
#define kBUnit_LOOKUPFLOW_STATE_SEND @"已发"


/* QA 问答*/
#define kBUnitIntent_FAQ_ANSWER  @"FAQ_ANSWER"//问答
#define kBUnitIntent_FAQ_BYE  @"BUILT_FAQ_BYE"//问答
#define kBUnitIntent_FAQ_CURSE  @"BUILT_FAQ_CURSE"//问答
#define kBUnitIntent_FAQ_HELLO  @"BUILT_FAQ_HELLO"//问答
#define kBUnitIntent_FAQ_PRAISE  @"BUILT_FAQ_PRAISE"//问答
#define kBUnitIntent_FAQ_THANKS  @"BUILT_FAQ_THANKS"//问答
/* UNIT 场景操作ID  需要澄清的*/
#define kBUnitIntentId_CALL    @"call_satisfy"//打电话
#define kBUnitIntentId_SENDMESSAGE    @"sendmessage_satisfy"//发短信
#define kBUnitIntentId_ARRANGE    @"arrange_satisfy"//查看安排
#define kBUnitIntentId_CREATECOORDINATI    @"createcoordinati_satisfy"//创建协同
#define kBUnitIntentId_LOOKUPPERSON    @"lookupperson_satisfy"//查人员
#define kBUnitIntentId_LOOKUP    @"lookup_satisfy"//查询
#define kBUnitIntentId_LEAVE      @"leave_satisfy"//请假

#define kXZ_M3APPLIST @"kXZ_M3APPLIST"//m3应用APP List

#define kXZ_MsgIsFirst  @"kXZ_MsgIsFirst"
#define kXZ_MsgIsNotFirst  @"kXZ_MsgIsNotFirst"






#define kScheduleModelHeight  (20+FONTSYS(16).lineHeight*2)
#define kOverdueModelHeight  (20+FONTSYS(16).lineHeight)
#define kWillDoneItemHeight (25+FONTSYS(16).lineHeight+FONTSYS(12).lineHeight )


/* 调试模式开关 */
#define SPEECH_DEBUG_MODE

#define SPEECH_END_KEY @"好了小致" // 长文本结束词
#define SPEECH_END_KEY2 @"好了，小致" // 长文本结束词2
#define SPEECH_END_KEY3 @"好了小智" // 长文本结束词3
#define SPEECH_END_KEY4 @"好了，小智" // 长文本结束词4
#define SPEECH_END_KEY5 @"好了小子" // 长文本结束词5
#define SPEECH_END_KEY6 @"好了，小子" // 长文本结束词6

#define SPEECH_END_MEMBER @"下一步" // 选人流程的结束词

#define SPEECH_MAX_SHORTTEXT 300 // 短文本最大字数
#define SPEECH_MAX_MEMBER 4000 // 语法文件最大支持人数，超过4000人截取4000人
#define SPEECH_WAKEUP_MIN_SCORE 20 // 唤醒门限值

#define SPEECH_SUBMIT_SUCCESS @"success"    // 网络提交成功
#define SPEECH_SUBMIT_FAIL @"fail"  // 网络提交失败

//--------------------科大讯飞前后置时间定义专区------------------------
//------------------------------------------------------
#define VAD_TIMEOUT @"10000" // 语音输入超时时间
#define VAD_MEMBER_EOS @"5000" // 人员输入后置时间（输入第二个人开始，第一个人的前置时间为超时时间）
#define VAD_MEMBER_BOS @"10000" // 人员输入前置时间

#define OUT_OF_VOCA @"nomatch:out-of-voca" // 拒识
#define NOMATCH_NOISY @"nomatch:noisy" // 噪声太大
#define NOMATCH_LOWVOLUME @"nomatch:low-volume"
#define NOMATCH_ALL @"nomatch"

//--------------------指令插件key------------------------
//------------------------------------------------------
#define COMMOND_KEY_COMMONDID @"commondID" // 命令ID
#define COMMOND_KEY_STEPS @"steps" // 步骤
#define COMMOND_KEY_TYPE @"type"   // 指令节点类型
#define COMMOND_KEY_STEPINDEX @"stepIndex"   // 步骤序列号
#define COMMOND_KEY_WORD @"word"   // 朗读内容
#define COMMOND_KEY_ISREADWORD @"isReadWord"   // 是否朗读
#define COMMOND_KEY_KEY @"key"   // 拼接数据时的key
#define COMMOND_KEY_SUCCESSSTEPINDEX @"successStepIndex"   // 成功跳转节点
#define COMMOND_KEY_FAILSTEPINDEX @"failStepIndex"   // 失败跳转节点
#define COMMOND_KEY_ISRESTART @"isRestart"   // 是否重新开始监听

#define COMMOND_KEY_OPTIONSTEPS @"optionSteps"   // 选择节点选项
#define COMMOND_KEY_OPTIONKEY @"optionKey"   // 选择节点选项的key
#define COMMOND_KEY_OPTION_STEPINDEX @"stepIndex"   // 选择节点选项的stepIndex
#define COMMOND_KEY_ALERTINFO @"alertInfo"   // 选择节点弹出提示

//-------------------- end------------------------

//-----------指令插件value枚举值--------------------
#define COMMOND_VALUE_TYPE_SHORTTEXT @"shorttext"  // 短文本
#define COMMOND_VALUE_TYPE_LONGTEXT  @"longtext"  // 长文本
#define COMMOND_VALUE_TYPE_MEMBER  @"member"  // 人员选择
#define COMMOND_VALUE_TYPE_OPTION  @"option"  // 选项
#define COMMOND_VALUE_TYPE_PROMPT  @"prompt"  // 不需要用户回答，仅展示即可
#define COMMOND_VALUE_TYPE_SUBMIT  @"submit"  // 提交
#define COMMOND_VALUE_TYPE_VIEW  @"view"  // 查看
#define COMMOND_VALUE_TYPE_SCHEDULE  @"schedule"  // 看今日安排

//-----------AnswerResultBlock的result返回key--------------------
#define ANSWERRESULTBLOCK_KEY_TYPE @"type"
#define ANSWERRESULTBLOCK_KEY_STEPINDEX @"stepIndex"
#define ANSWERRESULTBLOCK_KEY_KEY @"key"    // 提交时的key
#define ANSWERRESULTBLOCK_KEY_VALUE @"value"    // 最终值
#define ANSWERRESULTBLOCK_KEY_NAMES @"names"    // 选择的名字
#define ANSWERRESULTBLOCK_KEY_NEWLINE @"newline"    // 选人需要换行
#define ANSWERRESULTBLOCK_KEY_MEMBER_PROMT @"memberNeedPromt"    // 是否需要提示已选择的人
#define ANSWERRESULTBLOCK_KEY_PLAN @"plan"    // 今日安排
#define ANSWERRESULTBLOCK_KEY_BEYONDDATE @"beyonddate"    // 超期数据
#define ANSWERRESULTBLOCK_KEY_PLAN_SPEAK @"planspeak"    // 查看今日待办第一次朗读字符串
#define ANSWERRESULTBLOCK_KEY_SEARCHDOC @"searchdoctitle"    // 查看今日待办第一次朗读字符串
#define ANSWERRESULTBLOCK_KEY_SEARCHMAN @"searchman"    // 查找人
#define ANSWERRESULTBLOCK_KEY_SENDMESSAGE @"sendmessage"    // 发短信
#define ANSWERRESULTBLOCK_KEY_CALLPHONE @"callphone"    // 打电话
#define ANSWERRESULTBLOCK_KEY_SEARCHTITLE @"searchtitle"    // searchtitle

#define ANSWERRESULTBLOCK_KEY_MEMBER_SELECTED @"memberSelected"    // 选择的名字

//-----------查看今日安排类型--------------------
#define SCHEDULE_TYPE_TASK   @"task" // 任务
#define SCHEDULE_TYPE_TASK_MANAGE   @"taskManage" // 任务
#define SCHEDULE_TYPE_PLAN   @"plan" // 计划
#define SCHEDULE_TYPE_MEETING   @"meeting" // 会议
#define SCHEDULE_TYPE_EVENT   @"event" // 时间
#define SCHEDULE_TYPE_Calender   @"calendar" // 时间
#define SCHEDULE_TYPE_COLLABORATION   @"collaboration" // 协同
#define SCHEDULE_TYPE_EDOC   @"edoc" // 公告


#define kM3AppIDInHouse @"com.seeyon.m3.inhouse.dis"    // 企业版本App ID
#define kM3AppIDInAppStore @"com.seeyon.m3.appstore.new.phone" // App store版本 APP ID

@protocol XZMainViewControllerDelegate <NSObject>;

- (void)mainViewControllerDidDismiss;
- (void)mainViewControllerShouldSpeak;
- (void)mainViewControllerShouldStopSpeak;
- (BOOL)mainViewControllerNeedAlertWhenClickCloseBtn;
- (void)mainViewControllerVoiceStateChange:(BOOL)on;
/*analysis  是否分析 比如文字点击事件就不需要分析，而文本输入就需要解析*/
- (void)mainViewControllerInputText:(NSString *)text;
//文本点击事件
- (void)mainViewControllerTapText:(NSString *)text;
- (void)mainViewControllerDidSelectMembers:(NSArray *)members skip:(BOOL)skip;//skip 是否结束选人，进行下一步
//启动用于开启监听的语音唤醒
- (void)mainViewControllerShouldstartWakeup;
//启动用于关闭监听的语音唤醒
- (void)mainViewControllerShouldstopWakeUp;
- (void)mainViewControllerDidAppear;
- (void)mainViewControllerWillDisappear;

@end


#endif /* XZIntentConstant_h */

