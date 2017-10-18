//
//  NViewController.m
//  WZLearnOpenGL
//
//  Created by admin on 18/10/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "NViewController.h"
#import "NView.h"

@interface NViewController ()

@end

@implementation NViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NView *view = [[NView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
