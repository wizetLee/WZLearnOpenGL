//
//  NView.m
//  WZLearnOpenGL
//
//  Created by admin on 18/10/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "NView.h"

#import "GLProgram.h"
#import <GLKit/GLKit.h>
#include <math.h>

typedef NS_ENUM(NSUInteger, VertorOriention) {
    VertorOriention_None,
    VertorOriention_Left,
    VertorOriention_Right,
};

@interface NView()<UIGestureRecognizerDelegate>
{

}

@property (nonatomic, assign) VertorOriention touchPointOriention;

@property (nonatomic, strong) CAEAGLLayer *eaglLayer;
@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, assign) GLuint colorRenderBuffer;
@property (nonatomic, assign) GLuint colorFrameBuffer;

///p0
@property (nonatomic, assign) GLuint texture0;
@property (nonatomic, assign) GLuint buffer0;
@property (nonatomic, strong) GLProgram *program0;
@property (nonatomic, assign) GLuint index0;
@property (nonatomic, assign) float * arrBuffer;
@property (nonatomic, assign) int * indices;
@end

@implementation NView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    //
    self = [super initWithFrame:frame];
    ///画布尺寸。。。
    
#warning 保持画布和需要绘制的图片的宽高 比例保持一致
    
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews {
    [self setupLayer];
    [self setupContext];
    
    [self viewPort];
    
    [self setupProgram0];
    
    [self update];
    
    
    [self gestures];
}

- (void)gestures {
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotation:)];
    [self addGestureRecognizer:rotation];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [self addGestureRecognizer:pinch];
    rotation.delegate = self;
    pinch.delegate = self;
    pan.delegate = self;
}





- (void)pinch:(UIPinchGestureRecognizer *)pinch {
 
}


- (void)pan:(UIPanGestureRecognizer *)pan {
   
}

// MARK: - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return true;
}



- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    
    _eaglLayer.opaque = true;
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:false], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

////设置完上下文 即可配置ViewPoint
- (void)viewPort {
    CGFloat scale = [UIScreen mainScreen].scale;
    //设置视口
    glViewport(0.0
               , 0.0
               , self.frame.size.width * scale
               , self.frame.size.height * scale);
    
    ///视点决定描绘的位置以及尺寸
    //    glViewport(self.frame.origin.x * scale
    //               , self.frame.origin.y * scale
    //               , self.frame.size.width * scale
    //               , self.frame.size.height * scale);
    
}

- (NSString *)shaderStrWithResource:(NSString *)resource type:(NSString *)type {
    NSAssert([resource isKindOfClass:[NSString class]], @"OMG");
    NSAssert([type isKindOfClass:[NSString class]], @"OMG");
    NSString *shader = [[NSBundle mainBundle] pathForResource:resource ofType:type];
    shader = [NSString stringWithContentsOfFile:shader encoding:NSUTF8StringEncoding error:nil];
    return shader;
}

- (void)setupProgram0 {
    //读取文件路径
    NSString *vsh = [[NSBundle mainBundle] pathForResource:@"shaderDefaultV" ofType:@"vsh"];
    NSString *fsh = [[NSBundle mainBundle] pathForResource:@"shaderDefaultF" ofType:@"fsh"];
    
    //加载shader
    _program0 = [[GLProgram alloc] initWithVertexShaderString:[NSString stringWithContentsOfFile:vsh encoding:NSUTF8StringEncoding error:nil] fragmentShaderString:[NSString stringWithContentsOfFile:fsh encoding:NSUTF8StringEncoding error:nil]];
    
    if (!_program0.initialized) {
        [_program0 addAttribute:@"position"];
        [_program0 addAttribute:@"textureCoordinate"];
        //接入缓存
        if (![_program0 link]) {
            NSString *progLog = [_program0 programLog];
            NSLog(@"Program link log: %@", progLog);
            NSString *fragLog = [_program0 fragmentShaderLog];
            NSLog(@"Fragment shader compile log: %@", fragLog);
            NSString *vertLog = [_program0 vertexShaderLog];
            NSLog(@"Vertex shader compile log: %@", vertLog);
            _program0 = nil;
            NSAssert(false, @"Filter shader link failed");
        }
    }
    
    
    //取出
    GLuint texture0Uniform = [_program0 uniformIndex:@"texture"];
    GLuint displayPositionAttribute = [_program0 attributeIndex:@"position"];
    GLuint displayTextureCoordinateAttribute = [_program0 attributeIndex:@"textureCoordinate"];
    
    [_program0 use];
    glEnableVertexAttribArray(displayPositionAttribute);
    glEnableVertexAttribArray(displayTextureCoordinateAttribute);
    
    CGFloat scale = 0.5;
    GLfloat attrArr[] =
    {
        1.0 * scale, 1.0 * scale, -1.0,     1.0, 0.0,
        1.0 * scale, -1.0 * scale, -1.0,     1.0, 1.0,
        -1.0 * scale, -1.0 * scale, -1.0,    0.0, 1.0,
        -1.0 * scale, -1.0 * scale, -1.0,      0.0, 1.0,
        -1.0 * scale, 1.0 * scale, -1.0,     0.0, 0.0,
        1.0 * scale, 1.0 * scale, -1.0,     1.0, 0.0,
    };///矫正图片后的矩阵
    
    
    
    
    
    
    
    
    
    glGenBuffers(1, &_buffer0);
    glBindBuffer(GL_ARRAY_BUFFER, _buffer0);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
#warning 尝试使用点的复用
    //顶点索引
    GLuint tmpIndices[] =
    {
        0, 3, 2,
        0, 1, 3,
        //可以去掉注释
        //        0, 2, 4,
        //        0, 4, 1,
        //        2, 3, 4,
        //        1, 4, 3,
    };
    ///
    glGenBuffers(1, &_index0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _index0);//绑定
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(tmpIndices), tmpIndices, GL_STATIC_DRAW);
    
    glVertexAttribPointer(displayPositionAttribute, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
    glEnableVertexAttribArray(displayPositionAttribute);
    
    glVertexAttribPointer(displayTextureCoordinateAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);
    glEnableVertexAttribArray(displayTextureCoordinateAttribute);
    
    //加载纹理
    [self setupTexture:@"leaves.gif" textures:&_texture0 textureUnit:GL_TEXTURE0];
    glUniform1i(texture0Uniform, 0);
}



- (void)render {
    
    //通常在一帧渲染完成之后 最常见的图形操作就是清除缓存 每帧都需要清除一次缓存
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    //缓存的掩码 掩码操作
    //    glColorMask(GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha)
    
    
    [_program0 use];
    glBindBuffer(GL_ARRAY_BUFFER, _buffer0);
//    {
//        //不进行归一化处理 即转换为归一化的浮点数(0~1)
//        glVertexAttribPointer([_program0 attributeIndex:@"position"], 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
//        glEnableVertexAttribArray([_program0 attributeIndex:@"position"]);
//        glVertexAttribPointer([_program0 attributeIndex:@"textureCoordinate"], 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);
//        glEnableVertexAttribArray([_program0 attributeIndex:@"textureCoordinate"]);
//        glDrawArrays(GL_TRIANGLES, 0, 6);
//    }
    
    glVertexAttribPointer([_program0 attributeIndex:@"position"], 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4, NULL);
    glEnableVertexAttribArray([_program0 attributeIndex:@"position"]);
    glVertexAttribPointer([_program0 attributeIndex:@"textureCoordinate"], 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4, (float *)NULL + 2);
    glEnableVertexAttribArray([_program0 attributeIndex:@"textureCoordinate"]);
//            glDrawArrays(GL_TRIANGLES, 0, 6);
    
    [self changeData];
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
  
}

- (void)changeData {
    
    int column = 100 / 2 * 2;// 0 ~column-1  为偶数
    NSUInteger sizeOfArr = column * 2/*position :x, y*/ * 2/*texture: x, y*/ * 2/*两个点*/;
    
    if (_arrBuffer == NULL) {///重复使用数据缓存
        GLfloat tmpArr[sizeOfArr];//size临时缓存
        for (int i = 0; i < sizeOfArr; i++) {
            tmpArr[i] = 0;//初始值均为0
        }
        _arrBuffer = (float *)tmpArr;
    }
    
    if (_indices == NULL) {
        int tmpArr[column * 3/*位置*/ * 2/*个数*/];//
        _indices = (int *)tmpArr;
        int stride = 6;
        int index = 0;
        for (int i = 0; i < column; i++) {
            _indices[index + 0] = 1 + i*2;
            _indices[index + 1] = 3 + i*2;
            _indices[index + 2] = 2 + i*2;
            _indices[index + 3] = 2 + i*2;
            _indices[index + 4] = 0 + i*2;
            _indices[index + 5] = 1 + i*2;
            index += stride;
        }
    }
    
    int tmpIndex = 0;
    int stride = 4;//只保存顶点坐标xy 纹理坐标xy

//    CGFloat xfloat = (1 * 1.0);
    CGFloat yfloat = (column * 1.0);
    for (int j = 0; j < column; j++) {
        for (int i = 0; i < 2; i++) {//2个点为顶点坐标 另外两个点为纹理坐标
            CGFloat positionX = i;
            CGFloat positionY =  j / yfloat;
            
            CGFloat textureX = i;
            CGFloat texturey = j / yfloat;
            
            _arrBuffer[tmpIndex + 0] += positionX;
            _arrBuffer[tmpIndex + 1] += positionY;
            
            _arrBuffer[tmpIndex + 2] += textureX;
            _arrBuffer[tmpIndex + 3] += texturey;
            tmpIndex += stride;
        }
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, _buffer0);
    glBufferData(GL_ARRAY_BUFFER, sizeof(CGFloat)*sizeOfArr , _arrBuffer, GL_DYNAMIC_DRAW);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _index0);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(_indices), _indices, GL_STATIC_DRAW);
}


- (void)update {

    [self destroyRenderAndFrameBuffer];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    [self render];
    
}

- (void)setupContext {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    // 设置为当前上下文
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}


- (GLuint)setupTexture:(NSString *)fileName textures:(GLuint *)textures textureUnit:(GLenum)texture{
    // 1获取图片的CGImageRef
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    NSAssert(spriteImage, @"图片有问题");
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
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
    return 0;
}


- (void)destroyRenderAndFrameBuffer {
    glDeleteFramebuffers(1, &_colorFrameBuffer);
    _colorFrameBuffer = 0;
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
}

- (void)setupRenderBuffer {
    GLuint buffer;
    glGenRenderbuffers(1, &buffer);
    _colorRenderBuffer = buffer;
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    // 为 颜色缓冲区 分配存储空间
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupFrameBuffer {
    GLuint buffer;
    glGenFramebuffers(1, &buffer);
    _colorFrameBuffer = buffer;
    // 设置为当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _colorFrameBuffer);
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
}

@end
