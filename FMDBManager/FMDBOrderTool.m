//
//  FMDBOrderTool.m
//  DEMOKING
//
//  Created by DEMOKING  on 2018/5/3.
//  Copyright © 2018年 shike. All rights reserved.
//

#import "FMDBOrderTool.h"
#import <objc/runtime.h>

@implementation FMDBOrderTool

+ (NSArray *)allProperties:(Class)clazz {
    u_int count;
    //使用class_copyPropertyList及property_getName获取类的属性列表及每个属性的名称
    
    objc_property_t *properties = class_copyPropertyList(clazz, &count);
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        const char *propertyName = property_getName(properties[i]);
        [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
    }
    free(properties);
    return propertiesArray;
}
/**
 根据属性获取创建表的指令
 
 @param property 属性
 @return 指令
 */
+ (NSString *)createTableWithPropertyArray:(NSArray *)property name:(NSString *)name {
    // @"CREATE TABLE IF NOT EXISTS record (userId INTEGER,deviceId TEXT,heartRate INTEGER,high INTEGER,low INTEGER,createTime TEXT,appRecordId TEXT,flag INTEGER);"]
    if (property.count == 0 && name.length == 0) {
        return nil;
    }
    NSMutableString *string = [NSMutableString stringWithCapacity:0];
    [string appendString:@"CREATE TABLE IF NOT EXISTS "];
    [string appendString:name];
    [string appendString:@" (id integer PRIMARY KEY autoincrement,"];
    for (int i = 0; i < property.count; i ++) {
        NSString *key = property [i];
        if (i == property.count - 1) {
            [string appendString:key];
            [string appendString:@" TEXT"];
            [string appendString:@");"];
        }else {
            [string appendString:key];
            [string appendString:@" TEXT,"];
        }
    }
    return string;
}
/**
 增加一条数据
 
 @param model 数据源
 @param name 表名
 @return 指令
 */
+ (NSString *)insertValueWithModel:(id)model name:(NSString *)name {
    NSArray *property = [FMDBOrderTool allProperties:[model class]];
    if (property.count == 0) {
        NSLog(@"属性为空");
        return nil;
    }
    NSMutableArray *valueArray = [NSMutableArray arrayWithCapacity:0];
    [property enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj) {
            NSString *value = [model valueForKey:obj];
            [valueArray addObject:value];
        }else {
            // 用空字符串占位
            [valueArray addObject:@""];
        }
    }];
    NSMutableString *string = [NSMutableString stringWithCapacity:0];
    [string appendString:@"INSERT INTO "];
    [string appendString:name];
    [string appendString:@" ("];
    for (int i = 0; i < property.count; i ++) {
        NSString *key = property [i];
        if (i == property.count - 1) {
            [string appendString:key];
            [string appendString:@") VALUES ("];
        }else {
            [string appendString:key];
            [string appendString:@","];
        }
    }
    NSString *valueString = nil;
    for (int i = 0; i < valueArray.count; i ++) {
        NSString *value = valueArray [i];
        if (i == valueArray.count - 1) {
            if (valueString.length) {
                valueString = [NSString stringWithFormat:@"%@\"%@\")",valueString,value];
            }else {
                valueString = [NSString stringWithFormat:@"\"%@\")",value];
            }
        }else {
            if (valueString.length) {
                valueString = [NSString stringWithFormat:@"%@\"%@\",",valueString,value];
            }else {
                valueString = [NSString stringWithFormat:@"\"%@\",",value];
            }
        }
    }
    [string appendString:valueString];
    return string;
}
/**
 增加属性的指令
 
 @param column 属性名
 @param name 表名
 @return 指令
 */
+ (NSString *)addColumn:(NSString *)column name:(NSString *)name {
    NSMutableString *string = [NSMutableString stringWithCapacity:0];
    [string appendString:@"ALTER TABLE "];
    [string appendString:name];
    [string appendString:@" ADD "];
    [string appendString:column];
    [string appendString:@" TEXT"];
    return string;
}
/**
 移除一条数据
 
 @param key key
 @param value value
 @param name 表名
 @return  指令
 */
+ (NSString *)deleteDataWithKey:(NSString *)key
                          value:(NSString *)value
                           name:(NSString *)name {
    if (key.length == 0) {
        NSLog(@"key为空");
        return nil;
    }
    if (value.length == 0) {
        NSLog(@"value为空");
        return nil;
    }
    if (name.length == 0) {
        NSLog(@"表名为空");
        return nil;
    }
    NSMutableString *string = [NSMutableString stringWithCapacity:0];
    [string appendString:@"DELETE FROM "];
    [string appendString:name];
    [string appendString:@" WHERE "];
    [string appendString:key];
    [string appendString:@" = "];
    [string appendString:[NSString stringWithFormat:@"\"%@\";",value]];
    return string;
}
/**
 移除一张表的数据

 @param name 表名
 @return  指令
 */
+ (NSString *)deleteDataWithTableName:(NSString *)name {
    if (name.length == 0) {
        NSLog(@"表名为空");
        return nil;
    }
    NSMutableString *string = [NSMutableString stringWithCapacity:0];
    [string appendString:@"DELETE FROM "];
    [string appendString:name];
    [string appendString:@" WHERE 1 = 1"];
    return string;
}
/**
 查询所有数据的指令

 @param name 表名
 @return 指令
 */
+ (NSString *)allDataWithName:(NSString *)name {
    return [@"SELECT * FROM " stringByAppendingString:name];
}
/**
 查询一条数据
 
 @param key key
 @param value value
 @param name 表名
 @return  指令
 */
+ (NSString *)queryDataWithKey:(NSString *)key
                          value:(NSString *)value
                           name:(NSString *)name {
    if (key.length == 0) {
        NSLog(@"key为空");
        return nil;
    }
    if (value.length == 0) {
        NSLog(@"value为空");
        return nil;
    }
    if (name.length == 0) {
        NSLog(@"表名为空");
        return nil;
    }
    NSMutableString *string = [NSMutableString stringWithCapacity:0];
    [string appendString:@"SELECT * FROM "];
    [string appendString:name];
    [string appendString:@" WHERE "];
    [string appendString:key];
    [string appendString:@" = "];
    [string appendString:[NSString stringWithFormat:@"\"%@\";",value]];
    return string;
}
@end
