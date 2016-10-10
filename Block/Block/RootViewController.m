//
//  RootViewController.m
//  BlockMemeorySample
//
//  Created by Carouesl on 2016/10/1.
//  Copyright © 2016年 Youku Tudou Inc. All rights reserved.
//

#import "RootViewController.h"
#import "ViewController.h"

@interface RootViewController ()
@property (nonatomic, strong) ViewController* vc;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];

    self.title = @"RootViewController";
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    ViewController*vc = [[ViewController alloc] init];

    [self.navigationController  pushViewController:vc animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
