//
//  CoreDataService.h
//  EECoreDataDemo
//
//  Created by 卓哥的世界你不懂 on 14/11/13.
//  Copyright (c) 2014年 李卓. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface CoreDataService : NSObject
@property (strong, nonatomic)NSManagedObjectContext *context;
@property (strong, nonatomic)NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic)NSPersistentStoreCoordinator *persistentStoreCoordinator;

+(instancetype)shardInstance;
@end
