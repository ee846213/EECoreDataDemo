//
//  PersonBL.m
//  EECoreDataDemo
//
//  Created by 卓哥的世界你不懂 on 14/11/13.
//  Copyright (c) 2014年 李卓. All rights reserved.
//

#import "PersonHelper.h"

@implementation PersonHelper
-(NSArray *)addPerson:(Person *)person
{
    [[PersonDao shardInstance]addPerson:person];
    return [[PersonDao shardInstance]findAllData];
}

-(NSArray *)deletePerson:(NSInteger)personID
{
    [[PersonDao shardInstance]deletePerson:personID];;
    return [[PersonDao shardInstance]findAllData];
}

-(NSArray *)findAllData
{
    return [[PersonDao shardInstance]findAllData];
}

-(NSArray *)searchByName:(NSString *)name
{
   return [[PersonDao shardInstance]searchByName:name];
}

-(NSArray *)updatePerson:(NSDictionary *)updateInfo
{
    [[PersonDao shardInstance]upDatePerson:updateInfo];
    return [[PersonDao shardInstance]findAllData];
}
@end
