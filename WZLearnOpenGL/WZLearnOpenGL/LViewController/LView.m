//
//  LView.m
//  WZLearnOpenGL
//
//  Created by admin on 30/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "LView.h"

#define UsePerspective 1

@interface LView()

{
    CGFloat radians;
}

@property (nonatomic, strong) NSTimer *timer;

@end



@implementation LView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)dealloc {
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [_timer invalidate];
}

- (void)stop {
    [_timer invalidate];
    _timer = nil;
}

///一个轮询 对于变量的更新
- (void)poll {
  
    radians += 0.1;
    [self update];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (CGFloat)canvasScale {
    return 0.5;
}

- (void)createViews {
    [self setupLayer];
    [self setupContext];
    [self viewPort];
    
    [self setupProgram0];
    [self update];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(poll) userInfo:nil repeats:true];
}

- (void)setupLayer {
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    self.eaglLayer.opaque = true;
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    self.eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:false], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}
- (void)setupContext {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];
}

- (void)setupProgram0 {
    
    NSArray *attributeStrs = @[@"position", @"textureCoordinate"];
     _program0 = [[GLProgram alloc] initWithVertexShaderFilename:@"shaderLPerspectiveV" fragmentShaderFilename:@"shaderLPerspectiveF"];
    [self setupProgram:_program0 attributeArray:attributeStrs];
    
    [_program0 use];
    
    
    ///保持于图片的一致性
    CGFloat scale = [self canvasScale] ;///大小标量
    GLfloat attrArr[] =
    {
        1.0 * scale, 1.0 * scale, 0,     1.0, 0.0,
        1.0 * scale, -1.0 * scale, 0,     1.0, 1.0,
        -1.0 * scale, -1.0 * scale, 0,    0.0, 1.0,
        -1.0 * scale, -1.0 * scale, 0,    0.0, 1.0,
        -1.0 * scale, 1.0 * scale, 0,     0.0, 0.0,
        1.0 * scale, 1.0 * scale, 0,     1.0, 0.0,
    };
    
    
    //数据配置
    glGenBuffers(1, &_buffer0);
    glBindBuffer(GL_ARRAY_BUFFER, _buffer0);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_STATIC_DRAW);
    
//    glVertexAttribPointer([_program0 attributeIndex:@"position"], 3, GL_FLOAT, GL_FALSE, 5, NULL);
//    glVertexAttribPointer([_program0 attributeIndex:@"textureCoordinate"], 2, GL_FLOAT, GL_FALSE, 5, NULL + 3);
//
//    ///数据配置之后启用顶点
//    [self enableAttribute:_program0 attributeArray:attributeStrs];
    
    //配置图像
    setupTexture(@"leaves.gif", &_texture0, GL_TEXTURE0);//配置值
    glUniform1i([_program0 uniformIndex:@"texture"], 0);//赋值
}

- (void)update {
    [self destroyFrameBuffer:&_colorFrameBuffer];
    [self destroyRenderBuffer:&_colorRenderBuffer];
    [self setupFrameBuffer:&_colorFrameBuffer];
    [self setupRenderBuffer:&_colorRenderBuffer];
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eaglLayer];
    //集成到帧缓存中
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
    
    [self render];
    
    ///最后准备渲染
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)render {
    //通常在一帧渲染完成之后 最常见的图形操作就是清除缓存 每帧都需要清除一次缓存
    glClearColor(1.0, 1.0, 1.0  , 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
   //可配置多个program
   [_program0 use];
    glBindBuffer(GL_ARRAY_BUFFER, _buffer0);
    //不进行归一化处理 即转换为归一化的浮点数(0~1)
    glVertexAttribPointer([_program0 attributeIndex:@"position"], 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
    glVertexAttribPointer([_program0 attributeIndex:@"textureCoordinate"], 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);
    [self enableAttribute:_program0 attributeArray:@[@"position", @"textureCoordinate"]];
    
    ////配合旋转的弧度
   
    GLKMatrix4 rotateMatrix = GLKMatrix4MakeRotation(radians, 0, 1, 0); //围绕着Y旋转
    if (1) {
      
        /*
         fovyRadians 视角 传入幅度   视角（fovyRadians）越大，看到的东西就越多  相当于焦距 10 很小相当于长焦,100 就大了
         aspect 屏幕宽高比
         earZ表示可视范围在Z轴的起点到原点(0,0,0)的距离，farZ表示可视范围在Z轴的终点到原点(0,0,0)的距离,nearZ和farZ始终为正。near和far共同决定了可视深度
         **/
        GLKMatrix4 translateMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0, 0.0, -1.5);
//        GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(0, 0, -1.5);///z坐标的一个移动
        GLKMatrix4 target = GLKMatrix4Multiply(translateMatrix, rotateMatrix);///矩阵相乘
        
        
        // 透视投影
        float aspect = self.frame.size.width / self.frame.size.height;
        aspect = [UIScreen mainScreen].bounds.size.width/[UIScreen mainScreen].bounds.size.height;
        ///透视投影变换                                             ///将角度转换成弧度
        GLKMatrix4 perspectiveMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(100), aspect, 0.1, 100.0);
        target = GLKMatrix4Multiply(perspectiveMatrix , target);///矩阵相乘
        
        glUniformMatrix4fv([_program0 uniformIndex:@"transform"], 1, GL_FALSE, target.m);
        
    } else {
        // 正交投影
        float viewWidth = self.frame.size.width;
        float viewHeight = self.frame.size.height;
        GLKMatrix4 orthMatrix = GLKMatrix4MakeOrtho(-viewWidth/2, viewWidth/2, -viewHeight / 2, viewHeight/2, -10, 10);
        GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(200, 200, 200);
        GLKMatrix4 last = GLKMatrix4Multiply(scaleMatrix, rotateMatrix);
    }
    
    
    ///放在属性配置的最后
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

#pragma mark - Public Method
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
    
    if ([attributeArray count]) {
        for (NSString *attributeName in attributeArray) {
            [program addAttribute:attributeName];
        }
    }///为什么必须要排列在下面代码上面。。。。有待查证
    
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
}

///启用数组内的顶点属性
- (void)enableAttribute:(GLProgram *)program attributeArray:(NSArray <NSString *>*)attributeArray {
    if ([attributeArray count]) {
        for (NSString *attributeName in attributeArray) {
            glEnableVertexAttribArray([program attributeIndex:attributeName]);
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
