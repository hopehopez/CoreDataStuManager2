//
//  ELNAlerTool.m
//  AutomicCloseAlertDemo
//
//  Created by Elean on 16/1/11.
//  Copyright (c) 2016年 Elean. All rights reserved.
//

#import "ELNAlerTool.h"

@implementation ELNAlerTool
+ (void)showAlertMassgeWithController:(UIViewController *)ctr andMessage:(NSString *)message andInterval:(NSTimeInterval)time{

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [ctr presentViewController:alert animated:YES completion:^{
       
        [self performSelector:@selector(openAlert:) withObject:alert afterDelay:time];
        
    }];
    
}

+ (void)openAlert:(UIAlertController *)alert{

    [alert dismissViewControllerAnimated:YES completion:nil];
}

@end
