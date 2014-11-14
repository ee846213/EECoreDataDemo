//
//  CoreDataDao.m
//  EECoreDataDemo
//
//  Created by 卓哥的世界你不懂 on 14/11/13.
//  Copyright (c) 2014年 李卓. All rights reserved.
//

#import "PersonDao.h"

@implementation PersonDao
{
    NSArray *dataArray;
    
}
+(instancetype)shardInstance
{
    static PersonDao *dao = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        dao = [[PersonDao alloc]init];
    });
    return dao;
}
-(void)addPerson:(Person *)person
{
    [self savePerson];
}
-(void)deletePerson:(NSInteger)personID
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:modelName];
    //查询同ID的数据
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"personID=%i",personID];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    
    NSArray *fetchedObjects =  [[CoreDataService shardInstance].context executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects==nil) {
        NSLog(@"查询失败");
    }else
    {
        //删除查询到的数据
        for(Person *person in fetchedObjects)
        {
            [[CoreDataService shardInstance].context deleteObject:person];
        }
        [self savePerson];
    }

}
-(NSArray *)searchByName:(NSString *)name
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:modelName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@",name];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [[CoreDataService shardInstance].context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        
    }else
    {
        
        dataArray = fetchedObjects;
    }
    return dataArray;

}
-(void)upDatePerson:(NSDictionary *)updateInfo
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:modelName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"personID=%i",[updateInfo[@"personID"]integerValue]];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [[CoreDataService shardInstance].context executeFetchRequest:fetchRequest error:&error];
    if (fetchRequest == nil) {
        NSLog(@"%@",error);
    }else
    {
        
        for (Person *person in fetchedObjects) {
            
            [person setName:updateInfo[@"name"]];
            [person setSex:updateInfo[@"sex"]];
            [person setAge:updateInfo[@"age"]];
            [person setWage:updateInfo[@"wage"]];
            
        }
        [self savePerson];
    }

}
-(void)savePerson
{
    NSError* error;
    
    
    //保存数据
    BOOL isSaveSuccess=[[CoreDataService shardInstance].context save:&error];
    if (!isSaveSuccess) {
        NSLog(@"Error:%@",error);
    }else{
        NSLog(@"Save successful!");
    }
}


-(NSArray *)findAllData
{
    //    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    //    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:_context];
    //    [fetchRequest setEntity:entity];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:modelName];
    
    
    //查询条件
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"age>%i", 0];
    //    [fetchRequest setPredicate:predicate];
    //排序方法，ascending为yes是升序
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"personID"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[CoreDataService shardInstance].context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"失败");
    }else
    {
        
        dataArray = fetchedObjects;
    }
    return dataArray;

}
@end
