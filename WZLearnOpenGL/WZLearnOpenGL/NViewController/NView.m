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


#define Column (1000)
#define SizeOFVectorTextureCoordinate (Column * 2/*position :x, y*/ * 2/*texture: x, y*/ * 2/*两个点*/ + 4*2)
#define SizeOfIndices  (Column * 3/*位置*/ * 2/*个数*/)

typedef NS_ENUM(NSUInteger, VertorOriention) {
    VertorOriention_None,
    VertorOriention_Left,
    VertorOriention_Right,
};

@interface NView()<UIGestureRecognizerDelegate>
{

    float new_arrBuffer[SizeOFVectorTextureCoordinate];
//    float new_arrBufferOrigion[SizeOFVectorTextureCoordinate];
    int new_indices[SizeOfIndices];
    
    
    CGFloat targetY;//计算非线性方程极大值的依据   0~1
    CGFloat targetX;//计算偏移程度的依据
    CGFloat lastLocationX;
#warning  需要手动计算向左向右 依赖translation不怎么好
}


@property (nonatomic, strong) CAEAGLLayer *eaglLayer;
@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, assign) GLuint colorRenderBuffer;
@property (nonatomic, assign) GLuint colorFrameBuffer;

///p0
@property (nonatomic, assign) GLuint texture0;
@property (nonatomic, assign) GLuint buffer0;
@property (nonatomic, strong) GLProgram *program0;
@property (nonatomic, assign) GLuint index0;

@property (nonatomic, assign) BOOL updating;

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
    {
//        for (int i = 0; i < SizeOFVectorTextureCoordinate; i++) {
//            new_arrBuffer[i] = 0.0;//初始值均为0
//        }
        int tmpIndex = 0;
        int stride = 4;//只保存顶点坐标xy 纹理坐标xy
        CGFloat yfloat = (Column * 1.0);
        CGFloat multiple = 2.0;
        float *arr = (float *)new_arrBuffer;
//        float *arr2 = (float *)new_arrBufferOrigion;
///顶点坐标 纹理坐标
        for (int j = 0; j < Column + 1; j++) {
            for (int i = 0; i < 2; i++) {//2个点为顶点坐标 另外两个点为纹理坐标
                CGFloat positionX = i;
                CGFloat positionY =  j / yfloat;

                CGFloat textureX = i;
                CGFloat texturey = j / yfloat;
                if (positionX == NAN
                    ||positionY == NAN
                    ||textureX == NAN
                    ||texturey == NAN) {
                    NSLog(@"~~~");
                }

                arr[tmpIndex + 0] = positionX * multiple - 1.0;
                arr[tmpIndex + 1] = positionY * multiple - 1.0;

                arr[tmpIndex + 2] = textureX;
                arr[tmpIndex + 3] = 1.0 - texturey;//texturey; //纹理坐标跟position坐标Y翻转
//                {
//                    arr2[tmpIndex + 0] = arr[tmpIndex + 0];
//                    arr2[tmpIndex + 1] = arr[tmpIndex + 1];
//                    arr2[tmpIndex + 2] = arr[tmpIndex + 2];
//                    arr2[tmpIndex + 3] = arr[tmpIndex + 3];
//                }
                tmpIndex += stride;
            }
        }
        
        stride = 6;
        tmpIndex = 0;
///索引
        for (int i = 0; i < Column; i++) {
            new_indices[tmpIndex + 0] = 1 + i*2;
            new_indices[tmpIndex + 1] = 3 + i*2;
            new_indices[tmpIndex + 2] = 2 + i*2;
            new_indices[tmpIndex + 3] = 2 + i*2;
            new_indices[tmpIndex + 4] = 0 + i*2;
            new_indices[tmpIndex + 5] = 1 + i*2;
            tmpIndex += stride;
        }
    }
    
    [self setupLayer];
    [self setupContext];
    [self viewPort];
    [self setupProgram0];
    
    [self update];
    
    [self gestures];
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    
    _eaglLayer.opaque = true;
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
               , self.frame.size.height * scale
               );
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
    
    [_program0 use];
    glGenBuffers(1, &_buffer0);
    glGenBuffers(1, &_index0);
    
    //取出
    GLuint texture0Uniform = [_program0 uniformIndex:@"texture"];
    //加载纹理
    [self setupTexture:@"74172016103114541058969337.jpg" textures:&_texture0 textureUnit:GL_TEXTURE0];
    glUniform1i(texture0Uniform, 0);///配置纹理
}

- (void)render {
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [_program0 use];
    glBindBuffer(GL_ARRAY_BUFFER, _buffer0);
    glVertexAttribPointer([_program0 attributeIndex:@"position"], 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4, NULL);
    glEnableVertexAttribArray([_program0 attributeIndex:@"position"]);
    glVertexAttribPointer([_program0 attributeIndex:@"textureCoordinate"], 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4, (float *)NULL + 2);
    glEnableVertexAttribArray([_program0 attributeIndex:@"textureCoordinate"]);

    [self changeData];
    
    //渲染
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)changeData {
    {//--------------point : 计算偏移量
        
        CGFloat tmpTargetY = 1.0 - targetY;//取反得到纹理坐标系中的点
   
        ///手势对坐标的压缩量
        float xCompreess = 0.0;
        //计算偏移值
        int tmpIndex = 0;
        int stride = 4;//只保存顶点坐标xy 纹理坐标xy
        for (int j = 0; j < Column + 1; j++) {
            for (int i = 0; i < 2; i++) {//2个点为顶点坐标 另外两个点为纹理坐标
                //将[0.0, 1.0]区间映射到[-PI, PI]区间上
                xCompreess = j / (Column * 1.0);//0~1.0
                xCompreess = xCompreess * 2 * M_PI ;//0~2PI
                xCompreess = xCompreess - M_PI;//-PI~PI

                CGFloat tmpY = tmpTargetY;
                tmpY = tmpY * 2 * M_PI;//映射到[-PI, PI]区间上
                tmpY = tmpY - M_PI;

                //作差 得到 图形偏移
//                NSLog(@"图形偏移~%f", cos(xCompreess - tmpY) + 1);

                CGFloat degree = xCompreess - tmpY;
                if (degree > M_PI) {
                    degree = M_PI;
                } else if (degree < -M_PI) {
                    degree = -M_PI;
                }

                CGFloat tmpComPress = sqrt((cos(degree) + 1)) * targetX;

                new_arrBuffer[tmpIndex + 0] = new_arrBuffer[tmpIndex + 0] + tmpComPress;//只修改X坐标  根据j代入相应的非线性方程中 得到偏移量
                tmpIndex += stride;
            }
        }
    }
    
    ///打印数据
//    printf("\n--------------\n");
//    for(int i = 0 ; i < sizeOfArr ; i++) {if (i % 4 == 0) {printf("\n"); }
//        printf("%f ", arrBuffer[i]);
//    }
//    printf("\n--------------\n");
//    printf("\n--------------\n");
//    for(int i = 0 ; i < column * 3/*位置*/ * 2/*个数*/ ; i++) {if (i % 3 == 0) { printf("\n"); }
//        printf("%d ", _indices[i]);
//    }
//    printf("\n--------------\n");
    
    
    glBindBuffer(GL_ARRAY_BUFFER, _buffer0);
    glBufferData(GL_ARRAY_BUFFER, sizeof(float)*SizeOFVectorTextureCoordinate , new_arrBuffer, GL_DYNAMIC_DRAW);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _index0);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int)*SizeOfIndices, new_indices, GL_STATIC_DRAW);
    
    glDrawElements(GL_TRIANGLES, SizeOfIndices, GL_UNSIGNED_INT, 0);//绘制
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
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupFrameBuffer {
    GLuint buffer;
    glGenFramebuffers(1, &buffer);
    _colorFrameBuffer = buffer;
    glBindFramebuffer(GL_FRAMEBUFFER, _colorFrameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
}

#pragma mark - 手势
- (void)gestures {
 UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];    [self addGestureRecognizer:pan];
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    if (_updating) { return;}
    _updating = true;
    ///区分方向
    if (pan.state == UIGestureRecognizerStateBegan) {
        lastLocationX = [pan locationInView:pan.view].x;//拾获最初的角标
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [pan translationInView:pan.view];
//        NSLog(@"%@", NSStringFromCGPoint(translation));
        
        CGFloat result = [pan translationInView:pan.view].x - lastLocationX;//方向判别
        lastLocationX = [pan translationInView:pan.view].x;//更新位置
        if (result > 0) {
            //向右
            targetX = 0.003;
        } else if (result < 0) {
            //向左
            targetX = -0.003;
        } else {
            //不变
            targetX = 0.0;
        }
        
        /**
         translation.x < 0    向左
         translation.y < 0    向上
         **/
        CGPoint curPoint = [pan locationInView:pan.view];
        targetY =  curPoint.y / self.bounds.size.height;//iOS 设备坐标下的0~1.0

        //数据范围
        if (targetY < 0) {targetY = 0.0;}
        if (targetY > 1) {targetY = 1.0;}
        
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        
    }
    [self update];
    _updating = false;
}

@end
