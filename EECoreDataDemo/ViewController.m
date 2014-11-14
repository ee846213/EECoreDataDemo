//
//  ViewController.m
//  EECoreDataDemo
//
//  Created by 卓哥的世界你不懂 on 14/11/11.
//  Copyright (c) 2014年 李卓. All rights reserved.
//

#import "ViewController.h"
#import "CustomCell.h"
#import <sqlite3.h>
#import "PersonHelper.h"
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UITextField *nameText;


@property (strong, nonatomic) IBOutlet UISegmentedControl *sexSegment;

@property (strong, nonatomic) IBOutlet UITextField *ageText;
@property (strong, nonatomic) IBOutlet UITextField *wageText;
@property (strong, nonatomic) IBOutlet UITableView *dataTable;
@property (strong, nonatomic)NSArray *dataArray;
@property (strong, nonatomic)CoreDataService *coreData;
@property (strong, nonatomic)PersonHelper *helper;
@end

@implementation ViewController
{
    sqlite3 *db;
    NSInteger selectID;
    NSInteger dataID;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    [self createSqlite];
    self.coreData = [CoreDataService shardInstance];
    _helper = [[PersonHelper alloc]init];
    _dataArray = [_helper findAllData];
    [self refresh];

    // Do any additional setup after loading the view, typically from a nib.
}
//-(void)createSqlite
//{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documents = [paths objectAtIndex:0];
//    NSString *database_path = [documents stringByAppendingPathComponent:@"Person.sqlite"];
//    
//    NSLog(@"%@",database_path);
//    //操作数据库，有便打开，没有便创建
//    if (sqlite3_open([database_path UTF8String], &db) != SQLITE_OK) {
//        sqlite3_close(db);
//        NSLog(@"数据库打开失败");
//    }
//    //创建表
//    NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS Person (id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT,sex BOOL,age INTEGER,wage INTEGER)";
//    [self execSql:sqlCreateTable];
//}
//-(void)execSql:(NSString *)sql
//{
//    
//    char *err;
//    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
//        sqlite3_close(db);
//        NSLog(@"数据库操作数据失败!");
//    }
//}
#pragma mark- 增删改查
- (IBAction)addPerson:(id)sender {
    if (_nameText.text.length<1||_ageText.text.length<1||_wageText.text.length<1) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请填写完整信息" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
 
    Person* person=(Person *)[NSEntityDescription insertNewObjectForEntityForName:modelName inManagedObjectContext:_coreData.context];
    BOOL sex;
    if (_sexSegment.selectedSegmentIndex==0) {
        sex = NO;
    }else
    {
        sex = YES;
    }

    
    [person setName:_nameText.text];

    [person setAge:[NSNumber numberWithInteger:[_ageText.text integerValue]]];
    [person setSex:[NSNumber numberWithBool:sex]];
    [person setWage:[NSNumber numberWithInteger:[_wageText.text integerValue]]];
    
    [person setPersonID:[NSNumber numberWithInteger:(dataID+1)]];
    if ([self serchPersonWithID:(dataID+1)]) {
        
        _dataArray = [_helper addPerson:person];
        [self refresh];
    }
    
}
- (IBAction)deletePerson:(id)sender {
    if (selectID<0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请选择要删除的数据" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
  
    _dataArray = [_helper deletePerson:selectID];
    [self refresh];
        
}
- (IBAction)searchPerson:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"查询" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"查询所有" otherButtonTitles:@"根据名称查询", nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet destructiveButtonIndex]) {
        _dataArray = [_helper findAllData];
        dataID = [[[_dataArray lastObject]valueForKey:@"PersonID"]integerValue];
        [_dataTable reloadData];
    }else if(buttonIndex == [actionSheet firstOtherButtonIndex])
    {
        [self serchPersonWithName];
        
    }
}
//查找名称相同的数据
-(void)serchPersonWithName
{
    if (_nameText.text.length<1) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请填写名称" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    _dataArray =[_helper searchByName:_nameText.text];
    [_dataTable reloadData];
}
/**
 *  判断id是否有相同的
 */
-(BOOL)serchPersonWithID:(NSInteger )personID
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:modelName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"personID=%i",personID];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSInteger count=[self.coreData.context countForFetchRequest:fetchRequest error:&error];
    if (count>1) {
        NSLog(@"重复%ld",count);
        return NO;
    }else
    {
        return YES;
    }

}
- (IBAction)updatePerson:(id)sender {
    if (selectID<0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请选择要修改的数据" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setValue:[NSNumber numberWithInteger:selectID] forKey:@"personID"];
        [dic setValue:_nameText.text forKey:@"name"];
        [dic setValue:[NSNumber numberWithInteger:[_ageText.text integerValue]]forKey:@"age"];
        [dic setValue:[NSNumber numberWithInteger:_sexSegment.selectedSegmentIndex] forKey:@"sex"];
        [dic setValue:[NSNumber numberWithUnsignedInteger:[_wageText.text integerValue]] forKey:@"wage"];
        _dataArray = [_helper updatePerson:dic];
        [self refresh];
    }
}

#pragma mark- 排序
- (IBAction)sortByName:(id)sender {
    [self sortByKey:@"name"];
}
- (IBAction)sortBySex:(id)sender {
    [self sortByKey:@"sex"];
}
- (IBAction)sortByAge:(id)sender {
    [self sortByKey:@"age"];
}

- (IBAction)sortByWage:(id)sender {
    [self sortByKey:@"wage"];
}

-(void)sortByKey:(NSString *)key
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:modelName];
    
    //按key排序
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:key ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSError *error = nil;
    NSArray *fetchedObjects = [_coreData.context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"失败");
    }else
    {
        
        _dataArray = fetchedObjects;
        [_dataTable reloadData];
    }

}
#pragma mark- tableviewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"person"];
    cell.name.text = [_dataArray[indexPath.row]valueForKey:@"name"];
    NSString *sex;
    
    if ([[_dataArray[indexPath.row]valueForKey:@"sex"]integerValue]==1) {
        sex = @"女";
    }else
    {
        sex = @"男";
    }
    
    cell.sex.text = sex;
    cell.age.text = [NSString stringWithFormat:@"%@",[_dataArray[indexPath.row]valueForKey:@"age"]];
    cell.wage.text = [NSString stringWithFormat:@"%@",[_dataArray[indexPath.row]valueForKey:@"wage"]];
    NSLog(@"%@",[_dataArray[indexPath.row]valueForKey:@"personID"]);
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _nameText.text = [_dataArray[indexPath.row]valueForKey:@"name"];
    _sexSegment.selectedSegmentIndex = [[_dataArray[indexPath.row]valueForKey:@"sex"]integerValue];
    _ageText.text = [NSString stringWithFormat:@"%@",[_dataArray[indexPath.row]valueForKey:@"age"]];
    _wageText.text = [NSString stringWithFormat:@"%@",[_dataArray[indexPath.row]valueForKey:@"wage"]];
    selectID =[[_dataArray[indexPath.row]valueForKey:@"personID"]integerValue];
    
}
-(void)refresh
{
    _nameText.text = @"";
    _sexSegment.selectedSegmentIndex = 0;
    _ageText.text = @"";
    _wageText.text =@"";
    selectID = -1;
    [_dataTable reloadData];
    dataID = [[[_dataArray lastObject]valueForKey:@"personID"]integerValue];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

