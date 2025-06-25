//
//  SySearchResult.h.m
//  M1Core
//
//  Created by Aries on 14-3-6.
//
//

#import "SySearchResult.h"
#import "SyReverseGeocoder.h"
#import <CMPLib/CMPConstant.h>
@implementation SyPOI

- (void)dealloc
{
    [_address release];
    [_name release];
    [_type release];
    [_url release];
    [_pguid release];
    [_tel release];
    [_x release];
    [_y release];
    [_distance release];
    [_driverDistance release];
    [_match release];
    [_code release];
    [super dealloc];
}
@end

@implementation SyPoiSearchResult

- (void)dealloc
{
    [_pois release];
    [super dealloc];
}

@end
@implementation SyRoute

- (void)dealloc
{
    [_roadName release];
    [_direction release];
    [_roadLength release];
    [_action release];
    [_accessorialInfo release];
    [_driveTime release];
    [_grade release];
    [_form release];
    [_coor release];
    [_textInfo release];
    [super dealloc];
}
@end

@implementation SyRouteCity

- (void)dealloc
{
    [_cityName release];
    [_cityEnglishName release];
    [_code release];
    [_telnum release];
    [super dealloc];
}

@end
@implementation SyRouteSearchResult

- (void)dealloc
{
    [_searchtime release];
    [_coors release];
    [_routes release];
    [_length release];
    [_viaCities release];
    [_bounds release];
    [super dealloc];
}

@end
@implementation SyDistanceSearchResult

- (void)dealloc
{
    [_distance release];
    [super dealloc];
}

@end
@implementation SySegment

- (void)dealloc
{
    [_startName release];
    [_endName release];
    [_busName release];
    [_passDepotName release];
    [_driverLength release];
    [_footLength release];
    [_passDepotCount release];
    [_coordinateList release];
    [_passDepotCoordinate release];
    [super dealloc];
}

@end
@implementation SyBus

- (void)dealloc
{
    [_segmentArray release];
    [_footEndLength release];
    [_bounds release];
    [_expense release];
    [super dealloc];
}

@end
@implementation SyBusRouteSearchResult

- (void)dealloc
{
    [_searchtime release];
    [_routes release];
    [super dealloc];
}

@end
@implementation SyBusLine

- (void)dealloc
{
    [_length release];
    [_name release];
    [_type release];
    [_status release];
    [_line_id release];
    [_key_name release];
    [_front_name release];
    [_terminal_name release];
    [_start_time release];
    [_end_time release];
    [_company release];
    [_basic_price release];
    [_total_price release];
    [_commutation_ticket release];
    [_auto_ticket release];
    [_ic_card release];
    [_loop release];
    [_double_deck release];
    [_data_source release];
    [_air release];
    [_desc release];
    [_speed release];
    [_front_spell release];
    [_terminal_spell release];
    [_service_period release];
    [_time_interval1 release];
    [_interval1 release];
    [_time_interval2 release];
    [_interval2 release];
    [_time_interval3 release];
    [_interval3 release];
    [_time_interval4 release];
    [_interval4 release];
    [_time_interval5 release];
    [_interval5 release];
    [_time_interval6 release];
    [_interval6 release];
    [_time_interval7 release];
    [_interval7 release];
    [_time_interval8 release];
    [_interval8 release];
    [_time_desc release];
    [_express_way release];
    [_stationDesc release];
    [_coorDesc release];
    
    [super dealloc];
}

@end
@implementation SyBusLineSearchResult

- (void)dealloc
{
    [_searchtime release];
    [_busLineArray release];
    [super dealloc];
}

@end
@implementation SyRGCItem

- (void)dealloc
{
    [_x release];
    [_y release];
    [super dealloc];
}

@end
@implementation SyGeoPOI
- (SyAddress *)convertSyAddress
{
    SyAddress *address = [[[SyAddress alloc] init] autorelease];
    address.provinceName = _province;
    address.cityName = _city;
    address.districtName = _district;
    address.nearestPOI = _name;
    address.isPoi = YES;
    return address;
}
- (void)dealloc
{
    [_name release];
    [_level release];
 
    [_address release];
    [_province release];
    [_city release];
    [_district release];
    [_range release];
    [_ename release];
    [_eprovince release];
    [_ecity release];
    [_edistrict release];
    [_eaddress release];
    [super dealloc];
}

@end
@implementation SyGeoCodingSearchResult
- (id)init
{
    self = [super init];
    if(self){
        _geoCodingArray = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void)dealloc
{
    [_geoCodingArray release];
    [super dealloc];
}

@end
@implementation SyProvince

- (void)dealloc
{
    [_name release];
    [_code release];
    [super dealloc];
}

@end
@implementation SyCity

- (void)dealloc
{
    [_name release];
    [_code release];
    [_tel release];
    [super dealloc];
}

@end
@implementation SyDistrict

- (void)dealloc
{
    [_name release];
    [_code release];
    [_x release];
    [_y release];
    [_bounds release];
    [super dealloc];
}

@end

@implementation SyRoad

- (void)dealloc
{
    [_Id release];
    [_name release];
    [_ename release];
    [_width release];
    [_level release];
    [_direction release];
    [_distance release];
    [super dealloc];
}

@end
@implementation SyCross

- (void)dealloc
{
    [_name release];
    [_x release];
    [_y release];
    [super dealloc];
}

@end
@implementation SyReverseGeocodingInfo

- (void)dealloc
{
    [_province release];
    [_city release];
    [_district release];
    [_roads release];
    [_pois release];
    [_crosses release];
    [super dealloc];
}

@end
@implementation SyReverseGeocodingSearchResult

- (void)dealloc
{
    [_resultArray release];
    [super dealloc];
}

@end
@implementation SySpasSearchResult

- (void)dealloc
{
    [_poiArray release];
    [_suggestionArray release];
    [super dealloc];
}

@end
