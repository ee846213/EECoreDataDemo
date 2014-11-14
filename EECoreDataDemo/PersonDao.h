//
//  CoreDataDao.h
//  EECoreDataDemo
//
//  Created by 卓哥的世界你不懂 on 14/11/13.
//  Copyright (c) 2014年 李卓. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"
@interface PersonDao : NSObject
+(instancetype)shardInstance;
-(void)addPerson:(Person *)person;
-(void)deletePerson:(NSInteger)personID;
-(void)upDatePerson:(NSDictionary *)updateInfo;
-(NSArray *)searchByName:(NSString *)name;
-(NSArray *)findAllData;
@end
