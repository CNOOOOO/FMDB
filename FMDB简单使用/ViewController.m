//
//  ViewController.m
//  FMDB简单使用
//
//  Created by Mac1 on 2018/5/28.
//  Copyright © 2018年 Mac1. All rights reserved.
//FMDB类的说明文档：http://ccgus.github.io/fmdb/html/index.html

#import "ViewController.h"
#import <FMDB.h>
#import "Location.h"

@interface ViewController ()

@property (nonatomic, strong) FMDatabase *database;//数据库
@property (nonatomic, copy)   NSString *databasePath;//数据库本地路径
@property (nonatomic, strong) FMDatabaseQueue *queue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /**      界面空空如也，所有功能和介绍都写在注释里了，依次操作检测一下即可       */
    
    //数据库所在的本地路径
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    self.databasePath = [path stringByAppendingPathComponent:@"location.sqlite"];
    self.queue = [FMDatabaseQueue databaseQueueWithPath:self.databasePath];
    //初始化数据库
    /**
     1. 如果该路径下已经存在该数据库，直接获取该数据库;
     2. 如果不存在就创建一个新的数据库;
     3. 如果传@""，会在临时目录创建一个空的数据库，当数据库关闭时，数据库文件也被删除;
     4. 如果传nil，会在内存中临时创建一个空的数据库，当数据库关闭时，数据库文件也被删除;
     */
    self.database = [FMDatabase databaseWithPath:self.databasePath];
    //打开数据库,所有针对数据库的操作都必须在数据库打开的前提下
    [self.database open];
    [self createTable];
}

//创建表
- (void)createTable {
    if ([self.database open]) {
        BOOL result = [self.database executeUpdate:@"CREATE TABLE IF NOT EXISTS t_location (latitude text NOT NULL, longitude text NOT NULL, altitude text);"];
        //如果有id，可设置成自增id integer PRIMARY KEY AUTOINCREMENT，NOT NULL表示不能为空
        if (result) {
            NSLog(@"创建表成功");
        }else {
            NSLog(@"创建表失败");
        }
    }
}

//添加新字段
- (void)addNewColumn {
    //判断表中是否有该字段存在，不存在才添加
    if (![self.database columnExists:@"direction" inTableWithName:@"t_location"]){
        NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER",@"t_location",@"direction"];
        BOOL result = [self.database executeUpdate:alertStr];
        if(result){
            NSLog(@"添加成功");
        }else{
            NSLog(@"添加失败");
        }
    }
}

//删除表
- (void)deleteTable {
    if ([self.database open]) {
        BOOL result = [self.database executeUpdate:@"drop table if exists t_location"];
        if (result) {
            NSLog(@"删除表成功");
        }else {
            NSLog(@"删除表失败");
        }
    }
}

//插入数据
- (void)insertData {
    if ([self.database open]) {
        //不确定参数用 ？占位
        BOOL result = [self.database executeUpdate:@"INSERT INTO t_location (latitude, longitude, altitude) VALUES (?,?,?)",@"31.002823", @"121.6278899", @"0.12"];
        //不确定参数用 %@,%d,%f 占位,执行语句insert into ...不区分大小写
        //    BOOL result1 = [self.database executeUpdateWithFormat:@"INSERT INTO t_location (latitude, longitude, altitude) VALUES (%@,%@,%@)",@"31.002823", @"121.6278899", @"0.12"];
        //参数是数组的使用方式
        //    BOOL result2 = [self.database executeUpdate:@"INSERT INTO t_location (latitude, longitude, altitude) VALUES (?,?,?)" withArgumentsInArray:@[@"31.002823",@"121.6278899",@"0.12"]];
        
        if (result) {
            NSLog(@"插入数据成功");
        }else {
            NSLog(@"插入数据失败");
        }
    }
}

//删除数据
- (void)deleteData {
    if ([self.database open]) {
        BOOL result = [self.database executeUpdate:@"delete from t_location where latitude = ?",@"31.002823"];
        if (result) {
            NSLog(@"删除成功");
        }else {
            NSLog(@"删除失败");
        }
    }
}

//更改数据
- (void)updateData {
    if ([self.database open]) {
        BOOL result = [self.database executeUpdate:@"update t_location set longitude = ? where latitude = ?",@"122.12132312",@"31.002823"];
        if (result) {
            NSLog(@"修改成功");
        }else {
            NSLog(@"修改失败");
        }
    }
}

//查询数据
- (void)selectData {
    NSMutableArray *locations = [NSMutableArray array];
    if ([self.database open]) {
        //查询整个表
        FMResultSet *resultSet = [self.database executeQuery:@"select * from t_location"];
        //按条件查询
        //    FMResultSet *resultSet1 = [self.database executeQuery:@"select * from t_location where latitude = ?",@"31.002823"];
        //查询某个字段的所有值
        //    FMResultSet *resultSet2 = [self.database executeQuery:@"select latitude from t_location where altitude = ?",@"0.12"];
        while ([resultSet next]) {
            /**FMResultSet对应的方法：
            获取下一个记录
            - (BOOL)next;
            获取记录有多少列(字段)
            - (int)columnCount;
            通过列名得到列序号，通过列序号得到列名
            - (int)columnIndexForName:(NSString *)columnName;
            - (NSString *)columnNameForIndex:(int)columnIdx;
            获取存储的整形值
            - (int)intForColumn:(NSString *)columnName;
            - (int)intForColumnIndex:(int)columnIdx;
            获取存储的长整形值
            - (long)longForColumn:(NSString *)columnName;
            - (long)longForColumnIndex:(int)columnIdx;
            获取存储的布尔值
            - (BOOL)boolForColumn:(NSString *)columnName;
            - (BOOL)boolForColumnIndex:(int)columnIdx;
            获取存储的浮点值
            - (double)doubleForColumn:(NSString *)columnName;
            - (double)doubleForColumnIndex:(int)columnIdx;
            获取存储的字符串
            - (NSString *)stringForColumn:(NSString *)columnName;
            - (NSString *)stringForColumnIndex:(int)columnIdx;
            获取存储的日期数据
            - (NSDate *)dateForColumn:(NSString *)columnName;
            - (NSDate *)dateForColumnIndex:(int)columnIdx;
            获取存储的二进制数据
            - (NSData *)dataForColumn:(NSString *)columnName;
            - (NSData *)dataForColumnIndex:(int)columnIdx;
            获取存储的UTF8格式的C语言字符串
            - (const unsigned cahr *)UTF8StringForColumnName:(NSString *)columnName;
            - (const unsigned cahr *)UTF8StringForColumnIndex:(int)columnIdx;
            获取存储的对象，只能是NSNumber、NSString、NSData、NSNull
            - (id)objectForColumnName:(NSString *)columnName;
            - (id)objectForColumnIndex:(int)columnIdx;
             */
            
            NSString *latitude = [resultSet stringForColumn:@"latitude"];
            NSString *longitude = [resultSet stringForColumn:@"longitude"];
            NSString *altitude = [resultSet stringForColumn:@"altitude"];
            Location *location = [[Location alloc] init];
            location.latitude = latitude;
            location.longitude = longitude;
            location.altitude = altitude;
            [locations addObject:location];
        }
        NSLog(@"%@",locations);
        //关闭数据库
//        [self.database close];
    }
}

//多线程
- (void)databaseQueue {
    dispatch_queue_t queue1 = dispatch_queue_create("queue1", NULL);
    dispatch_queue_t queue2 = dispatch_queue_create("queue2", NULL);
    if ([self.database open]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(queue1, ^{
            for (int i=0; i<10; i++) {
                [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    NSString *latitude = [NSString stringWithFormat:@"31.0028%d",i];
                    NSString *longitude = [NSString stringWithFormat:@"121.62788%d",i];
                    BOOL result = [strongSelf.database executeUpdate:@"INSERT INTO t_location (latitude, longitude, altitude) VALUES (?,?,?)",latitude, longitude, @"2.1"];
                    if (result) {
                        NSLog(@"插入成功");
                    }else {
                        NSLog(@"插入失败");
                    }
                }];
            }
        });
        
        dispatch_async(queue2, ^{
            for (int j=0; j<10; j++) {
                [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    NSString *latitude = [NSString stringWithFormat:@"31.002%d",j];
                    NSString *longitude = [NSString stringWithFormat:@"121.6278%d",j];
                    BOOL result = [strongSelf.database executeUpdate:@"INSERT INTO t_location (latitude, longitude, altitude) VALUES (?,?,?)",latitude, longitude, @"1.3"];
                    if (result) {
                        NSLog(@"插入成功");
                    }else {
                        NSLog(@"插入失败");
                    }
                }];
            }
        });
    }
}

//事务:是指作为单个逻辑工作单元执行的一系列操作，要么全部执行，要么全部不执行。比如批量更新数据，当更新遇到错误时，把已更新的回滚成原来的数据，剩下的不再做更新操作；只有所有更新都没有异常时，此次批量更新才算成功
- (void)transaction {
    //开启事务
    [self.database beginTransaction];
    //是否回滚
    BOOL isRollback = NO;
    @try {
        for (int i=0; i<10; i++) {
            NSString *latitude = [NSString stringWithFormat:@"21.0028%d",i];
            NSString *longitude = [NSString stringWithFormat:@"123.62788%d",i];
            BOOL result = [self.database executeUpdate:@"INSERT INTO t_location (latitude, longitude, altitude) VALUES (?,?,?)",latitude, longitude, @"1.1"];
            if (result) {
                NSLog(@"插入成功");
            }else {
                NSLog(@"插入失败");
            }
        }
    }
    @catch (NSException *exception) {//有异常
        isRollback = YES;
        //事务回滚
        [self.database rollback];
    }
    @finally {
        if (!isRollback) {
            //事务提交
            [self.database commit];
        }
    }
    [self.database close];
}

//多线程事务
- (void)transactionByQueue {
    [self.queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (int i=0; i<10; i++) {
            NSString *latitude = [NSString stringWithFormat:@"41.00285%d",i];
            NSString *longitude = [NSString stringWithFormat:@"124.627882%d",i];
            BOOL result = [db executeUpdate:@"INSERT INTO t_location (latitude, longitude, altitude) VALUES (?,?,?)",latitude, longitude, @"1.7"];
            if (result) {
                NSLog(@"插入成功");
            }else {
                NSLog(@"插入失败");
                *rollback = YES;
                return;
            }
        }
        [self.database close];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
