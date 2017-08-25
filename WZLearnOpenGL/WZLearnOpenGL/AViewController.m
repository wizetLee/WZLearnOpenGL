//
//  AViewController.m
//  WZLearnOpenGL
//
//  Created by admin on 25/8/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "AViewController.h"

#import <GLKit/GLKit.h>

@interface AViewController ()

@property (nonatomic, strong) GLKView *glView;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;//隐藏OpenGL ES版本之间的差异
@property (nonatomic, assign) GLuint vertexBufferID;//顶点buffer ID

@end

@implementation AViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createViews];
}

- (void)createViews {
    _glView = [[GLKView alloc] init];
    _glView.frame = self.view.bounds;
    [self.view addSubview:_glView];
     //内建一个 EAGLContext 类的实例
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    _glView.context = context;
    [EAGLContext setCurrentContext:_glView.context];//在其他任何的OpenGL ES配置或者是渲染发生之前都要把GLKView实例中的上下文属性设置为当前。
    //一个应用可以使用多个上下文
    
    
    //GLKBaseEffect 的存在就是为了简化OpenGL ES的常用操作，同时也隐藏了多个OpenGL ES 版本之间的差异。
    _baseEffect = [[GLKBaseEffect alloc] init];
    _baseEffect.useConstantColor = GL_TRUE;
    _baseEffect.constantColor = GLKVector4Make(0.25, 0.35, 0.55, 1.0);//配置常量颜色  4分量向量
    
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f); //配置 background color
//    glClear(<#GLbitfield mask#>)//实现上面的配置
    
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
    
    
    
    
//    //复制应用的顶点数据到当前上下文所绑定的顶点缓存中
//    glBufferData(                  // STEP 3  复制数据到缓存中
//                 GL_ARRAY_BUFFER,  // Initialize buffer contents 指定要更新当前上下文绑定的哪一个缓存
//                 sizeof(vertices), // Number of bytes to copy 指定要复制进这个缓存的字节的数量
//                 vertices,         // Address of bytes to copy 要复制的字节的地址
//                 GL_STATIC_DRAW);  // Hint: cache in GPU memory   提示缓存在未来的运算中可能会被怎么使用
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
