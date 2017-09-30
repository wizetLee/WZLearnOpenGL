//
//  LViewController.m
//  WZLearnOpenGL
//
//  Created by admin on 30/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "LViewController.h"
#import "GLProgram.h"

@interface LViewController ()

@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, strong) CAEAGLLayer *layer;

@property (nonatomic, strong) GLProgram *program1;
//@property (nonatomic, strong) GLProgram *program2;

@property (nonatomic, assign) GLuint frameBufferHandle;
@property (nonatomic, assign) GLuint renderBufferHandle;


@property (nonatomic, assign) GLuint VBOHandle1;
//@property (nonatomic, assign) GLuint VBOHandle2;
@property (nonatomic, assign) GLuint textureHandle1;
//@property (nonatomic, assign) GLuint textureHandle2;


@end

@implementation LViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = false;
    
    [self createViews];

    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];
    
    [self viewPort];
    
    NSString *vertex = [[NSBundle mainBundle] pathForResource:@"LshaderNormal" ofType:@"vsh"];
    vertex = [NSString stringWithContentsOfFile:vertex encoding:NSUTF8StringEncoding error:nil];
    NSString *fragment = [[NSBundle mainBundle] pathForResource:@"LshaderNormal" ofType:@"fsh"];
    fragment = [NSString stringWithContentsOfFile:fragment encoding:NSUTF8StringEncoding error:nil];
    
    _program1 = [[GLProgram alloc] initWithVertexShaderString:vertex fragmentShaderString:fragment];
//    _program2 = [[GLProgram alloc] initWithVertexShaderString:vertex fragmentShaderString:fragment];//更换

    [_program1 addAttribute:@"position"];
    [_program1 addAttribute:@"textureCoordinate"];

//    [_program2 link];
    if (![_program1 link]) {
        NSLog(@"链接失败！！！！！！！！！！");
    }
    
    [_program1 use];
    
    [self destroyRenderBuffer:&_renderBufferHandle];
    [self destroyFrameBuffer:&_frameBufferHandle];
    
    [self setupRenderBuffer:&_renderBufferHandle];
    [self setupFrameBuffer:&_frameBufferHandle];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBufferHandle);
    
    
    _layer.opaque = true;
    _layer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking:[NSNumber numberWithBool:false]
                                  ,kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8
                                  };
    ///空间分配在设置之后
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_layer];
    
    
    GLfloat vertices[30] =
    {
        0.5, -0.5, 0,     1, 0,
        -0.5, 0.5, 0,     0, 1,
        -0.5, -0.5, 0,    0, 0,
        0.5, 0.5, 0,      1, 1,
        -0.5, 0.5, 0,     0, 1,
        0.5, -0.5, 0,     1, 0,
    };
   
    ///数据匹配
    glGenBuffers(1, &_VBOHandle1);
    glBindBuffer(GL_ARRAY_BUFFER, _VBOHandle1);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
//    glGenBuffers(1, &_VBOHandle2);
//    glBindBuffer(GL_ARRAY_BUFFER, _VBOHandle2);
//    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    
    [self render];
}



- (void)destroyFrameBuffer:(GLuint *)frameBufferHandle {
    glDeleteFramebuffers(1, frameBufferHandle);
    *frameBufferHandle = 0;
}
- (void)destroyRenderBuffer:(GLuint *)renderBufferHandle {
    glDeleteRenderbuffers(1, renderBufferHandle);
    *renderBufferHandle = 0;
}

- (void)setupFrameBuffer:(GLuint *)frameBufferHandle {
    glGenFramebuffers(1, frameBufferHandle);
    glBindFramebuffer(GL_FRAMEBUFFER, *frameBufferHandle);
}

- (void)setupRenderBuffer:(GLuint *)renderBufferHandle {
    glGenRenderbuffers(1, renderBufferHandle);
    glBindRenderbuffer(GL_RENDERBUFFER, *renderBufferHandle);
 
}

////设置完上下文 即可配置ViewPoint
- (void)viewPort {
    //视图放大倍数
    CGFloat scale = [UIScreen mainScreen].scale;
    //设置视口
    glViewport(self.view.frame.origin.x * scale
               , self.view.frame.origin.y * scale
               , self.view.frame.size.width * scale
               , self.view.frame.size.height * scale);
}

- (void)render {
    ///如果再次触发渲染的时候不清屏 就会有纹理残留
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
///1、切换着色器程序1
    [_program1 use];
///2、绑定数据
    glBindBuffer(GL_ARRAY_BUFFER, _VBOHandle1);
///3、顶点开启以及着色器属性重配置
    GLuint texture0 = [_program1 uniformIndex:@"texture0"];
    GLuint positionLocation = [_program1 attributeIndex:@"position"];
    GLuint textureCoordinateLoaction = [_program1 attributeIndex:@"textureCoordinate"];
    glEnableVertexAttribArray(positionLocation);
    glEnableVertexAttribArray(textureCoordinateLoaction);
    glVertexAttribPointer(positionLocation, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);//顶点部分
    glVertexAttribPointer(textureCoordinateLoaction, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);//顶点部分
    
    [self configTextureWithImage:@"beetle.png" textureBufferID:&_textureHandle1];
    glUniform1i(texture0, 0);///纹理第0层
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];//绘制命令:请求渲染几何图元
    
//    glClearColor(1, 1, 1, 1);
//    glClear(GL_COLOR_BUFFER_BIT);
//    ///着色器程序2
//    [_program2 use];
//    glBindRenderbuffer(GL_RENDERBUFFER, _renderBufferHandle2);
//    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle2);
}

- (void)createViews {
    _layer = [[CAEAGLLayer alloc] init];
    _layer.frame = UIScreen.mainScreen.bounds;
    _layer.backgroundColor = [UIColor greenColor].CGColor;
    
    [self.view.layer addSublayer:_layer];
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
    
    GLubyte *spriteData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte))/*RGBA*/;
    //在CGContext上绘制图片
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    CGContextRef context = CGBitmapContextCreate(spriteData
                                                 , width
                                                 , height
                                                 , 8
                                                 , width * 4
                                                 , colorSpace
                                                 , kCGImageAlphaPremultipliedLast);//RGBA!
    CGContextDrawImage(context
                       , CGRectMake(0.0, 0.0
                                    , width, height)
                       , imageRef);
    
    glActiveTexture(GL_TEXTURE0); // 类似于状态机，开启了TEXTURE1纹理   TextureUnit  GL_TEXTURE0默认激活，在使用其它纹理单元的时候需要手动激活。
    glEnable(GL_TEXTURE_2D);
    glGenTextures(1, &_textureHandle1);
    glBindTexture(GL_TEXTURE_2D, _textureHandle1);

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
    /**
     参数 target ：指定纹理单元的类型，二维纹理需要指定为GL_TEXTURE_2D
     参数 level：指定纹理单元的层次，非mipmap纹理level设置为0，mipmap纹理设置为纹理的层级
     参数 internalFormat：指定OpenGL ES是如何管理纹理单元中数据格式的
     参数 width：指定纹理单元的宽度
     参数 height：指定纹理单元的高度
     参数 border：指定纹理单元的边框，如果包含边框取值为1，不包含边框取值为0
     参数 format：指定data所指向的数据的格式
     参数 type：指定data所指向的数据的类型
     参数 data：实际指向的数据
     */
    free(spriteData);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    //    CGImageRelease(imageRef);
}
@end
