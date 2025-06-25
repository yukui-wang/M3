//
//  NSArray+MutableCopyCatetory.m
//  M3
//
//  Created by Shoujian Rao on 2022/1/8.
//

#import "NSArray+MutableCopyCatetory.h"
@implementation NSArray (Catetory)

-(NSMutableArray *)mutableArrayDeeoCopy{
    
    NSMutableArray * array = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        id objOject;
        
        if ([obj isKindOfClass:[NSDictionary class]]) {
            objOject = [obj mutableDicDeepCopy];
            
        }else if ([obj isKindOfClass:[NSArray class]]){
            
            objOject = [obj mutableArrayDeeoCopy];
            
        }else{
            
            objOject = obj;
        }
        [array addObject:objOject];
        
    }];
    
    return array;
}

@end

@implementation NSDictionary (Catetory)
-(NSMutableDictionary *)mutableDicDeepCopy{
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithCapacity:[self count]];
    
    NSArray *keys=[self allKeys];
    for(id key in keys)
    {
        //循环读取复制每一个元素
        id value=[self objectForKey:key];
        id copyValue;
        
        // 如果是字典，递归调用
        if ([value isKindOfClass:[NSDictionary class]]) {
            
            copyValue=[value mutableDicDeepCopy];
            
            //如果是数组，数组数组深拷贝
        }else if([value isKindOfClass:[NSArray class]])
            
        {
            copyValue=[value mutableArrayDeeoCopy];
        }else{
            
            copyValue = value;
        }
        
        [dict setObject:copyValue forKey:key];
        
    }
    return dict;
    
}

@end
