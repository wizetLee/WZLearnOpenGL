//
//  MViewController.m
//  WZLearnOpenGL
//
//  Created by 李炜钊 on 2017/10/4.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "MViewController.h"
#import "GLProgram.h"
#import "MView.h"
@interface MViewController ()

@end

@implementation MViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    self.automaticallyAdjustsScrollViewInsets = false;
    
    UIImage *image = [UIImage imageNamed:@"74172016103114541058969337.jpg"];
    MView *v = [[MView alloc]initWithFrame:CGRectMake(0.0, 64.0, [UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.width / image.size.width * image.size.height)];
    [self.view addSubview:v];
}


@end
