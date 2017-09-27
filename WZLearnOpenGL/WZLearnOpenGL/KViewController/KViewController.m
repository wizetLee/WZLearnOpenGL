//
//  KViewController.m
//  WZLearnOpenGL
//
//  Created by admin on 27/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "KViewController.h"
#import "KView.h"
@interface KViewController ()

@property (nonatomic, strong) KView *kView;

@end

@implementation KViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _kView = [[KView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:_kView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
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
