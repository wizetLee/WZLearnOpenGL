//  This is Jeff LaMarche's GLProgram OpenGL shader wrapper class from his OpenGL ES 2.0 book.
//  A description of this can be found at his page on the topic:
//  http://iphonedevelopment.blogspot.com/2010/11/opengl-es-20-for-ios-chapter-4.html
//  I've extended this to be able to take programs as NSStrings in addition to files, for baked-in shaders

#import <Foundation/Foundation.h>

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#else
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#endif

@interface GLProgram : NSObject 
{
    NSMutableArray  *attributes;
    NSMutableArray  *uniforms;
    GLuint          program, vertShader, fragShader;	
}


@property(readwrite, nonatomic) BOOL initialized;//是否已被初始化  链接之后的结果
@property(readwrite, copy, nonatomic) NSString *vertexShaderLog;
@property(readwrite, copy, nonatomic) NSString *fragmentShaderLog;
@property(readwrite, copy, nonatomic) NSString *programLog;

#pragma mark - 依据顶点着色器和片元着色器程序字符数组进行初始化本对象实例
- (id)initWithVertexShaderString:(NSString *)vShaderString 
            fragmentShaderString:(NSString *)fShaderString;
- (id)initWithVertexShaderString:(NSString *)vShaderString 
          fragmentShaderFilename:(NSString *)fShaderFilename;
- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename 
            fragmentShaderFilename:(NSString *)fShaderFilename;

///
- (void)addAttribute:(NSString *)attributeName;
- (GLuint)attributeIndex:(NSString *)attributeName;
- (GLuint)uniformIndex:(NSString *)uniformName;
///检查链接情况 清空着色器句柄 
- (BOOL)link;
//使用连接过的着色器程序program  须知：在使用前要绑定着色器,如果不绑定任何着色器，OpenGL的操作为未定义，不会报错  解除关联或者关联新的着色器，需要重新链接着色器程序没如果链接失败就会继续使用当前绑定的着色器，知道成功链接或者glUsePrigram指定了新的程序位置
///glUseProgram
- (void)use;
///检验program中包含的执行段在给定的当前OpenGL状态下是否可执行。
- (void)validate;
@end
