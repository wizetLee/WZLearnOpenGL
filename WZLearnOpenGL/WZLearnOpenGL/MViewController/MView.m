//
//  MView.m
//  WZLearnOpenGL
//
//  Created by 李炜钊 on 2017/10/5.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "MView.h"
#import <GLKit/GLKit.h>
@interface MView()

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

@property (nonatomic, assign) GLuint xOffset;
@property (nonatomic, assign) GLuint yOffset;

@property (nonatomic, assign) CGFloat xOffsetValue;
@property (nonatomic, assign) CGFloat yOffsetValue;

@property (nonatomic, assign) CGFloat verticalOffset;
@property (nonatomic, assign) CGFloat horizontalOffset;




@end

@implementation MView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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
    [self setupProgram1];
    
    [self update];
    
    
    [self gestures];
}

- (void)gestures {
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotation:)];
    [self addGestureRecognizer:rotation];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    pan.maximumNumberOfTouches = 1;
    pan.minimumNumberOfTouches = 1;
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [self addGestureRecognizer:pinch];
}

- (void)rotation:(UIRotationGestureRecognizer *)rotation {
//    NSLog(@"%lf", rotation.rotation);
    /// rotation.rotation 由0开始无限自增或者自减   rotation.rotation>0 为顺时针 反之逆时针
    _rotateAngle = _lastRotateAngle -(rotation.rotation);
    if (rotation.state == UIGestureRecognizerStateEnded) {
        _lastRotateAngle = _rotateAngle;//记录上次的旋转点
    }

    [self update];
}

- (void)pinch:(UIPinchGestureRecognizer *)pinch {
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

static  CGPoint startPoint;
static  CGFloat tmpXOffsetValue;
static  CGFloat tmpYOffsetValue;
- (void)pan:(UIPanGestureRecognizer *)pan {
 
    CGPoint curPoint = [pan locationInView:self];
    if (pan.state == UIGestureRecognizerStateBegan) {
        startPoint = [pan locationInView:self];
    }

    
    _xOffsetValue = curPoint.x - startPoint.x + tmpXOffsetValue;
    _yOffsetValue = curPoint.y - startPoint.y + tmpYOffsetValue;
    _xOffsetValue *= 0.0025;//缓冲量。不太准确.。。
    _yOffsetValue *= 0.0025;
   
    [self update];
    if (pan.state == UIGestureRecognizerStateEnded) {
        tmpXOffsetValue = curPoint.x - startPoint.x + tmpXOffsetValue;
        tmpYOffsetValue = curPoint.y - startPoint.y + tmpYOffsetValue;
    }
    
    NSLog(@"%f - %f",_xOffsetValue, _yOffsetValue );
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
    glViewport(self.frame.origin.x * scale
               , self.frame.origin.y * scale
               , self.frame.size.width * scale
               , self.frame.size.height * scale);
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
    
    GLuint texture0Uniform = [_program0 uniformIndex:@"texture0"];
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
    GLuint texture1Uniform = [_program1 uniformIndex:@"texture1"];
    GLuint displayPositionAttribute = [_program1 attributeIndex:@"position"];
    GLuint displayTextureCoordinateAttribute = [_program1 attributeIndex:@"textureCoordinate"];
    _rotateMatrix = [_program1 uniformIndex:@"rotateMatrix"];
    _scale = [_program1 uniformIndex:@"scale"];
    _yOffset = [_program1 uniformIndex:@"yOffset"];
    _xOffset = [_program1 uniformIndex:@"xOffset"];
    
    [_program1 use];
    glEnableVertexAttribArray(displayPositionAttribute);
    glEnableVertexAttribArray(displayTextureCoordinateAttribute);
    
    //前三个是顶点坐标， 后面两个是纹理坐标
    
    CGFloat scale = 0.5 ;///大小标量
    GLfloat attrArr[] =
    {
        1.0 * scale, 1.0 * scale, -1.0,     1.0, 0.0,
        1.0 * scale, -1.0 * scale, -1.0,     1.0, 1.0,
        -1.0 * scale, -1.0 * scale, -1.0,    0.0, 1.0,
        -1.0 * scale, -1.0 * scale, -1.0,    0.0, 1.0,
        -1.0 * scale, 1.0 * scale, -1.0,     0.0, 0.0,
        1.0 * scale, 1.0 * scale, -1.0,     1.0, 0.0,
    };
    /**
     
     **/
    
    ///数据配置
    int verticalCount = 1000;//将像图片划分为1000个正方向 无论垂直方向还是水平方向
    int horizontalCount = 1000;//将像图片划分为1000个正方向 无论垂直方向还是水平方向
    //1000 * 1000的图片坐标系
    CGFloat verticalOffset = 0.0;
    CGFloat horizontalOffset = 0.0;
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
//    CGFloat xSpace = w / horizontalCount;
//    CGFloat ySpace = h / verticalCount;
    
    ///每个分段切割出4个点。6个坐标 使用 比较消耗内存
//    glDrawArrays(GLenum mode, GLint first, GLsizei count)
    
    ///每个分段切割出4个点。4个坐标 使用
//    glDrawElements(GLenum mode, GLsizei count, GLenum type, const GLvoid *indices)
    

    GLfloat arr[verticalCount * horizontalCount * 30];
    
//    for (int y = 0; y < verticalCount; y++) {                   //Y
//        for (int x = 0; x < horizontalCount; x++) {             //X
//            //水平平铺 到垂直平铺
//
//            //////position   所有坐标 * 2 - 1 的得到position
//            CGFloat multiple  = 2.0;
//
//            //左上
//            CGPoint leftTop = CGPointMake((x / (horizontalCount * 1.0)), ((y + 1) / (verticalCount * 1.0) ));
//            //右上
//            CGPoint rightTop = CGPointMake(((x + 1) / (horizontalCount * 1.0)), ((y + 1) / (verticalCount * 1.0)));
//            //左下
//            CGPoint leftBottom = CGPointMake((x / (horizontalCount * 1.0)),  (y / (verticalCount * 1.0))) ;
//            //右下
//            CGPoint rightBottom = CGPointMake(((x + 1) / (horizontalCount * 1.0)) ,  (y / (verticalCount * 1.0)));
//
//            ///由于循环是由0 自增 因此 左上是左下  右上是右下
//            CGPoint t0 = CGPointMake(leftTop.x, 1 - leftTop.y);
//            CGPoint t1 = CGPointMake(rightTop.x, 1 - rightTop.y);
//            CGPoint t2 = CGPointMake(leftBottom.x, 1 - leftBottom.y);
//            CGPoint t3 = CGPointMake(rightBottom.x, 1 - rightBottom.y);
//
////            if (x < 1) {
////                NSLog(@"%@ - %@ - %@ - %@", NSStringFromCGPoint(leftTop), NSStringFromCGPoint(rightTop), NSStringFromCGPoint(leftBottom), NSStringFromCGPoint(rightBottom));
////            }
//
//            //0
//            //position
//            arr[(x + y) * 30 + 0] =
//            arr[(x + y) * 30 + 1] =
//            arr[(x + y) * 30 + 2] =
//              //纹理
//            arr[(x + y) * 30 + 3] =
//            arr[(x + y) * 30 + 4] =
//
//
//            //1
//            arr[(x + y) * 30 + 5] =
//            arr[(x + y) * 30 + 6] =
//            arr[(x + y) * 30 + 7] =
//            arr[(x + y) * 30 + 8] =
//            arr[(x + y) * 30 + 9] =
//            //2
//            arr[(x + y) * 30 + 10] =
//            arr[(x + y) * 30 + 11] =
//            arr[(x + y) * 30 + 12] =
//            arr[(x + y) * 30 + 13] =
//            arr[(x + y) * 30 + 14] =
//            arr[(x + y) * 30 + 15] =
//            arr[(x + y) * 30 + 16] =
//            arr[(x + y) * 30 + 17] =
//            arr[(x + y) * 30 + 18] =
//            arr[(x + y) * 30 + 19] =
//            arr[(x + y) * 30 + 20] =
//            arr[(x + y) * 30 + 21] =
//            arr[(x + y) * 30 + 22] =
//            arr[(x + y) * 30 + 23] =
//            arr[(x + y) * 30 + 24] =
//            arr[(x + y) * 30 + 25] =
//            arr[(x + y) * 30 + 26] =
//            arr[(x + y) * 30 + 27] =
//            arr[(x + y) * 30 + 28] =
//            arr[(x + y) * 30 + 29] =
////            arr[verticalCount * horizontalCount * 6] =
//            /*
//             position
//             -1  1        1  1
//                    0  0
//             -1 -1        1 -1
//
//             ->
//             0 2        2 2
//             0 0        2 0
//
//             texture
//             0 1    1 1
//             0 0    1 0
//             */
//
//
//        }
//    }
    
    //数据配置
    glGenBuffers(1, &_buffer1);
    glBindBuffer(GL_ARRAY_BUFFER, _buffer1);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    glVertexAttribPointer(displayPositionAttribute, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
    glEnableVertexAttribArray(displayPositionAttribute);
    
    glVertexAttribPointer(displayTextureCoordinateAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);
    glEnableVertexAttribArray(displayTextureCoordinateAttribute);
    
    //纹理加载
    [self setupTexture:@"beetle.png" textures:&_texture1 textureUnit:GL_TEXTURE1];
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
    
    
    [_program1 use];
    glUniformMatrix4fv(_rotateMatrix, 1, GL_FALSE, GLKMatrix4MakeZRotation(_rotateAngle).m);//顶点着色器 矩阵更换_rotateMatrix 旋转角度配置
    glUniform1f(_scale, _zoomLevel);// scale
    glUniform1f(_yOffset, _yOffsetValue);
    glUniform1f(_xOffset, _xOffsetValue);
//    NSLog(@"_rotateMatrix %u", _rotateMatrix);
//    NSLog(@"_rotateAngle %f", _rotateAngle);
    
    
    glBindBuffer(GL_ARRAY_BUFFER, _buffer1);
    [_program1 addAttribute:@"position"];
    [_program1 addAttribute:@"textureCoordinate"];
    
    glVertexAttribPointer([_program1 attributeIndex:@"position"], 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
    glEnableVertexAttribArray([_program1 attributeIndex:@"position"]);
    glVertexAttribPointer([_program1 attributeIndex:@"textureCoordinate"], 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);
    glEnableVertexAttribArray([_program1 attributeIndex:@"textureCoordinate"]);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
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


- (void)destroyRenderAndFrameBuffer
{
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
