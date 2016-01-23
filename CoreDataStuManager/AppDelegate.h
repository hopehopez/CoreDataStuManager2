//
//  AppDelegate.h
//  CoreDataStuManager
//
//  Created by Elean on 16/1/12.
//  Copyright (c) 2016年 Elean. All rights reserved.
//
/*
 一个app 为了保障同一时间只对数据库做一个操作 避免多个操作同时执行导致读取脏数据等问题 一个app最好只有一个context对一个数据库进行操作
 
 因此 将相关的对象在AppDelete中声明并创建 保证这些对象在这个app中是唯一的
 
 UIApplication单例 代理属性 AppDelegate(整个app只有一个，appDelegate的属性也只有一个)
  */
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
//调入coreData头文件

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,strong,readonly)NSManagedObjectContext *context;
//用于数据库的增删改查

@property (nonatomic,strong,readonly)NSManagedObjectModel *model;
//被管理的模型对象（对应的是coreDataModel）
//model本身不具备存储数据的功能 但是其内部包含的实体（在coreDataModel中设置的实体）生成的模型类是可以保存数据的

@property (nonatomic,strong,readonly)NSPersistentStoreCoordinator *coordinator;
//数据本地持久化协调器 协调实例模型与数据库的关联

//以上属性使用readonly 目的是 保证属性在appDelegate内部被创建 设置之后 外部不允许做任何修改


- (void)saveContext;
//save方法
- (NSString *)appDocumentsDirectory;
//返回数据库沙盒中Doucments的路径





@end

