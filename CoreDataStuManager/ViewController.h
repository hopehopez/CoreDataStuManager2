//
//  ViewController.h
//  CoreDataStuManager
//
//  Created by Elean on 16/1/12.
//  Copyright (c) 2016年 Elean. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *IDField;
- (IBAction)addClick:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)deleteClick:(id)sender;

- (IBAction)changeClick:(id)sender;
- (IBAction)searchClick:(id)sender;

@end

