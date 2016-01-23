//
//  AppDelegate.m
//  CoreDataStuManager
//
//  Created by Elean on 16/1/12.
//  Copyright (c) 2016年 Elean. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    //如果程序不能在后台运行（程序猿自己设置 如何设置请看UI第一天应用程序生命周期的说明） 进入后台调用的是该方法 方法内部应该对当前app的数据做保存
    
    [self saveContext];
    //保存数据库
    
    
    
}

#pragma mark -- Core Data 相关设置
@synthesize context = _context;
@synthesize model = _model;
@synthesize coordinator = _coordinator;
//【注意】如果不加实现 无法使用_属性名的形式调用属性
//如果只有声明 没有@synthesize 系统回自动添加get、set方法的实现 而不是没有


//懒加载

//返回Documents路径
- (NSString *)appDocumentsDirectory{

    NSString *path = [NSString stringWithFormat:@"%@/Documents",NSHomeDirectory()];
    
    return path;
    
}
//model的get方法 懒加载
- (NSManagedObjectModel *)model{

    if(!_model){
    
        //如果第一次进来 model为空 需要创建设置 否则直接返回
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"StudentModel" ofType:@"momd"];
        NSURL *url = [NSURL fileURLWithPath:path];
  
 /*
        NSURL *url1 = [[NSBundle mainBundle]URLForResource:@"StudentModel" withExtension:@"momd"];
  等于以上两行
  
  */
        
        _model = [[NSManagedObjectModel alloc]initWithContentsOfURL:url];
        
        
        
    }
    
    return _model;
}

//协调器 get方法 懒加载
- (NSPersistentStoreCoordinator *)coordinator{

    if (!_coordinator) {
        //创建 并设置
        
        _coordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:[self model]];
        //注意 由于下划线的形式并没有调用get方法 因此model不会被创建 需要使用点语法或者直接调用get方法 保证model不为空
        
        //关联数据库
      NSString *dataBasePath = [NSString stringWithFormat:@"%@/MyDataBase.db",[self appDocumentsDirectory]];
        
      NSError *error = nil;
        
      NSString *failureReason = @"There was an error creating or loading the application's saved data.";
        //提示的错误语句
        
      NSPersistentStore *store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:dataBasePath] options:nil error:&error];
        
        if (!store) {
            // Report any error we got.
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
 /*
  error userInfo 字典 存储错误中的详细信息
  
            value :error.localizedDescription;
            key:NSLocalizedDescriptionKey 错误的主要提示信息
  
            NSLocalizedFailureReasonErrorKey对应的value 操作失败的原因
  
            NSUnderlyingErrorKey 未知错误
  
*/
            dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
            dict[NSLocalizedFailureReasonErrorKey] = failureReason;
            dict[NSUnderlyingErrorKey] = error;
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
           
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            
//            exit(-1); 表示异常退出 C的函数 该指令还会通知其他相关的操作 在本地资源读取的时候使用
            
            
            abort();
            //强制异常停止操作
            //如果协调器创建失败 数据库创建失败 后续的操作是没有意义的 因此要强制停止
        }
        

        
    }
    
    return _coordinator;
    
}

//context 懒加载
- (NSManagedObjectContext *)context{
    if(!_context){
    
        NSPersistentStoreCoordinator *coordinator = [self coordinator];
//        self.coordinator;
        
        if (!coordinator) {
            //如果协调器为空 那么context 就没有必要再创建context
            return nil;
            
        }else{
        
            _context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];
            //在这里 如果写在appDelete中 需要使用第三个枚举值 使用主线程
        
            _context.persistentStoreCoordinator =  coordinator;
            //[self coordinator]; self.coodinator 由于是懒加载 只可能创建一个对象
        
           
        }
        
        
        
    }
    
    return _context;
}

#pragma mark -- 保存app对数据库的当前操作
- (void)saveContext{

    //如果app不允许在后台运行 每次按home键就是关闭应用程序 应该在应用程序关闭前 将操作的结果保存到数据库 避免数据的丢失
    
    //(1)如果要保存数据 先判断context是否为空
    NSManagedObjectContext *context = [self context];
    
    if (context) {
        //不为空 需要判断数据中有没有正在更新的相关操作 例如添加数据 修改数据 删除数据等操作 如果有 需要保存操作的结果 保存之后 强制停止其他操作
        NSError *error = nil;
        if([context hasChanges] && ![context save:&error]){
            //如果有修改的 需要保存 但是保存失败  提示错误 强制结束
            
            
            NSLog(@"error:%@",error.localizedDescription);
                
            
        
            abort();
            
        }
        
        
        
    }
    
    
}




@end







