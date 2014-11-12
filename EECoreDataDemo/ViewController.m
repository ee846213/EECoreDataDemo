//
//  ViewController.m
//  EECoreDataDemo
//
//  Created by 卓哥的世界你不懂 on 14/11/11.
//  Copyright (c) 2014年 李卓. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import <CoreData/CoreData.h>
#import "CustomCell.h"
#import <sqlite3.h>

static NSString *modelName = @"Person";
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UITextField *nameText;


@property (strong, nonatomic) IBOutlet UISegmentedControl *sexSegment;

@property (strong, nonatomic) IBOutlet UITextField *ageText;
@property (strong, nonatomic) IBOutlet UITextField *wageText;
@property (strong, nonatomic) IBOutlet UITableView *dataTable;
@property (strong, nonatomic)NSManagedObjectContext *context;
@property (strong, nonatomic)NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic)NSArray *dataArray;
@end

@implementation ViewController
{
    sqlite3 *db;
    NSInteger selectID;
    NSInteger dataNum;
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    [self createSqlite];

    [self loadData];

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
 
    Person* person=(Person *)[NSEntityDescription insertNewObjectForEntityForName:modelName inManagedObjectContext:self.context];
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
    [person setPersonID:[NSNumber numberWithInteger:(dataNum+1)]];
    if ([self serchPersonWithID:(dataNum+1)]) {
        NSError* error;
        
        
        //保存数据
        BOOL isSaveSuccess=[self.context save:&error];
        if (!isSaveSuccess) {
            NSLog(@"Error:%@",error);
        }else{
            NSLog(@"Save successful!");
            [self loadData];
        }

    }
    
}
- (IBAction)deletePerson:(id)sender {
    if (selectID<0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请选择要删除的数据" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:modelName];
    //查询同ID的数据
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"personID=%i",selectID];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    
    NSArray *fetchedObjects =  [self.context executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects==nil) {
        NSLog(@"查询失败");
    }else
    {
        //删除查询到的数据
        for(Person *person in fetchedObjects)
        {
            [self.context deleteObject:person];
        }
        BOOL isSaveSuccess=[self.context save:&error];
        if (!isSaveSuccess) {
            NSLog(@"Error:%@",error);
        }else{
            NSLog(@"Save successful!");
            [self loadData];
        }
    }
    
}
- (IBAction)searchPerson:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"查询" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"查询所有" otherButtonTitles:@"根据名称查询", nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet destructiveButtonIndex]) {
        [self loadData];
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
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:modelName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@",self.nameText.text];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        
    }else
    {
        [self refresh];
        _dataArray = fetchedObjects;
        [_dataTable reloadData];
    }
}
/**
 *  判断id是否有相同的
 */
-(BOOL)serchPersonWithID:(NSInteger )dataID
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:modelName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"personID=%i",dataID];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSInteger count=[self.context countForFetchRequest:fetchRequest error:&error];
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
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:modelName];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"personID=%i",selectID];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
        if (fetchRequest == nil) {
            NSLog(@"%@",error);
        }else
        {
//            BOOL sex;
//            if (_sexSegment.selectedSegmentIndex==0) {
//                sex = NO;
//            }else
//            {
//                sex = YES;
//            }
            for (Person *person in fetchedObjects) {
                [person setName:_nameText.text];
                [person setSex:[NSNumber numberWithInteger:_sexSegment.selectedSegmentIndex]];
                [person setAge:[NSNumber numberWithInteger:[_ageText.text integerValue]]];
                [person setWage:[NSNumber numberWithUnsignedInteger:[_wageText.text integerValue]]];
                
            }
            BOOL isSaveSuccess=[self.context save:&error];
            if (!isSaveSuccess) {
                NSLog(@"Error:%@",error);
            }else{
                NSLog(@"Save successful!");
                [self loadData];
            }
        }
        
    }
}
-(void)loadData
{
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:_context];
//    [fetchRequest setEntity:entity];
    [self refresh];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:modelName];

    
    //查询条件
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"age>%i", 0];
//    [fetchRequest setPredicate:predicate];
    //排序方法，ascending为yes是升序
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"personID"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"失败");
    }else
    {
        
        _dataArray = fetchedObjects;
        dataNum = [[[_dataArray lastObject]valueForKey:@"personID"]integerValue];
        [_dataTable reloadData];
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
    
    //按名称排序
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:key ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
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
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.bean.EECoreDataDemo" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
-(NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel!=nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle]URLForResource:modelName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc]initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

-(NSManagedObjectContext *)context
{
    if (_context!=nil) {
        return _context;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_context setPersistentStoreCoordinator:coordinator];
    return _context;
    
    //    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:[self managedObjectModel]];
    //    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"EECoreDataDemo.sqlite"];
    //    NSError *error =nil;
    //    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
    //
    //    }
    //    return _persistentStoreCoordinator;
    
    
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Person.sqlite"];
    
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}
@end

//
//@implementation CustomCell
//
//-(void)awakeFromNib
//{
//    
//}
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//    
//}
//@end
