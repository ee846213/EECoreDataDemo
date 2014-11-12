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
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
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
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createSqlite];

    [self loadData];

    // Do any additional setup after loading the view, typically from a nib.
}
-(void)createSqlite
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *database_path = [documents stringByAppendingPathComponent:@"Person.sqlite"];
    
    NSLog(@"%@",database_path);
    if (sqlite3_open([database_path UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"数据库打开失败");
    }
    NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS Person (name TEXT,sex BOOL,age INTEGER,wage INTEGER)";
    [self execSql:sqlCreateTable];
}
-(void)execSql:(NSString *)sql
{
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"数据库操作数据失败!");
    }
}

- (IBAction)addPerson:(id)sender {
    
    Person* person=(Person *)[NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self.context];
    BOOL sex;
    if (_sexSegment.selectedSegmentIndex==0) {
        sex = YES;
    }else
    {
        sex = NO;
    }

    [person setName:_nameText.text];

    [person setAge:[NSNumber numberWithInteger:[_ageText.text integerValue]]];
    [person setSex:[NSNumber numberWithBool:sex]];
    [person setWage:[NSNumber numberWithInteger:[_wageText.text integerValue]]];
    NSError* error;
    //保存数据
    BOOL isSaveSuccess=[self.context save:&error];
    if (!isSaveSuccess) {
        NSLog(@"Error:%@",error);
    }else{
        NSLog(@"Save successful!");
    }

}
- (IBAction)searchPerson:(id)sender {
    [self loadData];
}
-(void)loadData
{
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:_context];
//    [fetchRequest setEntity:entity];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Person"];

    
    //查询条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"age>%i", 0];
    [fetchRequest setPredicate:predicate];
    //排序方法，ascending为yes是升序
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"失败");
    }

    _dataArray = fetchedObjects;
    [_dataTable reloadData];
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
    return cell;
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
    NSURL *modelURL = [[NSBundle mainBundle]URLForResource:@"Person" withExtension:@"momd"];
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
