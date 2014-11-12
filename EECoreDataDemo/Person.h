//
//  Person.h
//  EECoreDataDemo
//
//  Created by 卓哥的世界你不懂 on 14/11/11.
//  Copyright (c) 2014年 李卓. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) NSNumber * wage;

@end
