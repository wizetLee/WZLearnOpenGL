//
//  MView.m
//  WZLearnOpenGL
//
//  Created by 李炜钊 on 2017/10/5.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "MView.h"
#import <GLKit/GLKit.h>
#include <math.h>
@interface MView()<UIGestureRecognizerDelegate>
{
    CGPoint startPoint;
    CGFloat tmpXOffsetValue;
    CGFloat tmpYOffsetValue;
    int xCount;
    int yCount;
    int numberOfPoint;
}
@property (nonatomic, strong) CAEAGLLayer *eaglLayer;
@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, assign) GLuint colorRenderBuffer;
@property (nonatomic, assign) GLuint colorFrameBuffer;

///p0
@property (nonatomic, assign) GLuint texture0;
@property (nonatomic, assign) GLuint buffer0;
@property (nonatomic, strong) GLProgram *program0;
///p1
@property (nonatomic, assign) GLuint texture1;
@property (nonatomic, assign) GLuint buffer1;
@property (nonatomic, strong) GLProgram *program1;
///p1变量
@property (nonatomic, assign) GLuint rotateMatrix;//uniform
@property (nonatomic, assign) float lastRotateAngle;//旋转变量
@property (nonatomic, assign) float rotateAngle;//旋转变量

@property (nonatomic, assign) GLuint scale;//uniform
@property (nonatomic, assign) float lastZoomLevel;
@property (nonatomic, assign) float zoomLevel;//缩放变量

//anchor
@property (nonatomic, assign) GLuint anchorPoint;
@property (nonatomic, assign) GLuint whRate;

@property (nonatomic, assign) GLuint xOffset;
@property (nonatomic, assign) GLuint yOffset;

@property (nonatomic, assign) CGFloat xOffsetValue;
@property (nonatomic, assign) CGFloat yOffsetValue;

@property (nonatomic, assign) CGFloat verticalOffset;
@property (nonatomic, assign) CGFloat horizontalOffset;

@property (nonatomic, assign) BOOL updating;
//@property (nonatomic, assign) BOOL roating;
//@property (nonatomic, assign) BOOL pinching;
///p2
@property (nonatomic, assign) GLuint texture2;
@property (nonatomic, assign) GLuint buffer2;
@property (nonatomic, strong) GLProgram *program2;



@end

@implementation MView

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
    
    _zoomLevel = 1.0;
    _lastZoomLevel = _zoomLevel;
    _rotateAngle = 0;
    _xOffsetValue = 0.0;
    _yOffsetValue = 0.0;
    
    [self setupLayer];
    [self setupContext];
    
    [self viewPort];
    

    [self setupProgram0];
//    [self setupProgram1]s;
    [self setupProgram2];
    
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

- (void)rotation:(UIRotationGestureRecognizer *)rotation {
    if (_updating) {
        return;
    }
//    NSLog(@"%lf", rotation.rotation);
    /// rotation.rotation 由0开始无限自增或者自减   rotation.rotation>0 为顺时针 反之逆时针
    _rotateAngle = _lastRotateAngle -(rotation.rotation);

    if (rotation.state == UIGestureRecognizerStateEnded) {
        _lastRotateAngle = _rotateAngle;//记录上次的旋转点
    }

    [self update];
}

- (void)pinch:(UIPinchGestureRecognizer *)pinch {
    if (_updating) {
        return;
    }
    //捏合初始点为 缩小小于1。放大大于1
    _zoomLevel = _lastZoomLevel + (pinch.scale - 1);
    if (_zoomLevel < 0.1) {
        _zoomLevel = 0.1;
    }
    if (pinch.state == UIGestureRecognizerStateEnded) {
        _lastZoomLevel = _zoomLevel;
    }
 
    [self update];
}


- (void)pan:(UIPanGestureRecognizer *)pan {
    if (_updating) {
        return;
    }
    
    if (!pan.view.subviews) {
        return;
    }
    CGPoint translation = [pan translationInView:[pan.view superview]];
//    NSLog(@"%@", NSStringFromCGPoint(translation));
    if (pan.state == UIGestureRecognizerStateBegan) {
        startPoint = [pan locationInView:self];
    }

    _xOffsetValue = translation.x + tmpXOffsetValue;
    _yOffsetValue = -(translation.y + tmpYOffsetValue);
    _xOffsetValue *= 0.0025;//缓冲量。不太准确.。。
    _yOffsetValue *= 0.0025;
   
    [self update];
    if (pan.state == UIGestureRecognizerStateEnded) {
        tmpXOffsetValue = translation.x + tmpXOffsetValue;
        tmpYOffsetValue = translation.y + tmpYOffsetValue;
    }
    
//    NSLog(@"%f - %f",_xOffsetValue, _yOffsetValue );
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
    
    GLuint texture0Uniform = [_program0 uniformIndex:@"texture"];
    GLuint displayPositionAttribute = [_program0 attributeIndex:@"position"];
    GLuint displayTextureCoordinateAttribute = [_program0 attributeIndex:@"textureCoordinate"];
    [_program0 use];
    glEnableVertexAttribArray(displayPositionAttribute);
    glEnableVertexAttribArray(displayTextureCoordinateAttribute);
    
    CGFloat scale = 1;
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
    
    glVertexAttribPointer(displayPositionAttribute, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
    glEnableVertexAttribArray(displayPositionAttribute);
    
    glVertexAttribPointer(displayTextureCoordinateAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);
    glEnableVertexAttribArray(displayTextureCoordinateAttribute);
    
    //加载纹理
    [self setupTexture:@"leaves.gif" textures:&_texture0 textureUnit:GL_TEXTURE0];
    glUniform1i(texture0Uniform, 0);
}


- (void)setupProgram1 {
    //读取文件路径
    NSString *vsh = [[NSBundle mainBundle] pathForResource:@"shaderTransformV" ofType:@"vsh"];
    NSString *fsh = [[NSBundle mainBundle] pathForResource:@"shaderTransformF" ofType:@"fsh"];

    _program1 = [[GLProgram alloc] initWithVertexShaderString:[NSString stringWithContentsOfFile:vsh encoding:NSUTF8StringEncoding error:nil] fragmentShaderString:[NSString stringWithContentsOfFile:fsh encoding:NSUTF8StringEncoding error:nil]];
    if (!_program1.initialized)
    {
        [_program1 addAttribute:@"position"];
        [_program1 addAttribute:@"textureCoordinate"];
        
        if (![_program1 link]) {
            NSString *progLog = [_program1 programLog];
            NSLog(@"Program link log: %@", progLog);
            NSString *fragLog = [_program1 fragmentShaderLog];
            NSLog(@"Fragment shader compile log: %@", fragLog);
            NSString *vertLog = [_program1 vertexShaderLog];
            NSLog(@"Vertex shader compile log: %@", vertLog);
            _program1 = nil;
            NSAssert(NO, @"Filter shader link failed");
        }
    }
    GLuint texture1Uniform = [_program1 uniformIndex:@"texture"];
    GLuint displayPositionAttribute = [_program1 attributeIndex:@"position"];
    GLuint displayTextureCoordinateAttribute = [_program1 attributeIndex:@"textureCoordinate"];
    _rotateMatrix = [_program1 uniformIndex:@"rotateMatrix"];
    _scale = [_program1 uniformIndex:@"scale"];
    _yOffset = [_program1 uniformIndex:@"yOffset"];
    _xOffset = [_program1 uniformIndex:@"xOffset"];
    _anchorPoint = [_program1 uniformIndex:@"anchorPoint"];
    _whRate = [_program1 uniformIndex:@"whRate"];
    
    
    [_program1 use];
    glEnableVertexAttribArray(displayPositionAttribute);
    glEnableVertexAttribArray(displayTextureCoordinateAttribute);
    
    //前三个是顶点坐标， 后面两个是纹理坐标
    
    ///保持于图片的一致性
    CGFloat scale = 1 ;///大小标量
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
    glGenBuffers(1, &_buffer1);
    glBindBuffer(GL_ARRAY_BUFFER, _buffer1);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    glVertexAttribPointer(displayPositionAttribute, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
    glEnableVertexAttribArray(displayPositionAttribute);
    
    glVertexAttribPointer(displayTextureCoordinateAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);
    glEnableVertexAttribArray(displayTextureCoordinateAttribute);
    
    //纹理加载
    
    NSAssert([UIImage imageNamed:@"74172016103114541058969337.jpg"], @"OMG");
   
    
    [self setupTexture:@"74172016103114541058969337.jpg" textures:&_texture1 textureUnit:GL_TEXTURE1];
    glUniform1i(texture1Uniform, 1);///配置纹理

    
    ///矩阵旋转
    glUniformMatrix4fv(_rotateMatrix, 1, GL_FALSE, GLKMatrix4MakeZRotation(_rotateAngle).m);
    glUniform1f(_scale, _zoomLevel);
    glUniform1f(_yOffset, _yOffsetValue);
    glUniform1f(_xOffset, _xOffsetValue);
    
//    _zoomLevel = 0.1;
//    glUniformMatrix4fv(_rotateMatrix, 1, GL_FALSE, GLKMatrix4MakeScale(_zoomLevel, _zoomLevel, _zoomLevel).m);
//    glUniformMatrix4fv(_rotateMatrix, 1, GL_FALSE, GLKMatrix4MakeTranslation(_zoomLevel, _zoomLevel, _zoomLevel).m);
    
    
    glEnable(GL_BLEND);//开启混合模式
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);//设置混合模式
    /**
     源因子和目标因子是可以通过glBlendFunc函数来进行设置的。glBlendFunc有两个参数，前者表示源因子，后者表示目标因子。这两个参数可以是多种值，下面介绍比较常用的几种。
     GL_ZERO：     表示使用0.0作为因子，实际上相当于不使用这种颜色参与混合运算。
     GL_ONE：      表示使用1.0作为因子，实际上相当于完全的使用了这种颜色参与混合运算。
     GL_SRC_ALPHA：表示使用源颜色的alpha值来作为因子。
     GL_DST_ALPHA：表示使用目标颜色的alpha值来作为因子。
     GL_ONE_MINUS_SRC_ALPHA：表示用1.0减去源颜色的alpha值来作为因子。
     GL_ONE_MINUS_DST_ALPHA：表示用1.0减去目标颜色的alpha值来作为因子。
     除此以外，还有GL_SRC_COLOR（把源颜色的四个分量分别作为因子的四个分量）、GL_ONE_MINUS_SRC_COLOR、 GL_DST_COLOR、GL_ONE_MINUS_DST_COLOR等，前两个在OpenGL旧版本中只能用于设置目标因子，后两个在OpenGL 旧版本中只能用于设置源因子。新版本的OpenGL则没有这个限制，并且支持新的GL_CONST_COLOR（设定一种常数颜色，将其四个分量分别作为 因子的四个分量）、GL_ONE_MINUS_CONST_COLOR、GL_CONST_ALPHA、 GL_ONE_MINUS_CONST_ALPHA。另外还有GL_SRC_ALPHA_SATURATE。新版本的OpenGL还允许颜色的alpha 值和RGB值采用不同的混合因子。但
     **/
}




- (void)render {
    glClearColor(1.0, 1.0, 1.0  , 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [_program0 use];
    glBindBuffer(GL_ARRAY_BUFFER, _buffer0);
    glVertexAttribPointer([_program0 attributeIndex:@"position"], 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
    glEnableVertexAttribArray([_program0 attributeIndex:@"position"]);
    glVertexAttribPointer([_program0 attributeIndex:@"textureCoordinate"], 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);
    glEnableVertexAttribArray([_program0 attributeIndex:@"textureCoordinate"]);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
//    {
//        [_program1 use];
//        //系统API生成绕Z轴旋转X角的矩阵
//        {
//            {
//                glUniformMatrix4fv(_rotateMatrix, 1, GL_FALSE, GLKMatrix4MakeZRotation(_rotateAngle).m);//顶点着色器 矩阵更换_rotateMatrix 旋转角度配置
//                NSLog(@"____%f", _rotateAngle);
//                /** 围绕X轴旋转
//                 cosX  sinX  0  0
//                 -sinX consx 0  0
//                 0     0     1  0
//                 0     0     0  1
//                 **/
//                //                printf("\n--------------\n");
//                //                for(int i = 0 ; i < 16 ; i++) {if (i % 4 == 0) {printf("\n"); }printf("%f ", GLKMatrix4MakeZRotation(_rotateAngle).m[i]);}
//                //                printf("\n--------------\n");
//            }
//            ///效果一致
//            //        {
//            //            float radians = _rotateAngle;// 180.0 / M_PI * _rotateAngle * M_PI / 180.0;
//            //            float s = sin(radians);
//            //            float c = cos(radians);
//            //            //z轴旋转矩阵
//            //            GLfloat zRotation[16] = {
//            //                c, s, 0, 0,
//            //                -s, c, 0, 0,
//            //                0, 0, 1.0, 0,
//            //                0.0, 0, 0, 1.0
//            //            };
//            //            glUniformMatrix4fv(_rotateMatrix, 1, GL_FALSE, (float *)&zRotation);
//            //        }
//            // 角度转弧度
//            //    GLKMathDegreesToRadians(float degrees)
//            //弧度转角度
//            //    GLKMathRadiansToDegrees(float radians)
//        }//PS 旋转的时候如何维持一个矩形？ 画布跟图片的尺寸比保持一致
//
//        glUniform1f(_scale, _zoomLevel);// scale
//        glUniform1f(_yOffset, _yOffsetValue);
//        glUniform1f(_xOffset, _xOffsetValue);
//        glUniform2f(_anchorPoint, 0.0, 0.0);//计算这个锚点
//        //    [UIImage imageNamed:@"74172016103114541058969337.jpg"].size.width / [UIImage imageNamed:@"74172016103114541058969337.jpg"].size.height
//        glUniform1f(_whRate, 1.0);
//        //    NSLog(@"_rotateMatrix %u", _rotateMatrix);
//        //    NSLog(@"_rotateAngle %f", _rotateAngle);
//
//        //通过一个单位矩阵来返回一个定义了坐标系的新矩阵
//        //    GLKMatrix4MakeTranslation(float tx, float ty, float tz)
//
//
//        glBindBuffer(GL_ARRAY_BUFFER, _buffer1);
//        glVertexAttribPointer([_program1 attributeIndex:@"position"], 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
//        glEnableVertexAttribArray([_program1 attributeIndex:@"position"]);
//        glVertexAttribPointer([_program1 attributeIndex:@"textureCoordinate"], 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);
//        glEnableVertexAttribArray([_program1 attributeIndex:@"textureCoordinate"]);
//        glDrawArrays(GL_TRIANGLES, 0, 6);
//        //    [_context presentRenderbuffer:GL_RENDERBUFFER];
//    }
    
    [self use2];
    
}

- (void)use2 {
    [_program2 use];
    GLProgram *program = _program2;
    
    glBindBuffer(GL_ARRAY_BUFFER, _buffer2);
    
    glUniform2f([program uniformIndex:@"touchPoint"], 0.1, 0.01);
    glVertexAttribPointer([program attributeIndex:@"position"], 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4, NULL);
    glEnableVertexAttribArray([program attributeIndex:@"position"]);
    glVertexAttribPointer([program attributeIndex:@"textureCoordinate"], 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4, (float *)NULL + 2);
    glEnableVertexAttribArray([program attributeIndex:@"textureCoordinate"]);
//    glDrawArrays(GL_TRIANGLES, 0, 6);
    glDrawArrays(GL_TRIANGLES, 0, xCount * yCount * numberOfPoint / 4);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}


- (void)update {
    if (_updating) {
        return;
    }
    _updating = true;
    [self destroyRenderAndFrameBuffer];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    [self render];
    _updating = false;
    
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

- (void)setupProgram2 {
    //读取文件路径
    NSString *vsh = [[NSBundle mainBundle] pathForResource:@"shaderAnomalyV" ofType:@"vsh"];
    NSString *fsh = [[NSBundle mainBundle] pathForResource:@"shaderAnomalyF" ofType:@"fsh"];
    
    _program2 = [[GLProgram alloc] initWithVertexShaderString:[NSString stringWithContentsOfFile:vsh encoding:NSUTF8StringEncoding error:nil] fragmentShaderString:[NSString stringWithContentsOfFile:fsh encoding:NSUTF8StringEncoding error:nil]];
    GLProgram *program = _program2;
    if (!program.initialized)
    {
        [program addAttribute:@"position"];
        [program addAttribute:@"textureCoordinate"];
        
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
    GLuint texture1Uniform = [program uniformIndex:@"texture"];
    GLuint displayPositionAttribute = [program attributeIndex:@"position"];
    GLuint displayTextureCoordinateAttribute = [program attributeIndex:@"textureCoordinate"];
    GLuint touchPointUniform = [program uniformIndex:@"touchPoint"];
    
    [program use];
    glEnableVertexAttribArray(displayPositionAttribute);
    glEnableVertexAttribArray(displayTextureCoordinateAttribute);
    
    ///数据配置
    xCount = 100;//将像图片划分为1000个正方向 无论垂直方向还是水平方向
    yCount = 100;//将像图片划分为1000个正方向 无论垂直方向还是水平方向
    //1000 * 1000的图片坐标系
    
    ///每个分段切割出4个点。6个坐标 使用 比较消耗内存
    //    glDrawArrays(GLenum mode, GLint first, GLsizei count)
    
    ///每个分段切割出4个点。4个坐标 使用
    //    glDrawElements(GLenum mode, GLsizei count, GLenum type, const GLvoid *indices)

    numberOfPoint = 24;
    GLfloat arr[xCount * yCount * numberOfPoint];
    CGFloat xfloat = (xCount * 1.0);
    CGFloat yfloat = (yCount * 1.0);
    printf("sizeofArr: %lu", sizeof(arr) / 4);
    //////position   所有坐标 * 2 - 1 的得到position
    CGFloat xOffsetContent = 0.1;
    
    CGFloat xGanraoti = 0;
    CGFloat yGanraoti = 0;
    
    NSInteger index = 0;
    CGFloat multiple  = 2.0;
        for (int y = 0; y < yCount; y++) {                   //Y
            for (int x = 0; x < xCount; x++) {             //X
                
                //X影响水平偏移
                //Y影响垂直偏移
                
                //水平平铺 到垂直平铺 由OPEN GL 坐标的0，0开始到1，1
                
                //左上
                CGPoint leftTop = CGPointMake((x / xfloat)            , ((y + 1) / yfloat ));
                //右上
                CGPoint rightTop = CGPointMake(((x + 1) / xfloat)     , ((y + 1) / yfloat));
                //左下
                CGPoint leftBottom = CGPointMake((x / xfloat)          ,  (y / yfloat)) ;
                //右下
                CGPoint rightBottom = CGPointMake(((x + 1) / xfloat)   ,  (y / yfloat));

                ///由于循环是由0 自增 因此 左上是左下  右上是右下

                CGPoint t0 = CGPointMake(rightTop.x, 1 - rightTop.y);
                CGPoint t2 = CGPointMake(leftBottom.x, 1 - leftBottom.y);
                CGPoint t1 = CGPointMake(rightBottom.x, 1 - rightBottom.y);
                CGPoint t3 = CGPointMake(leftTop.x, 1 - leftTop.y);
                //左上
                leftTop = CGPointMake(leftTop.x * multiple - 1            , leftTop.y * multiple-1);
                //右上
                rightTop = CGPointMake(rightTop.x* multiple -1      , rightTop.y* multiple-1);
                //左下
                leftBottom = CGPointMake(leftBottom.x* multiple -1          , leftBottom.y* multiple-1) ;
                //右下
               rightBottom = CGPointMake(rightBottom.x* multiple -1   ,  rightBottom.y* multiple-1);

                arr[index + 0] = rightTop.x;
                arr[index + 1] = rightTop.y;
                //纹理
                arr[index + 2] = t0.x;
                arr[index + 3] = t0.y;
                
                //1
                arr[index + 4] = rightBottom.x;
                arr[index + 5] = rightBottom.y;
                arr[index + 6] = t1.x;
                arr[index + 7] = t1.y;
                //2
                arr[index + 8] = leftBottom.x;
                arr[index + 9] = leftBottom.y;
                arr[index + 10] = t2.x;
                arr[index + 11] = t2.y;
                //3
                arr[index + 12] = leftBottom.x;
                arr[index + 13] = leftBottom.y;
                arr[index + 14] = t2.x;
                arr[index + 15] = t2.y;
                //4
                arr[index + 16] = leftTop.x;
                arr[index + 17] = leftTop.y;
                arr[index + 18] = t3.x;
                arr[index + 19] = t3.y;
                
                arr[index + 20] = rightTop.x;
                arr[index + 21] = rightTop.y;
                arr[index + 22] = t0.x;
                arr[index + 23] = t0.y;
                index += numberOfPoint;
            }
        }
    
    //根据坐标点的数目调整位置
    //数据配置
    glGenBuffers(1, &_buffer2);
    glBindBuffer(GL_ARRAY_BUFFER, _buffer2);
    glBufferData(GL_ARRAY_BUFFER, sizeof(arr), arr, GL_DYNAMIC_DRAW);
    
    glVertexAttribPointer(displayPositionAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4, NULL);
    glEnableVertexAttribArray(displayPositionAttribute);
    
    glVertexAttribPointer(displayTextureCoordinateAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4, (float *)NULL + 2);
    glEnableVertexAttribArray(displayTextureCoordinateAttribute);
    
    //纹理加载
    
    NSAssert([UIImage imageNamed:@"40682016071512070526937635.jpg"], @"OMG");
    
    [self setupTexture:@"40682016071512070526937635.jpg" textures:&_texture2 textureUnit:GL_TEXTURE2];
    glUniform1i(texture1Uniform, 2);///配置纹理 保持一致
    
    
    glEnable(GL_BLEND);//开启混合模式
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);//设置混合模式
    
}


@end
