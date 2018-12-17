//
//  FMDBManager.m
//  DEMOKING
//
//  Created by DEMOKING  on 2018/5/3.
//  Copyright © 2018年 shike. All rights reserved.
//

#import "FMDBManager.h"
#import <FMDB.h>
#import "FMDBOrderTool.h"

#define FMDB_MANAGER_DB_NAME        @"MY_FMDB_LOCATION.db"
@interface FMDBManager ()

@property (strong, nonatomic) FMDatabase *dataBase;

@end

@implementation FMDBManager
/**
 初始化单例类
 
 @return 单例类
 */
+ (instancetype)shareManager {
    static FMDBManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FMDBManager alloc] init];
    });
    return manager;
}

#pragma mark -
#pragma mark - PRIVITE GETTER

/**
 获取数据操作器

 @return 数据操作器
 */
- (FMDatabase *)dataBase {
    if (!_dataBase) {
        _dataBase = [FMDatabase databaseWithPath:[self dataBasePath]];
    }
    return _dataBase;
}

/**
 获取数据缓存位置

 @return 位置字符串
 */
- (NSString *)dataBasePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths firstObject];
    NSString *dataBasePath = [documentDirectory stringByAppendingPathComponent:FMDB_MANAGER_DB_NAME];
    return dataBasePath;
}

#pragma mark -
#pragma mark - PRIVITE 创建表格

/**
 创建表格
 
 @param clazz 类型
 @param name 表名
 @return 是否创建成功
 */
- (BOOL)createTableWithClass:(Class)clazz name:(NSString *)name {
    NSArray *property = [FMDBOrderTool allProperties:[clazz class]];
    if (![self.dataBase open]) {
        NSLog(@"数据库打开错误");
        [self.dataBase close];
        return NO;
    }
    [self.dataBase setShouldCacheStatements:YES];
    NSString *createTableOrder = [FMDBOrderTool createTableWithPropertyArray:property name:name];
    if (createTableOrder.length == 0) {
        NSLog(@"创建表格指令出错");
        [self.dataBase close];
        return NO;
    }
    if (![self.dataBase executeUpdate:createTableOrder]) {
        NSLog(@"表格创建失败");
        [self.dataBase close];
        return NO;
    }
    [self.dataBase close];
    return YES;
}
/**
 添加一条数据
 
 @param model 对象
 @param tableName 名称
 @return 是否成功
 */
- (BOOL)insertModel:(id)model withTableName:(NSString *)tableName {
    if (![self createTableWithClass:[model class] name:tableName]) {
        [self.dataBase close];
        return NO;
    }
    if (![self.dataBase open]) {
        NSLog(@"数据库打开错误");
        [self.dataBase close];
        return NO;
    }
    if (!model) {
        [self.dataBase close];
        NSLog(@"对象为空");
        return NO;
    }
    if (tableName.length == 0) {
        [self.dataBase close];
        NSLog(@"表名为空");
        return NO;
    }
    // 先获取model中的key
    NSString *insertValueOrder = [FMDBOrderTool insertValueWithModel:model name:tableName];
    if (![self.dataBase executeUpdate:insertValueOrder]) {
        NSLog(@"插入一条数据失败");
        return NO;
    }
    [self.dataBase close];
    return YES;
}
/**
 添加数组数据
 
 @param modelArray 对象数组
 @param tableName 名称
 */
- (void)insertModelArray:(NSArray *)modelArray withTableName:(NSString *)tableName {
    [modelArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self insertModel:obj withTableName:tableName];
    }];
}
/**
 移除一条数据
 
 @param key key
 @param value value
 @param tableName 表名
 @return 是否成功
 */
- (BOOL)deleteDataWithKey:(NSString *)key
                    value:(NSString *)value
            withTableName:(NSString *)tableName {
    if (![self.dataBase open]) {
        NSLog(@"数据库打开错误");
        [self.dataBase close];
        return NO;
    }
    if (tableName.length == 0) {
        [self.dataBase close];
        NSLog(@"表名为空");
        return NO;
    }
    if (key.length == 0) {
        NSLog(@"key为空");
        [self.dataBase close];
        return NO;
    }
    if (value.length == 0) {
        NSLog(@"value为空");
        [self.dataBase close];
        return NO;
    }
    NSString *deleteValueOrder = [FMDBOrderTool deleteDataWithKey:key value:value name:tableName];
    if (![self.dataBase executeUpdate:deleteValueOrder]) {
        NSLog(@"删除数据失败");
        [self.dataBase close];
        return NO;
    }
    [self.dataBase close];
    return YES;
}
/**
 移除一张表的数据
 
 @param tableName 表名
 @return 是否成功
 */
- (BOOL)deleteAllDataWithClass:(NSString *)tableName {
    if (![self.dataBase open]) {
        NSLog(@"数据库打开错误");
        [self.dataBase close];
        return NO;
    }
    if (tableName.length == 0) {
        [self.dataBase close];
        NSLog(@"表名为空");
        return NO;
    }
    NSString *deleteDataOrder = [FMDBOrderTool deleteDataWithTableName:tableName];
    FMResultSet *set = [self.dataBase executeQuery:deleteDataOrder];
    while ([set next]) {
        [set close];
        [self.dataBase close];
        return YES;
    }
    [set close];
    [self.dataBase close];
    return NO;
}
/**
 查询所有数据 默认倒序
 
 @param clazz 类
 @param tableName 表名
 @return 数组
 */
- (NSMutableArray *)allDataWithClass:(Class)clazz tableName:(NSString *)tableName {
    if (![self.dataBase open]) {
        NSLog(@"数据库打开错误");
        [self.dataBase close];
        return nil;
    }
    if (tableName.length == 0) {
        [self.dataBase close];
        NSLog(@"表名为空");
        return nil;
    }
    NSString *allDataOrder = [FMDBOrderTool allDataWithName:tableName];
    FMResultSet *set = [self.dataBase executeQuery:allDataOrder];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    NSArray *property = [FMDBOrderTool allProperties:[clazz class]];
    while ([set next]) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:0];
        [property enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *value = [set stringForColumn:obj];
            [dictionary setValue:value forKey:obj];
        }];
        id model = [[clazz alloc] init];
        [model setValuesForKeysWithDictionary:dictionary];
        [array addObject:model];
    }
    [set close];
    [self.dataBase close];
    return array;
}
/**
 查询一条数据
 
 @param key key
 @param value value
 @param tableName 表名
 @return 是否成功
 */
- (BOOL)queryDataWithKey:(NSString *)key
                    value:(NSString *)value
            withTableName:(NSString *)tableName {
    if (![self.dataBase open]) {
        NSLog(@"数据库打开错误");
        [self.dataBase close];
        return NO;
    }
    if (tableName.length == 0) {
        [self.dataBase close];
        NSLog(@"表名为空");
        return NO;
    }
    if (key.length == 0) {
        NSLog(@"key为空");
        [self.dataBase close];
        return NO;
    }
    if (value.length == 0) {
        NSLog(@"value为空");
        [self.dataBase close];
        return NO;
    }
    NSString *selectSql = [FMDBOrderTool queryDataWithKey:key value:value name:tableName];
    
    FMResultSet *rs = [self.dataBase executeQuery:selectSql];
    while ([rs next]) {
        return YES;
    }
    return NO;
}

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
                                  clazz:(Class)clazz {
    if (![self.dataBase open]) {
        NSLog(@"数据库打开错误");
        [self.dataBase close];
        return nil;
    }
    if (tableName.length == 0) {
        [self.dataBase close];
        NSLog(@"表名为空");
        return nil;
    }
    if (key.length == 0) {
        NSLog(@"key为空");
        [self.dataBase close];
        return nil;
    }
    if (value.length == 0) {
        NSLog(@"value为空");
        [self.dataBase close];
        return nil;
    }
    NSString *selectSql = [FMDBOrderTool queryDataWithKey:key value:value name:tableName];
    FMResultSet *rs = [self.dataBase executeQuery:selectSql];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    NSArray *property = [FMDBOrderTool allProperties:[clazz class]];
    while ([rs next]) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:0];
        [property enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *value = [rs stringForColumn:obj];
            [dictionary setValue:value forKey:obj];
        }];
        id model = [[clazz alloc] init];
        [model setValuesForKeysWithDictionary:dictionary];
        [array addObject:model];
    }
    return array;
}
@end
