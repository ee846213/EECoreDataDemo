//
//  PersonBL.h
//  EECoreDataDemo
//
//  Created by 卓哥的世界你不懂 on 14/11/13.
//  Copyright (c) 2014年 李卓. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PersonDao.h"
@interface PersonHelper : NSObject
-(NSArray *)addPerson:(Person *)person;
-(NSArray *)deletePerson:(NSInteger)personID;
-(NSArray *)searchByName:(NSString *)name;
-(NSArray *)updatePerson:(NSDictionary *)updateInfo;
-(NSArray *)findAllData;
@end
