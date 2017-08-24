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

GLuint LoadShader ( GLenum type, const char *shaderSrc )
{
    GLuint shader;
    GLint compiled;
    
    // Create the shader object
    shader = glCreateShader ( type );
    
    if ( shader == 0 )
    {
        return 0;
    }
    
    // Load the shader source
    glShaderSource ( shader, 1, &shaderSrc, NULL );
    
    // Compile the shader
    glCompileShader ( shader );
    
    // Check the compile status
    glGetShaderiv ( shader, GL_COMPILE_STATUS, &compiled );
    
    if ( !compiled )
    {
        GLint infoLen = 0;
        
        glGetShaderiv ( shader, GL_INFO_LOG_LENGTH, &infoLen );
        
        if ( infoLen > 1 )
        {
            char *infoLog = malloc ( sizeof ( char ) * infoLen );
            
            glGetShaderInfoLog ( shader, infoLen, NULL, infoLog );
            
            free ( infoLog );
        }
        
        glDeleteShader ( shader );
        return 0;
    }
    
    return shader;
    
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
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;//景深  模板缓冲区域
    [EAGLContext setCurrentContext:self.mContext];
    
    //长度  宽度  深度
    
    char vShaderStr[] =
    "#version 300 es                          \n"
    "layout(location = 0) in vec4 vPosition;  \n"
    "void main()                              \n"
    "{                                        \n"
    "   gl_Position = vPosition;              \n"
    "}                                        \n";
    
    char fShaderStr[] =
    "#version 300 es                              \n"
    "precision mediump float;                     \n"
    "out vec4 fragColor;                          \n"
    "void main()                                  \n"
    "{                                            \n"
    "   fragColor = vec4 ( 1.0, 0.0, 0.0, 1.0 );  \n"
    "}                                            \n";
    
    GLuint vertexShader;
    GLuint fragmentShader;
    vertexShader = LoadShader ( GL_VERTEX_SHADER, vShaderStr );
    fragmentShader = LoadShader ( GL_FRAGMENT_SHADER, fShaderStr );
    GLuint programObject = glCreateProgram();
//     GLuint vertexShader = 
//    glAttachShader(programObject, <#GLuint shader#>)

    glLinkProgram(programObject);
    
    // Load the vertex/fragment shaders
    vertexShader = LoadShader ( GL_VERTEX_SHADER, vShaderStr );
    fragmentShader = LoadShader ( GL_FRAGMENT_SHADER, fShaderStr );
    glCreateShader(GL_VERTEX_SHADER);//一个顶点着色器
    glCreateShader(GL_FRAGMENT_SHADER);//一个片段着色器
    glAttachShader ( programObject, vertexShader );
    glAttachShader ( programObject, fragmentShader );
    
    
    
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
    
//    glShaderSource(<#GLuint shader#>, <#GLsizei count#>, <#const GLchar *const *string#>, <#const GLint *length#>)//加载到着色器对象
//    glCompileShader(<#GLuint shader#>)//编译着色器
    
    
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
    

    [self aAnt];
    
}

//纹理贴图
- (void)uploadTexture {
    //纹理贴图
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"for_test" ofType:@"jpg"];
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];//GLKTextureLoaderOriginBottomLeft 纹理坐标系是相反的
    
    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];//纹理坐标系是相反的
    //着色器
    GLKBaseEffect *mEffect = [[GLKBaseEffect alloc] init];
    mEffect.texture2d0.enabled = GL_TRUE;
    mEffect.texture2d0.name = textureInfo.name;
}



- (GLuint)aAnt {
    /**
     编译着色器-》检查编译错误-》创建程序对象-》链接着色器-》链接程序并检查连接错误-》对象链接成功之后可使用程序对象进行渲染
     
     **/
    //创建程序对象和链接的简略过程：
    //(1)创建一个程序对象并且将vertex shader和fragment shader连接到对象上
    GLuint glProgramObject = glCreateProgram();
    if (glProgramObject == 0) {
        return 0;
    }
    
    GLuint vertexShader;
    GLuint fragmentShader;
    vertexShader = glCreateShader(GL_VERTEX_SHADER);//一个顶点着色器
    fragmentShader =  glCreateShader(GL_FRAGMENT_SHADER);//一个片段着色器
    
    glAttachShader(glProgramObject, vertexShader);//连接
    glAttachShader(glProgramObject, fragmentShader);//连接
    
    //(2)做好链接程序、检查错误的准备
    glLinkProgram(glProgramObject);//链接程序
    
    GLint linked;
    
    //检查链接状态
    glGetProgramiv(glProgramObject, GL_LINK_STATUS, &linked);
    
    if (!linked) {
        GLint infoLen = 0;
        glGetProgramiv(glProgramObject, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen > 1) {
            char *infoLog = malloc(sizeof(char) * infoLen);//获取错误 写成c字符串
            glGetProgramInfoLog(glProgramObject, infoLen, NULL, infoLog);
            //在这里可以输出这个错误
            
            free(infoLog);//释放
        }
        glDeleteProgram(glProgramObject);
        return false;
    }
    
    //把程序对象保存起来的操作
    
    //使用glUseProgram 绑定渲染对象进行渲染
    glUseProgram(glProgramObject);
    //用程序对象句柄调用glUseProgram之后，所有后续的渲染将会连接到程序对象的顶点着色器和片段着色器进行
    
    //视口由原点坐标（x，y）和宽度、高度所定义
    //通设置视口知OpenGL ES用于绘制的2D渲染表面的原点、宽度和高度
    GLsizei width;
    GLsizei height;
    glViewport(0, 0, width, height);
    
    //设置视口的下一步就是清除屏幕
    //绘图会设计多种缓冲区类型：颜色 深度和模板
    
    glClear(GL_COLOR_BUFFER_BIT);//在每帧开始，我们先去掉颜色缓存区
    
    glClearColor ( 1.0f, 1.0f, 1.0f, 0.0f );//缓冲区将被制定的颜色清除
    
    
    return glProgramObject;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
