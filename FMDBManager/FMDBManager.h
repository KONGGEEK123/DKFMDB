//
//  FMDBManager.h
//  DEMOKING
//
//  Created by DEMOKING  on 2018/5/3.
//  Copyright © 2018年 shike. All rights reserved.
//  所有存储的对象的属性，必须是字符串

#import <UIKit/UIKit.h>

@interface FMDBManager : NSObject

/**
 初始化单例类

 @return 单例类
 */
+ (instancetype)shareManager;
/**
 创建表格
 
 @param clazz 类型
 @param name 表名
 @return 是否创建成功
 */
- (BOOL)createTableWithClass:(Class)clazz name:(NSString *)name;
/**
 添加一条数据

 @param model 对象
 @param tableName 名称
 @return 是否成功
 */
- (BOOL)insertModel:(id)model withTableName:(NSString *)tableName;
/**
 添加数组数据
 
 @param modelArray 对象数组
 @param tableName 名称
 */
- (void)insertModelArray:(NSArray *)modelArray withTableName:(NSString *)tableName;
/**
 移除一条数据

 @param key key
 @param value value
 @param tableName 表名
 @return 是否成功
 */
- (BOOL)deleteDataWithKey:(NSString *)key
                    value:(NSString *)value
            withTableName:(NSString *)tableName;
/**
 移除一张表的数据
 
 @param tableName 表名
 @return 是否成功
 */
- (BOOL)deleteAllDataWithClass:(NSString *)tableName;
/**
 查询所有数据  默认倒序
 
 @param clazz 类
 @param tableName 表名
 @return 数组
 */
- (NSMutableArray *)allDataWithClass:(Class)clazz tableName:(NSString *)tableName;
/**
 查询一条数据
 
 @param key key
 @param value value
 @param tableName 表名
 @return 是否成功
 */
- (BOOL)queryDataWithKey:(NSString *)key
                   value:(NSString *)value
           withTableName:(NSString *)tableName;
/**
 查询符合条件的数据并返回
 
 @param key key
 @param value value
 @param tableName 表名
 @param clazz 类型
 @return 是否成功
 */
- (NSMutableArray *)queryAllDataWithKey:(NSString *)key
                                  value:(NSString *)value
                              tableName:(NSString *)tableName
                                  clazz:(Class)clazz;

@end

