//
//  JViewController.m
//  WZLearnOpenGL
//
//  Created by admin on 15/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "JViewController.h"

@interface JViewController ()
{
    GLKView * glkView;
}
@end

@implementation JViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    //以一个计时器作为驱动 对数据的进行修改
    glkView = (GLKView *)self.view;
    glkView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:glkView.context];
    
    //数据匹配
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}


@end
