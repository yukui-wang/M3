//
//  XZDateUtilsTool.m
//  M3
//
//  Created by wujiansheng on 2019/2/13.
//


//#define kREGEX_NUMBER_YEAR @"([〇零一二三四五六七八九]{2,4}|[0-9]{2,4}|[前去昨今明后本当])年"//数字年
#define kREGEX_NUMBER_YEAR @"([〇零一二三四五六七八九]{2,4}|[0-9]{2,4})年"//数字年

#define kREGEX_NUMBER_MONTH @"(0?[1-9]|1[0-2]|[一二三四五六七八九十]|十[一二])月份?"//数字月份
#define kREGEX_NUMBER_DAY @"((([十二三]{1,2})?[一二三四五六七八九十])|([12]?[0-9]|3[01]))[日号]"//数字日-----国历
#define kREGEX_NUMBER_YMD @"(([〇零一二三四五六七八九]{2,4}|[0-9]{2,4})年)((0?[1-9]|1[0-2]|[一二三四五六七八九十]|十[一二])月份?)(((([十二三]{1,2})?[一二三四五六七八九十])|([12]?[0-9]|3[01]))[日号])"//年月日格式yyyy-mm-dd
#define kREGEX_NUMBER_YM @"([〇零一二三四五六七八九]{2,4}|[0-9]{2,4})年(0?[1-9]|1[0-2]|[一二三四五六七八九十]|十[一二])月份?"//年月格式yyyy-mm
#define kREGEX_NUMBER_MD @"(0?[1-9]|1[0-2]|[一二三四五六七八九十]|十[一二])月份?((([十二三]{1,2})?[一二三四五六七八九十])|([12]?[0-9]|3[01]))[日号]"//月日格式mm-dd
#define kREGEX_ALIAS_YMD @"([前去昨今明后本当]年)((0?[1-9]|1[0-2]|[一二三四五六七八九十]|十[一二])月份?)(((([十二三]{1,2})?[一二三四五六七八九十])|([12]?[0-9]|3[01]))[日号])?"//年有别名的日期格式yyyy-mm-dd获取mm-dd格式
#define kREGEX_NUMBER_WEEK @"^(?![上个下]{1,2})(星期[一二三四五六天日]|周[一二三四五六天日]|星期[123456]|周[123456]|礼拜[一二三四五六天]|礼拜[123456])"//数字周
#define kREGEX_LUNAR_MONTH1 @"(([一二三四五六七八九]|十[一二]|[1-9]|1[0-2])月)(初((10)|[一二三四五六七八九十123456789]))"//农历,有月的说法
#define kREGEX_LUNAR_MONTH2 @"([冬正腊]月)((初[一二三四五六七八九十])|(十[一二三四五六七八九])|(二十([一二三四五六七八九])?)|(三十)|(初?[123]?[0-9]))"//传统农历说法
#define kREGEX_LUNAR_DAY @"初([二三]?十?[一二三四五六七八九十]|[123]{0,2}[0-9])"//农历,无月的说法
#define kREGEX_DAY_ALIAS @"大前[天日]|[前昨今明后当][天日]|大后[天日]|半[天日]"//天的别名
#define kREGEX_WEEK_ALIAS @"(上上?周|[这本]周|下下?周|上个?星期|这个?星期|下个?星期|上个礼拜|这个礼拜|下个礼拜)([一二三四五六日123456末])?"//周别名
#define kREGEX_MONTH_ALIAS1 @"上个?月|这个?月|[当本]月|下个?月"//月别名
#define kREGEX_MONTH_ALIAS2 @"月[初末中]"//月别名2
#define kREGEX_MONTH_DAY_ALIAS @"(上个?月|这个?月|[当本]月|下个?月)(((([十二三]{1,2})?[一二三四五六七八九十])|([12]?[0-9]|3[01]))[日号])"//月别名+日
#define kREGEX_YEAR_ALIAS @"([前去昨今明后本当]年)?(年[初中末底终]|开年|[上下]半年)"//年别名
#define kREGEX_YEAR_WHOLE_ALIAS @"[前去昨今明后本当]年"//整年别名
#define kREGEX_TEN_DAYS @"[上中下]旬"//旬
#define kREGEX_QUARTER @"([一二三四1234]|[上下这本]个?)季度"//季度
#define kREGEX_TIME  @"([上中下]午|凌晨|午夜|傍晚|晚上|半夜)?((([十二]{1,2})?[一二三四五六七八九十两])|(零)|((\\d{1}|1\\d{1}|2[0-3])))([点时:])([整半])?((([二三四五]?十?[一二三四五六七八九十]|[12345]?[0123456789])分?)|([一二三123]刻钟?))?"
#define kREGEX_WORK_TIME  @"([前昨今明后]天)(下班前|一整天)"//工作时间段
#define kREGEX_LATEST_TIME @"最新|最近|当前|现在|目前"//当前时间点
#define kREGEX_NEXT_TIME @"接下来|后面"//下一个时间，当前时间点之后的1小时
#define kREGEX_NOON @"[早晚]上|[上下中]午|凌晨|午夜|傍晚|半夜|日末"//上下午
#define kREGEX_DAY_LENGTH @"([1234567890]{1,2}|[一二三四五六七八九十两]{1,3})天([前后])"//三天后，五天前

#define kREGEX_SOLAR_TERMS @"立春|雨水|惊蛰|春分|清明|谷雨|立夏|小满|芒种|夏至|小暑|大暑|立秋|处暑|白露|秋分|寒露|霜降|立冬|小雪|大雪|冬至|小寒|大寒"//24节气
#define kREGEX_FESTIVAL @"元旦节?|世界湿地日|情人节|爱耳日|青年志愿者服务日|三八节|三八妇女节|妇女节|国际妇女节|保护母亲河日|(中国)?植树节|白色情人节|(国际)?警察日|(世界|国际)?消费者权益日|三[一幺]五|315|(世界)?森林日|(世界)?睡眠日|(世界)?水日|(世界)?气象日|(世界)?防治结核病日|愚人节|(世界)?卫生日|清明节?|(世界)地球日|(世界)?知识产权日|(国际|五一)?劳动节|(五一|51)节?|(世界)?哮喘日|(中国|五四|54)?青年节|(五四|54)节|(世界)?红十字日|(国际|世界)?护士节|(国际)?家庭日|(世界)?电信日|(中国|全国)?学生营养日|(国际)?牛奶日|(世界)?无烟日|(国际|六一|61)?儿童节|(六一|61)节|(世界|国际)?环境日|(全国)?爱眼日|世界防治荒漠化和干旱日|(国际)?奥林匹克日|(全国)?土地日|(国际)?禁毒日|(中国)?共产党诞生日|党的生日|共党节|建党节|(国际)?建筑日|中国人民抗日战争纪念日|(中国)?抗战[节日]|世界人口日|(中国人民解放军|八一|81)?建军节|(八一|81)节|国际青年节|(国际)?扫盲日|(中国)?教师节|(中国)?脑健康日|(国际)?臭氧层保护日|(中国|全国)爱牙日|世界停火日|世界旅游日|(中华人民共和国|十一|11)?国庆节?|十一|(国际)?音乐[节日]|国际老年人日|世界动物日|(世界|国际)?教师节|全国高血压日|世界邮政日|(世界)?精神卫生日|世界标准日|国际盲人节|世界农村妇女日|世界粮食日|国际消除贫困日|联合国日|世界发展新闻日|(中国)?男性健康日|国际生物多样性日|万圣节|中国记者日|消防宣传日|(世界)?糖尿病日|(国际)?大学生节|国际消除对妇女的暴力日|(世界)?艾滋病日|(世界)?残疾人日|(全国)?法制宣传日|(世界)?足球日|圣诞节|平安夜|国际麻风节|中小学生安全教育日|复活节|母亲节|全国助残日|父亲节|(国际|世界)?和平日|(全国)?国防教育日|国际聋人节|世界住房日|(加拿大|美国)?感恩节|国际减轻自然灾害日|世界爱眼日"//国历节日
#define kREGEX_LUNAR_FESTIVAL @"春节|元宵节?|端午节?|七夕节?|中国情人节|中秋节?|重阳节?|腊八节?|传统扫房日|小年夜|除夕|大?年?三十|冬至节?|火把节|祭灶|侗族芦笙节|填仓节|送穷日|瑶族忌鸟节|春龙节|僳僳族刀杆节|畲族会亲节|佤族播种节|白族三月节|牛王诞|锡伯族西迁节|(阿昌族)?泼水节|鄂温克族米阔鲁节|瑶族达努节|壮族祭田节|瑶族尝新节|女儿节|侗族吃新节|盂兰盆会|普米族转山会|祭祖节|瑶族盘王节"//农历节日


#define FORMAT_YYYY_MM_DD_HH_MM_SS  @"[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}" //yyyy-MM-dd hh:mm:ss格式
#define FORMAT_YYYY_MM_DD_HH_MM  @"[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}" //yyyy-MM-dd hh:mm格式


#import "XZDateUtilsTool.h"
#import "CalendarHeader.h"
#import <CMPLib/NSString+CMPString.h>


@interface  XZDateUtilsTool()
@property(nonatomic, strong)NSMutableDictionary *dateMapping;
@property(nonatomic, assign)BOOL hasTime;

@end

@implementation XZDateUtilsTool
static XZDateUtilsTool *_instance;

+ (XZDateUtilsTool *)sharedInstance {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (void)clearData {
    [XZDateUtilsTool sharedInstance].dateMapping = nil;
}

+ (NSDictionary *)numberTransDic {
    NSDictionary *result = @{@"0" : @"0",
                             @"1" : @"1",
                             @"2" : @"2",
                             @"3" : @"3",
                             @"4" : @"4",
                             @"5" : @"5",
                             @"6" : @"6",
                             @"7" : @"7",
                             @"8" : @"8",
                             @"9" : @"9",
                             @"零" : @"0",
                             @"一" : @"1",
                             @"二" : @"2",
                             @"三" : @"3",
                             @"四" : @"4",
                             @"五" : @"5",
                             @"六" : @"6",
                             @"七" : @"7",
                             @"八" : @"8",
                             @"九" : @"9",
                             @"十" : @"10",
                             @"百" : @"100",
                             @"千" : @"1000",
                             @"万" : @"10000",
                             @"亿" : @"100000000",
                             @"壹" : @"1",
                             @"贰" : @"2",
                             @"叁" : @"3",
                             @"肆" : @"4",
                             @"伍" : @"5",
                             @"陆" : @"6",
                             @"柒" : @"7",
                             @"捌" : @"8",
                             @"玖" : @"9",
                             @"拾" : @"10",
                             @"佰" : @"100",
                             @"仟" : @"1000",
                             @"〇" : @"0",
                             @"幺" : @"1",
                             @"两" : @"2"};
    return result;
}

+ (NSArray *)ten_hundred_thousandArray {
    NSArray *array = @[@"十",
                       @"百",
                       @"千",
                       @"拾",
                       @"佰",
                       @"仟"];
    return array;
}

+ (NSArray *)numberUnitArray {
    NSArray *array = @[@"十",
                       @"百",
                       @"千",
                       @"拾",
                       @"佰",
                       @"仟",
                       @"万",
                       @"亿"];
    return array;
}

+ (NSInteger)daysfromYear:(NSInteger)year andMonth:(NSInteger)month
{
    NSInteger num_year  = year;
    NSInteger num_month = month;
    
    BOOL isrunNian = num_year%4==0 ? (num_year%100==0? (num_year%400==0?YES:NO):YES):NO;
    switch (num_month) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            return 31;
        case 4:
        case 6:
        case 9:
        case 11:
            return 30;
        case 2:{
            if (isrunNian) {
                return 29;
            }else{
                return 28;
            }
        }
        default:
            break;
    }
    return 0;
}



- (NSString *)obtainSoleFormatDateTime:(NSString *)command {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[NSDate date]];
    //匹配数字年月日
    NSString *date = [self obtainNumberYearMonthDay:command components:components];
    if (!date) {
        //匹配周的别名
        date = [self obtainWeekAlias:command components:components];
    }
    if (!date) {
        //匹配农历
        date = [self obtainLunarMonth:command components:components];
    }
    if (!date) {
        //匹配日期的别名
        date = [self obtainDayAlias:command components:components];
    }
    if (!date) {
        //匹配周
        date = [self obtainNumberWeek:command components:components];
    }
    if (!date) {
        //匹配月的别名
        date = [self obtainMonthAlias:command components:components];
    }
    if (!date) {
        //匹配年的别名
        date = [self obtainYearAlias:command components:components];
    }
    if (!date) {
        //匹配整年的别名
        date = [self obtainWholeYearAlias:command components:components];
    }
    if (!date) {
        //匹配旬
        date = [self obtainTenDay:command components:components];
    }
    if (!date) {
        //匹配季度
        date = [self obtainQuarter:command components:components];
    }
    if (!date) {
        //匹配国历节日
        date = [self obtainFestival:command components:components];
    }
    if (!date) {
        //匹配农历节日
        date = [self obtainLunarFestival:command components:components];
    }
    if (!date) {
        //匹配工作时间段
        date = [self obtainWorkTime:command components:components];
    }
    if (!date) {
        //匹配当前时间点
        date = [self obtainLatestTime:command components:components];
    }
    if (!date) {
           //匹配当前时间点
           date = [self obtainDayLength:command components:components];//匹配几天前、或几天后
       }
    if (!self.hasTime) {
        NSString *result = date;
        if (!result) {
            result = [self dateStrWithYear:components.year month:components.month day:components.day];
        }
        return result;
    }
    //==========匹配日期end===========//
    
    //==========匹配时分start========//
    /**
     * 1、匹配原则，如果有日期，则将日期和时分拼接
     * 2、如果时分没有匹配上，则尝试匹配上下午，并且看是否有日期
     * 3、如果没有日期，则以当前的年月日作为日期拼接
     */
    NSString *time = [self obtainTime:command];
    NSString *result = nil;
    if (![NSString isNull:date]) {
        result = date;
    }
    if ([NSString isNull:time]) {
        //如果时间正则没有匹配，则尝试匹配上下午
        time = [self obtainNoonTime:command];
    }
    if (![NSString isNull:time]) {
        if ([NSString isNull:date]) {
            result = [self dateStrWithYear:components.year month:components.month day:components.day];
        }
        if (result.length > 10) {
            result = [result substringToIndex:10];
        }
        if([time isEqualToString:@"24:00"]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:kDateFormate_YYYY_MM_DD];
            formatter.timeZone = [NSTimeZone systemTimeZone];
            NSDate *date = [formatter dateFromString:result];
            result = [self numberDayAfterToday:1 date:date];
            result = [NSString stringWithFormat:@"%@ 00:00",result];
        }
        else {
            result = [NSString stringWithFormat:@"%@ %@",result,time];
        }
    }
    return result;
}

//获取时间类型（版本2，可以从一些多余的词语中提取时间，功能更强大）
+ (NSString *)obtainFormatDateTime:(NSString *)commandStr {
    XZDateUtilsTool *utils = [XZDateUtilsTool sharedInstance];
    utils.hasTime = YES;
    NSString *command = [utils handleDisturbCommand:commandStr];
    NSString *result = [utils obtainComplexity7LevelDate:command];
    if(!result) {
        result = [utils obtainComplexity6LevelDate:command];
    }
    if(!result) {
        result = [utils obtainComplexity5LevelDate:command];
    }
    if(!result) {
        result = [utils obtainComplexity4LevelDate:command];
    }
    if(!result) {
        result = [utils obtainComplexity3LevelDate:command];
    }
    if(!result) {
        result = [utils obtainComplexity2LevelDate:command];
    }
    if(!result) {
        result = [utils obtainComplexity1LevelDate:command];
    }
    if(!result) {
        result = [utils obtainComplexity0LevelDate:command];
    }
    if(result) {
        if ([result rangeOfString:@"#"].location != NSNotFound) {
            //添加时间，如果没有时间，开始时间添加00:00，结束时间加23:59
            NSArray *array = [result componentsSeparatedByString:@"#"];
            NSString *beginTime = [array firstObject];
            if ([beginTime rangeOfString:@":"].location == NSNotFound) {
                beginTime = [NSString stringWithFormat:@"%@ 00:00",beginTime];
            }
            NSString *endTime = [array lastObject];
            if ([endTime rangeOfString:@":"].location == NSNotFound) {
                endTime = [NSString stringWithFormat:@"%@ 23:59",endTime];
            }
            result = [NSString stringWithFormat:@"%@#%@",beginTime,endTime];
        }
        return result;
    }
    command = [utils handleWeekDisturbCommand:command];
    result = [utils obtainSoleFormatDateTime:command];
    return result;
}

/**
 * 专门处理命令干扰，将一些对时间抽取有干扰的都通过此函数处理
 */
- (NSString *)handleDisturbCommand:(NSString *)command{
    NSString *result = [command replaceCharacter:@"开始到" withString:@"到"];
    result = [result replaceCharacter:@"开始" withString:@"到"];
    result = [result replaceCharacter:@"的" withString:@""];
    result = [result replaceCharacter:@"明早" withString:@"明天早上"];
    result = [result replaceCharacter:@"明晚" withString:@"明天晚上"];
    result = [result replaceCharacter:@"：" withString:@":"];//将中文冒号修改成英文冒号
    return result;
}

/**
 * 专门处理说周的口语干扰
 */
- (NSString *)handleWeekDisturbCommand:(NSString *)command{
    NSString *result = [command replaceCharacter:@"周周" withString:@"周"];
    result = [result replaceCharacter:@"周星期" withString:@"周"];
    result = [result replaceCharacter:@"周礼拜" withString:@"周"];
    result = [result replaceCharacter:@"星期周" withString:@"星期"];
    result = [result replaceCharacter:@"星期礼拜" withString:@"星期"];
    result = [result replaceCharacter:@"星期星期" withString:@"星期"];
    result = [result replaceCharacter:@"礼拜周" withString:@"礼拜"];
    result = [result replaceCharacter:@"礼拜星期" withString:@"礼拜"];
    result = [result replaceCharacter:@"礼拜礼拜" withString:@"礼拜"];
    return result;
}

/**
 * 获取7级复杂度日期格式
 *     "【下周】开会时间是【周一】到【周2】"
 *     "【2019年】开会时间是【三月】到【五月】"
 *     "【2019年】开会时间是【三月5日】到【6月7日】"
 *     "【6月】开会时间是【5号】到【6号】"
 *     "【今年】开会时间是【一季度】到【二季度】"
 *     "【三月】开会时间是【八号上午九点】到【九号下午三点】"
 * @param command 识别对象
 * @return result
 */

- (NSString *)obtainComplexity7LevelDate:(NSString *)command {
    NSString *pattern = [self obtainRegexStrByLevel:7];
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:pattern];
    if (checkResult) {
        NSInteger numberOfRanges = checkResult.numberOfRanges;
        if (numberOfRanges == 43) {
            NSString* weekAlias = [self value:command result:checkResult index:2];//上周、下周
            NSString* week1 = [self value:command result:checkResult index:5];//星期一
            NSString* week2 = [self value:command result:checkResult index:8];//星期2
            
            NSString* year = [self value:command result:checkResult index:12];//今年，2019年
            NSString* yearMonth1 = [self value:command result:checkResult index:14];//3月 月份名称
            NSString* yearMonthDay1 = [self value:command result:checkResult index:15];//4号
            NSString* yearMonth2 = [self value:command result:checkResult index:16];//3月 月份名称
            NSString* yearMonthDay2 = [self value:command result:checkResult index:17];//4号
            
            NSString* qYear = [self value:command result:checkResult index:19];//今年，年+季度的匹配年
            NSString* qYearQuarter1 = [self value:command result:checkResult index:21];//3号/1季度，号和季度匹配在同一个位置
            NSString* qYearQuarter2 = [self value:command result:checkResult index:22];//4号/2季度，号和季度匹配在同一个位置
            
            NSString *mMonth = [self value:command result:checkResult index:24];//3月，月+日的匹配
            NSString *mMonthDay1 = [self value:command result:checkResult index:26];//5号，月+日的日
            
            NSString *mMonthDayNoon1 = [self value:command result:checkResult index:27];//月+日+上下午的上下午
            NSString *mMonthDayNoonTime1 = [self value:command result:checkResult index:28];//月+日+[上下午]+几点的时间
            NSString *mMonthDay2 = [self value:command result:checkResult index:35];//5号，月+日的日
            NSString *mMonthDayNoon2 = [self value:command result:checkResult index:36];//月+日+上下午的上下午
            NSString *mMonthDayNoonTime2 = [self value:command result:checkResult index:37];//月+日+[上下午]+几点的时间
            
            
            return [self level67Date:weekAlias
                               week1:week1
                               week2:week2
                                year:year
                          yearMonth1:yearMonth1
                       yearMonthDay1:yearMonthDay1
                          yearMonth2:yearMonth2
                       yearMonthDay2:yearMonthDay2
                               qYear:qYear
                       qYearQuarter1:qYearQuarter1
                       qYearQuarter2:qYearQuarter2
                              mMonth:mMonth
                          mMonthDay1:mMonthDay1
                          mMonthDay2:mMonthDay2
                      mMonthDayNoon1:mMonthDayNoon1
                  mMonthDayNoonTime1:mMonthDayNoonTime1
                      mMonthDayNoon2:mMonthDayNoon2
                  mMonthDayNoonTime2:mMonthDayNoonTime2];
        }
    }
    return nil;
}
/**
 * 获取6级复杂度日期格式
 *     "开会时间是【下周】【周一】到【周2】"
 *     "开会时间是【2019年】【三月】到【五月】"
 *     "开会时间是【2019年】【三月5日】到【6月7日】"
 *     "开会时间是【6月】【5号】到【6号】"
 *     "开会时间是【今年】【一季度】到【二季度】"
 * @param command 识别对象
 * @return result
 */
- (NSString *)obtainComplexity6LevelDate:(NSString *)command {
    NSString *pattern = [self obtainRegexStrByLevel:6];
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:pattern];
    if (checkResult) {
        NSInteger numberOfRanges = checkResult.numberOfRanges;
        if (numberOfRanges == 25) {
            NSString* weekAlias = [self value:command result:checkResult index:2];//上周、下周
            NSString* week1 = [self value:command result:checkResult index:4];//星期一
            NSString* week2 = [self value:command result:checkResult index:7];//星期2
            
            NSString* year = [self value:command result:checkResult index:11];//今年，2019年
            NSString* yearMonth1 = [self value:command result:checkResult index:12];//3月
            NSString* yearMonthDay1 = [self value:command result:checkResult index:13];//4号
            NSString* yearMonth2 = [self value:command result:checkResult index:14];//3月
            NSString* yearMonthDay2 = [self value:command result:checkResult index:15];//4号
            
            NSString* qYear = [self value:command result:checkResult index:17];//5月
            NSString* qYearQuarter1 = [self value:command result:checkResult index:18];//3号
            NSString* qYearQuarter2 = [self value:command result:checkResult index:19];//4号
            
            NSString *mMonth = [self value:command result:checkResult index:21];
            NSString *mMonthDay1 = [self value:command result:checkResult index:22];
            NSString *mMonthDay2 = [self value:command result:checkResult index:23];
            
            return [self level67Date:weekAlias
                               week1:week1
                               week2:week2
                                year:year
                          yearMonth1:yearMonth1
                       yearMonthDay1:yearMonthDay1
                          yearMonth2:yearMonth2
                       yearMonthDay2:yearMonthDay2
                               qYear:qYear
                       qYearQuarter1:qYearQuarter1
                       qYearQuarter2:qYearQuarter2
                              mMonth:mMonth
                          mMonthDay1:mMonthDay1
                          mMonthDay2:mMonthDay2
                      mMonthDayNoon1:nil
                  mMonthDayNoonTime1:nil
                      mMonthDayNoon2:nil
                  mMonthDayNoonTime2:nil];
        }
    }
    return nil;
}

/**
 * 获取5级复杂度类型1日期格式
 *      "【明天】到会时间是【早上】【十二点半】到【下午】【三点50分】"  ,
 *      "【明天】到会时间是【5点】到【下午】【三点】"
 *      去除多余的文字，抽取时间文字组合成所需时间格式
 * @param command 识别对象
 * @return result
 */
- (NSString *)obtainComplexity5LevelDate:(NSString *)command {
    NSString *pattern = [self obtainRegexStrByLevel:5];
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:pattern];
    if (checkResult) {
        NSInteger numberOfRanges = checkResult.numberOfRanges;
        if (numberOfRanges == 42) {
            NSString *dateStr = [self value:command result:checkResult index:1];//日期，如：明天、2019年3月5日
            if(![NSString isNull:dateStr]){//如果日期不为空，则说明符合这种句式的匹配
                NSString *noonStr1 = [self value:command result:checkResult index:15];//早上、下午、傍晚
                NSString *timeStr1= [self value:command result:checkResult index:16];//10点、十二点半
                NSString *noonStr2 = [self value:command result:checkResult index:35];//早上、下午、傍晚
                NSString *timeStr2 = [self value:command result:checkResult index:36];//10点、十二点半
                NSString *date = [self obtainSoleFormatDateTime:dateStr];
                NSString *time1 = [self obtainSoleFormatDateTime:[NSString stringWithFormat:@"%@%@",noonStr1,timeStr1]];
                time1 = [self removeDateStr:time1];
                if([NSString isNull:noonStr2]){//如果没有上下午的文字，则使用前面匹配的上下文文字
                    noonStr2 = noonStr1;
                }
                NSString *time2 = [self obtainSoleFormatDateTime:[NSString stringWithFormat:@"%@%@",noonStr2,timeStr2]];
                time2 = [self removeDateStr:time2];
                NSString *result = [NSString stringWithFormat:@"%@ %@#%@ %@",date,time1,date,time2];
                return [self sortMultiTime:result];
            }
        }
    }
    return nil;
}
/**
 * 获取4级复杂度日期格式
 *       "到会时间是【明天】【上午】【6点】到【明天】【下午】【三点】",
 *       "到会时间是【明天】【上午】【6点】到【8点】",
 *       "到会时间是【下午】【6点】到【8点】",
 *       "到会时间是【6点】到【8点】"
 *       "【2019年6月5日】【10点】到【明天下午8点】"
 *       "【2019年6月5日】【中午】到【明天下午8点】"
 *       "【下周的星期一】【6点半】到【下周的周二】【3点】"
 * @param command 返回一句话中的日期数据即可
 */
- (NSString *)obtainComplexity4LevelDate:(NSString *)command {
    NSString *pattern = [self obtainRegexStrByLevel:4];
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:pattern];
    if (checkResult) {
        NSInteger numberOfRanges = checkResult.numberOfRanges;
        if (numberOfRanges == 53) {
            NSString *dateStr1 = [self value:command result:checkResult index:1];//日期，如：明天、2019年3月5日
            NSString *weekAliasStr1 = [self value:command result:checkResult index:15];//下周
            NSString *weekStr1 = [self value:command result:checkResult index:17];//周一
            NSString *noonStr1 = [self value:command result:checkResult index:20];//早上、下午、傍晚
            NSString *timeStr1 = [self value:command result:checkResult index:21];//10点、十二点半
            NSString *dateStr2 = [self value:command result:checkResult index:27];//日期
            NSString *weekAliasStr2 = [self value:command result:checkResult index:41];//本周
            NSString *weekStr2 = [self value:command result:checkResult index:43];//星期一
            NSString *noonStr2 = [self value:command result:checkResult index:46];//早上、下午、傍晚
            NSString *timeStr2 = [self value:command result:checkResult index:47];//10点、十二点半
            
            if([NSString isNull:dateStr1]){
                //如果没有日期，则以“今天”作为日期
                if(![NSString isNull:weekStr1]){
                    if(![NSString isNull:weekAliasStr1]){//如果周有别名
                        NSString *week1Num = [self replaceregExpString:@"周|星期|礼拜" inString:weekStr1 withString:@""];//获取到周的数字
                        dateStr1 = [NSString stringWithFormat:@"%@%@",weekAliasStr1,week1Num];
                    }
                    else {
                        dateStr1 = weekStr1;//如果周不为空，则将周作为日期
                    }
                }
                else{
                    dateStr1 = @"今天";
                }
            }
            if([NSString isNull:noonStr1]){
                //如果没有上下午
                if (![NSString isNull:timeStr1]) {
                    //如果时间不为空则则默认是早上（计算时间差就是0）
                    noonStr1 = @"早上";
                }
                else {
                    //上下午也没有，时间也没有的情况，则将时间设置成零点
                    noonStr1 = @"";//上下午作为空字符串，只用时间去匹配
                    timeStr1 = @"零点";
                }
            }
            else{//如果有上下午的情况
                if([NSString isNull:timeStr1]){
                    //如果时间为空
                    timeStr1 = @"";
                }else {
                    //todo 既有上下午，又有时间，则不处理
                }
            }
            if([NSString isNull:timeStr1]){
                //没有时间需要处理成0点
                timeStr1 = @"零点";
            }
            if([NSString isNull:dateStr2]){
                if(![NSString isNull:weekStr2]){
                    if(![NSString isNull:weekAliasStr2]){
                        NSString *week2Num = [self replaceregExpString:@"周|星期|礼拜" inString:weekStr2 withString:@""];//获取到周的数字
                        dateStr2 = [NSString stringWithFormat:@"%@%@",weekAliasStr2,week2Num];//周别名不为空，需要将别名和周数字进行组合
                    }
                    else {
                        dateStr2 = weekStr2;
                    }
                }
                else {
                    //如果时间2没有日期，则使用时间1的日期
                    dateStr2 = dateStr1;
                }
            }
            else {
                if([NSString isNull:noonStr2]){
                    //如果没有上下午，则按照时间1的情况来
                    noonStr2 = @"早上";
                }
            }
            if([NSString isNull:noonStr2]){
                //如果没有上下午，则按照时间1的情况来
                noonStr2 = noonStr1;
            }
            
            if([NSString isNull:timeStr2]){
                //没有时间，则需要处理成24点
                if([@"早上" isEqualToString:noonStr2] ||
                   [@"上午" isEqualToString:noonStr2] ||
                   [@"凌晨" isEqualToString:noonStr2]){
                    timeStr2 = @"24点";
                }
                else{
                    timeStr2 = @"12点";
                }
            }
            NSString *date1 = [self obtainSoleFormatDateTime:dateStr1];
            NSString *time1 = [self obtainSoleFormatDateTime:[NSString stringWithFormat:@"%@%@",noonStr1,timeStr1]];
            time1 = [self removeDateStr:time1];
            
            NSString *date2 = [self obtainSoleFormatDateTime:dateStr2];
            NSString *time2 = [self obtainSoleFormatDateTime:[NSString stringWithFormat:@"%@%@",noonStr2,timeStr2]];
            time2 = [self removeDateStr:time2];
            NSString *result = [NSString stringWithFormat:@"%@ %@#%@ %@",date1,time1,date2,time2];
            return [self sortMultiTime:result];
        }
    }
    return nil;
}
/**
 * 获取3级复杂度日期格式
 *      "到会时间是【今天】下午到【明天】【下午】"
 *      "到会时间是【3月5日】【上午】到【6月7日】"
 *      "【明天】到会时间是【上午】到【下午】",
 *      "开会时间是【明天上午9点】到【下个星期一】",
 *      "开会时间是【三月初五上午9点】到【10月初6】",
 *      "【下周2】到【2019年3月8日】",
 *      "【腊月16上午9点】到【下个星期一】"
 *      "【2019年3月6日上午9点】到【下个星期一】"
 *      "【下周一】的【下午九点半】到【下周二】的【下午五点半】"
 *      "【下周一】的【下午】到【下周二】的下午五点半"
 *      "【下周一】的【8点】到【下周二】的【下午五点半】"
 *      "【下周一】的【8点】到【下周二】的【6点半】"
 * @param command 识别对象
 * @return result
 */
- (NSString *)obtainComplexity3LevelDate:(NSString *)command {
    NSString *pattern = [self obtainRegexStrByLevel:3];
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:pattern];
    if (checkResult) {
        NSInteger numberOfRanges = checkResult.numberOfRanges;
        if (numberOfRanges == 45) {
            NSString *dateStr1 = [self value:command result:checkResult index:1];
            NSString *noonStr1 = [self value:command result:checkResult index:16];
            NSString *timeStr1 = [self value:command result:checkResult index:17];
            NSString *dateStr2 = [self value:command result:checkResult index:23];
            NSString *noonStr2 = [self value:command result:checkResult index:38];
            NSString *timeStr2 = [self value:command result:checkResult index:39];

            
            if (([NSString isNull:dateStr1] &&[NSString isNull:noonStr1] &&[NSString isNull:timeStr1])||
                ([NSString isNull:dateStr2] &&[NSString isNull:noonStr2] &&[NSString isNull:timeStr2])) {
                //完全没有时间段的情况，则不处理
                return nil;
            }
            if ([NSString isNull:noonStr1] &&[NSString isNull:timeStr1] &&[NSString isNull:noonStr2] &&[NSString isNull:timeStr2] ) {
                if (![NSString isNull:dateStr1] && ![NSString isNull:dateStr2]) {
                    if ([dateStr1 containsString:@"年"] && [dateStr1 containsString:@"月"] && [dateStr2 containsString:@"年"]) {//整年整月的情况，不处理
                        return nil;
                    }
                }
            }
            
            if([NSString isNull:dateStr1]){
                dateStr1 = @"今天";
            }
            
            if([NSString isNull:noonStr1]){//如果没有上下午，
                if(![NSString isNull:timeStr1]){//如果时间不为空则则默认是早上（计算时间差就是0）
                    noonStr1 = @"早上";
                }else {//上下午也没有，时间也没有的情况，则将时间设置成零点
                    noonStr1 = @"";//上下午作为空字符串，只用时间去匹配
                    timeStr1 = @"零点";
                }
            }else{//如果有上下午的情况
                if([NSString isNull:timeStr1]){//如果时间为空
                    timeStr1 = @"";
                }else {
                    //todo 既有上下午，又有时间，则不处理
                }
            }
            

            NSString *date1 = [self obtainSoleFormatDateTime:dateStr1];
            NSString *time1 = [self obtainSoleFormatDateTime:[NSString stringWithFormat:@"%@%@",noonStr1,timeStr1]];
            time1 = [self removeDateStr:time1];
            if([NSString isNull:dateStr2]){
                dateStr2 = dateStr1;
            }
            if([NSString isNull:noonStr2]){
                noonStr2 = @"日末";
            }
            NSString *date2 = [self obtainSoleFormatDateTime:dateStr2];
            
            if([NSString isNull:noonStr2]){
                if([NSString isNull:timeStr2]){
                    noonStr2 = @"日末";
                    timeStr2 = @"";
                }else {
                    noonStr2 = @"";
                }
            }else {
                if([NSString isNull:timeStr2]){
                    timeStr2 = @"";
                }
            }
            NSString *time2 = [self obtainSoleFormatDateTime:[NSString stringWithFormat:@"%@%@",noonStr2,timeStr2]];
            time2 = [self removeDateStr:time2];
            NSString *result = [NSString stringWithFormat:@"%@ %@#%@ %@",date1,time1,date2,time2];
            return [self sortMultiTime:result];
        }
    }
    return nil;
}

/**
 * 获取2级复杂度日期格式
 *     "【明天】开会时间是【下午】【两点】"
 *     "【后天】开会时间是【12点】"
 *     "【今天】开会时间是【下午】"
 * @param command 识别对象
 * @return result
 */
- (NSString *)obtainComplexity2LevelDate:(NSString *)command {
    NSString *pattern = [self obtainRegexStrByLevel:2];
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:pattern];
    if (checkResult) {
        NSInteger numberOfRanges = checkResult.numberOfRanges;
        if (numberOfRanges == 22) {
            NSString *dateStr = [self value:command result:checkResult index:1];
            NSString *noonStr = [self value:command result:checkResult index:15];
            NSString *timeStr = [self value:command result:checkResult index:16];
            if(![NSString isNull:dateStr]){
                if([NSString isNull:noonStr]){//如果没有上下午，则默认是早上（计算时间差就是0）
                    noonStr = @"早上";
                }
                NSString *date = [self obtainSoleFormatDateTime:dateStr];
                NSString *time = [self obtainSoleFormatDateTime:[NSString stringWithFormat:@"%@%@",noonStr,timeStr]];
                time = [self removeDateStr:time];
                return [NSString stringWithFormat:@"%@ %@",date,time];
            }
        }
    }
    return nil;
}
/**
 * 获取1级复杂度日期格式
 *      "到会时间是【今天】到【明天】"
 *      "到会时间是【端午】到【国庆】",
 *      "到会时间是【5点】到【明天】"
 * @param command 识别对象
 * @return result
 */
- (NSString *)obtainComplexity1LevelDate:(NSString *)command {
    NSString *pattern = [self obtainRegexStrByLevel:1];
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:pattern];
    if (checkResult) {
        NSInteger numberOfRanges = checkResult.numberOfRanges;
        if (numberOfRanges == 27) {
         //todo
        }
        NSString *dateStr1 = [self value:command result:checkResult index:1];//日期1
        NSString *dateStr2 = [self value:command result:checkResult index:14];//日期2
        NSString *date1 = [self obtainSoleFormatDateTime:dateStr1];
        NSString *date2 = [self obtainSoleFormatDateTime:dateStr2];
        if([dateStr2 containsString:@"年"] &&
           ![dateStr2 containsString:@"月"] &&
           ![dateStr2 containsString:@"日"] &&
           ![dateStr2 containsString:@"号"]){//单年
            NSString *year2 = [self getYearNumByDateStr:date2];
            date2 = [NSString stringWithFormat:@"%@-12-31",year2];
        }
        else if([dateStr2 containsString:@"月"]&&
                ![dateStr2 containsString:@"日"] &&
                ![dateStr2 containsString:@"号"]){
            //月，不包含日
            NSArray *ymdTemp = [date2 componentsSeparatedByString:@"-"];
            NSInteger year2 = [ymdTemp[0] integerValue];
            NSInteger month = [ymdTemp[1] integerValue];
            NSInteger day = [XZDateUtilsTool daysfromYear:year2 andMonth:month];
            date2 = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",(long)year2,(long)month,(long)day];
        }
        if(![NSString isNull:date1] && ![NSString isNull:date2]){
            NSString *time1 = @"00:00";//时间1处理成0点
            NSString *time2 = @"23:59";//时间2处理成24点
            if ([date1 rangeOfString:@"#"].location != NSNotFound) {
                NSArray *array = [date1 componentsSeparatedByString:@"#"];
                date1 = array[0];
            }
            NSString *result = [NSString stringWithFormat:@"%@ %@#%@ %@",date1,time1,date2,time2];
            return [self sortMultiTime:result];
        }
    }
    return nil;
}
/**
 * 获取0级复杂度日期格式
 *      "到会时间是【一季度】到【二季度】"
 *      "到会时间是【这季度】到【下季度】",
 *      "到会时间是【这周】到【下周】"
 *      "到会时间是【这个月】到【下个月】"
 * @param command 识别对象
 * @return result
 */
- (NSString *)obtainComplexity0LevelDate:(NSString *)command {
    NSString *pattern = [self obtainRegexStrByLevel:0];
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:pattern];
    if (checkResult) {
        NSInteger numberOfRanges = checkResult.numberOfRanges;
        if (numberOfRanges == 15) {
            NSString *quarter1 = [self value:command result:checkResult index:2];//一季度
            NSString *quarter2 = [self value:command result:checkResult index:3];//下季度
            NSString *week1 = [self value:command result:checkResult index:5];//下周（整周）
            NSString *weekNum1 = [self value:command result:checkResult index:7];//具体星期几
            NSString *week2 = [self value:command result:checkResult index:10];//本周（整周）
            NSString *weekNum2 = [self value:command result:checkResult index:12];//具体星期几
            
            NSString *date1 = @"";
            NSString *date2 = @"";
            if(![NSString isNull:quarter1]){
                date1 = quarter1;
            }
            if(![NSString isNull:quarter2]){
                date2 = quarter2;
            }
            if(![NSString isNull:week1]){
                date1 = week1;
                if (![NSString isNull:weekNum1]){
                    NSString *temp = [self replaceregExpString:@"周|星期|礼拜" inString:weekNum1 withString:@""];
                    date1 = [NSString stringWithFormat:@"%@%@",date1,temp];
                }
            }
            if(![NSString isNull:week2]){
                date2 = week2;
                if (![NSString isNull:weekNum2]){
                    NSString *temp = [self replaceregExpString:@"周|星期|礼拜" inString:weekNum2 withString:@""];
                    date2 = [NSString stringWithFormat:@"%@%@",date2,temp];
                }
            }

            date1 = [self obtainSoleFormatDateTime:date1];
            date2 = [self obtainSoleFormatDateTime:date2];
            if ([date1 rangeOfString:@"#"].location != NSNotFound) {
                date1 = [date1 substringToIndex:[date1 rangeOfString:@"#"].location];
            }
            if ([date2 rangeOfString:@"#"].location != NSNotFound) {
                date2 = [date2 substringFromIndex:[date2 rangeOfString:@"#"].location+1];
            }
            NSString *result = [NSString stringWithFormat:@"%@#%@",date1,date2];
            return [self sortMultiTime:result];
        }
    }
    return nil;
}
/**
 * 根据语法获取匹配正则表达式的字符串
 * @param level 复杂度级数
 */
- (NSString *)obtainRegexStrByLevel:(NSInteger)level {
    
    NSMutableString *result = [NSMutableString string];
    
    NSMutableString *datePrefix = [NSMutableString string];//日期前缀
    NSMutableString *timeSuffix = [NSMutableString string];//时间后缀
    
    NSMutableString *weekPrefix = [NSMutableString string];//周前缀
    NSMutableString *weekSuffix = [NSMutableString string];//周后缀
    
    NSMutableString *yearPrefix = [NSMutableString string];//年前缀
    
    NSMutableString *monthPrefix = [NSMutableString string];//月前缀
    NSMutableString *daySuffix = [NSMutableString string];//日后缀
    
    NSMutableString *quarterSuffix = [NSMutableString string];//季度后缀
    
    NSString *noonRegex = @"([早晚]上|[上下中]午|凌晨|午夜|傍晚|半夜)";
    NSString *connectorRegex = @"[到和至~]";
    NSString *wildRegex = @"((?![一二三四五六七八九十1234567890下上早晚傍凌午明今后前大当昨]).){1,}";//通配符
    
    //==========前缀start
    [datePrefix appendString:@"("];
    [datePrefix appendString:@"大前[天日]|[前昨今明后当][天日]|大后[天日]"];//天
    
    [datePrefix appendString:@"|"];
    
    [datePrefix appendString:@"("];
    [datePrefix appendString:@"[上个下本这]{0,2}(星期|周|礼拜)([一二三四五六天日末]|[123456])"];//星期
    [datePrefix appendString:@")"];
    
    [datePrefix appendString:@"|"];
    
    [datePrefix appendString:@"("];
    [datePrefix appendString:@"([一二三四五六七八九]月|十[一二]?月|[1-9]月|1[0-2]月)?初[一二三四五六七八九十0123456789]{1,3}"];//农历月+初
    [datePrefix appendString:@")"];
    
    [datePrefix appendString:@"|"];
    
    [datePrefix appendString:@"("];
    [datePrefix appendString:@"[十冬腊正]月初?[一二三四五六七八九十0123456789]{1,3}"];//农历十冬腊正月
    [datePrefix appendString:@")"];
    
    [datePrefix appendString:@"|"];
    
    [datePrefix appendString:@"("];
    [datePrefix appendString:@"元旦节?|三八节|三八妇女节|妇女节|国际妇女节|三[一幺]五|315|愚人节|清明节?|[国际五一]{0,2}劳动节|五一节|[五四54]{0,2}青年节|[五四54]{2}节|[六一61]{0,2}儿童节|[六一61]{2}节|[中国]{0,2}共产党诞生日|党的生日|共党节|建党节"];//国历节日
    [datePrefix appendString:@"|[八一81]{0,2}建军节|[八一81]{2}节|[中国]{0,2}教师节|[十一1]{0,2}国庆节?|十一|圣诞节|平安夜|复活节|母亲节|父亲节"];
    [datePrefix appendString:@")"];
    
    [datePrefix appendString:@"|"];
    
    [datePrefix appendString:@"("];
    [datePrefix appendString:@"春节|元宵节?|端午节?|七夕节?|中国情人节|中秋节?|重阳节?|腊八节?|小年夜|除夕|大?年?三十|冬至节"];//农历节日
    [datePrefix appendString:@")"];
    
    [datePrefix appendString:@"|"];
    
    [datePrefix appendString:@"("];
    [datePrefix appendString:@"("];
    [datePrefix appendString:@"[〇零一二三四五六七八九]{2,4}年|[0-9]{2,4}年|[前去昨今明后本当]年"];//年
    [datePrefix appendString:@")?"];
    
    [datePrefix appendString:@"("];
    [datePrefix appendString:@"0?[1-9]月份?|1[0-2]月份?|[一二三四五六七八九十]月份?|十[一二]月份?|上个?月|这个?月|[当本]月|下个?月"];//月
    [datePrefix appendString:@")?"];
    
    [datePrefix appendString:@"("];
    [datePrefix appendString:@"[十二三]{0,2}[一二三四五六七八九十][日号]|[12]?[0-9][日号]|3[01][日号]"];//日
    [datePrefix appendString:@")?"];
    [datePrefix appendString:@")"];
    
    [datePrefix appendString:@")"];
    //====================前缀end
    
    
    //===================后缀start
    [timeSuffix appendString:@"("];
    [timeSuffix appendString:@"([十二]{1,}[一二三四五六七八九][点时][半整]?|[一二三四五六七八九十两零][点时][半整]?|[12][0-9][点时][半整]?|[0-9][点时][半整]?)"];
    [timeSuffix appendString:@"((([二三四五]?十?[一二三四五六七八九十]|[12345]?[0123456789])分?)|([一二三123]刻钟?))?"];
    [timeSuffix appendString:@")"];
    
    //=================后缀end
    
    //周前缀
    [weekPrefix appendString:@"("];
    [weekPrefix appendString:@"[上个下本这]{0,2}(星期|周|礼拜)"];
    [weekPrefix appendString:@")"];
    
    //周后缀
    [weekSuffix appendString:@"("];
    [weekSuffix appendString:@"(星期|周|礼拜)([一二三四五六天日末]|[123456])"];
    [weekSuffix appendString:@")"];
    
    //年前缀
    [yearPrefix appendString:@"("];
    [yearPrefix appendString:@"[〇零一二三四五六七八九]{2,4}年|[0-9]{2,4}年|[前去昨今明后本当]年"];
    [yearPrefix appendString:@")"];
    
    //月前缀
    [monthPrefix appendString:@"("];
    [monthPrefix appendString:@"0?[1-9]月份?|1[0-2]月份?|[一二三四五六七八九十]月份?|十[一二]月份?|上个?月|这个?月|[当本]月|下个?月"];
    [monthPrefix appendString:@")"];
    
    //日后缀
    [daySuffix appendString:@"("];
    [daySuffix appendString:@"[十二三]{0,2}[一二三四五六七八九十][日号]|[12]?[0-9][日号]|3[01][日号]"];
    [daySuffix appendString:@")"];
    
    //季度后缀
    [quarterSuffix appendString:@"("];
    [quarterSuffix appendString:@"[一二三四1234上下本这]个?季度"];
    [quarterSuffix appendString:@")"];
    
    switch (level){
        case 7: {
            [result appendString:@"("];
            [result appendString:weekPrefix];
            [result appendString:wildRegex];
            [result appendString:weekSuffix];
            [result appendString:connectorRegex];
            [result appendString:weekSuffix];
            [result appendString:@")"]; //周
            
            [result appendString:@"|"];
            
            [result appendString:@"("];
            [result appendString:yearPrefix];
            [result appendString:wildRegex];
            [result appendString:monthPrefix];
            [result appendString:daySuffix];
            [result appendString:@"?"];
            [result appendString:connectorRegex];
            [result appendString:monthPrefix];
            [result appendString:daySuffix];
            [result appendString:@"?"];
            [result appendString:@")"];//年月(日)
            
            [result appendString:@"|"];
            
            [result appendString:@"("];
            [result appendString:yearPrefix];
            [result appendString:wildRegex];
            [result appendString:quarterSuffix];
            [result appendString:connectorRegex];
            [result appendString:quarterSuffix];
            [result appendString:@")"];//年季度
            
            [result appendString:@"|"];
            
            [result appendString:@"("];
            [result appendString:monthPrefix];
            [result appendString:wildRegex];
            [result appendString:daySuffix];
            [result appendString:noonRegex];
            [result appendString:@"?"];
            [result appendString:timeSuffix];
            [result appendString:@"?"];
            [result appendString:connectorRegex];
            [result appendString:@"("];
            [result appendString:daySuffix];
            [result appendString:noonRegex];
            [result appendString:@"?"];
            [result appendString:timeSuffix];
            [result appendString:@"?"];
            [result appendString:@")"];
            [result appendString:@")"];//月日[午][时]
            }
            break;
        case 6: {
            
            [result appendString:@"("];
            [result appendString:weekPrefix];
            [result appendString:weekSuffix];
            [result appendString:connectorRegex];
            [result appendString:weekSuffix];
            [result appendString:@")"];//周
            
            [result appendString:@"|"];
            
            [result appendString:@"("];
            [result appendString:yearPrefix];
            [result appendString:monthPrefix];
            [result appendString:daySuffix];
            [result appendString:@"?"];
            [result appendString:connectorRegex];
            [result appendString:monthPrefix];
            [result appendString:daySuffix];
            [result appendString:@"?"];
            [result appendString:@")"];//年月(日)
            
            [result appendString:@"|"];
            
            [result appendString:@"("];
            [result appendString:yearPrefix];
            [result appendString:quarterSuffix];
            [result appendString:connectorRegex];
            [result appendString:quarterSuffix];
            [result appendString:@")"];//年季度
            
            [result appendString:@"|"];
            
            [result appendString:@"("];
            [result appendString:monthPrefix];
            [result appendString:daySuffix];
            [result appendString:connectorRegex];
            [result appendString:@"("];
            [result appendString:daySuffix];
            [result appendString:@")"];
            [result appendString:@")"];//月日
        }
            break;
        case 5:{
            //复杂5级
            [result appendString:datePrefix];
            [result appendString:wildRegex];
            [result appendString:noonRegex];
            [result appendString:@"?"];
            [result appendString:timeSuffix];
            [result appendString:connectorRegex];
            [result appendString:datePrefix];
            [result appendString:@"?"];
            [result appendString:noonRegex];
            [result appendString:@"?"];
            [result appendString:timeSuffix];
        }
            break;
        case 4:{
            //复杂度4级
            [result appendString:datePrefix];
            [result appendString:@"?"];
            [result appendString:@"("];
            [result appendString:weekPrefix];
            [result appendString:weekSuffix];
            [result appendString:@")"];
            [result appendString:@"?"];
            [result appendString:noonRegex];
            [result appendString:@"?"];
            [result appendString:timeSuffix];
            [result appendString:@"?"];
            [result appendString:connectorRegex];
            [result appendString:datePrefix];
            [result appendString:@"?"];
            [result appendString:@"("];
            [result appendString:weekPrefix];
            [result appendString:weekSuffix];
            [result appendString:@")"];
            [result appendString:@"?"];
            [result appendString:noonRegex];
            [result appendString:@"?"];
            [result appendString:timeSuffix];
        }
            break;
        case 3: {//复杂度3级
            [result appendString:datePrefix];
            [result appendString:@"?"];
            [result appendString:@"("];
            [result appendString:wildRegex];
            [result appendString:@")"];
            [result appendString:@"?"];
            [result appendString:noonRegex];
            [result appendString:@"?"];
            [result appendString:timeSuffix];
            [result appendString:@"?"];
            [result appendString:connectorRegex];
            [result appendString:datePrefix];
            [result appendString:@"?"];
            [result appendString:@"("];
            [result appendString:wildRegex];
            [result appendString:@")"];
            [result appendString:@"?"];
            [result appendString:noonRegex];
            [result appendString:@"?"];
            [result appendString:timeSuffix];
            [result appendString:@"?"];
        }
            break;
        case 2: {
            
            //复杂度2级
            [result appendString:datePrefix];
            [result appendString:wildRegex];
            [result appendString:noonRegex];
            [result appendString:@"?"];
            [result appendString:timeSuffix];
        }
            break;
        case 1: {
            //复杂度1级
            [result appendString:datePrefix];
            [result appendString:connectorRegex];
            [result appendString:datePrefix];
        }
            break;
        case 0: {
            //复杂度0级  季度
            
            [result appendString:@"("];
            [result appendString:quarterSuffix];
            [result appendString:connectorRegex];
            [result appendString:quarterSuffix];
            [result appendString:@")"];

            [result appendString:@"|"];

            [result appendString:@"("];
            [result appendString:weekPrefix];
            [result appendString:weekSuffix];
            [result appendString:@"?"];
            [result appendString:connectorRegex];
            [result appendString:weekPrefix];
            [result appendString:weekSuffix];
            [result appendString:@"?"];
            [result appendString:@")"];
        }
            break;
    }
    return [NSString stringWithString:result];
}

- (NSString *)value:(NSString *)command result:(NSTextCheckingResult *)checkResult index:(NSInteger)index {
    NSRange range = [checkResult rangeAtIndex:index];
    if (range.location != NSNotFound) {
        return [command substringWithRange:range];
    }
    return @"";
}

- (NSString *) replaceregExpString:(NSString *)regExpString inString:(NSString *)oldStr withString:(NSString *)nStr {
    NSString *result = [oldStr stringByReplacingOccurrencesOfString:regExpString
                                                         withString:nStr
                                                            options:NSRegularExpressionSearch // 注意里要选择这个枚举项,这个是用来匹配正则表达式的
                                                              range:NSMakeRange (0, oldStr.length)];
    return result;
}



- (NSString *)level67Date:(NSString *)weekAlias
                    week1:(NSString *)week1
                    week2:(NSString *)week2
                     year:(NSString *)year
               yearMonth1:(NSString *)yearMonth1
            yearMonthDay1:(NSString *)yearMonthDay1
               yearMonth2:(NSString *)yearMonth2
            yearMonthDay2:(NSString *)yearMonthDay2
                    qYear:(NSString *)qYear
            qYearQuarter1:(NSString *)qYearQuarter1
            qYearQuarter2:(NSString *)qYearQuarter2
                   mMonth:(NSString *)mMonth
               mMonthDay1:(NSString *)mMonthDay1
               mMonthDay2:(NSString *)mMonthDay2
           mMonthDayNoon1:(NSString *)mMonthDayNoon1
       mMonthDayNoonTime1:(NSString *)mMonthDayNoonTime1
           mMonthDayNoon2:(NSString *)mMonthDayNoon2
       mMonthDayNoonTime2:(NSString *)mMonthDayNoonTime2 {
    if (![NSString isNull:weekAlias]) {
        NSString *week1Num = [self replaceregExpString:@"周|星期|礼拜" inString:week1 withString:@""];
        NSString *week2Num = [self replaceregExpString:@"周|星期|礼拜" inString:week2 withString:@""];
        NSString *date1 = [self obtainSoleFormatDateTime:[NSString stringWithFormat:@"%@%@",weekAlias,week1Num]];
        NSString *date2 = [self obtainSoleFormatDateTime:[NSString stringWithFormat:@"%@%@",weekAlias,week2Num]];
        NSString *result = [NSString stringWithFormat:@"%@#%@",date1,date2];
        result = [self sortMultiTime:result];
        return result;
    }
    else if(![NSString isNull:year]){
        if([NSString isNull:yearMonthDay1]){
            yearMonthDay1 = @"1号";
        }
        if([NSString isNull:yearMonthDay2]){
            NSString *yearTemp = [self obtainSoleFormatDateTime:year];
            NSString *yearNum = [self getYearNumByDateStr:yearTemp];
            if(![self isNumeric:yearNum]){
                yearNum = [self convertChineseNumber2ArabicNumber:yearNum];
            }
            NSString *month2Num = [self replaceregExpString:@"月|号|份" inString:yearMonth2 withString:@""];
            if(![self isNumeric:month2Num]){
                month2Num = [self convertChineseNumber2ArabicNumber:month2Num];
            }
            NSInteger day = [XZDateUtilsTool daysfromYear:yearNum.integerValue andMonth:month2Num.integerValue];
            yearMonthDay2 = [NSString stringWithFormat:@"%ld号",(long)day];
        }
        NSString *date1 = [self obtainSoleFormatDateTime:[NSString stringWithFormat:@"%@%@%@",year,yearMonth1,yearMonthDay1]];
        NSString *date2 = [self obtainSoleFormatDateTime:[NSString stringWithFormat:@"%@%@%@",year,yearMonth2,yearMonthDay2]];
        NSString *result = [NSString stringWithFormat:@"%@#%@",date1,date2];
        return [self sortMultiTime:result];
    }
    else if(![NSString isNull:qYear]){
        NSString *dateStr = [self obtainSoleFormatDateTime:qYear];
        NSString *yearNum = [self getYearNumByDateStr:dateStr];//获取年的数字
        NSString *dateQuarter1 = [self obtainSoleFormatDateTime:qYearQuarter1];
        NSArray *dateQuarter1Temp = [dateQuarter1 componentsSeparatedByString:@"#"];
        NSString *prefixDate = dateQuarter1Temp[0];//取前季度的第一个日期
        NSString *dateQuarter2 = [self obtainSoleFormatDateTime:qYearQuarter2];
        NSArray *dateQuarter2Temp = [dateQuarter2 componentsSeparatedByString:@"#"];
        NSString *suffixDate = dateQuarter2Temp[1];//取前季度的后面日期
        
        prefixDate = [prefixDate replaceCharacter:yearNum withString:@""];
        suffixDate = [suffixDate replaceCharacter:yearNum withString:@""];
        NSString *result = [NSString stringWithFormat:@"%@%@#%@%@",yearNum,prefixDate,yearNum,suffixDate];
        return [self sortMultiTime:result];
    }
    else if (![NSString isNull:mMonth]) {
        NSString *mMonthTemp = mMonth;
        NSTextCheckingResult *checkResult = [self firstMatchInString:mMonthTemp pattern:kREGEX_MONTH_ALIAS1];
        if (checkResult) {
            NSString *dateTemp = [self obtainSoleFormatDateTime:[mMonth substringWithRange:checkResult.range]];
            NSArray *dateArr = [dateTemp componentsSeparatedByString:@"#"];
            NSString *preDate = dateArr[0];
            dateArr = [preDate componentsSeparatedByString:@"-"];
            NSInteger monthNum = [dateArr[1] integerValue];//根据月的别名的处理规则，获取月的数字
            mMonthTemp = [NSString stringWithFormat:@"%ld月",(long)monthNum];
        }
        
        
        NSString *dateTime1 = [NSString stringWithFormat:@"%@%@",mMonth,mMonthDay1];
        if(![NSString isNull:mMonthDayNoon1]){
            dateTime1 = [NSString stringWithFormat:@"%@%@",dateTime1,mMonthDayNoon1] ;
        }
        if(![NSString isNull:mMonthDayNoonTime1]){
            dateTime1 = [NSString stringWithFormat:@"%@%@",dateTime1,mMonthDayNoonTime1];
        }
        NSString *date1 = [self obtainSoleFormatDateTime:dateTime1];
        
        NSString *dateTime2 = [NSString stringWithFormat:@"%@%@",mMonth,mMonthDay2];
        if(![NSString isNull:mMonthDayNoon2]){
            dateTime2 = [NSString stringWithFormat:@"%@%@",dateTime2,mMonthDayNoon2];
        }
        if(![NSString isNull:mMonthDayNoonTime2]){
            dateTime2 = [NSString stringWithFormat:@"%@%@",dateTime2,mMonthDayNoonTime2];
        }
        NSString *date2 = [self obtainSoleFormatDateTime:dateTime2];
        NSString *result = [NSString stringWithFormat:@"%@#%@",date1,date2];
        return [self sortMultiTime:result];

    }
    return nil;
}

/**
 * 多时间排序，将时间小的
 */
- (NSString *)sortMultiTime:(NSString *)multiTime {
    NSArray *temp = [multiTime componentsSeparatedByString:@"#"];
    NSString *time1 = temp[0];
    NSString *time2 = temp[1];
    NSString *result = multiTime;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kDateFormate_YYYY_MM_DD];
    NSDate *date1 = [dateFormatter dateFromString:[time1 substringToIndex:10]];
    NSDate *date2 = [dateFormatter dateFromString:[time2 substringToIndex:10]];
    if([date2 timeIntervalSinceDate:date1] < 0){
        //如果前面的时间小于后面的时间则调整位置
        result = [NSString stringWithFormat:@"%@#%@",time2,time1];;
    }
    return result;
}

//判断是否是否是国历闰年
- (BOOL)isNationalLeap:(int)year{
    return (year % 4 == 0 && year%100 != 0) || year % 400 == 0;
}

//是否是没有秒的日期时间格式字符串
- (BOOL)isDateTimeWithoutSecondFormatStr:(NSString *)dateStr {
    
    NSTextCheckingResult *checkResult2 = [self firstMatchInString:dateStr pattern:FORMAT_YYYY_MM_DD_HH_MM_SS];
    NSTextCheckingResult *checkResutl3 = [self firstMatchInString:dateStr pattern:FORMAT_YYYY_MM_DD_HH_MM];
    return checkResutl3 && !checkResult2;
    return YES;
}

//去除日期保留时间
- (NSString *)removeDateStr:(NSString *)dateStr{
    if([self isDateTimeWithoutSecondFormatStr:dateStr]){
        NSArray *temp = [dateStr componentsSeparatedByString:@" "];
        return temp[1];
    }
    return dateStr;
}

//通过日期格式获取年数字
- (NSString *)getYearNumByDateStr:(NSString *)dateStr{
    NSString *yearNum = [dateStr substringToIndex:[dateStr rangeOfString:@"-"].location];
    return yearNum;
}

//
- (NSDate *)dateForYear:(NSInteger)year month:(NSInteger)m day:(NSInteger)d {
    NSString *dateStr = [NSString stringWithFormat:@"%ld-%02ld-%02ld",(long)year,(long)m,(long)d];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone systemTimeZone];
    [formatter setDateFormat:kDateFormate_YYYY_MM_DD];
    return [formatter dateFromString:dateStr];
}

//几月几号对应的日期
- (NSDate *)dateForMonth:(NSInteger)m day:(NSInteger)d {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:[NSDate date]];
    return [self dateForYear:components.year month:m day:d];
}

//麻风病日期 时间为每年1月的最后一个星期日
- (NSString *)obtainLeprosyDay {
    NSDate *date = [self dateForMonth:1 day:31];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:date];
    NSInteger week = [self weekForComponents:components];
    NSString *result = nil;
    if (week == 7) {
        //1月31日是周日
        result = [self dateStrWithYear:components.year month:components.month day:components.day];
    }
    else {
        result = [self numberDayAfterToday:-week date:date];
    }
    return result;
}
//学生安全教育日 每年3月份最后一周的星期一
- (NSString *)obtainSafetyStudentsDay {
    NSDate *date = [self dateForMonth:3 day:31];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:date];
    NSInteger week = [self weekForComponents:components];
    NSString *result = nil;
    if (week == 1) {
        //3月31日是周-
        result = [self dateStrWithYear:components.year month:components.month day:components.day];
    }
    else {
        result = [self numberDayAfterToday:1-week date:date];
    }
    return result;
}
//复活节 每年春分月圆之后第一个星期日
- (NSString *)obtainEaster {
    NSInteger offset;
    NSInteger leap;
    NSInteger day;
    NSInteger month;
    NSInteger temp1;
    NSInteger temp2;
    NSInteger total;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSInteger year = components.year;
    
    offset = year % 19;
    leap = year % 4;
    day = year % 7;
    temp1 = (19 * offset + 24) % 30;
    temp2 = (2 * leap + 4 * day + 6 * temp1 + 5) % 7;
    total = (22 + temp1 + temp2);
    if (total > 31) {
        month = 4;
        day = total - 31;
    } else {
        month = 3;
        day = total;
    }
    NSString *result = [self dateStrWithYear:year month:month day:day];
    return result;
}
//计算母亲节，母亲节为每年的5月份，第二个周日
- (NSString *)obtainMotherDay {
    return [self obtainDateByDayNameWithMonth:5 num:2 dayName:7];
}
//5月第三个星期日 全国助残日
- (NSString *)obtainAssistiveDay {
    return [self obtainDateByDayNameWithMonth:5 num:3 dayName:7];
}
//6月第三个星期日 父亲节
- (NSString *)obtainFatherDay {
    return [self obtainDateByDayNameWithMonth:6 num:3 dayName:7];
}
//9月第三个星期二 国际和平日
- (NSString *)obtainPeaceDay {
    return [self obtainDateByDayNameWithMonth:9 num:3 dayName:2];
}
//9月第三个星期六 全国国防教育日
- (NSString *)obtainDefenseDay {
    return [self obtainDateByDayNameWithMonth:9 num:3 dayName:6];
}
//9月第四个星期日 国际聋人节
- (NSString *)obtainDeafDay {
    return [self obtainDateByDayNameWithMonth:9 num:4 dayName:7];
}
//10月的第一个星期一 世界住房日
- (NSString *)obtainHousingDay {
    return [self obtainDateByDayNameWithMonth:10 num:1 dayName:1];
}
//11月第四个星期四美国感恩节
- (NSString *)obtainThanksgiving {
    return [self obtainDateByDayNameWithMonth:11 num:4 dayName:4];
}
//10月的第二个星斯一 加拿大感恩节
- (NSString *)obtainCanadaThanksgiving {
    return [self obtainDateByDayNameWithMonth:10 num:2 dayName:1];
}
//10月第二个星期三 国际减轻自然灾害日
- (NSString *)obtainDisasterDay {
    return [self obtainDateByDayNameWithMonth:10 num:2 dayName:3];
}
//10月第二个星期四 世界爱眼日
- (NSString *)obtainSightDay {
    return [self obtainDateByDayNameWithMonth:10 num:2 dayName:4];
}

- (NSInteger)weekForComponents:(NSDateComponents *)components {
    NSInteger week = components.weekday-1;
    if (week == 0) {
        week = 7;
    }
    return week;
}


//获取月份第几个星期几
- (NSString *)obtainDateByDayNameWithMonth:(NSInteger)month num:(NSInteger)num  dayName:(NSInteger)dayName {
    NSDate *date = [self dateForMonth:month day:1];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:date];
    NSInteger year = components.year;
    NSInteger day = components.day;
    NSInteger firstWeek = [self weekForComponents:components];//1号的星期
    if (firstWeek > dayName) {
        day = 1 + num *7 - (firstWeek - dayName);
    }
    else {
        day = 1 + (num-1) *7 + dayName - firstWeek;
    }
    NSString *result = [self dateStrWithYear:year month:month day:day];
    return result;
}

- (NSDictionary *)dateMapping {
    
    if (!_dateMapping) {
        NSArray *kv_number = @[@"〇 0",@"零 0",@"一 1",@"二 2",@"两 2",@"三 3",@"四 4",@"五 5",@"六 6",@"七 7",@"八 8",@"九 9",@"十 10",@"整 00",@"半 30",@"点 :",@": :",@"日 7",@"天 7",@"正 1",@"冬 11",@"腊 12",@"0 0",@"1 1",@"2 2",@"3 3",@"4 4",@"5 5",@"6 6",@"7 7",@"8 8",@"9 9",@"10 10"];
        NSArray *kv_festival = @[@"元旦 01-01",@"世界湿地日 02-02",@"情人节 02-14",@"爱耳日 03-03",@"青年志愿者服务日 03-05",@"三八 03-08",@"妇女 03-08",@"植树节 03-12",@"保护母亲河日 03-09",@"白色情人节 03-14",@"警察日 03-14",@"消费者权益日 03-15",@"三一五 03-15",@"三幺五 03-15",@"315 03-15",@"森林日 03-21",@"睡眠日 03-21",@"水日 03-22",@"气象日 03-23",@"防治结核病日 03-24",@"愚人 04-01",@"卫生日 04-07",@"清明 04-05",@"地球日 04-22",@"知识产权 04-26",@"五一 05-01",@"劳动 05-01",@"哮喘日 05-03",@"五四 05-04",@"青年 05-04",@"红十字日 05-08",@"护士 05-12",@"家庭日 05-15",@"电信日 05-17",@"学生营养日 05-20",@"牛奶日 05-23",@"无烟日 05-31",@"六一 06-01",@"儿童 06-01",@"61 06-01",@"环境日 06-05",@"爱眼日 06-06",@"世界防治荒漠化和干旱日 06-17",@"奥林匹克日 06-23",@"土地日 06-25",@"禁毒日 06-26",@"共产党诞生日 07-01",@"党的生日 07-01",@"共党节 07-01",@"建党 07-01",@"建筑日 07-01",@"抗日战争纪念日 07-07",@"抗战 07-07",@"世界人口日 07-11",@"八一 08-01",@"81 08-01",@"建军 08-01",@"中国人民解放军 08-01",@"国际青年节 08-12",@"扫盲日 09-08",@"教师 09-10",@"脑健康日 09-16",@"臭氧层保护日 09-16",@"爱牙日 09-20",@"世界停火日 09-21",@"世界旅游日 09-27",@"十一 10-01",@"11 10-01",@"国庆 10-01",@"中华人民共和国国庆 10-01",@"音乐 10-01",@"国际老年人日 10-01",@"世界动物日 10-04",@"世界教师节 10-05",@"全国高血压日 10-08",@"世界邮政日 10-09",@"精神卫生日 10-10",@"世界标准日 10-14",@"国际盲人节 10-15",@"世界农村妇女日 10-15",@"世界粮食日 10-16",@"国际消除贫困日 10-17",@"联合国日 10-24",@"世界发展新闻日 10-24",@"男性健康日 10-28",@"国际生物多样性日 10-29",@"万圣节 10-31",@"中国记者日 11-08",@"消防宣传日 11-09",@"糖尿病日 11-14",@"大学生节 11-17",@"国际消除对妇女的暴力日 11-25",@"艾滋病日 12-01",@"残疾人日 12-03",@"法制宣传日 12-04",@"足球日 12-09",@"圣诞节 12-25",@"平安夜 12-24"];
        NSArray *kv_day_alias = @[@"大前天 -3",@"大前日 -3",@"前天 -2",@"前日 -2",@"昨天 -1",@"昨日 -1",@"今天 0",@"今日 0",@"当天 0",@"当日 0",@"明天 1",@"明日 1",@"后天 2",@"后日 2",@"大后天 3",@"大后日 3"];
        NSArray *kv_month_alias = @[@"上月 -1",@"上个月 -1",@"这月 0",@"这个月 0",@"本月 0",@"当月 0",@"下月 1",@"下个月 1"];
        NSArray * kv_year_alias = @[@"前年 -2",@"去年 -1",@"昨年 -1",@"今年 0",@"当年 0",@"本年 0",@"明年 1",@"后年 2"];
        NSArray *kv_week_alias = @[@"上上周 -14",@"上周 -7",@"上个星期 -7",@"上星期 -7",@"上个礼拜 -7",@"这周 0",@"本周 0",@"这个星期 0",@"这星期 0",@"这个礼拜 0",@"下周 7",@"下个星期 7",@"下星期 7",@"下个礼拜 7",@"下下周 14"];
        NSArray *kv_hour_alias = @[@"上午 0",@"中午 12",@"下午 12",@"凌晨 0",@"傍晚 12",@"午夜 0",@"晚上 12",@"半夜 12"];
        NSArray *kv_lunar_festival = @[@"春节 1-1",@"元宵 1-15",@"端午 5-5",@"七夕 7-7",@"中国情人节 7-7",@"中秋 8-15",@"重阳 9-9",@"腊八 12-8",@"传统扫房日 12-24",@"小年夜 12-23",@"除夕 12-30",@"三十 12-30",@"祭灶 12-24",@"侗族芦笙节 1-15",@"填仓节 1-25",@"送穷日 1-29",@"瑶族忌鸟节 2-1",@"春龙节 2-2",@"僳僳族刀杆节 2-8",@"佤族播种节 3-15",@"白族三月街 3-15",@"牛王诞 4-8",@"锡伯族西迁节 4-18",@"泼水节 5-13",@"鄂温克族米阔鲁节 5-22",@"瑶族达努节 5-29",@"壮族祭田节 6-6",@"瑶族尝新节 6-6",@"火把节 6-24",@"女儿节 7-7",@"侗族吃新节 7-13",@"盂兰盆会 7-15",@"普米族转山会 7-15",@"祭祖节 10-1",@"瑶族盘王节 10-16"];
        NSMutableArray *kv_dynamic_festival = [[NSMutableArray alloc] init];
        [kv_dynamic_festival addObject:[NSString stringWithFormat:@"国际麻风节 %@",[self obtainLeprosyDay]]];
        [kv_dynamic_festival addObject:[NSString stringWithFormat:@"中小学生安全教育日 %@",[self obtainSafetyStudentsDay]]];
        [kv_dynamic_festival addObject:[NSString stringWithFormat:@"复活节 %@",[self obtainEaster]]];
        [kv_dynamic_festival addObject:[NSString stringWithFormat:@"母亲节 %@",[self obtainMotherDay]]];
        [kv_dynamic_festival addObject:[NSString stringWithFormat:@"全国助残日 %@",[self obtainAssistiveDay]]];
        [kv_dynamic_festival addObject:[NSString stringWithFormat:@"父亲节 %@",[self obtainFatherDay]]];
        [kv_dynamic_festival addObject:[NSString stringWithFormat:@"和平日 %@",[self obtainPeaceDay]]];
        [kv_dynamic_festival addObject:[NSString stringWithFormat:@"国防教育日 %@",[self obtainDefenseDay]]];
        [kv_dynamic_festival addObject:[NSString stringWithFormat:@"国际聋人节 %@",[self obtainDeafDay]]];
        [kv_dynamic_festival addObject:[NSString stringWithFormat:@"世界住房日 %@",[self obtainHousingDay]]];
        [kv_dynamic_festival addObject:[NSString stringWithFormat:@"感恩节 %@",[self obtainThanksgiving]]];
        [kv_dynamic_festival addObject:[NSString stringWithFormat:@"加拿大感恩节 %@",[self obtainCanadaThanksgiving]]];
        [kv_dynamic_festival addObject:[NSString stringWithFormat:@"国际减轻自然灾害日 %@",[self obtainDisasterDay]]];
        [kv_dynamic_festival addObject:[NSString stringWithFormat:@"世界爱眼日 %@",[self obtainSightDay]]];
        
        NSArray *all = [NSArray arrayWithObjects:kv_number,kv_festival,kv_day_alias,kv_week_alias,kv_month_alias,kv_year_alias,kv_hour_alias,kv_lunar_festival,kv_dynamic_festival, nil];
        _dateMapping = [[NSMutableDictionary alloc] init];
        for (NSArray *array in all) {
            for (NSString *str in array) {
                NSArray *list = [str componentsSeparatedByString:@" "];
                if (list.count >1) {
                    [_dateMapping setObject:list[1] forKey:list[0]];
                }
            }
        }
    }
    return _dateMapping;
    
}



- (NSString *)dateStrWithYear:(NSInteger)y month:(NSInteger)m day:(NSInteger)d {
    NSString *result = [NSString stringWithFormat:@"%ld-%02ld-%02ld",(long)y,(long)m,(long)d];
    return result;
}

//是否是阿拉伯数字
- (BOOL)isNumeric:(NSString *)str {
    NSInteger l = str.length;
    for (NSInteger i = 0 ; i < l; i ++) {
        unichar chr =  [str characterAtIndex:i];
        if(chr < 48 || chr > 57) {
            return NO;
        }
    }
    return YES;
}




//处理年，如果年只有2位，如一八年，则补位20作为21世纪的年
- (NSString *)handleYear:(NSString *)year  string:(NSString *)string {
    NSMutableString *result = [NSMutableString string];
    if (year.length < 4) {
        //如果年份小于4位，说明只说了如：18年，19年这样的语句
        [result appendString:@"20"];
    }
    NSInteger l = year.length;
    for(int i =0; i < l; i++) {
        NSString *temp = [year substringWithRange:NSMakeRange(i, 1)];
        [result appendString:self.dateMapping[temp]];
    }
    [result appendString:@"-"];
    return result;
}


- (NSInteger)handleYear:(NSString *)year {
    NSMutableString *result = [NSMutableString string];
    if (year.length < 4) {
        //如果年份小于4位，说明只说了如：18年，19年这样的语句
        [result appendString:@"20"];
    }
    NSInteger l = year.length;
    for(int i =0; i < l; i++) {
        NSString *temp = [year substringWithRange:NSMakeRange(i, 1)];
        [result appendString:self.dateMapping[temp]];
    }
    return [result integerValue];
}


//处理月份
- (NSString *)handleMonth:(NSString *)month  string:(NSString *)string {
    NSMutableString *result = [NSMutableString stringWithString:string];
    if ([self isNumeric:month]) {
        NSInteger m = [month integerValue];
        [result appendFormat:@"%02ld",(long)m];
    }
    else {
        [result appendString:[self convertChineseNumber2ArabicNumber:month]];
    }
    [result appendString:@"-"];
    return result;
}

- (NSInteger)handleMonth:(NSString *)month {
    NSString *result = nil;
    if ([self isNumeric:month]) {
        result = month;
    }
    else {
       result = [self convertChineseNumber2ArabicNumber:month];
    }
    return [result integerValue];
}

//处理天格式
- (NSString *)handleDay:(NSString *)day  string:(NSString *)string {
    NSMutableString *result = [NSMutableString stringWithString:string];
    if ([self isNumeric:day]) {
        NSInteger m = [day integerValue];
        [result appendFormat:@"%02ld",(long)m];
    }
    else {
        [result appendString:[self convertChineseNumber2ArabicNumber:day]];
    }
    return result;
}
//十五转15
- (NSInteger)numberFormString:(NSString *)string {
    NSString *str = string;
    NSString *sub = [str substringToIndex:1];
    if ([sub isEqualToString:@"十"]||[sub isEqualToString:@"百"]||[sub isEqualToString:@"千"]) {
        str = [NSString stringWithFormat:@"一%@",str];
    }
    str = [str replaceCharacter:@"十" withString:@""];
    str = [str replaceCharacter:@"百" withString:@""];
    str = [str replaceCharacter:@"千" withString:@""];
    NSMutableString *result = [NSMutableString string];
    NSInteger l = string.length;
    for(int i =0; i < l; i++) {
        NSString *temp = [str substringWithRange:NSMakeRange(i, 1)];
        [result appendString:self.dateMapping[temp]];
    }
    return [result integerValue];
}

- (NSString *)numberDayAfterToday:(NSInteger)mumber date:(NSDate *)oldDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDateFormate_YYYY_MM_DD];
    formatter.timeZone = [NSTimeZone systemTimeZone];
    NSDate *date = [oldDate dateByAddingTimeInterval:mumber*24*60*60];
    NSString *result = [formatter stringFromDate:date];
    return result;
}

- (NSTextCheckingResult *)firstMatchInString:(NSString *)command pattern:(NSString *)pattern {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *checkResult = [regex firstMatchInString:command options:NSMatchingReportProgress range:NSMakeRange(0, [command length])];
    return checkResult;
}

//获取某月的天数
- (NSInteger)maxDayForYear:(NSInteger)year month:(NSInteger)month {
    
    NSDateFormatter *format= [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM"];
    NSDate *newDate=[format dateFromString:[NSString stringWithFormat:@"%ld-%02ld",(long)year,(long)month]];
    double interval = 0;
    NSDate *beginDate = nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    BOOL ok = [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&beginDate interval:&interval forDate:newDate];
    //分别修改为 NSDayCalendarUnit NSWeekCalendarUnit NSYearCalendarUnit
    if (ok) {
        NSInteger result = interval/(24*60*60);
        return result;
    }else {
        return 30;
    }
    
}
//农历转公历
- (NSString *)solarStrFromLunarWithYear:(int)year month:(int)month day:(int)day {
    Lunar *l = [[Lunar alloc]initWithYear:(int)year
                                 andMonth:(int)month
                                   andDay:(int)day];
    Solar *s = [CalendarDisplyManager obtainSolarFromLunar:l];
    NSString *result = [NSString stringWithFormat:@"%i-%02i-%02i",s.solarYear,s.solarMonth,s.solarDay];
    return result;
}
//数字年、月、日组合==========start==============================//

- (NSString *)obtainNumberYearMonthDay:(NSString *)command
                            components:(NSDateComponents *)components {
    
    
    NSTextCheckingResult *checkResult= nil;
    checkResult = [self firstMatchInString:command pattern:kREGEX_NUMBER_YMD];
    if (checkResult) {
        //年月日
        NSString* year = [self value:command result:checkResult index:2];//年
        NSString* month = [self value:command result:checkResult index:4];//月
        NSString* day = [self value:command result:checkResult index:6];//日
        NSString *result = [NSString string];
        result = [self handleYear:year string:result];
        result = [self handleMonth:month string:result];
        result = [self handleDay:day string:result];
        return result;
    }
   
    checkResult = [self firstMatchInString:command pattern:kREGEX_ALIAS_YMD];
    if (checkResult) {
        //年有别名的日期格式yyyy-mm-dd获取mm-dd格式
        NSString *yk = [self value:command result:checkResult index:1];
        NSString *m = [self value:command result:checkResult index:3];//月
        NSString *d = [self value:command result:checkResult index:5];//日
        NSInteger y = components.year;
        NSInteger diffY = [self.dateMapping[yk] integerValue];//获取年和今年的差值
        y = y + diffY;
        if([NSString isNull:d]){//没有匹配日 则设置日为1号
            d = @"1";
        }
        NSString *result = [NSString string];
        result = [self handleYear:[NSString stringWithFormat:@"%ld",(long)y] string:result];
        result = [self handleMonth:m string:result];
        result = [self handleDay:d string:result];
        return result;
    }

    checkResult = [self firstMatchInString:command pattern:kREGEX_NUMBER_YM];
    if (checkResult) {
        //年月
        NSString *year = [self value:command result:checkResult index:1];//年
        NSString *month = [self value:command result:checkResult index:2];//月
        NSString *result = [NSString string];
        result = [self handleYear:year string:result];
        result = [self handleMonth:month string:result];
        result = [self handleDay:@"1" string:result];//取1号
        return result;
    }
    checkResult = [self firstMatchInString:command pattern:kREGEX_NUMBER_MD];
    if (checkResult) {
        //月日
        NSString *year = [NSString stringWithFormat:@"%ld",(long)components.year];//取当前年
        NSString *month = [self value:command result:checkResult index:1];//月
        NSString *day = [self value:command result:checkResult index:2];//日
        NSString *result = [NSString string];
        result = [self handleYear:year string:result];
        result = [self handleMonth:month string:result];
        result = [self handleDay:day string:result];
        return result;
    }
    checkResult = [self firstMatchInString:command pattern:kREGEX_MONTH_DAY_ALIAS];//mm-dd  月是别名说法
    if (checkResult) {
        NSInteger y = components.year;//年使用当年
        //单独处理月的别名
        NSString *mStr = [self value:command result:checkResult index:1];
        NSInteger diffM = [self.dateMapping[mStr] integerValue];
        NSInteger m = components.month;//取出当月数字
        m = m + diffM;
        if(m < 1){
            y --;
            m = 12;
        }else if(m > 12){
            y ++;
            m = 1;
        }
        NSString *year = [NSString stringWithFormat:@"%ld",(long)y];
        NSString *month = [NSString stringWithFormat:@"%ld",(long)m];
        NSString * day = [self value:command result:checkResult index:3];//取出日的数字
        NSString *result = [NSString string];
        result = [self handleYear:year string:result];
        result = [self handleMonth:month string:result];
        result = [self handleDay:day string:result];
        return result;
    }
    //单说年或月或日的情况
    //单年
    checkResult = [self firstMatchInString:command pattern:kREGEX_NUMBER_YEAR];
    if (checkResult) {
        NSString *yearStr = [self value:command result:checkResult index:1];//年
        NSString *result = [NSString string];
        result = [self handleYear:yearStr string:result];
        result = [self handleMonth:@"1" string:result];
        result = [self handleDay:@"1" string:result];
        return result;
    }
    //单月
    checkResult = [self firstMatchInString:command pattern:kREGEX_NUMBER_MONTH];
    NSTextCheckingResult *lunar = [self firstMatchInString:command pattern:kREGEX_LUNAR_MONTH1];
    if (checkResult && !lunar) {
        //排除农历几月几号的影响
        NSString *year = [NSString stringWithFormat:@"%ld",(long)components.year];//取当前年
        NSString *month = [self value:command result:checkResult index:1];//月
        NSString *result = [NSString string];
        result = [self handleYear:year string:result];
        result = [self handleMonth:month string:result];//取1月
        result = [self handleDay:@"1" string:result];//取1号
        return result;
    }
    //单日
    checkResult = [self firstMatchInString:command pattern:kREGEX_NUMBER_DAY];
    if (checkResult) {
        NSString *year = [NSString stringWithFormat:@"%ld",(long)components.year];//取当前年
        NSString *month = [NSString stringWithFormat:@"%ld",(long)components.month];//取当前月
        NSString *day = [self value:command result:checkResult index:1];//日
        NSString *result = [NSString string];
        result = [self handleYear:year string:result];
        result = [self handleMonth:month string:result];
        result = [self handleDay:day string:result];
        return result;
    }
    return nil;
}

//数字周=============================start=======================================//
- (NSString *)obtainNumberWeek:(NSString *)command
                    components:(NSDateComponents *)components {
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:kREGEX_NUMBER_WEEK];
    if (checkResult) {
        NSString *week = [self value:command result:checkResult index:0];//星期几中的数字
//        week = [week replaceCharacter:@"星期" withString:@""];
//        week = [week replaceCharacter:@"周" withString:@""];
        week = [self replaceregExpString:@"[周星期礼拜]{1,2}" inString:week withString:@""];
        NSInteger weekNum = [self.dateMapping[week] integerValue];
        NSInteger cWeekNum = [self weekForComponents:components];
        NSString *result = [self numberDayAfterToday:(weekNum - cWeekNum) date:[NSDate date]];
        return result;
    }
    return nil;
}
//获取农历日期
- (NSString *)obtainLunarMonth:(NSString *)command
                    components:(NSDateComponents *)components {
    //19年一月初一
    NSInteger year =  components.year;
    NSInteger month = -1;
    NSInteger day = -1;
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:kREGEX_LUNAR_MONTH1];
    if (checkResult) {
        NSString* lm = [self value:command result:checkResult index:2];
        NSString* ld = [self value:command result:checkResult index:4];
        month = [self numberFormString:lm];
        day = [self numberFormString:ld];
    }
    else {
        checkResult = [self firstMatchInString:command pattern:kREGEX_LUNAR_MONTH2];
        if (checkResult) {
            NSString* lm = [self value:command result:checkResult index:1];
            NSString* ld = [self value:command result:checkResult index:2];
            lm = [lm replaceCharacter:@"月" withString:@""];
            ld = [ld replaceCharacter:@"初" withString:@""];
            month = [self numberFormString:lm];
            day = [self numberFormString:ld];
        }
        else {
            checkResult = [self firstMatchInString:command pattern:kREGEX_LUNAR_DAY];
            if (checkResult) {
                NSString* ld = [self value:command result:checkResult index:1];
                month = components.month;
                day = [self numberFormString:ld];
            }
        }
    }
    if (month != -1 && day != -1) {
        NSString *result = [self solarStrFromLunarWithYear:(int)year month:(int)month day:(int)day];
        return result;
    }
    return nil;
}
//前、昨、今、明、后等时间格式
- (NSString *)obtainDayAlias:(NSString *)command
                  components:(NSDateComponents *)components {
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:kREGEX_DAY_ALIAS];
    if (checkResult) {
        NSString* lm = [command substringWithRange:[checkResult range]];
        NSInteger day = [self.dateMapping[lm] integerValue];
        NSString *result = [self numberDayAfterToday:day date:[NSDate date]];
        return result;
    }
    return nil;
}
//上周、本周、下周  上周一。。。时间格式  上周：本周的星期数作为上周的星期数；上周一：具体就是上周一
- (NSString *)obtainWeekAlias:(NSString *)command
                   components:(NSDateComponents *)components {
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:kREGEX_WEEK_ALIAS];
    if (checkResult) {
        NSString *weekName = [self value:command result:checkResult index:1];
        NSInteger diffVal = [self.dateMapping[weekName] integerValue];
        NSInteger cWeekNum = [self weekForComponents:components];
       
        NSRange weekNumRange  = [checkResult rangeAtIndex:2];
        if (weekNumRange.location == NSNotFound) {
            NSString *begin = [self numberDayAfterToday:(1 - cWeekNum)+diffVal date:[NSDate date]];
            NSString *end = [self numberDayAfterToday:(7 - cWeekNum)+diffVal date:[NSDate date]];
            NSString *result = [NSString stringWithFormat:_hasTime ?@"%@ 00:00#%@ 23:59":@"%@#%@",begin,end];
            return result;
        }
        else {
            NSString *weekNumber =[command substringWithRange:weekNumRange];
            NSInteger day = [self.dateMapping[weekNumber] integerValue];
            NSString *result = [self numberDayAfterToday:(day - cWeekNum)+diffVal date:[NSDate date]];
            return result;
        }
    }
    return nil;
}


//上月、本月，返回的是时间范围，使用#进行开始时间和结束时间的分割
- (NSString *)obtainMonthAlias:(NSString *)command
                    components:(NSDateComponents *)components {
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:kREGEX_MONTH_ALIAS1];
    NSInteger year = components.year;
    NSInteger month = components.month;
    if (checkResult) {
        NSString *mk = [command substringWithRange:[checkResult range]];
        NSInteger diffM = [self.dateMapping[mk] integerValue];
        month = month + diffM;
        if(month < 1){
            year --;
            month = 12;
        }else if(month > 12){
            year ++;
            month = 1;
        }
        NSInteger maxDay = [self maxDayForYear:year month:month];
        NSString *begin = [self dateStrWithYear:year month:month day:1];
        NSString *end = [self dateStrWithYear:year month:month day:maxDay];
        NSString *result = [NSString stringWithFormat:_hasTime ?@"%@ 00:00#%@ 23:59":@"%@#%@",begin,end];
        return result;
    }
    
    checkResult = [self firstMatchInString:command pattern:kREGEX_MONTH_ALIAS2];
    if (checkResult) {
        NSString *mk = [command substringWithRange:[checkResult range]];
        NSInteger day = [self maxDayForYear:year month:month];
        if ([mk isEqualToString:@"月中"]) {
            day = day/2;
        }
        else if([mk isEqualToString:@"月初"]){
            day = 1;
        }
        NSString *result = [self dateStrWithYear:year month:month day:day];
        return result;
    }
   
    return nil;
}
//年初，上半年，下半年
- (NSString *)obtainYearAlias:(NSString *)command
                   components:(NSDateComponents *)components {
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:kREGEX_YEAR_ALIAS];
    if (checkResult) {
        NSInteger year = components.year;
        NSString *yk = [command substringWithRange:[checkResult range]];
        NSString *result = nil;
        if ([yk isEqualToString:@"年初"] || [yk isEqualToString:@"开年"]) {
            result = [self dateStrWithYear:year month:1 day:1];
        }
        else if([yk isEqualToString:@"年中"]){
            result = [self dateStrWithYear:year month:6 day:30];
        }
        else if([yk isEqualToString:@"年底"]||[yk isEqualToString:@"年末"]||[yk isEqualToString:@"年终"]){
            result = [self dateStrWithYear:year month:12 day:31];
        }
        else if([yk isEqualToString:@"上半年"]){
            
            result = [NSString stringWithFormat:_hasTime ?@"%@ 00:00#%@ 23:59":@"%@#%@", [self dateStrWithYear:year month:1 day:1], [self dateStrWithYear:year month:6 day:30]];
        }
        else if([yk isEqualToString:@"下半年"]){
            result = [NSString stringWithFormat:_hasTime ?@"%@ 00:00#%@ 23:59":@"%@#%@", [self dateStrWithYear:year month:7 day:1], [self dateStrWithYear:year month:12 day:31]];
        }
        return result;
    }
    return nil;
}

//匹配整年的别名
- (NSString *)obtainWholeYearAlias:(NSString *)command
                components:(NSDateComponents *)components {
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:kREGEX_YEAR_WHOLE_ALIAS];
    if (checkResult) {
        NSString *yk = [command substringWithRange:[checkResult range]];
        NSInteger y = components.year;
        NSInteger diffY = [self.dateMapping[yk] integerValue];//获取年和今年的差值
        y = y + diffY;
        return [NSString stringWithFormat:@"%ld-01-01#%ld-12-31",(long)y,(long)y];
    }
    return nil;
}


//上、中、下旬
- (NSString *)obtainTenDay:(NSString *)command
                components:(NSDateComponents *)components {
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:kREGEX_TEN_DAYS];
    if (checkResult) {
        NSString *tk = [command substringWithRange:[checkResult range]];
        NSInteger year = components.year;
        NSInteger month = components.month;
        NSInteger sDay = [tk isEqualToString:@"上旬"]?1:[tk isEqualToString:@"中旬"]?11:21;
        NSInteger eDay = [tk isEqualToString:@"上旬"]?10:[tk isEqualToString:@"中旬"]?20:[self maxDayForYear:year month:month];
        NSString *result = [NSString stringWithFormat:_hasTime ?@"%@ 00:00#%@ 23:59":@"%@#%@", [self dateStrWithYear:year month:month day:sDay], [self dateStrWithYear:year month:month day:eDay]];
        return result;
    }
    return nil;
}
//季度
- (NSString *)obtainQuarter:(NSString *)command
                 components:(NSDateComponents *)components {
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:kREGEX_QUARTER];
    if (checkResult) {
        NSString *qNumStr = [command substringWithRange:[checkResult rangeAtIndex:1]];
        qNumStr = [qNumStr replaceCharacter:@"个" withString:@""];

        NSInteger year = components.year;
        NSInteger qNum = 0;
        NSInteger sm = 0;//开始月份
        NSInteger em = 0;//结束月份
        NSInteger sd = 0;//开始日
        NSInteger ed = 0;//结束日
        if ([qNumStr isEqualToString:@"上"]||
            [qNumStr isEqualToString:@"下"]||
            [qNumStr isEqualToString:@"本"]||
            [qNumStr isEqualToString:@"这"]) {
            NSInteger month = components.month;
            qNum = month%3 == 0 ?  month/3 : month/3+1;
            if ([qNumStr isEqualToString:@"上"]) {
                qNum--;
                if(qNum <1){
                    qNum = 4;
                    year --;
                }
            }
            else if ([qNumStr isEqualToString:@"下"])  {
                qNum ++;
                if(qNum >4){
                    qNum = 1;
                    year ++;
                }
            }
        }
        else {
            qNum = [self.dateMapping[qNumStr] integerValue];
        }
        
        switch (qNum){
            case 1://一季度
                sm = 1;
                sd = 1;
                em = 3;
                ed = 31;
                break;
            case 2://二季度
                sm = 4;
                sd = 1;
                em = 6;
                ed = 30;
                break;
            case 3://三季度
                sm = 7;
                sd = 1;
                em = 9;
                ed = 30;
                break;
            case 4://四季度
                sm = 10;
                sd = 1;
                em = 12;
                ed = 31;
                break;
        }
        NSString *result = [NSString stringWithFormat:_hasTime ?@"%@ 00:00#%@ 23:59":@"%@#%@", [self dateStrWithYear:year month:sm day:sd], [self dateStrWithYear:year month:em day:ed]];
        return result;
    }
    
    return nil;
}
//国历节日
- (NSString *)obtainFestival:(NSString *)command
                  components:(NSDateComponents *)components {
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:kREGEX_FESTIVAL];
    if (checkResult) {
        NSString *f = [command substringWithRange:[checkResult range]];
        f = [f replaceCharacter:@"节" withString:@""];
        NSInteger year = components.year;
        NSArray *keyArray = [self.dateMapping allKeys];
        for (NSString *key in keyArray) {
            if ([key rangeOfString:f].location != NSNotFound) {
                NSString *md = self.dateMapping[key];
                NSString *yearStr = [NSString stringWithFormat:@"%04ld-",(long)year];
                md = [md replaceCharacter:yearStr withString:@""];//干掉年
                NSString *reslut = [NSString stringWithFormat:@"%@%@",yearStr,md];
                return reslut;
            }
        }
    }
    return nil;
}
//农历节日
- (NSString *)obtainLunarFestival:(NSString *)command
                       components:(NSDateComponents *)components {
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:kREGEX_LUNAR_FESTIVAL];
    if (checkResult) {
        NSString *l = [command substringWithRange:[checkResult range]];
        NSInteger year = components.year;
        NSArray *keyArray = [self.dateMapping allKeys];
        for (NSString *key in keyArray) {
            if ([key rangeOfString:l].location != NSNotFound) {
                NSString *md = self.dateMapping[key];
                NSArray *list = [md componentsSeparatedByString:@"-"];
                NSInteger month = [list[0] integerValue];
                NSInteger day =[list[1] integerValue];
                NSString *result = [self solarStrFromLunarWithYear:(int)year month:(int)month day:(int)day];
                return result;
            }
        }
    }
    return nil;
}

//匹配工作时间段
- (NSString *)obtainWorkTime:(NSString *)command
                       components:(NSDateComponents *)components {
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:kREGEX_WORK_TIME];
    if (checkResult) {
        NSString *dn = [self value:command result:checkResult index:1];
        NSInteger diffVal = [self.dateMapping[dn] integerValue];
        NSString *result = [self numberDayAfterToday:diffVal date:[NSDate date]];
        result = [NSString stringWithFormat:@"%@ 09:00#%@ 18:00",result,result];
        return result;
        
        ;
    }
    return nil;
}
//匹配当前时间点
- (NSString *)obtainLatestTime:(NSString *)command
                       components:(NSDateComponents *)components {
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:kREGEX_LATEST_TIME];
    if (checkResult) {
        NSString *result = [self numberDayAfterToday:0 date:[NSDate date]];
        result = [NSString stringWithFormat:@"%@ %02ld:%02ld",result,(long)components.hour,(long)components.minute];
        return result;
    }
    return nil;
}
- (NSString *)obtainDayLength:(NSString *)command
                components:(NSDateComponents *)components {
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:kREGEX_DAY_LENGTH];
    if (checkResult) {
        NSString *dayLengthName = [self value:command result:checkResult index:1];
        NSString *preOrSub = [self value:command result:checkResult index:2];
        dayLengthName = [self convertChineseNumber2ArabicNumber:dayLengthName];
        NSInteger diffNum = dayLengthName.integerValue;
        if (![NSString isNull:preOrSub] &&[preOrSub isEqualToString:@"前"]) {
            diffNum = 0-diffNum;
        }
        NSString *result = [self numberDayAfterToday:diffNum date:[NSDate date]];
        return result;
    }
    return nil;
}



- (NSDictionary *)noonTimeDic {
    NSDictionary *dic = @{@"早上":@"07:00",
                          @"上午":@"09:00",
                          @"凌晨":@"01:00",
                          @"午夜":@"01:00",
                          @"中午":@"12:00",
                          @"下午":@"14:00",
                          @"傍晚":@"18:00",
                          @"晚上":@"21:00",
                          @"半夜":@"00:00",
                          @"日末":@"23:59"};
    return dic;
}
//匹配上下午
- (NSString *)obtainNoonTime:(NSString *)command {
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:kREGEX_NOON];
    if (checkResult) {
        NSDictionary *dic = [self noonTimeDic];
        NSString *noon = [self value:command result:checkResult index:1];
        NSString *result = dic[noon];
        return result;
    }
    return nil;
}

//时间
- (NSString *)obtainTime:(NSString *)command {
    NSTextCheckingResult *checkResult = [self firstMatchInString:command pattern:kREGEX_TIME];
    if (checkResult) {
        NSInteger m = 0;
        NSString *hAlias = [self value:command result:checkResult index:1];//上下午别名
        NSString *hNum = [self value:command result:checkResult index:2];
        NSString *connect = [self value:command result:checkResult index:8];
        NSString *zbAlias = [self value:command result:checkResult index:9];//整点、半点别名
        NSString *mNum = [self value:command result:checkResult index:10];
        
        NSString *hStr = [self isNumeric:hNum]?hNum:[self convertChineseNumber2ArabicNumber:hNum];
        NSInteger h = hStr.integerValue;
        if (hAlias) {
            NSInteger diffVal = [self.dateMapping[hAlias] integerValue];
            if(h > 12){
                //大于12就将上下午设置成0来计算
                diffVal = 0;
            }
            h += diffVal;
        }
        NSMutableString *result = [NSMutableString string];
        if (h < 10) {
            [result appendString:@"0"];
        }
        connect = self.dateMapping[connect];
        [result appendString:[NSString stringWithFormat:@"%ld",(long)h]];
        [result appendString:connect];
        if (![NSString isNull:zbAlias]) {
            [result appendString:self.dateMapping[zbAlias]];
            return result;
        }
        if (mNum) {//刻钟情况
            if ([mNum rangeOfString:@"刻"].location != NSNotFound) {
                mNum = [mNum replaceCharacter:@"刻" withString:@""];
                mNum = [mNum replaceCharacter:@"钟" withString:@""];
                NSString *qhStr = [self isNumeric:mNum] ? mNum:[self convertChineseNumber2ArabicNumber:mNum];
                NSInteger qh = [qhStr integerValue];
                switch (qh){
                    case 1:
                        m = 15;
                        break;
                    case 2:
                        m = 30;
                        break;
                    case 3:
                        m = 45;
                        break;
                }
                [result appendString:[NSString stringWithFormat:@"%ld",(long)m]];
                
            }else {//分钟情况
                mNum = [mNum replaceCharacter:@"分" withString:@""];
                NSString *mStr = [self isNumeric:mNum] ? mNum:[self convertChineseNumber2ArabicNumber:mNum];
                m = [mStr integerValue];
                [result appendString:[NSString stringWithFormat:@"%02ld",(long)m]];
            }
        }
        else {
            [result appendString:@"00"];
        }
        return result;
    }
    NSDictionary *dic = [self noonTimeDic];
    NSArray *allkeys = [dic allKeys];
    for (NSString *key in allkeys) {
        if ([command rangeOfString:key].location != NSNotFound) {
            return dic[key];
        }
    }
    return nil;
}


/**
 * 中文数字转阿拉伯数字
 */

- (NSString *)convertChineseNumber2ArabicNumber:(NSString *)str {
    
    if (!str || ![str isKindOfClass:[NSString class]] || str.length == 0) {
        //非空非Null判断
        return 0;
    }
    NSInteger number = 0;
    number = [str  integerValue];
    if (number != 0) {
        //直接是阿拉伯数字
        return [NSString stringWithFormat:@"%02ld",(long)number];
    }
    
    NSDictionary *numberDic = [XZDateUtilsTool numberTransDic];
    NSArray *ten_hundred_thousandArray = [XZDateUtilsTool ten_hundred_thousandArray];//十百千
    NSArray *numberUnitArray = [XZDateUtilsTool numberUnitArray];//十百千亿万
    
    NSString *first = [str substringWithRange:NSMakeRange(0, 1)];
    NSString *oldStr = str;
    if ([numberUnitArray containsObject:first]) {
        oldStr = [NSString stringWithFormat:@"一%@",str];
    }
    NSInteger lenth = oldStr.length;
    NSInteger billion = 100000000; //亿
    NSInteger tenThousand = 10000;// 万
    NSInteger billionNumber = 0;
    for (NSInteger i = 0; i < lenth; i++) {
        NSString *subStr = [oldStr substringWithRange:NSMakeRange(i, 1)];
        NSString *next = @"";
        
        if (i + 1 < lenth) {
            next = [oldStr substringWithRange:NSMakeRange(i+1, 1)];
        }
        if ([ten_hundred_thousandArray containsObject:next]) {
            //十百千
            number +=  [numberDic[subStr] longLongValue] * [numberDic[next] longLongValue];
            i ++;//跳过
        }
        else if ([subStr isEqualToString:@"亿"]) {
            billionNumber = billionNumber * billion + number;
            number = 0;
        }
        else if ([subStr isEqualToString:@"万"]) {
            number = number * tenThousand;
        }
        else {
            number += [numberDic[subStr] longLongValue];
        }
    }
    number += billionNumber*billion;
    return [NSString stringWithFormat:@"%02ld",(long)number];
}

@end
