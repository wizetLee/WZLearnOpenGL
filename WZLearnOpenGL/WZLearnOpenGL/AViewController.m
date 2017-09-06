//
//  AViewController.m
//  WZLearnOpenGL
//
//  Created by admin on 25/8/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "AViewController.h"

#import <GLKit/GLKit.h>

@interface AViewController ()<GLKViewDelegate>

@property (nonatomic, strong) GLKView *glView;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;//隐藏OpenGL ES版本之间的差异
@property (nonatomic, assign) GLuint vertexBufferID;//顶点buffer ID

@end

@implementation AViewController


typedef struct{
    GLKVector3 positionCoords;//一;个含有三分量属性的结构体
} SceneVertex;//顶点结构体

//数据数组  提供数据（顶点）
static const SceneVertex vertices[] = {
    {{-1, -1, 0.0}},//左下角
    {{ 1, -1, 0.0}},//右上角
    {{-1, 1, 0.0}},//左上角
};



- (void)viewDidLoad {
    [super viewDidLoad];
    [self createViews];
}

- (void)createViews {
    _glView = [[GLKView alloc] init];
    _glView.frame = self.view.bounds;
    _glView.delegate = self;
    [self.view addSubview:_glView];
     //内建一个 EAGLContext 类的实例
    
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    _glView.context = context;
    [EAGLContext setCurrentContext:_glView.context];//在其他任何的OpenGL ES配置或者是渲染发生之前都要把GLKView实例中的上下文属性设置为当前。
    //一个应用可以使用多个上下文
    
    //GLKBaseEffect 的存在就是为了简化OpenGL ES的常用操作，同时也隐藏了多个OpenGL ES 版本之间的差异。
    _baseEffect = [[GLKBaseEffect alloc] init];
    _baseEffect.useConstantColor = GL_TRUE;
    _baseEffect.constantColor = GLKVector4Make(
                                                   1.0f, // Red
                                                   0.0f, // Green
                                                   0.0f, // Blue
                                                   1.0f);// Alpha//配置常量颜色  4分量向量
    
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f); //配置 background color
//    glClear(<#GLbitfield mask#>)//实现上面的配置
    
    
    
#pragma mark - 通用流程
    //vertexBufferID 保存了顶点数据的缓存的OpenGL ES的标识符
    glGenBuffers(1/*生成标识符的数量*/                                              // STEP 1为缓存生成一个独一无二的标识符
                 , &_vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER/*指定绑定的缓存类型*/                         // STEP 2为接下来的运算绑定缓存
                 , _vertexBufferID/*缓存标识符*/);
    /*
     第一个参数只支持以下俩种类型的缓存
     GL_ARRAY_BUFFER                        指定一个顶点属性的数组
     GL_ELEMENT_ARRAY_BUFFER
     **/
    
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//    
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//    
//    
//    //除了减小和放大过滤的选项、 当U、V的坐标值小于0或者大于1的时候，程序会指定要发生什么.
//    //有两个选择，（1）尽可能多重复纹理以填满映射到几何图形的整个U、V区域
//    //（2）每当片元的U、V坐标的值超出纹理的S、T坐标系的范围时，取样纹理边缘的纹素
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
//    
//    
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    
//    //复制应用的顶点数据到当前上下文所绑定的顶点缓存中
    glBufferData(                  // STEP 3  复制数据到缓存中
                 GL_ARRAY_BUFFER,  // Initialize buffer contents 指定要更新当前上下文绑定的哪一个缓存
                 sizeof(vertices), // Number of bytes to copy 指定要复制进这个缓存的字节的数量
                 vertices,         // Address of bytes to copy 要复制的字节的地址
                 GL_STATIC_DRAW);  // Hint: cache in GPU memory   提示缓存在未来的运算中可能会被怎么使用
    
    //    GL_STREAM_DRAW
    //    GL_STATIC_DRAW 缓存中的内容适合复制到GPU控制的内存，因为很少对其进行修改
    //    GL_DYNAMIC_DRAW 告诉上下文，缓存中的数据会频繁地改变，也提示OpneGL ES以不同的方式来处理缓存的存储
}

#pragma mark - delegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    //准备重绘
    [self.baseEffect prepareToDraw];
    
    //设置当前绑定的帧缓存的像素颜色渲染缓存中的每个像素的颜色为前面使用的glClearColor（）函数中设定的值
    glClear(GL_COLOR_BUFFER_BIT);//glClear（）函数会有效地设置帧缓存中的每一个像素的颜色为背景颜色
    
    //启动顶点缓存渲染操作
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    //顶点数据指针设置
    //告诉OpenGL ES顶点数据在哪里 以及解释每个顶点保存的数据
    glVertexAttribPointer(GLKVertexAttribPosition/*只是当前绑定的缓存包含每个顶点的位置信息*/
                          , sizeof(vertices) / sizeof(vertices[0])//每个顶点3个数据
                          , GL_FLOAT/*告诉OpenGL ES每个部分都保存为一个浮点类型的值*/
                          , GL_FALSE/*告诉OpenGL ES小数点固定数据是否可以改变*/
                          , sizeof(SceneVertex)/*步幅：指定了每个顶点的保存需要多少个字节*/
                          , NULL);/*告诉OpenGL ES 可以从当前绑定的顶点缓存的开始位置访问顶点数据
                                   当顶点缓存数据不存在即当前glBufferData不曾设置的时候便在此处设置顶点数据*/
    
    //执行绘图操作
    glDrawArrays(GL_TRIANGLES /*ES 怎么处理在绑定的顶点缓存内的顶点数据*/
                 , 0/*指定缓存内需要渲染的第一个顶点的位置*/
                 , 3);/*指定缓存内需要渲染的顶点的数量*/
    
    /*
     GL_TRIANGLES 指示OpenGL ES 取渲染三角形
     
     */
}


@end
