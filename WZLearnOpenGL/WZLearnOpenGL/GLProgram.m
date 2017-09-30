//  This is Jeff LaMarche's GLProgram OpenGL shader wrapper class from his OpenGL ES 2.0 book.
//  A description of this can be found at his page on the topic:
//  http://iphonedevelopment.blogspot.com/2010/11/opengl-es-20-for-ios-chapter-4.html


#import "GLProgram.h"
// START:typedefs
#pragma mark Function Pointer Definitions
typedef void (*GLInfoFunction)(GLuint program, GLenum pname, GLint* params);
typedef void (*GLLogFunction) (GLuint program, GLsizei bufsize, GLsizei* length, GLchar* infolog);
// END:typedefs
#pragma mark -
#pragma mark Private Extension Method Declaration
// START:extension
@interface GLProgram()

///用于编译且检查着色器编译情况
- (BOOL)compileShader:(GLuint *)shader 
                 type:(GLenum)type 
               string:(NSString *)shaderString;

@end
// END:extension
#pragma mark -

@implementation GLProgram
// START:init

@synthesize initialized = _initialized;

///读字符
- (id)initWithVertexShaderString:(NSString *)vShaderString 
            fragmentShaderString:(NSString *)fShaderString;
{
    if ((self = [super init])) 
    {
        _initialized = NO;
        
        attributes = [[NSMutableArray alloc] init];
        uniforms = [[NSMutableArray alloc] init];
        program = glCreateProgram();//创建shader程序
        
        //编译顶点着色器  （创建程序、编译GLSL且检查）
        if (![self compileShader:&vertShader 
                            type:GL_VERTEX_SHADER 
                          string:vShaderString])
        {
            NSLog(@"Failed to compile vertex shader");
        }
        
        // Create and compile fragment shader
        //编译片元着色器
        if (![self compileShader:&fragShader 
                            type:GL_FRAGMENT_SHADER 
                          string:fShaderString])
        {
            NSLog(@"Failed to compile fragment shader");
        }
        
        //程序与着色器之间的关联
        glAttachShader(program, vertShader);
        glAttachShader(program, fragShader);
    }
    
    return self;
}
///读文件 依据于读字符
- (id)initWithVertexShaderString:(NSString *)vShaderString 
          fragmentShaderFilename:(NSString *)fShaderFilename;
{
    NSString *fragShaderPathname = [[NSBundle mainBundle] pathForResource:fShaderFilename ofType:@"fsh"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:fragShaderPathname encoding:NSUTF8StringEncoding error:nil];
    
    if ((self = [self initWithVertexShaderString:vShaderString fragmentShaderString:fragmentShaderString])) 
    {
    }
    
    return self;
}
///读文件 依据于读字符
- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename 
            fragmentShaderFilename:(NSString *)fShaderFilename;
{
    NSString *vertShaderPathname = [[NSBundle mainBundle] pathForResource:vShaderFilename ofType:@"vsh"];
    NSString *vertexShaderString = [NSString stringWithContentsOfFile:vertShaderPathname encoding:NSUTF8StringEncoding error:nil];

    NSString *fragShaderPathname = [[NSBundle mainBundle] pathForResource:fShaderFilename ofType:@"fsh"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:fragShaderPathname encoding:NSUTF8StringEncoding error:nil];
    
    if ((self = [self initWithVertexShaderString:vertexShaderString fragmentShaderString:fragmentShaderString])) 
    {
    }
    
    return self;
}

// END:init
// START:compile

///用于编译且检查着色器编译情况
- (BOOL)compileShader:(GLuint *)shader 
                 type:(GLenum)type 
               string:(NSString *)shaderString
{
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();//当前绝对时间

    GLint status;
    const GLchar *source;
    
    source = 
      (GLchar *)[shaderString UTF8String];//OC字符转为C字符数组 表示  着色器源代码数据
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);//创建着色器对象并且获取其句柄（*shader）
    glShaderSource(*shader, 1, &source, NULL);//将着色器代码数据关联到一个着色器对象（*shader）上
    glCompileShader(*shader);//编译着色器的源代码
    
    //iv 表示 int vertices  整型顶点数据
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);//查看着色器对象的编译的状态情况

	if (status != GL_TRUE) //如果编译失败的情况
	{
		GLint logLength;
		glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);//获取错误日志的大小
		if (logLength > 0)
		{
			GLchar *log = (GLchar *)malloc(logLength);//分配字符数组空间
			glGetShaderInfoLog(*shader, logLength, &logLength, log);//如果便以失败的化、可以调取编译日志去判断编译错误的原因   该函数会返回一个与具体相关实现的具体，用于描述编译时的错误
            
            if (shader == &vertShader)//类型区分
            {
                self.vertexShaderLog = [NSString stringWithFormat:@"%s", log];
            }
            else
            {
                self.fragmentShaderLog = [NSString stringWithFormat:@"%s", log];
            }

			free(log);//释放字符数组的空间
		}
	}	
	
    CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);//编译时长的计算
    NSLog(@"Compiled in %f ms", linkTime * 1000.0);

    return status == GL_TRUE;
}
// END:compile


#pragma mark -


// START:addattribute
///根据属性角标绑定顶点属性
- (void)addAttribute:(NSString *)attributeName
{
    if (![attributes containsObject:attributeName])
    {
        [attributes addObject:attributeName];
        //绑定属性到着色器程序中
        glBindAttribLocation(program, 
                             (GLuint)[attributes indexOfObject:attributeName],//属性的角标
                             [attributeName UTF8String]);//属性的名字 c字符数组
    }
}
// END:addattribute


// START:indexmethods
///获取某个attribute属性的角标 -- 数组中获取
- (GLuint)attributeIndex:(NSString *)attributeName
{
    //    glGetAttribLocation(program, [attributeName UTF8String]);//为什么不用这个直接用indexOf😯
    return (GLuint)[attributes indexOfObject:attributeName];
}

///获取某个uniform属性的角标
- (GLuint)uniformIndex:(NSString *)uniformName
{
    return glGetUniformLocation(program, [uniformName UTF8String]);
}
// END:indexmethods



#pragma mark -
// START:link
///链接并且返回结果
- (BOOL)link
{
//    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();

    GLint status;
    
    glLinkProgram(program);//链接到着色器程序  处理所有与program相关联的着色器来生成一个完整的着色器程序
    
    glGetProgramiv(program, GL_LINK_STATUS, &status);//检查链接的状态
    if (status == GL_FALSE) {
        return NO;
    }
    
    if (vertShader)
    {
        glDeleteShader(vertShader);//链接的时候删除顶点着色器的句柄
        vertShader = 0;
    }
    if (fragShader)
    {
        glDeleteShader(fragShader);//链接的时候删除片元着色器的句柄
        fragShader = 0;
    }
    
    self.initialized = YES;///初始化成功

//    CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
//    NSLog(@"Linked in %f ms", linkTime * 1000.0);

    return YES;
}
// END:link


// START:use
- (void)use
{
    glUseProgram(program);
}

// END:use



#pragma mark -

- (void)validate;
{
	GLint logLength;
	
	glValidateProgram(program);//检测program中包含的执行段在给定的当前OpenGL状态下是否可执行
	glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0)
	{
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(program, logLength, &logLength, log);
        self.programLog = [NSString stringWithFormat:@"%s", log];
		free(log);
	}	
}

#pragma mark -
// START:dealloc
- (void)dealloc
{
    if (vertShader)
        glDeleteShader(vertShader);
        
    if (fragShader)
        glDeleteShader(fragShader);
    
    if (program)
        glDeleteProgram(program);
       
}
// END:dealloc
@end
