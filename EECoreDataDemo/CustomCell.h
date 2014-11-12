//
//  CustomCell.h
//  EECoreDataDemo
//
//  Created by 卓哥的世界你不懂 on 14/11/11.
//  Copyright (c) 2014年 李卓. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *name;

@property (strong, nonatomic) IBOutlet UILabel *sex;
@property (strong, nonatomic) IBOutlet UILabel *age;
@property (strong, nonatomic) IBOutlet UILabel *wage;

@end
