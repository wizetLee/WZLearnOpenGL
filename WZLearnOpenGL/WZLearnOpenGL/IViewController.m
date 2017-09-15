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
}
@end

@implementation IViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    glkView = (GLKView *)self.view;
    //设置放大倍数
    [self.view setContentScaleFactor:[UIScreen mainScreen].scale];
    
    // 设置描绘属性  不维持渲染内容以及颜色格式为 RGBA8
    ((CAEAGLLayer *)glkView.layer).drawableProperties = @{kEAGLDrawablePropertyRetainedBacking : @(false),kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8
          };
    
    glkView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:glkView.context];
    
    glDeleteFramebuffers(1, &frameBufferID);
    glDeleteRenderbuffers(1, &renderBufferID);
    //如果不重复利用 初始化之前先删除是个好习惯
    glGenFramebuffers(1, &frameBufferID);
    glGenRenderbuffers(1, &renderBufferID);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBufferID);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBufferID);
    
    // 为 颜色缓冲区 分配存储空间
    [glkView.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)glkView.layer];
    
    //颜色·渲染缓存需要装配到帧缓存中
    glFramebufferRenderbuffer(GL_FRAMEBUFFER
                              ,GL_COLOR_ATTACHMENT0//装配点 
                              , GL_RENDERBUFFER
                              , renderBufferID);
    /* 有三种渲染缓存的类型
     # GL_DEPTH_BUFFER_BIT
     # GL_STENCIL_BUFFER_BIT
     # GL_COLOR_BUFFER_BIT
     */
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    //视图放大倍数
    CGFloat scale = [UIScreen mainScreen].scale;
    //设置视口大小
    glViewport(self.view.frame.origin.x * scale
               , self.view.frame.origin.y * scale
               , self.view.frame.size.width * scale
               , self.view.frame.size.height * scale);
    
    NSString *vertex = [[NSBundle mainBundle] pathForResource:@"shaderv1" ofType:@"vsh"];
    NSString *fragment = [[NSBundle mainBundle] pathForResource:@"shaderf1" ofType:@"fsh"];
    
    GLuint program = glCreateProgram();//着色器程序
    
    {
        GLuint vertexShader;
        GLuint fragmentShader;
        
        [[self class] complierShader:&vertexShader
                                type:GL_VERTEX_SHADER
                        shaderString:[NSString stringWithContentsOfFile:vertex encoding:NSUTF8StringEncoding error:nil]];
        [[self class] complierShader:&fragmentShader
                                type:GL_FRAGMENT_SHADER
                        shaderString:[NSString stringWithContentsOfFile:fragment encoding:NSUTF8StringEncoding error:nil]];
        glAttachShader(program, vertexShader);
        glAttachShader(program, fragmentShader);
        //不会马上释放  等到不需要的时候才会释放掉
        glDeleteShader(vertexShader);
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
            glUseProgram(program);
        }
    }
    
    GLfloat vertices[] =
    {
        0.5, -0.5, 0,     1, 0,
        -0.5, 0.5, 0,     0, 1,
        -0.5, -0.5, 0,    0, 0,
        0.5, 0.5, 0,      1, 1,
        -0.5, 0.5, 0,     0, 1,
        0.5, -0.5, 0,     1, 0,
    };
    
    GLuint bufferID;
    glGenBuffers(1, &bufferID);
    glBindBuffer(GL_ARRAY_BUFFER, bufferID);
    glBufferData(GL_ARRAY_BUFFER
                 , sizeof(vertices)
                 , vertices
                 , GL_DYNAMIC_DRAW);//GL_STATIC_DRAW 的区别
    
    //外部赋值给着色器
    GLuint position = glGetAttribLocation(program, "position");
    
    glVertexAttribPointer(position
                          , 3
                          , GL_FLOAT
                          , GL_FALSE
                          , sizeof(GLfloat) * 5
                          , NULL);
    glEnableVertexAttribArray(position);
    GLuint textureColor = glGetAttribLocation(program
                                              , "textCoordinate");
   
    glVertexAttribPointer(textureColor
                          , 2
                          , GL_FLOAT
                          , GL_FALSE
                          , sizeof(GLfloat) * 5
                          , (float *)NULL + 3);
     glEnableVertexAttribArray(textureColor);
//    ///纹理配置部分
    glDeleteTextures(1, &textureBufferID);
    textureBufferID = 0;
    glGenTextures(1, &textureBufferID);
    //绘图

    [self configTextureWithImage:@"beetle" textureBufferID:&textureBufferID];
    glFramebufferTexture2D(GL_FRAMEBUFFER
                               , GL_COLOR_ATTACHMENT0
                               , GL_TEXTURE_2D
                               , textureBufferID
                               , 0);
    
    GLuint cotateMatrix = glGetUniformLocation(program, "rotateMatrix");//uniform 传入旋转矩阵的值

    float radians = 10 * M_PI/ 180.0;
    float s = sin(radians);
    float c = cos(radians);

    //z轴旋转矩阵
    GLfloat zRotation[16] = {
        c, -s, 0, 0,
        s, c, 0, 0,
        0, 0, 1.0, 0,
        0.0, 0, 0, 1.0
    };
    glUniformMatrix4fv(cotateMatrix
                       , 1
                       , GL_FALSE//是否要转置
                       , (GLfloat *)&zRotation[0]);
    
    glDrawArrays(GL_TRIANGLES
                 , 0
                 , 6);
    [glkView.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)viewDidLayoutSubviews {
  
}

- (void)configTextureWithImage:(NSString *)imageName textureBufferID:(GLuint *)textureBufferID{
    if (!imageName.length) {return;};
    
    CGImageRef imageRef = [UIImage imageNamed:imageName].CGImage;
    
    if(!imageRef) {
        NSLog(@"111");
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
 
    glBindTexture(GL_TEXTURE_2D, *textureBufferID);
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
    CGImageRelease(imageRef);
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
                   , NULL);
    
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
