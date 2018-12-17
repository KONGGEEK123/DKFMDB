//
//  FMDBOrderTool.h
//  DEMOKING
//
//  Created by DEMOKING  on 2018/5/3.
//  Copyright © 2018年 shike. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMDBOrderTool : NSObject

/**
 获取类的所有属性

 @param clazz 类
 @return 属性
 */
+ (NSArray *)allProperties:(Class)clazz;
/**
 根据属性获取创建表的指令

 @param property 属性
 @param name 表名
 @return 指令
 */
+ (NSString *)createTableWithPropertyArray:(NSArray *)property name:(NSString *)name;
/**
 增加一条数据

 @param model 数据源
 @param name 表名
 @return 指令
 */
+ (NSString *)insertValueWithModel:(id)model name:(NSString *)name;
/**
 增加属性的指令
 
 @param column 属性名
 @param name 表名
 @return 指令
 */
+ (NSString *)addColumn:(NSString *)column name:(NSString *)name;
/**
 移除一条数据
 
 @param key key
 @param value value
 @param name 表名
 @return  指令
 */
+ (NSString *)deleteDataWithKey:(NSString *)key
                          value:(NSString *)value
                           name:(NSString *)name;
/**
 移除一张表的数据
 
 @param name 表名
 @return  指令
 */
+ (NSString *)deleteDataWithTableName:(NSString *)name;

/**
 查询所有数据的指令
 
 @param name 表名
 @return 指令
 */
+ (NSString *)allDataWithName:(NSString *)name;
/**
 查询一条数据
 
 @param key key
 @param value value
 @param name 表名
 @return  指令
 */
+ (NSString *)queryDataWithKey:(NSString *)key
                         value:(NSString *)value
                          name:(NSString *)name;
@end
