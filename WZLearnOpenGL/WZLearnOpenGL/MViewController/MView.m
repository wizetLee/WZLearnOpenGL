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

typedef NS_ENUM(NSUInteger, vertorOriention) {
    /**
       3  |   0
          |
     ------------
          |
       2  |   1
     **/
    vertorOriention_none,
    vertorOriention_2to0,
    vertorOriention_0to2,
    vertorOriention_3to1,
    vertorOriention_1to3,
    vertorOriention_2to3_1to0,
    vertorOriention_3to2_0to1,
    vertorOriention_3to0_2to1,
    vertorOriention_0to3_1to2,
};

@interface MView()<UIGestureRecognizerDelegate>
{
    CGPoint startPoint;
    CGFloat tmpXOffsetValue;
    CGFloat tmpYOffsetValue;
    int xCount;
    int yCount;
    int numberOfPoint;
    float *arrBuffer;
}

@property (nonatomic, assign) vertorOriention touchPointOriention;

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

///////
@property (nonatomic, assign) CGFloat targetX;
@property (nonatomic, assign) CGFloat targetY;
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
//    [self setupProgram1];
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
    
    _targetY = [pan locationInView:self].y / pan.view.frame.size.height;
    _targetX = [pan locationInView:self].x / pan.view.frame.size.width;
//    NSLog(@"%f - %f",_xOffsetValue, _yOffsetValue );
    
    {//
        
      
        if (translation.x > 0 && translation.y > 0) {
            _touchPointOriention = vertorOriention_3to1;
        } else if (translation.x < 0 && translation.y > 0) {
            _touchPointOriention = vertorOriention_0to2;
        } else if (translation.x > 0 && translation.y < 0) {
            _touchPointOriention = vertorOriention_2to0;
        } else if (translation.x < 0 && translation.y < 0) {
            _touchPointOriention = vertorOriention_1to3;
        } else if (translation.x > 0 && translation.y == 0) {
            _touchPointOriention = vertorOriention_3to0_2to1;
        } else if (translation.x < 0 && translation.y == 0) {
            _touchPointOriention = vertorOriention_0to3_1to2;
        } else if (translation.x == 0 && translation.y > 0) {
            _touchPointOriention = vertorOriention_3to2_0to1;
        } else if (translation.x == 0 && translation.y < 0) {
            _touchPointOriention = vertorOriention_2to3_1to0;
        } else {
            _touchPointOriention = vertorOriention_none;
        }
    }
    
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
 ///x 或者y 方向的旋转可以观察透视投影效果
    //    GLKMatrix4MakePerspective 透视投影
    glUniform1f(_scale, _zoomLevel);
    glUniform1f(_yOffset, _yOffsetValue);
    glUniform1f(_xOffset, _xOffsetValue);
 
//    _zoomLevel = 0.1;
//    glUniformMatrix4fv(_rotateMatrix, 1, GL_FALSE, GLKMatrix4MakeScale(_zoomLevel, _zoomLevel, _zoomLevel).m);
//    glUniformMatrix4fv(_rotateMatrix, 1, GL_FALSE, GLKMatrix4MakeTranslation(_zoomLevel, _zoomLevel, _zoomLevel).m);
    
    glEnable(GL_BLEND);//开启混合模式
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);//设置混合模式
}

- (void)render {
    
    //通常在一帧渲染完成之后 最常见的图形操作就是清除缓存 每帧都需要清除一次缓存
    glClearColor(1.0, 1.0, 1.0  , 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    //缓存的掩码 掩码操作
//    glColorMask(GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha)
    
    
    [_program0 use];
    glBindBuffer(GL_ARRAY_BUFFER, _buffer0);
                                                                                //不进行归一化处理 即转换为归一化的浮点数(0~1)
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
//
//
//        //通知OpenGL 在哪里设置近平面和远平面
//        //glDepthRangef(GLclampf zNear, GLclampf zFar) /// [0, 1]
//
//
//    }

    [self use2];
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)changeData {
    
    const int sizeOfArr = xCount * yCount * numberOfPoint;
   
    if (arrBuffer == NULL) {///重复使用数据缓存
         GLfloat tmpArr[sizeOfArr];//size临时缓存
        arrBuffer = (float *)tmpArr;
    }
    float *arr = (float *)arrBuffer;
    
    CGFloat xfloat = (xCount * 1.0);
    CGFloat yfloat = (yCount * 1.0);
    
    NSInteger index = 0;
    CGFloat multiple  = 2.0;
    for (int y = 0; y < yCount; y++) {                   //Y
        for (int x = 0; x < xCount; x++) {             //X
            
            //X影响水平偏移
            //Y影响垂直偏移
            //水平平铺 到垂直平铺 由OPEN GL 坐标的0，0开始到1，1
            
            //左上
            CGPoint leftTop = CGPointMake((x / xfloat)     , ((y + 1) / yfloat ) );
            //右上
            CGPoint rightTop = CGPointMake(((x + 1) / xfloat)    , ((y + 1) / yfloat) );
            //左下
            CGPoint leftBottom = CGPointMake((x / xfloat)       ,  (y / yfloat) ) ;
            //右下
            CGPoint rightBottom = CGPointMake(((x + 1) / xfloat)  ,  (y / yfloat) );
            
            ///由于循环是由0 自增 因此 左上是左下  右上是右下
            /**
             3     |      0
             |
             ------------------
             2     |      1
             |
             **/
            ///纹理位置设置
            CGPoint t0 = CGPointMake(rightTop.x, 1 - rightTop.y);
            CGPoint t1 = CGPointMake(rightBottom.x, 1 - rightBottom.y);
            CGPoint t2 = CGPointMake(leftBottom.x, 1 - leftBottom.y);
            CGPoint t3 = CGPointMake(leftTop.x, 1 - leftTop.y);
            
            ///手势对坐标的压缩量
            CGFloat xCompreess = 0.0;
            CGFloat yCompreess = 0.0;
            
            /**
             vertorOriention_none,
             vertorOriention_2to0,
             vertorOriention_0to2,
             vertorOriention_3to1,
             vertorOriention_1to3,
             
             vertorOriention_2to3_1to0,
             vertorOriention_3to2_0to1,
             
             vertorOriention_3to0_2to1,
             vertorOriention_0to3_1to2,
             **/
            switch (_touchPointOriention) {
                case vertorOriention_none: {
                    
                }
                    break;
                case vertorOriention_2to0: {
                    
                }
                    break;
                case vertorOriention_0to2: {
                    
                }
                    break;
                case vertorOriention_3to1: {
                    
                }
                    break;
                case vertorOriention_1to3: {
                    
                }
                    break;
                case vertorOriention_2to3_1to0: {
                    
                }
                    break;
                case vertorOriention_3to2_0to1: {
                    
                }
                    break;
                case vertorOriention_3to0_2to1: {
                    
                }
                    break;
                case vertorOriention_0to3_1to2: {
                    
                }
                    break;
                default:
                    break;
            }
            {//偏移计算
                //设置影响半径的范围
                CGFloat a = yCount ;
                CGFloat traget = (1 - _targetY) * a;
                CGFloat scopeValue = 2;
                if (fabs((y - traget)) <= a / 2 /scopeValue) {
                    CGFloat effectScope = a / scopeValue;//缩小了影响范围
                    CGFloat compress = y - (traget);//得到整数扩散量越接近0 偏移量越大 需要更大的反差
                    // -100 ~ 100
                    compress = compress * M_PI / (effectScope);
                    //-PI ~ PI
                    //线性方程设置倾斜
                    if (cos(compress) < 0) {
                        xCompreess =  fabs(cos(compress));
                    } else {
                        xCompreess = cos(compress);
                    }
                    xCompreess *= 0.1;
                }
                
                {//X坐标
                    a = xCount;
                    traget = (_targetX) * a;
                    if (fabs((x - traget)) <= a / 4) {
                        CGFloat effectScope = a / 2;//缩小了影响范围
                        CGFloat compress = x - (traget);//得到整数扩散量越接近0 偏移量越大 需要更大的反差
                        // -100 ~ 100
                        compress = compress * M_PI / (effectScope);
                        if (cos(compress) < 0) {
                            yCompreess =  fabs(cos(compress));
                        } else {
                            yCompreess = cos(compress);
                        }
                        yCompreess *= 0.1;
                    }
                }
                
                /*
                 sinX   -PI ~ PI
                 sin(-PI) = 0;
                 sin(0) = 1;
                 sin(PI) = 0;
                 */
            }
            
            CGFloat scale = 0.5;
            ///根据手势的方向 加点偏移 减点偏移 使用一个枚举控制偏移量的方向
            //左上
            leftTop = CGPointMake(leftTop.x * multiple - 1   + xCompreess    , leftTop.y * multiple-1+ yCompreess);
            //右上1
            
            rightTop = CGPointMake(rightTop.x* multiple -1     + xCompreess    , rightTop.y* multiple-1+ yCompreess);
            //左下
            leftBottom = CGPointMake(leftBottom.x* multiple -1   + xCompreess  , leftBottom.y* multiple-1+ yCompreess) ;
            //右下
            rightBottom = CGPointMake(rightBottom.x* multiple -1  + xCompreess   ,  rightBottom.y* multiple-1+ yCompreess);
            
            
            leftTop = CGPointMake(leftTop.x *scale, leftTop.y *scale);
            rightTop = CGPointMake(rightTop.x *scale, rightTop.y *scale);
            leftBottom = CGPointMake(leftBottom.x *scale, leftBottom.y *scale);
            rightBottom = CGPointMake(rightBottom.x *scale, rightBottom.y *scale);
            
            arr[index + 0] = rightTop.x;
            arr[index + 1] = rightTop.y;
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
    
    glBindBuffer(GL_ARRAY_BUFFER, _buffer2);
    glBufferData(GL_ARRAY_BUFFER, sizeof(float) * sizeOfArr, arrBuffer, GL_DYNAMIC_DRAW);
    
//    printf("\n--------------\n");
//    for(int i = 0 ; i < sizeOfArr ; i++) {if (i % 4 == 0) {printf("\n"); }
//        printf("%f ", arrBuffer[i]);
//    }
//    printf("\n--------------\n");
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
    
    [self changeData];
    glDrawArrays(GL_TRIANGLES, 0, xCount * yCount * numberOfPoint / 4);
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

    [program use];

    ///数据配置
    xCount = 100;//将像图片划分为1000个正方向 无论垂直方向还是水平方向
    yCount = 100;//将像图片划分为1000个正方向 无论垂直方向还是水平方向
    //1000 * 1000的图片坐标系
    
    ///每个分段切割出4个点。6个坐标 使用 比较消耗内存
    //    glDrawArrays(GLenum mode, GLint first, GLsizei count)
    
    ///每个分段切割出4个点。4个坐标 使用 但是需要额外的数组指示出数据的索引
    //    glDrawElements(GLenum mode, GLsizei count, GLenum type, const GLvoid *indices)

    numberOfPoint = 24;
   
    //根据坐标点的数目调整位置
    //数据配置
    glGenBuffers(1, &_buffer2);
    [self changeData];
    
    //纹理加载
    GLuint texture1Uniform = [program uniformIndex:@"texture"];
    NSAssert([UIImage imageNamed:@"40682016071512070526937635.jpg"], @"OMG");

    [self setupTexture:@"40682016071512070526937635.jpg" textures:&_texture2 textureUnit:GL_TEXTURE2];
    glUniform1i(texture1Uniform, 2);///配置纹理 保持一致
    
    //开启所有缓存的混融模式
    glEnable(GL_BLEND);//开启混融模式
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);//设置混融模式
    //控制片元输出的颜色值与存储在帧缓存中的值之间的缓和方式
//    glBlendFuncSeparate(GLenum srcRGB, GLenum dstRGB, GLenum srcAlpha, GLenum dstAlpha)
    [self readPixels];
}

///片元的测试与操作
///剪切测试
- (void)scissorTest {
    glClearStencil(0);//设置模板的清除值
    glEnable(GL_SCISSOR_TEST);
    //将程序窗口中的一个矩形区域称为一个剪切盒，并且将所有的绘制操作都限制在这个区域当中
    glScissor(0.0, 0.0, 1.0, 1.0);
}
///模板测试
- (void)stencilTest {
    glEnable(GL_STENCIL_TEST);
    //模板值为1的时候绘制球体
    glStencilFunc(GL_EQUAL, 1, 1);
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
    
    //控制OpenGL的一些具体特性
//    glHint(GLenum target, GLenum mode)
//    GL_FASTEST等
}

- (void)readPixels {
    CGSize imageSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    size_t size = imageSize.width * imageSize.height * 4/*RGBA*/;
    GLubyte *rawImagePixels = malloc(size);
    glReadPixels(0.0, 0.0, imageSize.width, imageSize.height, GL_RGBA, GL_UNSIGNED_BYTE, rawImagePixels);
    
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rawImagePixels, size, dataProviderReleaseCallback/*一个指定类型的函数指针*/);
    CGColorSpaceRef defaultRGBColorSpace = CGColorSpaceCreateDeviceRGB();//颜色空间
    CGImageRef cgImageFromBytes = CGImageCreate((int)imageSize.width, (int)imageSize.height, 8, 32, 4 * (int)imageSize.width, defaultRGBColorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaLast, dataProvider, NULL, NO, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    CGColorSpaceRelease(defaultRGBColorSpace);
    
    UIImage *image =  [UIImage imageWithCGImage:cgImageFromBytes];
}

void dataProviderReleaseCallback (void *info, const void *data, size_t size)
{
    free((void *)data);
}
@end
