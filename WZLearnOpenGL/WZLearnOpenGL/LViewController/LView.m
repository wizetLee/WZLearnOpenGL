//
//  LView.m
//  WZLearnOpenGL
//
//  Created by admin on 30/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "LView.h"


@interface LView()



@end

@implementation LView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createViews];
    }
    return self;
}

- (CGFloat)canvasScale {
    return 1.0;
}

- (void)createViews {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];

    self.eaglLayer.opaque = true;
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    self.eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:false], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    [self viewPort];
    
    NSArray *attributeStrs = @[@"position", @"textureCoordinate"];
    [self setupProgram:_program0 attributeArray:attributeStrs];
    
    ///保持于图片的一致性
    CGFloat scale = [self canvasScale] ;///大小标量
    GLfloat attrArr[] =
    {
        1.0 * scale, 1.0 * scale, -1.0,     1.0, 0.0,
        1.0 * scale, -1.0 * scale, -1.0,     1.0, 1.0,
        -1.0 * scale, -1.0 * scale, -1.0,    0.0, 1.0,
        -1.0 * scale, -1.0 * scale, -1.0,    0.0, 1.0,
        -1.0 * scale, 1.0 * scale, -1.0,     0.0, 0.0,
        1.0 * scale, 1.0 * scale, -1.0,     1.0, 0.0,
    };
    
    //数据配置
    glGenBuffers(1, &_buffer0);
    glBindBuffer(GL_ARRAY_BUFFER, _buffer0);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_STATIC_DRAW);
    
    glVertexAttribPointer([_program0 attributeIndex:@"position"], 3, GL_FLOAT, GL_FALSE, 5, NULL);
    glVertexAttribPointer([_program0 attributeIndex:@"textureCoordinate"], 2, GL_FLOAT, GL_FALSE, 5, NULL + 3);
    
    ///数据配置之后启用顶点
    [self enableAttribute:_program0 attributeArray:attributeStrs];
  
    
    [self destroyFrameBuffer:&_colorFrameBuffer];
    [self destroyRenderBuffer:&_colorRenderBuffer];
    [self setupFrameBuffer:&_colorFrameBuffer];
    [self setupRenderBuffer:&_colorRenderBuffer];
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eaglLayer];
    //集成到帧缓存中
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
    
    //配置图像
    
    setupTexture(@"imageName", &_texture0, GL_TEXTURE0);//配置值
    
    glUniform1i([_program0 uniformIndex:@"texture"], 0);//赋值
    
}


void setupTexture(NSString *fileName, GLuint *textures, GLenum texture) {
    // 1获取图片的CGImageRef
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
 
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    // 2 读取图片的大小
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte *spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte)); //rgba共4个byte
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 3在CGContextRef上绘图
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    if (texture == 0) {
        glActiveTexture(GL_TEXTURE0);
    } else {
        glActiveTexture(texture);
    }
    
    glEnable(GL_TEXTURE_2D);
    
    glGenTextures(1, textures);
    glBindTexture(GL_TEXTURE_2D, *textures);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
                                   //该格式决定颜色和深度的存储值
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    
    free(spriteData);
}

- (void)setupProgram:(GLProgram *)program attributeArray:(NSArray <NSString *>*)attributeArray {
    program = [[GLProgram alloc] initWithVertexShaderFilename:@"" fragmentShaderFilename:@""];
    
    if (!program.initialized)
    {
        if (![program link]) {
            NSString *progLog = [program programLog];
            NSLog(@"Program link log: %@", progLog);
            NSString *fragLog = [program fragmentShaderLog];
            NSLog(@"Fragment shader compile log: %@", fragLog);
            NSString *vertLog = [program vertexShaderLog];
            NSLog(@"Vertex shader compile log: %@", vertLog);
            program = nil;
            NSAssert(NO, @"Filter shader link failed");
        }
    }
    
    if ([attributeArray count]) {
        for (NSString *attributeName in attributeArray) {
            [program addAttribute:attributeName];
        }
    }
}

///启用数组内的顶点属性
- (void)enableAttribute:(GLProgram *)program attributeArray:(NSArray <NSString *>*)attributeArray {
    if ([attributeArray count]) {
        for (NSString *attributeName in attributeArray) {
            glEnableVertexAttribArray([program uniformIndex:attributeName]);
        }
    }
}


- (NSString *)shaderStrWithResource:(NSString *)resource type:(NSString *)type {
    NSAssert([resource isKindOfClass:[NSString class]], @"OMG");
    NSAssert([type isKindOfClass:[NSString class]], @"OMG");
    NSString *shader = [[NSBundle mainBundle] pathForResource:resource ofType:type];
    shader = [NSString stringWithContentsOfFile:shader encoding:NSUTF8StringEncoding error:nil];
    return shader;
}


- (void)viewPort {
    //视图放大倍数
    CGFloat scale = [UIScreen mainScreen].scale;
    //设置视口
    glViewport(0.0
               , 0.0
               , self.frame.size.width * scale
               , self.frame.size.height * scale);
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

#pragma mark - Accessor

- (CAEAGLLayer *)eaglLayer {
    return (CAEAGLLayer *)self.layer;
}

@end
