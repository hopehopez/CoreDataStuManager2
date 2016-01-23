//
//  ViewController.m
//  CoreDataStuManager
//
//  Created by Elean on 16/1/12.
//  Copyright (c) 2016年 Elean. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Student.h"
#import "ELNAlerTool.h"
@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *dataArr;
//数组 存储数据
@property (nonatomic, strong) NSManagedObjectContext *context;
//赋值为AppDelegate中的context
@property (nonatomic, assign) NSInteger currentRow;
//记录当前选中的cell是第几个 选个一个cell 把相应的学生信息显示在输入框里 对学生的信息操作

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self loadData];
    //每次进来刷新数据
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //1.初始化创建数组
    _dataArr = [NSMutableArray array];
    
    //2.设置context
    //(1)先获取AppDelegate
    AppDelegate *appDelete = [UIApplication sharedApplication].delegate;
    
    //(2)获取AppDelegate中的 属性 context
    _context = appDelete.context;
    
    //3.设置currentRow
    _currentRow = -1;
    //一开始没有选中的cell
    
    //4.在viewWillAppear中从数据库中读取最新的 数据 显示在tableView上
    
    //5.设置tableView
    [self setUpTableView];
}

#pragma mark - loadData from database
- (void)loadData{
#if 0
    Student *elean = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:_context];
    elean.name = @"Elean";
    elean.stuID = @(1001);
    
    //(3)将数据添加到数据库
    NSError *error = nil;
    BOOL isOk = [_context save:&error];
    if (isOk) {
        NSLog(@"添加数据成功");
    } else {
        NSLog(@"添加数据失败");
    }

#endif
    
    //查询数据库中所有的数据 存入dataArr
    
    //(1)查询设置
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Student"];
    
    //如果不设置任何查询条件 就是获取所有数据
    NSArray *array = [_context executeFetchRequest:request error:nil];
    
    //(2)将返回的结果存入dataArr
    [_dataArr removeAllObjects];
    [_dataArr addObjectsFromArray:array];
    
    
    //(3)tableView刷新
    [_tableView reloadData];
}

#pragma mark - 设置tableView
- (void)setUpTableView{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.rowHeight = 80;
}

#pragma mark - dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    //数据刷新
    Student *stu = _dataArr[indexPath.row];
    //取出模型 因为数组中的数据由coreData已经转换成模型 因此可以直接使用模型接收
    cell.textLabel.text = [NSString stringWithFormat:@"学号: %@", stu.stuID];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"姓名: %@", stu.name];
    
    return cell;
}

#pragma mark - delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Student *stu = _dataArr[indexPath.row];
    
    _IDField.text = [stu.stuID stringValue];
    ;
    _nameField.text = stu.name;
    
    _currentRow = indexPath.row;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 增加
- (IBAction)addClick:(id)sender {
    [_nameField resignFirstResponder];
    [_IDField resignFirstResponder];
    
    //将输入框中输入的信息写入数据库
    NSString *stuID = _IDField.text;
    NSString *name = _nameField.text;
    
    if(stuID.length == 0 || name.length == 0){
        NSString *message = @"学生学号与姓名不能为空";
        [ELNAlerTool showAlertMassgeWithController:self andMessage:message andInterval:1.5];
        return;
    }
    
    //添加信息
    Student *elean = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:_context];
    elean.name = name;
    elean.stuID = @([stuID integerValue]);
    
    //(3)将数据添加到数据库
    NSError *error = nil;
    BOOL isOk = [_context save:&error];
    if (isOk) {
        NSLog(@"添加数据成功");
        [ELNAlerTool showAlertMassgeWithController:self andMessage:@"添加成功" andInterval:1];
        
        //将新的对象 加入数组 刷新tableView
        [_dataArr addObject:elean];
        
        [_tableView reloadData];
    } else {
        NSLog(@"添加数据失败");
        [ELNAlerTool showAlertMassgeWithController:self andMessage:@"添加失败" andInterval:1];
    }
    
    _IDField.text = nil;
    _nameField.text = nil;
    _currentRow = -1;
}


#pragma mark - 删除
- (IBAction)deleteClick:(id)sender {
    [_nameField resignFirstResponder];
    [_IDField resignFirstResponder];
    
    NSString *name = _nameField.text;
    NSString *stuID = _IDField.text;
    
    if(stuID.length == 0 || name.length == 0){
        NSString *message = @"学生学号与姓名不能为空";
        [ELNAlerTool showAlertMassgeWithController:self andMessage:message andInterval:1.5];
        return;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Student"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"%K = %@ and %K = %@", @"name", name, @"stuID", stuID];
    
    NSArray *array = [_context executeFetchRequest:request error:nil];
    
    //如果未找到要删除的学生 提示信息 并返回
    if (array.count == 0) {
        [ELNAlerTool showAlertMassgeWithController:self andMessage:@"该学生不存在" andInterval:1];
        return ;
    }
    
    for (Student *stu in array) {
        [_context deleteObject:stu];
    }
    
    NSError *error = nil;
    BOOL isOK = [_context save:&error];
    if (isOK) {
        NSLog(@"删除数据成功");
        [ELNAlerTool showAlertMassgeWithController:self andMessage:@"删除成功" andInterval:1];
        
        [_dataArr removeObjectsInArray:array];
        [_tableView reloadData];
    } else {
        NSLog(@"删除数据失败");
        [ELNAlerTool showAlertMassgeWithController:self andMessage:@"删除失败" andInterval:1];
    }
    
    _IDField.text = nil;
    _nameField.text = nil;
    _currentRow = -1;
}
#pragma mark - 修改
- (IBAction)changeClick:(id)sender {
    [_nameField resignFirstResponder];
    [_IDField resignFirstResponder];
    
    NSString *name = _nameField.text;
    NSString *stuID = _IDField.text;
    
    if(stuID.length == 0 || name.length == 0){
        NSString *message = @"学生学号与姓名不能为空";
        [ELNAlerTool showAlertMassgeWithController:self andMessage:message andInterval:1.5];
        return;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Student"];
    
    Student *oldStu = _dataArr[_currentRow];
    request.predicate = [NSPredicate predicateWithFormat:@"%K = %@ and %K = %@", @"name", oldStu.name, @"stuID", oldStu.stuID];
    
    NSArray *array = [_context executeFetchRequest:request error:nil];
    
    if (array.count == 0) {
        [ELNAlerTool showAlertMassgeWithController:self andMessage:@"该学生不存在" andInterval:1];
        return ;
    }
    
    for (Student *stu in array) {
        stu.name = name;
        stu.stuID = @([stuID integerValue]);
    }
    NSError *error = nil;
    BOOL isOK = [_context save:&error];
    if (isOK) {
        NSLog(@"修改数据成功");
        [ELNAlerTool showAlertMassgeWithController:self andMessage:@"修改成功" andInterval:1];
        
        [self loadData];
        [_tableView reloadData];
    } else {
        NSLog(@"修改数据失败");
        [ELNAlerTool showAlertMassgeWithController:self andMessage:@"修改失败" andInterval:1];
    }
    
    _IDField.text = nil;
    _nameField.text = nil;
    _currentRow = -1;
}
#pragma mark - 查询
- (IBAction)searchClick:(id)sender {
    [_nameField resignFirstResponder];
    [_IDField resignFirstResponder];
    
    [_nameField resignFirstResponder];
    [_IDField resignFirstResponder];
    
    NSString *name = _nameField.text;
    NSString *stuID = _IDField.text;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Student"];
    if (name.length == 0 && stuID.length != 0) {
        request.predicate = [NSPredicate predicateWithFormat:@"%K like %@", @"stuID", [NSString stringWithFormat:@"*%@*", stuID]];
    } else if (name.length !=0 && stuID.length == 0){
        request.predicate = [NSPredicate predicateWithFormat:@"%K like %@", @"name", [NSString stringWithFormat:@"*%@*", name]];
    } else if (name.length >0 && stuID.length >0 ){
        request.predicate = [NSPredicate predicateWithFormat:@"%K = %@ and %K = %@",@"name", name, @"stuID", stuID];
    }
    
    NSArray *array = [_context executeFetchRequest:request error:nil];
    
    if (array.count == 0) {
        [ELNAlerTool showAlertMassgeWithController:self andMessage:@"该学生不存在" andInterval:1];
        return ;
    }else {
         [ELNAlerTool showAlertMassgeWithController:self andMessage:@"查询成功" andInterval:1];
    }
    
    _dataArr = [NSMutableArray arrayWithArray:array];
    
    [_tableView reloadData];
    
    _nameField.text = nil;
    _IDField.text = nil;
}
@end
