//
//  ViewController.m
//  WZLearnOpenGLWZ
//
//  Created by admin on 18/8/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>

@interface ViewController ()

@property (nonatomic, strong) EAGLContext *mContext;

@end

@implementation ViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupConfig];
}



- (void)setupConfig {
    //新建OpenGLES 上下文
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2]; //2.0，还有1.0和3.0
    GLKView* view = (GLKView *)self.view; //storyboard记得添加
    
    if (![view isKindOfClass:[GLKView class]]) {
        return;
    }
    
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;  //颜色缓冲区格式
    [EAGLContext setCurrentContext:self.mContext];
    
    //长度  宽度  深度
    
    //顶点数据，前三个是顶点坐标，后面两个是纹理坐标
    GLfloat squareVertexData[] =
    {
        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        0.5, 0.5, -0.0f,    1.0f, 1.0f, //右上
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上
        
        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上
        -0.5, -0.5, 0.0f,   0.0f, 0.0f, //左下
    };
    
    //顶点数据缓存
    GLuint buffer;//无符号整型
    // a sign
    glGenBuffers(1, &buffer);
    // make the sign binf to GL_ARRAY_BUFFER
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    //copy thr data from CPU to GPU
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);
    
    //开启对应的都顶点属性
    glEnableVertexAttribArray(GLKVertexAttribPosition); //顶点数据缓存
    //设置合适的格式从buffer里面读取数据
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0); //纹理
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
