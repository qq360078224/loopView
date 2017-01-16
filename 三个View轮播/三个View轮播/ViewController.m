//
//  ViewController.m
//  三个View轮播
//
//  Created by 都市蚂蚁 on 2017/1/9.
//  Copyright © 2017年 com.dingqi. All rights reserved.
//

#import "ViewController.h"
#import "XQLoopView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    XQLoopView *view = [[XQLoopView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor greenColor];
    view.imageURLStrings = @[@"1.jpg", @"2.jpg", @"3.jpg", @"1.jpg", @"2.jpg", @"3.jpg"];
    //view.curIndex = 1;
    view.scrollDuration = 2;
    view.clickAction = ^(NSInteger index) {
        NSLog(@"%ld", index);
    
    };
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
