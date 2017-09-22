//
//  IViewController.m
//  WZLearnOpenGL
//
//  Created by admin on 15/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "IViewController.h"

@interface IViewController ()
{
    GLKView *glkView;
    
    GLuint frameBufferID;
    GLuint renderBufferID;
    GLuint textureBufferID;
    GLuint bufferID;
}

@end

GLfloat *vertices;


GLfloat vertices0[30] =
{
    0.5, -0.5, 0,     1, 0,
    -0.5, 0.5, 0,     0, 1,
    -0.5, -0.5, 0,    0, 0,
    0.5, 0.5, 0,      1, 1,
    -0.5, 0.5, 0,     0, 1,
    0.5, -0.5, 0,     1, 0,
};

GLfloat vertices1[30] =
{
    0.5, -0.5, 0,     0, 1,
    -0.5, 0.5, 0,     1, 0,
    -0.5, -0.5, 0,    1, 1,
    0.5, 0.5, 0,      0, 0,
    -0.5, 0.5, 0,     1, 0,
    0.5, -0.5, 0,     0, 1,
};
GLfloat vertices2[30] =
{
    0.5, -0.5, 0,     1, 1,
    -0.5, 0.5, 0,     0, 0,
    -0.5, -0.5, 0,    0, 1,
    0.5, 0.5, 0,      1, 0,
    -0.5, 0.5, 0,     0, 0,
    0.5, -0.5, 0,     1, 1,
};
GLfloat vertices3[30] =
{
    0.5, -0.5, 0,     0, 0,
    -0.5, 0.5, 0,     1, 1,
    -0.5, -0.5, 0,    1, 0,
    0.5, 0.5, 0,      0, 1,
    -0.5, 0.5, 0,     1, 1,
    0.5, -0.5, 0,     0, 0,
};

@implementation IViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createViews];
   
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (vertices == nil) {
        vertices = vertices0;
    }
    [self openGL];
}

- (void)createViews {
    for (int i = 0; i < 4; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 64.0 + i * 44 + i * 10, [UIScreen mainScreen].bounds.size.width, 44)];
        button.tag = i;
        [self.view addSubview:button];
        switch (i) {
            case 0:
                [button setTitle:@"正常" forState:UIControlStateNormal];
                break;
            case 1:
                [button setTitle:@"以正常为基准的颠倒" forState:UIControlStateNormal];
                break;
            case 2:
                [button setTitle:@"以正常为基准的垂直翻转" forState:UIControlStateNormal];
                break;
            case 3:
                [button setTitle:@"以正常为基准的水平翻转" forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[[UIColor yellowColor] colorWithAlphaComponent:0.35]];
        [button addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    
}

- (void)clickedBtn:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
             vertices = vertices0;
            break;
        case 1:
             vertices = vertices1;
            break;
        case 2:
             vertices = vertices2;
            break;
        case 3:
             vertices = vertices3;
            break;
        default:
            break;
    }
    [self.view setNeedsLayout];
}

//- (void)glkViewControllerUpdate:(GLKViewController *)controller {
//    [self openGL];
//}

- (void)openGL {
    glkView = (GLKView *)self.view;
//    self.delegate = (id<GLKViewControllerDelegate>)self;
    //设置放大倍数
    [self.view setContentScaleFactor:[UIScreen mainScreen].scale];
    
    // 设置描绘属性  不维持渲染内容以及颜色格式为 RGBA8
    ((CAEAGLLayer *)glkView.layer).drawableProperties = @{kEAGLDrawablePropertyRetainedBacking:[NSNumber numberWithBool:false]
                                                          ,kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8
                                                          };
    
    glkView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:glkView.context];
    
    if (glIsBuffer(frameBufferID)) {
        glDeleteFramebuffers(1, &frameBufferID);
        frameBufferID = 0;
    }
    if (glIsBuffer(renderBufferID)) {
        glDeleteRenderbuffers(1, &renderBufferID);
        renderBufferID = 0;
    }
    //如果不重复利用 初始化之前先删除是个好习惯
    
    
    glGenRenderbuffers(1, &renderBufferID);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBufferID);
    
    
    
    glGenFramebuffers(1, &frameBufferID);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBufferID);
    
    
    //颜色·渲染缓存需要装配到帧缓存中
    glFramebufferRenderbuffer(GL_FRAMEBUFFER
                              ,GL_COLOR_ATTACHMENT0//装配点
                              , GL_RENDERBUFFER
                              , renderBufferID);
    
    // 为 颜色缓冲区 分配存储空间
    [glkView.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)glkView.layer];
   

    //视图放大倍数
    CGFloat scale = [UIScreen mainScreen].scale;
    //设置视口
    glViewport(self.view.frame.origin.x * scale
               , self.view.frame.origin.y * scale
               , self.view.frame.size.width * scale
               , self.view.frame.size.height * scale);
    
    NSString *vertex = [[NSBundle mainBundle] pathForResource:@"shaderv1" ofType:@"vsh"];
    NSString *fragment = [[NSBundle mainBundle] pathForResource:@"shaderf1" ofType:@"fsh"];
    
    GLuint program = glCreateProgram();//着色器程序
    
    {
        GLuint vertexShader = 0;//写成全局的吧...
        GLuint fragmentShader = 0;
        
        if (!glIsShader(vertexShader)) {
            [[self class] complierShader:&vertexShader
                                    type:GL_VERTEX_SHADER
                            shaderString:[NSString stringWithContentsOfFile:vertex encoding:NSUTF8StringEncoding error:nil]];
        }
        if (!glIsShader(fragmentShader)) {
            [[self class] complierShader:&fragmentShader
                                    type:GL_FRAGMENT_SHADER
                            shaderString:[NSString stringWithContentsOfFile:fragment encoding:NSUTF8StringEncoding error:nil]];
        }
        glAttachShader(program, vertexShader);
        glAttachShader(program, fragmentShader);
        //不会马上释放  等到不需要的时候才会释放掉
        glDeleteShader(vertexShader);//如果着色器对象当前已经链接到了一个或者多个激活的着色器程序上，那么将会被标示为“可删除”，当对应的着色器不再使用的时候，会自动删除这个对象
        glDeleteShader(fragmentShader);

    }
    
    
    { // MARK: - 开始链接
        glLinkProgram(program);
        GLint linkStatus;
        glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
        
        if (linkStatus == GL_FALSE) {
            //链接失败
            GLint infoLogLength;
            glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLogLength);
            if (infoLogLength) {
                GLchar *infoLog = malloc(infoLogLength);
                glGetProgramInfoLog(program
                                    , infoLogLength
                                    , &infoLogLength
                                    , infoLog);
                printf("链接出错:%s", infoLog);
                free(infoLog);
            }
        } else {
            glUseProgram(program);//使用链接过的着色器程序
        }
    }
   
    ///显示的图像是相反的。需要更改y轴坐标
    
    glGenBuffers(1, &bufferID);//VBO 顶点缓存对象的创建  vertex buffer object  返回N个未使用的缓存对象名称 n小于0则产生GL_INVALID_VALUL错误  而0是系统保留的缓存对象名称
    glBindBuffer(GL_ARRAY_BUFFER, bufferID);
    //GL_ARRAY_BUFFER  将顶点数据保存在缓存中
    glBufferData(GL_ARRAY_BUFFER
                 , sizeof(vertices0)//
                 , vertices
                 , GL_DYNAMIC_DRAW);//GL_STATIC_DRAW 的区别
    
    //外部赋值给着色器
    GLuint position = glGetAttribLocation(program, "position"); ///着色器变量 着色器并不知道自己的数据从哪里来，只是每次运行时直接获取数据对应的输入变量 我们必须要自己完成着色线管的装配
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position
                          , 3
                          , GL_FLOAT
                          , GL_FALSE
                          , sizeof(GLfloat) * 5
                          , NULL);//将着色器变量关联到一个顶点属性数组
    
    
    GLuint textureCoord = glGetAttribLocation(program, "textCoordinate");//textureCoord 属于 [0, GL_MAX_VERTEX_ATTRIBS -1];
    glEnableVertexAttribArray(textureCoord);
    glVertexAttribPointer(textureCoord
                          , 2
                          , GL_FLOAT
                          , GL_FALSE
                          , sizeof(GLfloat) * 5
                          , (float *)NULL + 3);
    
    glActiveTexture(GL_TEXTURE0);
    glEnable(GL_TEXTURE_2D);
    //    ///纹理配置部分
    glDeleteTextures(1, &textureBufferID);
	textureBufferID = 0;
    glGenTextures(1, &textureBufferID);
    //绘图
    [self configTextureWithImage:@"beetle.png" textureBufferID:&textureBufferID];
    //    glFramebufferTexture2D(GL_FRAMEBUFFER
    //                               , GL_DEPTH_ATTACHMENT
    //                               , GL_TEXTURE_2D
    //                               , textureBufferID
    //                               , 0);
    ///获取rotateMatrix在uniform变量列表的索引
    GLuint rotateMatrix = glGetUniformLocation(program, "rotateMatrix");//uniform 传入旋转矩阵的值
    
    float radians = 10 * 3.14159 / 180.0;
    float s = sin(radians);
    float c = cos(radians);
    
    //z轴旋转矩阵
    GLfloat zRotation[16] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1.0, 0,
        0.0, 0, 0, 1.0
    };
  
//    GLfloat zRotation[16] = {
//        c, -s, 0, 0.2,
//        s, c, 0, 0,
//        0, 0, 1.0, 0,
//        0.0, 0, 0, 1.0
//    };
    //对rotateMatrix变量进行赋值
    glUniformMatrix4fv(rotateMatrix
                       , 1
                       , GL_FALSE//是否要转置
                       , (GLfloat *)&zRotation[0]);
    
    
    
    /* 有三种渲染缓存的类型
     # GL_DEPTH_BUFFER_BIT
     # GL_STENCIL_BUFFER_BIT
     # GL_COLOR_BUFFER_BIT
     */
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);//颜色值缓存
    //    glClearDepthf(GLclampf depth)
    //    glClear(GL_DEPTH_BUFFER_BIT);//深度缓存
    
    //    glClearStencil(GLint s)
    //    glClear(GL_STENCIL_BUFFER_BIT);//模板缓存
    
    glDrawArrays(GL_TRIANGLES
                 , 0
                 , 6);//绘制命令:请求渲染几何图元
    
    //    [glkView.context presentRenderbuffer:GL_FRAMEBUFFER];
    [glkView.context presentRenderbuffer:GL_RENDERBUFFER];
}


- (void)configTextureWithImage:(NSString *)imageName textureBufferID:(GLuint *)texBufferID{
    if (!imageName.length) {return;};
    
    CGImageRef imageRef = [UIImage imageNamed:imageName].CGImage;
    
    if(!imageRef) {
        return;
    };
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    /////做判断是否需要图片渲染小一点
    
    GLubyte *spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte))/*RGBA*/;
    //在CGContext上绘制图片
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    CGContextRef context = CGBitmapContextCreate(spriteData
                                                 , width
                                                 , height
                                                 , 8
                                                 , width * 4
                                                 , colorSpace, kCGImageAlphaPremultipliedLast);//RGBA!
    CGContextDrawImage(context
                       , CGRectMake(0.0, 0.0
                                    , width, height)
                       , imageRef);
 
    glBindTexture(GL_TEXTURE_2D, *texBufferID);
    //配置左右上下环绕采样模式
    glTexParameteri(GL_TEXTURE_2D
                    , GL_TEXTURE_MIN_FILTER
                    , GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D
                    , GL_TEXTURE_MAG_FILTER
                    , GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D
                    , GL_TEXTURE_WRAP_S
                    , GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D
                    , GL_TEXTURE_WRAP_T
                    , GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D
                 , 0
                 , GL_RGBA
                 , (GLsizei)width
                 , (GLsizei)height
                 , 0
                 , GL_RGBA
                 , GL_UNSIGNED_BYTE
                 , spriteData);
    
    free(spriteData);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
//    CGImageRelease(imageRef);
}



- (void)clean {
//    glShaderBinary(GLsizei n, const GLuint *shaders, GLenum binaryformat, const GLvoid *binary, GLsizei length)
//    GL_SHADER_BINARY_FORMATS
    
    ///各种删掉缓存
//    glDeleteProgram()
}


//仿写GPUImage 的一个编译判断
+ (BOOL)complierShader:(GLuint *)shader
                  type:(GLenum)type
          shaderString:(NSString *)shaderString {
    NSAssert(shaderString.length, @"着色器语言目标丢失");
    
    const GLchar *source = shaderString.UTF8String;
    if (!source) {return false;}//字符串
    
    *shader = glCreateShader(type);//顶点或者是片元的
    glShaderSource(*shader
                   , 1
                   , &source
                   , NULL);//如果length为NULL 则
    
    glCompileShader(*shader);//开始编译
    
    GLint complierStatus;
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &complierStatus);
    
    if (complierStatus != GL_TRUE) {
        GLint infoLogLength;
        glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &infoLogLength);
    
        if (infoLogLength) {
            GLchar *infoLog = malloc(infoLogLength);//分配
            glGetShaderInfoLog(*shader
                               , infoLogLength
                               , &infoLogLength
                               , infoLog);
            printf("编译报错 : %s", infoLog);
            free(infoLog);//释放
        }
    }
    
    return complierStatus == GL_TRUE;
}


- (void)dealloc {
    printf("%s", __func__);
}













@end
